
param appServicePlanName string = 'arnemSvcPlan'             // App Service Plan name.
param location string = resourceGroup().location
param appSvcPlanKind string = 'linux'
param storageAccountName string = 'arnemfuncsacc'
param appInsightsName string = 'arnemappi'
param functionAppName string = 'arnemfunc'
param tagValues object =  {
  usage: 'testing'
  env: 'dev'
}
param publicIpName string = 'arnemPubIp'
param virtualNetworkName string = 'arnemVnet'

var functionBaseUrl =  func_app.outputs.functionBaseUrl


resource publicIp 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

module vNet 'network-virtualNetwork.bicep' = {
  name: 'network-vNet'
  params: {
    virtualNetworkName: virtualNetworkName
    location: location
  }
}

var applicationGatewaySubnetResourceId = vNet.outputs.applicationGatewaySubnetResourceId


module app_svc_plan 'app-service-plan.bicep' = {
  name: 'app-svc-plan'
  params: {
    appServicePlanName: appServicePlanName
    location: location
    sku: 'B1'
    appSvcPlanKind: appSvcPlanKind
    tagValues: tagValues
  }
}

module func_app_resources 'function-app-resources.bicep' = {
  name: 'func-app-resources'
  params: {
    storageAccountName: storageAccountName
    location: location
    appInsightsName: appInsightsName
  }
}


module func_app 'function-app.bicep' = {
  name: 'function-app'
  params: {
    functionAppName: functionAppName
    servicePlanName: appServicePlanName
    location: location
    storageAccountName: storageAccountName
    storageAccountResourceGroup: resourceGroup().name
    appInsightsName: appInsightsName
    appInsightsResourceGroup: resourceGroup().name
    applicationGatewaySubnetResourceId: applicationGatewaySubnetResourceId
  }
  dependsOn: [
    app_svc_plan
    func_app_resources
  ]
}



module app_gw 'appGateway.bicep' = {
  name: 'application-gateway'
  params: {
    location: location
    functionBaseUrl: functionBaseUrl
    applicationGatewaySubnetResourceId: applicationGatewaySubnetResourceId
  }
  dependsOn: [
    func_app
  ]
}
