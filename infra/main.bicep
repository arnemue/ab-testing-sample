
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


var functionBaseUrl =  func_app.outputs.functionBaseUrl


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
  }
  dependsOn: [
    func_app
  ]
}
