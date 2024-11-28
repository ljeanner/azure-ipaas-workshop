param name string
param location string = resourceGroup().location
param tags object = {}
param deployment object = {
  format: 'OpenAI'
  name: 'gpt-4o-mini'
  version: '2024-07-18'
}

resource azureOpenAI 'Microsoft.CognitiveServices/accounts@2024-06-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'S0'
  }
  kind: 'OpenAI'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    apiProperties: {}
    customSubDomainName: name
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: false
    allowedFqdnList: []
    disableLocalAuth: false
    dynamicThrottlingEnabled: false
  }
}

resource gpt4oMini 'Microsoft.CognitiveServices/accounts/deployments@2024-06-01-preview' = {
  parent: azureOpenAI
  name: deployment.name
  sku: {
    name: 'Standard'
    capacity: 10
  }
  properties: {
    model: deployment
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    currentCapacity: 10
  }
}

output id string = azureOpenAI.id
output name string = azureOpenAI.name
output endpoint string = azureOpenAI.properties.endpoint
output deploymentName string = deployment.name
