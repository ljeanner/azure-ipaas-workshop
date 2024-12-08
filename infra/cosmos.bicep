param accountName string
param location string = resourceGroup().location
param tags object = {}

param containers array = [
  {
    name: 'orders'
    id: 'orders'
    partitionKey: '/id'
  }
]
param databaseName string = ''
// param keyVaultName string

var defaultDatabaseName = 'ordersdb'
var actualDatabaseName = !empty(databaseName) ? databaseName : defaultDatabaseName

module cosmos './core/database/cosmos/sql/cosmos-sql-db.bicep' = {
  name: 'cosmos-sql-db'
  params: {
    accountName: accountName
    databaseName: actualDatabaseName
    location: location
    containers: containers
    // keyVaultName: keyVaultName
    tags: tags
  }
}

// output connectionStringSecret string = cosmos.outputs.connectionStringSecret
output databaseName string = cosmos.outputs.databaseName
output containerName string = containers[0].name
output endpoint string = cosmos.outputs.endpoint
output accountId string = cosmos.outputs.accountId
output accountName string = accountName
output dataReaderRoleDefinitionId string = cosmos.outputs.dataReaderRoleDefinitionId
output dataContributorRoleDefinitionId string = cosmos.outputs.dataContributorRoleDefinitionId
