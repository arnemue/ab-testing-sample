param functionAppName string = 'arnemfunc'              // Function App name.
param servicePlanName string = 'arnemasp'             // Existing Service Plan Name (must be in the same RG).
param storageAccountName string = 'arnemfuncsacc'          // Existing Storage Account Name - could be in different RG than Function app.
param storageAccountResourceGroup string = 'bicep-rg'  // Resource group where Storage Account is located.
param appInsightsName string = 'arnemappi'             // Existing App Insight Name - could be in different RG than Function app.
param appInsightsResourceGroup string = 'bicep-rg'    // Resource group where  App Insight is located - mainly is a Devo rg.
param location string = resourceGroup().location // Location where to deploy the Function app

var storageAccountEndpoint = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'


resource servicePlan 'Microsoft.Web/serverfarms@2022-03-01' existing = {
  name: servicePlanName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
  scope: resourceGroup(storageAccountResourceGroup)
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' existing = {
  name: appInsightsName
  scope: resourceGroup(appInsightsResourceGroup)
}

resource functionAppResource 'Microsoft.Web/sites@2021-02-01' = {
  name: functionAppName
  identity:{
    type:'SystemAssigned'    
  }
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: servicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'Python|3.9'
      http20Enabled: true
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'AzureWebJobsStorage'
          value: storageAccountEndpoint
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: storageAccountEndpoint
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
      ]
    }
  }
}
