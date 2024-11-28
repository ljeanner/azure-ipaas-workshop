metadata description = 'Creates a role assignment under the specified storage account.'
param name string
param roleDefinitionId string
param principalId string = ''
param principalType string = 'ServicePrincipal'

resource role 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storage.id, roleDefinitionId, principalId)
  scope: storage
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: principalId
    principalType: principalType
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: name
}
