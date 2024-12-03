metadata description = 'Creates a role assignment under the specified apim.'
param name string
param roleDefinitionId string
param principalId string = ''
param principalType string = 'ServicePrincipal'

resource role 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(apim.id, roleDefinitionId, principalId)
  scope: apim
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: principalId
    principalType: principalType
  }
}

resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' existing = {
  name: name
}
