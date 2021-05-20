# Azure-DevOps-Variable-Groups
Creating Variable groups using Shell Script.

Pre-Requisite: 

     install azure-devops extention if not installed already. 
     vm-var-group-upload.ps1 file

Step 1: Open CMD Promt from your local machine

step 2: Run below command

    set ADAL_PYTHON_SSL_NO_VERIFY=1
    set AZURE_CLI_DISABLE_CONNECTION_VERIFICATION=1
    az-login
  
Step 3: Microsoft login browser will open to authenticate you

step 4: Run Powershell from local  

step 5: Copy and paste the vm-var-group-upload.ps1 in powershell script

step 6: Fill access $personalAccessToken

step 7: Run the shell script

step 8: If Promt the Group Id in Command Enter Group Id 

step 9: Verify in DevOps Library Section, Variable group should be Created
