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
param acrSku string = 'Basic'

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

output acrLoginServer string = containerregistry.properties.loginServer
