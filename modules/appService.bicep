param location string
param appServiceAppName string 

@allowed([
  'nonprod'
  'prod'
])
param environmentType string

var appServicePlanSkuName = (environmentType == 'prod') ? 'P2v3' : 'F1'
var appServicePlanName = 'toy-product-launch-plan'

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

