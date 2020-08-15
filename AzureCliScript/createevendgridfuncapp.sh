#!/bin/bash

resourceGroupName=eventgrid$RANDOM-rg
blobStorage=blobstorage$RANDOM
funcappStorage=funcappstorage$RANDOM
funcappName=funcapp$RANDOM
singleFunction=EventGridTriggerCSharpFunc
location=westeurope
skuType=Standard_LRS
username="<YOUR USERNAME>"
password="<YOUR PASSWORD>"
gitLocalDirectory="<PATH TO LOCAL FOLDER WITH AZURE FUNCTION>"

# Create a resource group
az group create --name $resourceGroupName --location $location 

# Create a blob storage account
az storage account create --name $blobStorage \
	--resource-group $resourceGroupName \
	--location $location \
	--sku $skuType \
	--kind blobstorage \
	--access-tier hot

# Create a storage container in blob storage account	
az storage container create --name filecontainer \
	--account-name $blobStorage

# Create a storage account for azure function
az storage account create --name $funcappStorage \
    --resource-group $resourceGroupName \
    --location $location \
    --sku $skuType \
    --kind storage

# Create a function app
az functionapp create --name $funcappName \
    --resource-group $resourceGroupName \
    --consumption-plan-location $location \
    --storage-account $funcappStorage \
    --functions-version 3 \
	--deployment-local-git

# Set the account-level deployment credentials
az functionapp deployment user set --user-name $username  \
    --password $password

# Get deployment URL for function app
url=$(az functionapp deployment source config-local-git --name $funcappName --resource-group $resourceGroupName --query url --output tsv)

# Add Azure remote branch to your local Git respository and push your code
cd $gitLocalDirectory
git remote add azure $url
git push azure master

# Get resource id of the blob storage account
storageid=$(az storage account show --name $blobStorage --resource-group $resourceGroupName --query id --output tsv)

# Get function app id
functionappid=$(az functionapp show --name $funcappName --resource-group $resourceGroupName --query id --output tsv)

# Create a new event subscription for an Event Grid topic using Azure Function as destination
az eventgrid event-subscription create --name demosubscriptiontoblobstorage \
	 --endpoint $functionappid/functions/$singleFunction \
     --source-resource-id $storageid \
     --endpoint-type azurefunction