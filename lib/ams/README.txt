This method only works on Linux (Unix) or Mac OS X systems.

STEPS
1. Make sure you have installed the latest version of the AWS CLI from:
   - https://aws.amazon.com/cli/
   - http://docs.aws.amazon.com/cli/latest/userguide/installing.html
2. Install the Managed Services CLI by executing the file named:
       AWSManagedServices_InstallCLI.sh
   You can achieve this by executing from your shell/command line one
     of the following two commands:
       sh AWSManagedServices_InstallCLI.sh
       ./AWSManagedServices_InstallCLI.sh
   Note that the following two directories and their contents must be in
   the same location/directory as the AWSManagedServices_InstallCLI.sh file:
       amscm
       amsskms
3. After the installation succeeds, you can find more information about
   the Managed Services APIs using:
       aws amscm help
       aws amsskms help