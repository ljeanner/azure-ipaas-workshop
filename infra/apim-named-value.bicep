metadata description = 'Creates a named Value in the specified apim.'
param name string
param namedValueName string
param namedValueValue string
param isSecret bool = false



resource namedValue 'Microsoft.ApiManagement/service/namedValues@2023-09-01-preview' = {
  parent: apim
  name: namedValueName
  properties: {
    displayName: namedValueName
    value: namedValueValue
    secret: isSecret
  }
}

resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' existing = {
  name: name
}
