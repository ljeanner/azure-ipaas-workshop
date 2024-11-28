param name string
param location string = resourceGroup().location
param tags object = {}

resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Consumption'
    capacity: 0
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: 'company@example.com'
    publisherName: 'Innovation Team'
  }
}

output id string = apim.id
output name string = apim.name
