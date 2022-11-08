param keyvaultName string
param webappName string
param webSiteSlotName string
param functionAppName string
param functionAppSlotName string
param tenant string

@secure()
param appServiceprincipalId string
@secure()
param appServiceSlotServiceprincipalId string
@secure()
param funcAppServiceprincipalId string
@secure()
param funcAppSlotServiceprincipalId string

////////////////////////////////////////////////////////////////
// TEMP ONLY!!!  Addes Get, List access policies to Key Value.
// TEMP ONLY!!!  Can remove once system up an running!
@secure()
param ADOServiceprincipalObjectId string
@secure()
param AzObjectIdAbele string
@secure()
param AzObjectIdPagels string
// TEMP ONLY!!!  Addes Get, List access policies to Key Value.
// TEMP ONLY!!!  Can remove once system up an running!
////////////////////////////////////////////////////////////////

// Application Insights
param appInsightsInstrumentationKey string
param appInsightsConnectionString string

////////////////////////////////////////////////////////////////
// Azure Function App
////////////////////////////////////////////////////////////////
param KV_AzureWebJobsStorageName string
@secure()
param KV_AzureWebJobsStorageNameValue string
param KV_WebsiteContentAzureFileConnectionStringName string
@secure()
param KV_WebsiteContentAzureFileConnectionStringNameValue string
param KV_WebsiteContentShareName string
@secure()
param KV_WebsiteContentShareNameValue string

////////////////////////////////////////////////////////////////
// Azure SQL Credentials
////////////////////////////////////////////////////////////////
param KV_SQLDB_AdministratorLoginName string
param KV_SQLDB_AdministratorLoginNameValue string
@secure()
param KV_SQLDB_AdministratorPasswdName string
@secure()
param KV_SQLDB_AdministratorPasswdValue string
param sqlDBName string
param sqlserverName string
param sqlserverfullyQualifiedDomainName string
param KV_SQLDB_ConnectionStringName string
var KV_SQLDB_ConnectionStringNameValue = 'Server=tcp:${sqlserverfullyQualifiedDomainName},1433;Initial Catalog=${sqlDBName};Persist Security Info=False;User Id=${KV_SQLDB_AdministratorLoginNameValue}@${sqlserverName};Password=${KV_SQLDB_AdministratorPasswdValue};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'

// Azure Service Bus Credentials - This uses Original Service Bus Connection, NOT a new one
// TODO! Add comment on why!
param KV_ServiceBus_ConnectionStringName string
param KV_ServiceBus_ConnectionStringNameValue string

// Azure CosmosDB Credentials.
param KV_CosmosDB_PrimaryKeyName string
@secure()
param KV_CosmosDB_PrimaryKeyNameValue string
param KV_CosmosDB_ConnectionStringName string
@secure()
param KV_CosmosDB_ConnectionStringNameValue string
//param KV_CaseMessagesTrigger_ConnectionStringName string
//@secure()
//param KV_CaseMessagesTrigger_ConnectionStringNameValue string

param KV_CritWatcherSignalRConnectorURLName string
@secure()
param KV_CritWatcherSignalRConnectorURLNameValue string

param CosmosDB_URI string

param KV_SignalR_ConnectionStringName string
param KV_SignalR_ConnectionStringNameValue string
param SignalR_HubNameName string

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
    objectId: funcAppServiceprincipalId
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
    objectId: appServiceSlotServiceprincipalId
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
    objectId: funcAppSlotServiceprincipalId
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
    objectId: AzObjectIdAbele
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

// This is added directly in FuncApp Config, NOT Key Vault
// Create KeyVault Secrets for Func App
//resource secret1 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
//  name: KV_AzureWebJobsStorageName
//  parent: existing_keyvault
//  properties: {
//    contentType: 'text/plain'
//    value: KV_AzureWebJobsStorageNameValue
//  }
//}

// This is added directly in FuncApp Config, NOT Key Vault
//resource secret2 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
//  name: KV_WebsiteContentAzureFileConnectionStringName
//  parent: existing_keyvault
//  properties: {
//    contentType: 'text/plain'
//    value: KV_WebsiteContentAzureFileConnectionStringNameValue
//  }
//}
// This is added directly in FuncApp Config, NOT Key Vault
//resource secret3 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
//  name: KV_WebsiteContentShareName
//  parent: existing_keyvault
//  properties: {
//    contentType: 'text/plain'
//    value: KV_WebsiteContentShareNameValue
//  }
//}

// Create KeyVault Secrets for SQL DB
resource secret4 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: KV_SQLDB_AdministratorLoginName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: KV_SQLDB_AdministratorLoginNameValue
  }
}
resource secret5 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: KV_SQLDB_AdministratorPasswdName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: KV_SQLDB_AdministratorPasswdValue
  }
}

