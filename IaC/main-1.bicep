// Deploy Azure infrastructure for FuncApp + monitoring

// Region for all resources
param location string = resourceGroup().location
param createdBy string = 'bgfast'
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

// Resource names may contain alpha numeric characters only and must be between 5 and 50 characters.
var containerregistryName = 'cr${uniqueString(resourceGroup().id)}'

var containerName = 'containers-${uniqueString(resourceGroup().id)}'
var containerAppName = 'ca-${uniqueString(resourceGroup().id)}'
var containerAppEnvName = 'cae-${uniqueString(resourceGroup().id)}'
var containerAppLogAnalyticsName = 'calog-${uniqueString(resourceGroup().id)}'

// Default image needed to create Container App
// https://mcr.microsoft.com/en-us/product/mcr/hello-world/about
//var containerImage = 'mcr.microsoft.com/mcr/hello-world:v2.0'
var containerImage = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'

// Tags
var defaultTags = {
  App: 'Web App for Containers'
  CostCenter: costCenter
  CreatedBy: createdBy
  NickName: nickName
}

// KeyVault Secret Names
// Note: Secret names can only contain alphanumeric characters and dashes!!!
// Warning: No! No! No! Underbars!!!!
param KV_acr_usernameName string = 'acrusername'
param KV_acr_passName string = 'acrpassword'

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
     containerregistryName: containerregistryName
     containerImage: containerImage
     defaultTags: defaultTags
   }
   dependsOn:  [
     containerregistrymod
   ]
  }

// This is NOT supported. Look up Object ID for Service Principal
//var randyPagelsRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'rpagels@microsoft.com') // b6be0700-1fda-4f88-bf20-1aa508a91f73

// Object Id of Service Principal "AzureWebAppforContainerApps_FullAccess"
param ADOServiceprincipalObjectId string = '689f5f89-8dfc-4e60-886b-f3a04d859962'

// Application Id of Service Principal "RPagels" Alias.
param AzObjectIdPagels string = 'b7e9d138-aa96-4069-8eb6-296717cff0cd'

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
    ACRUrl: containerregistrymod.outputs.acrLoginServer
    KV_acr_usernameName: KV_acr_usernameName
    KV_acr_usernameNameValue: containerregistrymod.outputs.output_acr_username
    KV_acr_passName: KV_acr_passName
    KV_acr_passNameValue: containerregistrymod.outputs.output_acr_pass
    }
    dependsOn:  [
     keyvaultmod
     webappmod
   ]
 }

// Output Params used for IaC deployment in pipeline
output out_webSiteName string = webSiteName
output out_keyvaultName string = keyvaultName
output out_containerregistryName string = containerregistryName
output out_containerAppName string = containerAppName
output out_containerAppEnvName string = containerAppEnvName
output out_containerName string = containerName
output out_containerAppFQDN string = containerappmod.outputs.containerAppFQDN

// output output_acr_username string = containerregistrymod.outputs.output_acr_username
// #disable-next-line outputs-should-not-contain-secrets
// output output_acr_password string = containerregistrymod.outputs.output_acr_password
