#!/bin/bash
NUMBER=${1:?"No resource group number provided"}

. envars
. secrets

set -euo pipefail
IFS=$'\n\t'

declare resourceGroupPrefix="director"
declare deploymentName="cloud-lab-${NUMBER:?}"
declare resourceGroupLocation="westus"

resourceGroupName=${resourceGroupPrefix:?}${NUMBER:?}

#login to azure using your credentials
azure account show 1> /dev/null

if [ $? != 0 ]; 
then
    azure login
fi

#set the default subscription id
azure account set ${SUBSCRIPTION_ID:?}

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

templateFilePath="azure_resource_template.json"

#Check for existing RG


PARAM_FILE=/tmp/params.json.$$
trap "rm -f ${PARAM_FILE:?}" EXIT

#Start deployment
echo "Starting deployment..."
cat >/tmp/params.json <<EOF
{
"number": { "value": "${NUMBER:?}"},
"subscriptionId": {"value": "${SUBSCRIPTION_ID:?}"},
"tenantId": {"value": "${TENANT_ID:?}"},
"clientId": {"value": "${CLIENT_ID:?}"},
"clientSecret": {"value": "${CLIENT_SECRET:?}"}
}
EOF

azure group create --name ${resourceGroupName:?} --location $resourceGroupLocation 1> /dev/null
azure group deployment create --name $deploymentName --resource-group ${resourceGroupName:?} --template-file $templateFilePath --verbose --parameters-file ${PARAM_FILE:?}

