param containerAppName string
param containerAppEnvName string
param containerAppLogAnalyticsName string
param containerregistryName string

// Specifies the docker container image to deploy.')
param containerImage string

@description('Specifies the location for all resources.')
@allowed([
  'northcentralusstage'
  'eastus'
  'eastus2'
  'northeurope'
  'canadacentral'
])
param location string //cannot use resourceGroup().location since it's not available in most of regions

@description('Specifies the container port.')
param targetPort int = 80

@description('Number of CPU cores the container can use. Can be with a maximum of two decimals.')
param cpuCore string = '0.5'

@description('Amount of memory (in gibibytes, GiB) allocated to the container up to 4GiB. Can be with a maximum of two decimals. Ratio with CPU cores must be equal to 2.')
param memorySize string = '1'

@description('Minimum number of replicas that will be deployed')
@minValue(0)
@maxValue(25)
param minReplicas int = 1

@description('Maximum number of replicas that will be deployed')
@minValue(0)
@maxValue(25)
param maxReplicas int = 3

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: containerAppLogAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource containerAppEnv 'Microsoft.App/managedEnvironments@2022-06-01-preview' = {
  name: containerAppEnvName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

resource containerApp 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: containerAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: targetPort
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
    }
    template: {
      revisionSuffix: 'firstrevision'
      containers: [
        {
          name: containerAppName
          image: containerImage
          resources: {
            cpu: json(cpuCore)
            memory: '${memorySize}Gi'
          }
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
      }
    }
  }
}

// Reference Existing resource
// resource existing_containerregistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
//   name: containerregistryName
// }

// resource containerApp 'Microsoft.App/containerApps@2022-06-01-preview' = {
//   name: containerAppName
//   location: location
//   identity: {
//     type: 'SystemAssigned'
//   }
//   properties: {
//     managedEnvironmentId: containerAppEnv.id
//     configuration: {
//       ingress: {
//         external: true
//         targetPort: targetPort
//         allowInsecure: false
//         traffic: [
//           {
//             latestRevision: true
//             weight: 100
//           }
//         ]
//       }
//       // secrets: [
//       //   {
//       //     name: existing_containerregistry.name
//       //     value: existing_containerregistry.listCredentials().passwords[0].value
//       //   }
//       // ]
//     }
//     template: {
//       revisionSuffix: 'firstrevision'
//       containers: [
//         {
//           name: containerAppName
//           image: containerImage
//           resources: {
//             cpu: json(cpuCore)
//             memory: '${memorySize}Gi'
//           }
//         }
//       ]
//       scale: {
//         minReplicas: minReplicas
//         maxReplicas: maxReplicas
//       }
//     }
//   }
// }

output containerAppFQDN string = containerApp.properties.configuration.ingress.fqdn
