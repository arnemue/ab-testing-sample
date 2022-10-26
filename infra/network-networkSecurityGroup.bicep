/*
------------------------
parameters
------------------------
*/
param networkSecurityGroupName string
param location string

/*
------------------------
resources
------------------------
*/
resource nsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'Port_65200_65535'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationPortRange: '65200-65535'
          direction: 'Inbound'
          priority: 1000
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowHttpsInBound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
          direction: 'Inbound'
          priority: 100
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
        }        
      }
      {
        name: 'AllowGetSessionInformationOutBound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationPortRanges: [
            '80'
            '443'
          ]
          direction: 'Outbound'
          priority: 130
          protocol: '*'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
        }        
      }
      {
        name: 'DenyAllInBound'
        properties: {
          access: 'Deny'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          direction: 'Inbound'
          priority: 4000
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
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
output networkSecurityGroupResourceId string = nsg.id
