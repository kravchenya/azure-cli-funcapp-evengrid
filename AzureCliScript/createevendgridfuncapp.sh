#!/bin/bash

resourceGroupName=eventgrid$RANDOM-rg
funcappStorage=funcappstorage$RANDOM
functionappName=funcapp$RANDOM
singleFunction=EventGridTriggeredFunc
myblobstorageaccount=blobstorage$RANDOM
location=westeurope
skuType=Standard_LRS

username=dkravche
password=GTiEHCS73U43vc3QX8RonQeykPOc8DTSQZiefnVbXvxBI10tN/GmpA==
gitdirectory=C:\\Users\\dmitr\\Documents\\CSharpCode\\AzEventGrid\\FunctionApp

#gitrepo="<your GitHub repo link>"

# Provide an endpoint for handling the events.
#myEndpoint="<endpoint URL>"


# Create resource group
az group create --name $resourceGroupName \
    --location $location 

# Create blob storage account
az storage account create --name $myblobstorageaccount \
    --resource-group $resourceGroupName \
    --location $location \
    --sku $skuType \
    --kind blobstorage \
    --access-tier hot

# Create a storage for azure function
az storage account create --name $funcappStorage \
    --resource-group $resourceGroupName \
    --location $location \
    --sku $skuType \
    --kind storage

# Create function app
az functionapp create --name $functionappName \
    --resource-group $resourceGroupName \
    --consumption-plan-location $location \
    --storage-account $funcappStorage \
    --functions-version 3

# Get storage account string into a variable
storageConnetionString=$(az storage account show-connection-string --name $funcappStorage --resource-group $resourceGroupName --query connectionString --output tsv)

# Assings connection string 
az functionapp config appsettings set --name $functionappName \
    --resource-group $resourceGroupName \
    --settings myblobstorageaccount_STORAGE=$storageConnetionString


# Deploy code from GitHub
#az functionapp deployment source config --name $functionappName --resource-group $resourceGroupName --repo-url $gitrepo --branch master --manual-integration

# Set the account-level deployment credentials
az functionapp deployment user set --user-name $username  \
    --password $password

# Configure local Git and get deployment URL
url=$(az functionapp deployment source config-local-git --name $functionappName --resource-group $resourceGroupName --query url --output tsv)

# Add the Azure remote to your local Git respository and push your code
cd $gitdirectory
git remote add azure $url
git push azure master

# Get the resource ID of the Blob storage account
storageid=$(az storage account show --name $myblobstorageaccount --resource-group $resourceGroupName --query id --output tsv)


# Gets subsription ID
subscriptionId=$(az account list --query id --output tsv)

# Create a new event subscription for an Event Grid topic, using Azure Function as destination.
az eventgrid event-subscription create --name demoSubToStorage2 \
    --source-resource-id $storageid \
    --endpoint /subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Web/sites/$functionappName/functions/$singleFunction \
    --endpoint-type azurefunction






az eventgrid event-subscription create --name demoSubToStorage2 \
    --source-resource-id $storageid \
    --endpoint /subscriptions/{SubID}/resourceGroups/{RG}/providers/Microsoft.Web/sites/{functionappname}/functions/{functionname} \
    --endpoint-type azurefunction


