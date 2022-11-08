// Deploy Azure infrastructure for FuncApp + monitoring

// Region for all resources
param location string = resourceGroup().location
param createdBy string = 'Randy Pagels'
param costCenter string = '12345678'
param nickName string = 'rpagels'

// Variables for Recommended abbreviations for Azure resource types
// https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
var appInsightsName = 'appi-${uniqueString(resourceGroup().id)}'
var appInsightsWorkspaceName = 'appiws-${uniqueString(resourceGroup().id)}'
var appInsightsAlertName = 'responsetime-${uniqueString(resourceGroup().id)}'
var webAppPlanName = 'appplan-${uniqueString(resourceGroup().id)}'
var webSiteName = 'app-${uniqueString(resourceGroup().id)}'
var keyvaultName = 'kv-${uniqueString(resourceGroup().id)}'
var containerregistryName = 'containerregistry-${uniqueString(resourceGroup().id)}'
var containerAppName = 'containerapp-${uniqueString(resourceGroup().id)}'
var containerAppEnvName = 'containerapp-env-${uniqueString(resourceGroup().id)}'
var containerAppLogAnalyticsName = 'containerapp-log-${uniqueString(resourceGroup().id)}'

// KeyVault Secret Names
// Note: Secret names can only contain alphanumeric characters and dashes!!!
param KV_AzureWebJobsStorageName string = 'AzureWebJobsStorage'
param KV_WebsiteContentAzureFileConnectionStringName string = 'WEBSITECONTENTAZUREFILECONNECTIONSTRING'
param KV_Website_ContentShareName string = 'WEBSITECONTENTSHARE'

// Tags
var defaultTags = {
  App: 'Web App for Containers'
  CostCenter: costCenter
  CreatedBy: createdBy
  NickName: nickName
}

// TBD:Future Feature
// 
// Logic App Connections
// 
// Update Subscription GUIDs
// param connections_office365_externalid string = '/subscriptions/97284064-a541-4591-aa38-d52ed9453088/resourceGroups/rsgRIMDashboard/providers/Microsoft.Web/connections/office365'
// param connections_sql_externalid string = '/subscriptions/97284064-a541-4591-aa38-d52ed9453088/resourceGroups/rsgRIMDashboard/providers/Microsoft.Web/connections/sql'
// param connections_teams_externalid string = '/subscriptions/97284064-a541-4591-aa38-d52ed9453088/resourceGroups/rsgRIMDashboard/providers/Microsoft.Web/connections/teams'


// Create Application Insights
module appinsightsmod 'main-1-appinsights.bicep' = {
  name: 'appinsightsdeploy'
  params: {
    location: location
    appInsightsName: appInsightsName
    defaultTags: defaultTags
    appInsightsAlertName: appInsightsAlertName
    appInsightsWorkspaceName: appInsightsWorkspaceName
  }
}

// Create Function App
module functionappmod 'main-1-funcapp.bicep' = {
  name: 'functionappdeploy'
  params: {
    location: location
    functionAppServicePlanName: functionAppServicePlanName
    functionAppName: functionAppName
    funcAppstorageAccountName: funcAppstorageAccountName
    defaultTags: defaultTags
  }
  dependsOn:  [
    appinsightsmod
  ]
  
}

// Create Web App
module webappmod './main-1-webapp.bicep' = {
  name: 'webappdeploy'
  params: {
    webAppPlanName: webAppPlanName
    webSiteName: webSiteName
    location: location
    defaultTags: defaultTags
    appInsightsName: appInsightsName
  }
  dependsOn:  [
    appinsightsmod
  ]
}

// Create Azure KeyVault
module keyvaultmod './main-1-keyvault.bicep' = {
  name: keyvaultName
  params: {
    location: location
    vaultName: keyvaultName
    }
 }

 // Create SQL database
module sqldbmod './main-1-sqldatabase.bicep' = {
  name: sqlserverName
  params: {
    location: location
    sqlserverName: sqlserverName
    sqlDBName: sqlDBName
    sqlAdminLoginName: sqlAdminLoginName
    sqlAdminLoginPassword: sqlAdminLoginPassword
    defaultTags: defaultTags
  }
}

module cosmosdbmod 'main-1-cosmosdb.bicep' = {
  name: cosmosDBName
  params: {
    cosmosDBName: cosmosDBName
    defaultTags: defaultTags
    location: location
    primaryRegion: 'centralus'
    secondaryRegion: 'westus'
    thirdRegion: 'eastus'
  }
}

module signalrmod 'main-1-signalr.bicep' = {
  name: signalRName
  params: {
    defaultTags: defaultTags
    signalRName: signalRName
    location: location
  }
}

module servicebusmod 'main-1-servicebus.bicep' = {
  name: servicebusName
  params: {
    // defaultTags: defaultTags
    // servicebusName: servicebusName
    // location: location
  }
}

// This is NOT supported. Look up Object ID for Service Principal
//var randyPagelsRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'rpagels@microsoft.com') // b6be0700-1fda-4f88-bf20-1aa508a91f73

// Application Id of Service Principal "ReactiveIntelligence_ServicePrincipal_Full"
param ADOServiceprincipalObjectId string = '5ade87e8-4d4f-422d-949a-924a1bd230f4'

