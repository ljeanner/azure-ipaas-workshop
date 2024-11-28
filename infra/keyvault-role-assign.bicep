metadata description = 'Creates a role assignment under the specified storage account.'
param name string
param roleDefinitionId string
param principalId string = ''
param principalType string = 'ServicePrincipal'

resource role 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(keyVault.id, roleDefinitionId, principalId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: principalId
    principalType: principalType
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: name
}
