param location string = resourceGroup().location
param prefix string = 'notif'
param keyVaultName string = 'kv-${uniqueString(resourceGroup().id)}'

var uniqueName = '${prefix}-${uniqueString(resourceGroup().id)}'

// 1. Create the Key Vault to store the secret
resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true // Modern standard: Use RBAC instead of Access Policies
  }
}

resource nhNamespace 'Microsoft.NotificationHubs/namespaces@2023-10-01-preview' = {
  name: 'nhns-${uniqueName}'
  location: location
  sku: {
    name: 'Standard'
  }
}

resource notificationHub 'Microsoft.NotificationHubs/namespaces/notificationHubs@2023-10-01-preview' = {
  parent: nhNamespace
  name: 'hub-${uniqueName}'
  location: location
  properties: {}
}

resource sendAuthRule 'Microsoft.NotificationHubs/namespaces/notificationHubs/authorizationRules@2023-10-01-preview' = {
  parent: notificationHub
  name: 'BackendSendPolicy'
  properties: {
    rights: [ 'Send' ]
  }
}

// 2. Fix: Store the secret in Key Vault instead of an output
resource secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: kv
  name: 'NotificationHubConnectionString'
  properties: {
    // This uses the correct symbolic reference to fix the linter warning
    value: sendAuthRule.listKeys().primaryConnectionString 
  }
}

// 3. Safe Output: Return the Resource Names, NOT the secrets
output vaultName string = kv.name
output hubName string = notificationHub.name
