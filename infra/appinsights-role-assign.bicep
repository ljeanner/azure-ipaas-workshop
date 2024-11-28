metadata description = 'Creates a role assignment under the specified app insights.'
param name string
param roleDefinitionId string
param principalId string = ''
param principalType string = 'ServicePrincipal'

resource role 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(applicationInsights.id, roleDefinitionId, principalId)
  scope: applicationInsights
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: principalId
    principalType: principalType
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: name
}
