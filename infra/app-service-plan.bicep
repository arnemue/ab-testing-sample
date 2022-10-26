param appServicePlanName string              // App Service Plan name.
param sku string = 'F1' // The SKU of App Service Plan
param location string = resourceGroup().location // Location where to deploy the Function app
param tagValues object
param appSvcPlanKind string


resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: sku
  }
  kind: appSvcPlanKind
  properties: {
    reserved: true
  }
  tags: tagValues
}
