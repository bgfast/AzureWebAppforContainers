param location string
param containerregistryName string

@description('Enable an admin user that has push/pull permission to the registry.')
param acrAdminUserEnabled bool = true

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
@description('Tier of your Azure Container Registry.')
param acrSku string = 'Standard'

// azure container registry
resource containerregistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: containerregistryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    displayName: 'Container Registry'
    'container.registry': containerregistryName
  }
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

//var acr_username = containerregistry.listCredentials().username
//var acr_password = containerregistry.listCredentials().passwords[0].value

output acrLoginServer string = containerregistry.properties.loginServer
//output output_acr_username string = acr_username

#disable-next-line outputs-should-not-contain-secrets
//output output_acr_password string = acr_password
