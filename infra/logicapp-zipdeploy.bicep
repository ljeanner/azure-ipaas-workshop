param logicAppName string

resource logicAppZipDeploy 'Microsoft.Web/sites/extensions@2022-03-01' = {
  name: '${logicAppName}/zipdeploy'
  properties: {
    packageUri: 'https://github.com/ikhemissi/azure-ipaas-workshop/raw/refs/heads/main/src/workflows.zip'
  }
}
