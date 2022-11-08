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

// Tags
var defaultTags = {
  App: 'Web App for Containers'
  CostCenter: costCenter
  CreatedBy: createdBy
  NickName: nickName
}

// Create Application Insights
module appinsightsmod './main-1-AppInsights.bicep' = {
  name: 'appinsightsdeploy'
  params: {
    location: location
    appInsightsName: appInsightsName
    defaultTags: defaultTags
    appInsightsAlertName: appInsightsAlertName
    appInsightsWorkspaceName: appInsightsWorkspaceName
  }
}

// Create Web App
module webappmod './main-1-WebApp.bicep' = {
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
module keyvaultmod './main-1-KeyVault.bicep' = {
  name: keyvaultName
  params: {
    location: location
    vaultName: keyvaultName
    }
 }

 // Create Azure Container Registry
 module containerregistrymod './main-1-ContainerRegistry.bicep' = {
  name: containerregistryName
  params: {
    containerregistryName: containerregistryName
    location: location
  }
 }

 // Create Azure Container App
 module containerappmod './main-1-ContainerApps.bicep' = {
  name: containerAppName
  params: {
    containerAppEnvName: containerAppEnvName
    containerAppLogAnalyticsName: containerAppLogAnalyticsName
    containerAppName: containerAppName
    location: location
  }
 }

// This is NOT supported. Look up Object ID for Service Principal
//var randyPagelsRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'rpagels@microsoft.com') // b6be0700-1fda-4f88-bf20-1aa508a91f73

// Application Id of Service Principal "RPagels-AzureWebAppforContainers-Full"
param ADOServiceprincipalObjectId string = '38372314-e1c9-455d-a11e-3edb60a46687'

// Application Id of Service Principal "RPagels" Alias.
param AzObjectIdPagels string = 'b6be0700-1fda-4f88-bf20-1aa508a91f73'

 // Create Configuration Entries
module configsettingsmod './main-1-ConfigSettings.bicep' = {
  name: 'configSettings'
  params: {
    keyvaultName: keyvaultName
    tenant: subscription().tenantId
    webappName: webSiteName
    appServiceprincipalId: webappmod.outputs.out_appServiceprincipalId
    appInsightsInstrumentationKey: appinsightsmod.outputs.out_appInsightsInstrumentationKey
    appInsightsConnectionString: appinsightsmod.outputs.out_appInsightsConnectionString
    ADOServiceprincipalObjectId: ADOServiceprincipalObjectId
    AzObjectIdPagels: AzObjectIdPagels
    }
    dependsOn:  [
     keyvaultmod
     webappmod
   ]
 }

// Output Params used for IaC deployment in pipeline
output out_webSiteName string = webSiteName
output out_keyvaultName string = keyvaultName
