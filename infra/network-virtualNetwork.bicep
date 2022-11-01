/*
------------------------
parameters
------------------------
*/
param virtualNetworkName string
param location string

/*
------------------------
variables
------------------------
*/
var kubernetesSubnetName = 'subnet-kubernetes'
var applicationGatewaySubnetName = 'subnet-applicationGateway'


/*
------------------------
resources
------------------------
*/
resource vNet 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '172.20.0.0/14'
      ]
    }
    subnets:[
      {
        name: kubernetesSubnetName
        properties: {
          addressPrefix: '172.20.0.0/16'
        }
      }
      {
        name: applicationGatewaySubnetName
        properties: {
          addressPrefix: '172.21.0.0/16'
          serviceEndpoints: [
            {
              service: 'Microsoft.Web'
              locations: [ '*' ]
            }
          ]
        }
      }

    ]
  }
}

/*
------------------------
outputs
------------------------
*/
output kubernetesSubnetResourceId string = vNet.properties.subnets[0].id
output applicationGatewaySubnetResourceId string = vNet.properties.subnets[1].id
