metadata description = 'Creates a role assignment under the specified resource group.'
param resourceGroupid string
param roleDefinitionId string
param principalId string = ''

resource role 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroupid, roleDefinitionId, principalId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