// TEMP ONLY!!!  Addes Get, List access policies to Key Valut.
// TEMP ONLY!!!  Can remove once system is running in Production!
param AzObjectIdAbele string = '037d077e-6ced-4e89-90e7-0dd01d1c5cf0'
param AzObjectIdPagels string = 'b6be0700-1fda-4f88-bf20-1aa508a91f73'

 // Create Configuration Entries
module configsettingsmod './main-1-configsettings.bicep' = {
  name: 'configSettings'
  params: {
    keyvaultName: keyvaultName
    tenant: subscription().tenantId
    webappName: webSiteName
    webSiteSlotName: webappmod.outputs.out_webSiteSlotName
    appServiceprincipalId: webappmod.outputs.out_appServiceprincipalId
    appServiceSlotServiceprincipalId: webappmod.outputs.out_appServiceSlotServiceprincipalId
    functionAppName: functionAppName
    functionAppSlotName: functionappmod.outputs.out_functionAppSlotName
    funcAppServiceprincipalId: functionappmod.outputs.out_funcAppServiceprincipalId
    funcAppSlotServiceprincipalId: functionappmod.outputs.out_funcAppSlotServiceprincipalId
    sqlserverName: sqlserverName
    sqlDBName: sqlDBName
    sqlserverfullyQualifiedDomainName: sqldbmod.outputs.sqlserverfullyQualifiedDomainName
    KV_SQLDB_AdministratorLoginName: KV_SQLDB_AdministratorLoginName
    KV_SQLDB_AdministratorLoginNameValue: sqlAdminLoginName
    KV_SQLDB_AdministratorPasswdName: KV_SQLDB_AdministratorPasswdName
    KV_SQLDB_AdministratorPasswdValue: sqlAdminLoginPassword
    KV_SQLDB_ConnectionStringName: KV_SQLDB_ConnectionStringName
    KV_AzureWebJobsStorageName: KV_AzureWebJobsStorageName
    KV_AzureWebJobsStorageNameValue: functionappmod.outputs.out_AzureWebJobsStorageConnection
    KV_WebsiteContentAzureFileConnectionStringName: KV_WebsiteContentAzureFileConnectionStringName
    KV_WebsiteContentAzureFileConnectionStringNameValue: functionappmod.outputs.out_AzureWebJobsStorageConnection
    KV_WebsiteContentShareName: KV_Website_ContentShareName
    KV_WebsiteContentShareNameValue: functionAppName
   // KV_CaseMessagesTrigger_ConnectionStringName: KV_CaseMessagesTrigger_ConnectionStringName
    //KV_CaseMessagesTrigger_ConnectionStringNameValue: 'TBD-May NOT be needed' //functionappmod.outputs.???
    KV_CosmosDB_ConnectionStringName: KV_CosmosDB_ConnectionStringName
    KV_CosmosDB_ConnectionStringNameValue: cosmosdbmod.outputs.out_CosmosDBConnectionString
    KV_CosmosDB_PrimaryKeyName: KV_CosmosDB_PrimaryKeyName
    KV_CosmosDB_PrimaryKeyNameValue: cosmosdbmod.outputs.out_CosmosPrimaryKey
    KV_CritWatcherSignalRConnectorURLName: KV_CritWatcherSignalRConnectorURLName
    KV_CritWatcherSignalRConnectorURLNameValue: signalrmod.outputs.out_signalRhostName
    KV_SignalR_ConnectionStringName: KV_SignalR_ConnectionStringName
    KV_SignalR_ConnectionStringNameValue: signalrmod.outputs.out_signalRhostConnectionString
      KV_ServiceBus_ConnectionStringName: KV_ServiceBus_ConnectionStringName
    KV_ServiceBus_ConnectionStringNameValue: servicebusmod.outputs.out_servicebusConnectionString
    CosmosDB_URI: cosmosdbmod.outputs.out_CosmosDB_URI
    SignalR_HubNameName: signalrmod.name
    appInsightsInstrumentationKey: appinsightsmod.outputs.out_appInsightsInstrumentationKey
    appInsightsConnectionString: appinsightsmod.outputs.out_appInsightsConnectionString
    ADOServiceprincipalObjectId: ADOServiceprincipalObjectId
    AzObjectIdAbele: AzObjectIdAbele
    AzObjectIdPagels: AzObjectIdPagels
    }
    dependsOn:  [
     keyvaultmod
     webappmod
     functionappmod
   ]
 }

///////////////////////////////
// TBD:Future Feature
////////////////////////////////
// module logicappmod 'main-1-logicapp.bicep' = {
//   name: logicAppName
//   params: {
//     defaultTags: defaultTags
//     logicAppName: logicAppName
//     location: location
//     // connections_office365_externalid: connections_office365_externalid
//     // connections_sql_externalid: connections_sql_externalid
//     // connections_teams_externalid: connections_teams_externalid
//   }
// }

// Output Params used for IaC deployment in pipeline
output out_webSiteName string = webSiteName
output out_functionAppName string = functionAppName
output out_keyvaultName string = keyvaultName
//output out_sqlDBName string = sqlDBName
//output out_sqlserverFQDN string = sqldbmod.outputs.sqlserverfullyQualifiedDomainName

