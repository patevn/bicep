@description('The name of the environment. This must be dev, test, or prod.')
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentName string = 'dev'

@description('The unique name of the solution. This is used to ensure that resource names are unique.')
@minLength(5)
@maxLength(30)
param solutionName string = 'toyhr${uniqueString(resourceGroup().id)}'

@description('The number of App Service plan instances.')
@minValue(1)
@maxValue(10)
param appServicePlanInstanceCount int = 1

@description('The name and tier of the App Service plan SKU.')
param appServicePlanSku object

@description('The Azure region into which the resources should be deployed.')
param location string = 'Australia Central'

@description('sql db username')
@secure()
param sqlServerAdministratorLogin string

@description('sql db pw')
@secure()
param sqlServerAdministratorPassword string

@description('The name and tier of the sql db SKU.')
param sqlDatabaseSku object

@description('kv url')
param vaultUri string


var appServicePlanName = '${environmentName}-${solutionName}-plan'
var appServiceAppName = '${environmentName}-${solutionName}-app'
var sqlServerName = '${environmentName}-${solutionName}-sql'
var sqlDatabaseName = 'Employees'

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku.name
    tier: appServicePlanSku.tier
    capacity: appServicePlanInstanceCount
  }
}

resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: 'PetersVault1'
  location: 'australiaeast'
  properties: {
    sku: {
        family: 'A'
        name: 'standard'
    }
    accessPolicies: [
      {
          tenantId: subscription().tenantId
          objectId: 'c591fc1c-743a-47a9-99f7-55eb3d011467' // has tro be hardcoded as bicep can't give this yet
          permissions: {
              keys: [
                  'all'
              ]
              secrets: [
                  'all'
              ]
              certificates: [
                  'all'
              ]
              storage: [
                  'all'
              ]
          }
      }
  ]
    tenantId: subscription().tenantId
    enabledForDeployment: false
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    vaultUri: vaultUri
    publicNetworkAccess: 'Enabled'
    }
}

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorPassword
  }
  dependsOn: [ keyVault ]
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: {
    name: sqlDatabaseSku.name
    tier: sqlDatabaseSku.tier
  }
  dependsOn: [ keyVault ]
}
