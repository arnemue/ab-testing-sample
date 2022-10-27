param appGatewayName string = 'arnemAppGw'
param location string
param networkSecurityGroupName string = 'arnemNsg'
param virtualNetworkName string = 'arnemVnet'
param publicIpName string = 'arnemPubIp'
param dsHostName string = 'ds-api-ac.arnemue.de'
param functionBaseUrl string

// default parameters
@allowed([
  'WAF_v2'
  'Standard_v2'
])
param appGatewaySku string = 'WAF_v2'



// NOTE a better solution will be introduced in the next version
// https://github.com/Azure/bicep/issues/1852
var appGatewayId = resourceId('Microsoft.Network/applicationGateways', appGatewayName)
var appGatewayFrontendIp = '${appGatewayId}/frontendIPConfigurations/appgw-public-frontend-ip'
var appGatewayFrontendPort = '${appGatewayId}/frontendPorts/httpPort'
var appGatewayListener = '${appGatewayId}/httpListeners/httpListener'
var appGatewayBackendAddressPool = '${appGatewayId}/backendAddressPools/appGatewayBackendPool'
var appGatewayBackendHttpSettings = '${appGatewayId}/backendHttpSettingsCollection/appGatewayBackendHttpSetting'




module nsg 'network-networkSecurityGroup.bicep' = {
  name: 'network-nsg'
  params: {
    networkSecurityGroupName: networkSecurityGroupName
    location: location
  }
}

module vNet 'network-virtualNetwork.bicep' = {
  name: 'network-vNet'
  params: {
    virtualNetworkName: virtualNetworkName
    networkSecurityGroupId: networkSecurityGroupResourceId
    location: location
  }
  dependsOn: [
    nsg
  ]
}

// assign outputs to variables
var networkSecurityGroupResourceId =  nsg.outputs.networkSecurityGroupResourceId
var applicationGatewaySubnetResourceId = vNet.outputs.applicationGatewaySubnetResourceId

resource publicIp 'Microsoft.Network/publicIPAddresses@2022-01-01' existing = {
  name: publicIpName
}



resource appgw 'Microsoft.Network/applicationGateways@2020-11-01' = {
  name: appGatewayName
  location: location
  properties: {
    sku: {
      name: appGatewaySku
      tier: appGatewaySku
    }
    autoscaleConfiguration: {
      minCapacity: 1
      maxCapacity: 2
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties:{
          subnet:{
            id: applicationGatewaySubnetResourceId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name:'appgw-public-frontend-ip'
        properties:{
          publicIPAddress:{
            id: publicIp.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'httpPort'
        properties:{
          port: 80
        }
      }
    ]
    backendAddressPools:[
      { 
        name: 'appGatewayBackendPool'
        properties:{
          backendAddresses:[
            {
              fqdn: functionBaseUrl
            }
          ]
        }
      }       
    ]
    backendHttpSettingsCollection:[
      {
        name: 'appGatewayBackendHttpSetting'
        properties:{
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
        }
      }
    ]
    httpListeners:[
      {
        name: 'httpListener'
        properties:{
          protocol:'Http'
          hostName: dsHostName
          frontendIPConfiguration:{
            id: appGatewayFrontendIp
          }
          frontendPort:{
            id: appGatewayFrontendPort
          }
        }
      }        
    ]
    requestRoutingRules:[
      {
        name: 'routing-apigw'
        properties:{
          ruleType:'Basic'
          httpListener:{
            id: appGatewayListener
          }
          backendAddressPool:{
            id: appGatewayBackendAddressPool
          }
          backendHttpSettings:{
            id: appGatewayBackendHttpSettings
          }
        }
      }    
    ]
  }
}
