#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

declare subscriptionId="4ef67e2d-e018-42f1-b93d-fb0a90e3a7bc"
declare resourceGroupPrefix="director"
declare deploymentName="cloud-lab"
declare resourceGroupLocation="westus"


#login to azure using your credentials
azure account show 1> /dev/null

if [ $? != 0 ]; 
then
	azure login
fi

#set the default subscription id
azure account set $subscriptionId

#switch the mode to azure resource manager
set +e

azure config list --json | grep -q "arm"
 if [ $?  != 0 ]; 
 then
	echo "Setting mode to arm.."
	azure config mode 'arm'
else
	echo "Mode is already set to arm"
 fi

parametersFilePath="parameters.json"
templateFilePath="template.json"

#Check for existing RG


#Start deployment
echo "Starting deployment..."
for NUMBER in 14
do
    resourceGroupName=${resourceGroupPrefix:?}${NUMBER:?}
    azure group create --name ${resourceGroupName:?} --location $resourceGroupLocation 1> /dev/null
    azure group deployment create --name $deploymentName --resource-group ${resourceGroupName:?} --template-file $templateFilePath --verbose --parameters "{ \"number\": {\"value\": \"${NUMBER:?}\" }}"
done