resource secret6 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: KV_SQLDB_ConnectionStringName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: KV_SQLDB_ConnectionStringNameValue
  }
}

// TODO! add why this connecting uses the original Servive Bus, NOT the new one!!
resource secret7 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: KV_ServiceBus_ConnectionStringName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: KV_ServiceBus_ConnectionStringNameValue
  }
}

// CosmosDB Keys
resource secret8 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: KV_CosmosDB_PrimaryKeyName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: KV_CosmosDB_PrimaryKeyNameValue
  }
}
resource secret9 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: KV_CosmosDB_ConnectionStringName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: KV_CosmosDB_ConnectionStringNameValue
  }
}

/*
resource secret10 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: KV_CaseMessagesTrigger_ConnectionStringName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: KV_CaseMessagesTrigger_ConnectionStringNameValue
  }
}
*/

resource secret11 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: KV_CritWatcherSignalRConnectorURLName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: KV_CritWatcherSignalRConnectorURLNameValue
  }
}

resource secret12 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: KV_SignalR_ConnectionStringName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: KV_SignalR_ConnectionStringNameValue
  }
}

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
    //'ConnectionString:ReactiveIntelligenceWebContext': '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${KV_SQLDB_ConnectionStringName})'
    SQLDB_ConnectionString: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${KV_SQLDB_ConnectionStringName})'

    // This points to "Live" data from original V1.0
    // NOT needed once the cut-over is done!
    SQLDB_ConnectionString_Live: '@Microsoft.KeyVault(VaultName=RIMDashboardKeyVault;SecretName=AzureSQLDbConnection)'
    KeyVaultUrl: existing_keyvault.properties.vaultUri
  }
  dependsOn: [
    secret6
  ]
}

// NOT needed for .Net! Create Web connectionstrings - Web App
// resource webSiteConnectionStrings 'Microsoft.Web/sites/config@2022-03-01' = {
//   name: 'connectionstrings'
//   parent: existing_appService
//   properties: {
//     ReactiveIntelligenceWebContext: {
//       value: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${KV_SQLDB_ConnectionStringName})'
//       type: 'SQLAzure'
//     }
//   }
//   dependsOn: [
//     secret6
//   ]
// }

/////////////////////////////////////////////////
// Add Settings for Function App
/////////////////////////////////////////////////

// Reference Existing resource
resource existing_funcAppService 'Microsoft.Web/sites@2022-03-01' existing = {
  name: functionAppName
}
// Create Web appsettings - Function App
resource funcAppSettingsStrings 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'appsettings'
  kind: 'string'
  parent: existing_funcAppService
  properties: {
    AzureWebJobsStorage: KV_AzureWebJobsStorageNameValue
    //AzureWebJobsStorage: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${KV_AzureWebJobsStorageName})'
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: KV_WebsiteContentAzureFileConnectionStringNameValue
    //WebsiteContentAzureFileConnectionString: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${KV_WebsiteContentAzureFileConnectionStringName})'
    //WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${KV_WebsiteContentAzureFileConnectionStringName})'
    WEBSITE_CONTENTSHARE: KV_WebsiteContentShareNameValue
    //WEBSITE_CONTENTSHARE: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${KV_WebsiteContentShareName})'
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsightsInstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectionString
    FUNCTIONS_WORKER_RUNTIME: 'dotnet'
    FUNCTIONS_EXTENSION_VERSION: '~4'
    SQLDB_ConnectionString: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${KV_SQLDB_ConnectionStringName})'
    //CaseMessagesTrigger_ConnectionString:'@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${KV_CaseMessagesTrigger_ConnectionStringName})'
    CosmosDB_ConnectionString: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${KV_CosmosDB_ConnectionStringName})'
    CosmosDB_Collection: 'CaseMessages'
    CosmosDB_Database: 'CaseData'
    CosmosDB_URI: CosmosDB_URI
    CosmosDB_Key: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${KV_CosmosDB_PrimaryKeyName})'
    SignalR_ConnectionString: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${KV_SignalR_ConnectionStringName})'
    SignalR_HubName: SignalR_HubNameName
    ServiceBus_ConnectionString: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${KV_ServiceBus_ConnectionStringName})'
  }
  dependsOn: [
    secret6
    secret7
    secret8
    secret9
    secret11
    secret12
  ]
}

// NOT Needed for .Net! Create Web connectionstrings - Function App
// resource funcAppConnectionStrings 'Microsoft.Web/sites/config@2022-03-01' = {
//   name: 'connectionstrings'
//   parent: existing_funcAppService
//   properties: {
//     ReactiveIntelligenceWebContext: {
//       value: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${KV_SQLDB_ConnectionStringName})'
//       type: 'SQLAzure'
//     }
//   }
// }

