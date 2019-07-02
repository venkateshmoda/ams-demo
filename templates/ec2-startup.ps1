# Install choco, python and awscli
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install python --pre -y
$Env:Path += ';C:\Python38\Scripts'
C:\Python38\Scripts\pip3 install awscli

# EC2 Instance DNS records
$zoneName = "ams{{ env_postfix }}.domain.com"
$instanceID = Invoke-WebRequest -UseBasicParsing -Uri http://169.254.169.254/latest/meta-data/instance-id
$instanceID = "$($instanceID.Content)"
$recordName = aws ec2 describe-instances --instance-id $instanceID --query 'Reservations[*].Instances[*].[Tags[?Key==`ServerName`].Value]' --output text --region ap-southeast-2
$envName = aws ec2 describe-instances --instance-id $instanceID --query 'Reservations[*].Instances[*].[Tags[?Key==`Environment`].Value]' --output text --region ap-southeast-2
$privateIP = Invoke-WebRequest -UseBasicParsing -Uri http://169.254.169.254/latest/meta-data/local-ipv4
$privateIP = "$($privateIP.Content)"
$R53ZoneID = (Get-R53HostedZones | Where-Object Name -eq "ams{{ env_postfix }}.domain.com." | Select-Object -ExpandProperty ID).TrimStart("/hostedzone/")

# EC2 Set ResourceRecordSet
$resourceName = "XXX-" + $recordName + "-" + $envName + "." + $zoneName + "."
$resourceRecordSet = New-Object Amazon.Route53.Model.ResourceRecordSet
$resourceRecordSet.Name = $resourceName
$resourceRecordSet.Type = "A"
$resourceRecordSet.ResourceRecords = New-Object Amazon.Route53.Model.ResourceRecord ("$privateIP")
$resourceRecordSet.TTL = 300

# EC2 Set Action
if (((Get-R53ResourceRecordSet -HostedZoneId $R53ZoneID).ResourceRecordSets | where Name -eq $resourceName | measure).Count -eq 0)
{ $action = [Amazon.Route53.ChangeAction]::CREATE }
else
{ $action = [Amazon.Route53.ChangeAction]::UPSERT }

# EC2 Set Change
$change = New-Object Amazon.Route53.Model.Change ($action, $resourceRecordSet)

# EC2 Execute
Edit-R53ResourceRecordSet -HostedZoneId $R53ZoneID -ChangeBatch_Change $change
#################################
Write-Output "Route53 EC2 A record update completed"

# DB Instance DNS records
$dbrecordName = "db"
$dbDNSAddress = aws ec2 describe-instances --instance-id $instanceID --query 'Reservations[*].Instances[*].[Tags[?Key==`Database`].Value]' --output text --region ap-southeast-2

# DB Set ResourceRecordSet
$resourceName = "XXX-" + $dbrecordName + "-" + $envName + "." + $zoneName + "."
$resourceRecordSet = New-Object Amazon.Route53.Model.ResourceRecordSet
$resourceRecordSet.Name = $resourceName
$resourceRecordSet.Type = "CNAME"
$resourceRecordSet.ResourceRecords = New-Object Amazon.Route53.Model.ResourceRecord ("$dbDNSAddress")
$resourceRecordSet.TTL = 300

# DB Set Action
if (((Get-R53ResourceRecordSet -HostedZoneId $R53ZoneID).ResourceRecordSets | where Name -eq $resourceName | measure).Count -eq 0)
{ $action = [Amazon.Route53.ChangeAction]::CREATE }
else
{ $action = [Amazon.Route53.ChangeAction]::UPSERT }

# DB Set Change
$change = New-Object Amazon.Route53.Model.Change ($action, $resourceRecordSet)

# DB Execute
Edit-R53ResourceRecordSet -HostedZoneId $R53ZoneID -ChangeBatch_Change $change
#################################
Write-Output "Route53 DB CNAME record update completed"
