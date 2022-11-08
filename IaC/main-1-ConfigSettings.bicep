param keyvaultName string
param webappName string
param tenant string

@secure()
param appServiceprincipalId string

////////////////////////////////////////////////////////////////
// TEMP ONLY!!!  Addes Get, List access policies to Key Value.
// TEMP ONLY!!!  Can remove once system up an running!
@secure()
param ADOServiceprincipalObjectId string
@secure()
param AzObjectIdPagels string
// TEMP ONLY!!!  Addes Get, List access policies to Key Value.
// TEMP ONLY!!!  Can remove once system up an running!
////////////////////////////////////////////////////////////////

// Application Insights
param appInsightsInstrumentationKey string
param appInsightsConnectionString string

//////////////////////////////////////////////////////
// Create KeyVault accessPolicies
//////////////////////////////////////////////////////

// Define KeyVault accessPolicies
param accessPolicies array = [
  {
    tenantId: tenant
    objectId: appServiceprincipalId
    permissions: {
      keys: [
        'get'
        'list'
      ]
      secrets: [
        'get'
        'list'
      ]
    }
  }
  {
    tenantId: tenant
    objectId: ADOServiceprincipalObjectId
    permissions: {
      keys: [
        'get'
        'list'
      ]
      secrets: [
        'get'
        'list'
        'set'
      ]
    }
  }
 {
    tenantId: tenant
    objectId: AzObjectIdPagels
    permissions: {
      keys: [
        'get'
        'list'
      ]
      secrets: [
        'get'
        'list'
        'set'
        'delete'
      ]
    }
  }
]

//////////////////////////////////////////////////////
// Create KeyVault Secrets
//////////////////////////////////////////////////////

// Reference Existing resource
resource existing_keyvault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyvaultName
}

// Create KeyVault accessPolicies
resource keyvaultaccessmod 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: 'replace'
  parent: existing_keyvault
  properties: {
    accessPolicies: accessPolicies
  }
}

// resource secret11 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
//   name: KV_CritWatcherSignalRConnectorURLName
//   parent: existing_keyvault
//   properties: {
//     contentType: 'text/plain'
//     value: KV_CritWatcherSignalRConnectorURLNameValue
//   }
// }

// resource secret12 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
//   name: KV_SignalR_ConnectionStringName
//   parent: existing_keyvault
//   properties: {
//     contentType: 'text/plain'
//     value: KV_SignalR_ConnectionStringNameValue
//   }
// }

/////////////////////////////////////////////////
// Add Settings for Web App
/////////////////////////////////////////////////

// Reference Existing resource
resource existing_appService 'Microsoft.Web/sites@2022-03-01' existing = {
  name: webappName
}

// Create Web appsettings - Web App
resource webSiteAppSettingsStrings 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'appsettings'
  parent: existing_appService
  kind: 'string'
  properties: {
    WEBSITE_RUN_FROM_PACKAGE: '1'
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsightsInstrumentationKey
    APPINSIGHTS_PROFILERFEATURE_VERSION: '1.0.0'
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION: '1.0.0'
    APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectionString
    WebAppUrl: 'https://${existing_appService.name}.azurewebsites.net/'
    ASPNETCORE_ENVIRONMENT: 'Development'
    KeyVaultUrl: existing_keyvault.properties.vaultUri
  }
  // dependsOn: [
  //   secret6
  // ]
}


