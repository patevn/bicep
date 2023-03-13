param location string = resourceGroup().location
param storageAccountName string = 'toylaunch${uniqueString(resourceGroup().id)}'
param appServiceAppName string = 'toylaunch${uniqueString(resourceGroup().id)}'

@allowed([
  'nonprod'
  'prod'
])
param environmentType string

var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'
var appServicePlanSkuName = (environmentType == 'prod') ? 'P2v3' : 'F1'
var appServicePlanName = 'toy-product-launch-plan'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  kind: 'StorageV2'
  location: location
  name: storageAccountName
  sku: {
    name: storageAccountSkuName
  }
  properties:{
    accessTier: 'Hot'
  }
}


resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku:{
    name: appServicePlanSkuName
  }
}

resource appServiceApp 'Microsoft.Web/sites@2022-03-01'  = {
  location: location
  name: appServiceAppName
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}
