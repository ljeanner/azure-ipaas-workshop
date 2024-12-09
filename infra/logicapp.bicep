param appName string
param planName string
param location string = resourceGroup().location
param storageAccountName string
param storageAccountDataName string
param storageAccountConnectionString string
param serviceBusFqdn string
param applicationInsightsName string
param resourceGroupName string
param subscriptionId string
param tags object = {}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource storageData 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountDataName
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: planName
  location: location
  sku: {
    name: 'WS1'
    tier: 'WorkflowStandard'
    capacity: 1 // Number of instances
  }
  properties: {
    targetWorkerCount: 1
    targetWorkerSizeId: 0 // Corresponds to WS1
  }
  tags: tags
}

resource apiConnection 'Microsoft.Web/connections@2018-07-01-preview' = {
  name: 'azureeventgrid'
  location: location
  kind: 'V2'
  properties: {
    displayName: 'co-eg-handsonlabinoday01'
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'azureeventgrid')
      type: 'Microsoft.Web/locations/managedApis'
    }
    parameterValueType:'Alternative'
    alternativeParameterValues:{}
  }
  tags: tags
}

resource logicApp 'Microsoft.Web/sites@2022-09-01' = {
  name: appName
  location: location
  kind: 'workflowapp,functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        { 
          name: 'APP_KIND'
          value: 'workflowApp' 
        }
        { 
          name: 'AzureFunctionsJobHost__extensionBundle__id'
          value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows' 
        }
        { 
          name: 'AzureBlob_blobStorageEndpoint'
          value: storageData.properties.primaryEndpoints.blob
        }
        { 
          name: 'serviceBus_fullyQualifiedNamespace'
          value: serviceBusFqdn
        }
        { 
          name: 'AzureFunctionsJobHost__extensionBundle__version'
          value: '[1.*, 2.0.0)' 
        }
        {
          name: 'AzureWebJobsStorage'
          value: storageAccountConnectionString
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        { 
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING' 
          value: storageAccountConnectionString
        }
        { 
          name: 'WEBSITE_CONTENTSHARE' 
          value: toLower(appName) 
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value : 'InstrumentationKey=${appInsights.properties.InstrumentationKey};IngestionEndpoint=https://${location}.in.applicationinsights.azure.com/;LiveEndpoint=https://${location}.livediagnostics.monitor.azure.com/'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~18'
        }
        { 
          name: 'storageAccount_Name'
          value: storageData.name
        }
        { 
          name: 'resourceGroup_Name'
          value: resourceGroupName
        }
        { 
          name: 'subscription_Id'
          value: subscriptionId
        }
        { 
          name: 'eventGrid_connectionRuntimeUrl'
          value: apiConnection.properties.connectionRuntimeUrl
        }
      ]
    }
  }
  tags: tags
  dependsOn: [
    appServicePlan
    storage
    apiConnection
  ]
}

// https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/storage#storage-blob-data-owner
var storageBlobDataOwnerRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b')

// Allow access from function app to storage account using a managed identity
resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storage.id, logicApp.id, storageBlobDataOwnerRoleId)
  scope: storage
  properties: {
    roleDefinitionId: storageBlobDataOwnerRoleId
    principalId: logicApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource apiConnectionAccessPolicy 'Microsoft.Web/connections/accessPolicies@2016-06-01' = {
  name: '${apiConnection.name}/${logicApp.name}' // Unique access policy name
  location: resourceGroup().location
  properties: {
    principal: {
      type: 'ActiveDirectory'
      identity: {
        tenantId: subscription().tenantId
        objectId: logicApp.identity.principalId
      }
    }
  }
}

output principalId string = logicApp.identity.principalId
output name string = logicApp.name
