# Welcome to your new app

## I'm in the fast lane!

** WARNING **

This repo doesn't assume anything specific about which account you will login to. You'll need to update the vars in `group_vars` or set `extra-vars` at runtime.

Here's a quick guide for which varaibles you'll need to set:

```
# for all playbooks
env=dev
aws_profile_np=aws-np
aws_profile_ams_np=ams-np
aws_profile_ams_p=ams-p

# for S3 create
VpcId=vpc-xxx

# for RDP access
username=lastnamef
VpcId=vpc-xxx

# for stack create
SecretLocation=ams-shared/foo
VpcId=vpc-xxx
PrivSubnet=subnet-xxx
PrivSubnets=subnet-xxx,subnet-xxx
AppWebInstanceProfile=customer_xxx_instance_profile
ImageId=ami-xxx
ManagementSG=sg-xxx
```

Examples:

```
# bucket creation per deployment
ansible-playbook create-s3.yml --extra-vars "env=dev aws_profile_np=aws-np aws_profile_ams_np=ams-np aws_profile_ams_p=ams-p VpcId=vpc-xxx"

# note: you'll need to create secret for RDS per deployment, or if you use an existing secret you can skip this step
ansible-playbook stack-create.yml --extra-vars "env=test aws_profile_np=aws-np aws_profile_ams_np=ams-np aws_profile_ams_p=ams-p SecretLocation=ams-shared/foo VpcId=vpc-xxx PrivSubnet=subnet-xxx PrivSubnets=subnet-xxx,subnet-xxx AppWebInstanceProfile=customer_xxx_instance_profile ImageId=ami-xxx ManagementSG=sg-xxx" --tags cf,secret

# create stack
ansible-playbook stack-create.yml --extra-vars "env=test aws_profile_np=aws-np aws_profile_ams_np=ams-np aws_profile_ams_p=ams-p SecretLocation=ams-shared/foo VpcId=vpc-xxx PrivSubnet=subnet-xxx PrivSubnets=subnet-xxx,subnet-xxx AppWebInstanceProfile=customer_xxx_instance_profile ImageId=ami-xxx ManagementSG=sg-xxx" --skip-tags cf,secret

# request stack access
ansible-playbook stack-access.yml --extra-vars "env=test aws_profile_np=aws-np aws_profile_ams_np=ams-np aws_profile_ams_p=ams-p username=lastnamef"
```

**Start your container:**

- Create your own container for local development: `docker build . -t ams-aws-ansible`
- Run your container: `docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/opt/app ams-aws-ansible bash`

**Stack Playbooks:**

- Stack Create:        `ansible-playbook stack-create.yml --extra-vars env=dev`
- Stack Update:        `ansible-playbook stack-update.yml --extra-vars env=dev`
- Stack Delete:        `ansible-playbook stack-delete.yml --extra-vars env=dev`
- Stack Access:        `ansible-playbook stack-access.yml --extra-vars "env=dev username=lastf"`

**Other Playbooks:**

- Create S3 Bucket:    `ansible-playbook create-s3.yml --extra-vars env=dev`
- Create AMI from EC2: `ansible-playbook ami-create-ec2.yml --extra-vars 'instance_id=i-xxx ami_name=contino-test env=dev'`
- Restore from AMI:    `ansible-playbook stack-update.yml --extra-vars 'env=dev ImageId=ami-xxx'`

**Creating Secrets (one-time):**

```
ansible-playbook stack-create.yml --extra-vars env=test --tags secret --skip-tags cf
ansible-playbook stack-create.yml --extra-vars env=dev --tags secret --skip-tags cf
```

## Requirements

- An AWS Acconut to store files (in S3) & do test Deploys (CF Stacks)
- An AMS Account to do deploys (CF Stacks via RFCs)
- Docker (to run the scripts in this repo)



# Tips

Make sure your `~/.aws` configuration includes the appropriate profile name & region (for AMS and for AWS).

Windows users should replace `~/.aws` with the full path to their aws config folder, e.g `C:\Users\userx\.aws`.

Windows users should also replace `$(pwd)` with the current directory for this repo e.g `C:\Users\userx\repos\this-repo`

If you have problems mounting volumes in docker make sure you've shared your volumes in Docker Preference (ie `C:` or `/Users`).

You can perform a federated login to AMS with `docker run --rm -it -v ~/.aws:/root/.aws dtjohnson/aws-azure-login` to configure your local aws config file on your host machine. Your AWS config may end up looking a little like this when you're done:

```
[default]
region=ap-southeast-2
output=json
azure_tenant_id=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx
azure_app_id_uri=https://xxx-ams-nonprod.signin.aws.amazon.com/console
azure_default_username=first.last@xxx.com.au
azure_default_role_arn=xx
azure_default_duration_hours=1

[profile xxxusers]
region=ap-southeast-2
aws_access_key_id=xx
aws_secret_access_key=xx
mfa_serial=arn:aws:iam::83xxx64:mfa/first.last

[profile xxx-anp]
role_arn=arn:aws:iam::18xx79:role/UsersXXX
source_profile=xxxusers
region=ap-southeast-2
mfa_serial=arn:aws:iam::83xxx64:mfa/first.last
```


# Example Ansible Commands

```
# skip the cf run
ansible-playbook stack-create.yml --extra-vars env=nonprod --skip-tags cf

# skip validate
ansible-playbook stack-create.yml --extra-vars env=nonprod --skip-tags validate

# skip ams tasks
ansible-playbook stack-create.yml --extra-vars env=nonprod --skip-tags ams

# skip validate and ams (cf create only)
ansible-playbook stack-create.yml --extra-vars env=nonprod --skip-tags 'ams, validate'
```
