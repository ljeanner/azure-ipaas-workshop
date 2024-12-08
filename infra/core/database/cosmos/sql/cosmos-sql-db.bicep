metadata description = 'Creates an Azure Cosmos DB for NoSQL account with a database.'
param accountName string
param databaseName string
param location string = resourceGroup().location
param tags object = {}

param containers array = []
// param keyVaultName string

module cosmos 'cosmos-sql-account.bicep' = {
  name: 'cosmos-sql-account'
  params: {
    name: accountName
    location: location
    tags: tags
    // keyVaultName: keyVaultName
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-05-15' = {
  name: '${accountName}/${databaseName}'
  properties: {
    resource: { id: databaseName }
  }

  resource list 'containers' = [for container in containers: {
    name: container.name
    properties: {
      resource: {
        id: container.id
        partitionKey: { paths: [ container.partitionKey ] }
      }
      options: {}
    }
  }]

  dependsOn: [
    cosmos
  ]
}

module roleDefinition 'cosmos-sql-role-def.bicep' = {
  name: 'cosmos-sql-role-definition'
  params: {
    accountName: accountName
  }
  dependsOn: [
    cosmos
    database
  ]
}

output accountId string = cosmos.outputs.id
output accountName string = cosmos.outputs.name
// output connectionStringSecret string = cosmos.outputs.connectionStringSecret
output databaseName string = databaseName
output endpoint string = cosmos.outputs.endpoint
output dataReaderRoleDefinitionId string = roleDefinition.outputs.dataReaderRoleId
output dataContributorRoleDefinitionId string = roleDefinition.outputs.dataContributorRoleId
