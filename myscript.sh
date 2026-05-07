luqma@Luqman-PC MINGW64 ~/OneDrive/Documents/VS Code
$ az login
Select the account you want to log in with. For more information on login with Azure CLI, see https://go.microsoft.com/fwlink/?linkid=2271136

Retrieving tenants and subscriptions for the selection...

[Tenant and subscription selection]

No     Subscription name     Subscription ID                       Tenant
-----  --------------------  ------------------------------------  -----------------
[1] *  Azure subscription 1  f1f0b6b4-7c21-4928-809d-12903053d8ac  Default Directory

The default is marked with an *; the default tenant is 'Default Directory' and subscription is 'Azure subscription 1' (f1f0b6b4-7c21-4928-809d-12903053d8ac).

Select a subscription and tenant (Type a number or Enter for no changes): 

Tenant: Default Directory
Subscription: Azure subscription 1 (f1f0b6b4-7c21-4928-809d-12903053d8ac)

[Announcements]
With the new Azure CLI login experience, you can select the subscription you want to use more easily. Learn more about it and its configuration at https://go.microsoft.com/fwlink/?linkid=2271236

If you encounter any problem, please open an issue at https://aka.ms/azclibug

[Warning] The login output has been updated. Please be aware that it no longer displays the full list of available subscriptions by default.


luqma@Luqman-PC MINGW64 ~/OneDrive/Documents/VS Code
$ # Set environment variables for Azure resources
export RESOURCE_GROUP="rg-notifications-${RANDOM_SUFFIX}"
export LOCATION="eastus"
export SUBSCRIPTION_ID=$(az account show --query id --output tsv)

# Generate unique suffix for resource names
RANDOM_SUFFIX=$(openssl rand -hex 3)

# Set Notification Hub specific variables
export NH_NAMESPACE="nh-namespace-${RANDOM_SUFFIX}"
export NH_NAME="notification-hub-${RANDOM_SUFFIX}"

# Create resource group
az group create \
    --name ${RESOURCE_GROUP} \
    --location ${LOCATION} \
    --tags purpose=recipe environment=demo

echo "✅ Resource group created: ${RESOURCE_GROUP}"
{
  "id": "/subscriptions/f1f0b6b4-7c21-4928-809d-12903053d8ac/resourceGroups/rg-notifications-",
  "location": "eastus",
  "managedBy": null,
  "name": "rg-notifications-",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": {
    "environment": "demo",
    "purpose": "recipe"
  },
  "type": "Microsoft.Resources/resourceGroups"
}
✅ Resource group created: rg-notifications-

luqma@Luqman-PC MINGW64 ~/OneDrive/Documents/VS Code
$ [200~# Create Notification Hub namespace
bash: [200~#: command not found

luqma@Luqman-PC MINGW64 ~/OneDrive/Documents/VS Code
$ az notification-hub namespace create \
>     --resource-group ${RESOURCE_GROUP} \
>     --name ${NH_NAMESPACE} \
>     --location ${LOCATION} \
>     --sku Free
This command is experimental and under development. Reference and support levels: https://aka.ms/CLI_refstatus
{
  "enabled": false,
  "id": "/subscriptions/f1f0b6b4-7c21-4928-809d-12903053d8ac/resourceGroups/rg-notifications-/providers/Microsoft.NotificationHubs/namespaces/nh-namespace-c41418",
  "name": "nh-namespace-c41418",
  "provisioningState": "Unknown",
  "resourceGroup": "rg-notifications-",
  "type": "Microsoft.NotificationHubs/namespaces"
}

luqma@Luqman-PC MINGW64 ~/OneDrive/Documents/VS Code
$ 

luqma@Luqman-PC MINGW64 ~/OneDrive/Documents/VS Code
$ echo "✅ Notification Hub namespace created: ${NH_NAMESPACE}"~
✅ Notification Hub namespace created: nh-namespace-c41418~

luqma@Luqman-PC MINGW64 ~/OneDrive/Documents/VS Code
$ # Create notification hub within the namespace
az notification-hub create \
    --resource-group ${RESOURCE_GROUP} \
    --namespace-name ${NH_NAMESPACE} \
    --name ${NH_NAME} \
    --location ${LOCATION}

echo "✅ Notification hub created: ${NH_NAME}"
This command is experimental and under development. Reference and support levels: https://aka.ms/CLI_refstatus
{
  "id": "/subscriptions/f1f0b6b4-7c21-4928-809d-12903053d8ac/resourceGroups/rg-notifications-/providers/Microsoft.NotificationHubs/namespaces/nh-namespace-c41418/NotificationHubs/notification-hub-c41418",
  "location": "East US",
  "name": "notification-hub-c41418",
  "registrationTtl": "10675199.02:48:05.4775807",
  "resourceGroup": "rg-notifications-",
  "type": "Microsoft.NotificationHubs/namespaces/notificationHubs"
}
✅ Notification hub created: notification-hub-c41418

luqma@Luqman-PC MINGW64 ~/OneDrive/Documents/VS Code
$ # List authorization rules for the notification hub
az notification-hub authorization-rule list \
    --resource-group ${RESOURCE_GROUP} \
    --namespace-name ${NH_NAMESPACE} \
    --notification-hub-name ${NH_NAME} \
    --output table

echo "✅ Listed authorization rules for ${NH_NAME}"
This command is experimental and under development. Reference and support levels: https://aka.ms/CLI_refstatus
Location    Name                                ResourceGroup
----------  ----------------------------------  -----------------
East US     DefaultListenSharedAccessSignature  rg-notifications-
East US     DefaultFullSharedAccessSignature    rg-notifications-
✅ Listed authorization rules for notification-hub-c41418

luqma@Luqman-PC MINGW64 ~/OneDrive/Documents/VS Code
$ # Get connection string for client applications
LISTEN_CONNECTION=$(az notification-hub authorization-rule list-keys \
    --resource-group ${RESOURCE_GROUP} \
    --namespace-name ${NH_NAMESPACE} \
    --notification-hub-name ${NH_NAME} \
    --name DefaultListenSharedAccessSignature \
    --query primaryConnectionString --output tsv)

echo "✅ Retrieved listen connection string"
echo "Client connection string: ${LISTEN_CONNECTION:0:50}..."
WARNING: This command is experimental and under development. Reference and support levels: https://aka.ms/CLI_refstatus
✅ Retrieved listen connection string
Client connection string: Endpoint=sb://nh-namespace-c41418.servicebus.windo...

luqma@Luqman-PC MINGW64 ~/OneDrive/Documents/VS Code
$ # Get connection string for back-end applications
FULL_CONNECTION=$(az notification-hub authorization-rule list-keys \
    --resource-group ${RESOURCE_GROUP} \
    --namespace-name ${NH_NAMESPACE} \
    --notification-hub-name ${NH_NAME} \
    --name DefaultFullSharedAccessSignature \
    --query primaryConnectionString --output tsv)

echo "✅ Retrieved full access connection string"
echo "Server connection string: ${FULL_CONNECTION:0:50}..."
WARNING: This command is experimental and under development. Reference and support levels: https://aka.ms/CLI_refstatus
✅ Retrieved full access connection string
Server connection string: Endpoint=sb://nh-namespace-c41418.servicebus.windo...

luqma@Luqman-PC MINGW64 ~/OneDrive/Documents/VS Code
$ # Send a test notification to verify configuration
az notification-hub test-send \
    --resource-group ${RESOURCE_GROUP} \
    --namespace-name ${NH_NAMESPACE} \
    --notification-hub-name ${NH_NAME} \
    --notification-format template \
    --message "Hello from Azure Notification Hubs!"

echo "✅ Test notification sent successfully"
Preview version of extension is disabled by default for extension installation, enabled for modules without stable versions. 
Please run 'az config set extension.dynamic_install_allow_preview=true or false' to config it specifically. 
No stable version of 'notification-hub' to install. Preview versions allowed.
'test-send' is misspelled or not recognized by the system.

Examples from AI knowledge base:
https://aka.ms/cli_ref
Read more about the command in reference docs
✅ Test notification sent successfully

luqma@Luqman-PC MINGW64 ~/OneDrive/Documents/VS Code
$ # Check notification hub deployment status
az notification-hub show \
    --resource-group ${RESOURCE_GROUP} \
    --namespace-name ${NH_NAMESPACE} \
    --name ${NH_NAME} \
    --query "{Name:name,Location:location,Status:provisioningState}" \
    --output table
This command is experimental and under development. Reference and support levels: https://aka.ms/CLI_refstatus
Name                     Location
-----------------------  ----------
notification-hub-c41418  East US

luqma@Luqman-PC MINGW64 ~/OneDrive/Documents/VS Code
$ # Verify authorization rules are properly configured
az notification-hub authorization-rule list \
    --resource-group ${RESOURCE_GROUP} \
    --namespace-name ${NH_NAMESPACE} \
    --notification-hub-name ${NH_NAME} \
    --query "[].{Name:name,Rights:rights}" \
    --output table
This command is experimental and under development. Reference and support levels: https://aka.ms/CLI_refstatus
Name
----------------------------------
DefaultListenSharedAccessSignature
DefaultFullSharedAccessSignature

luqma@Luqman-PC MINGW64 ~/OneDrive/Documents/VS Code
$ # Validate connection strings are accessible
echo "Testing connection string retrieval..."
CONNECTION_TEST=$(az notification-hub authorization-rule list-keys \
    --resource-group ${RESOURCE_GROUP} \
    --namespace-name ${NH_NAMESPACE} \
    --notification-hub-name ${NH_NAME} \
    --name DefaultListenSharedAccessSignature \
    --query primaryConnectionString --output tsv)

if [[ -n "$CONNECTION_TEST" ]]; then
    echo "✅ Connection string retrieval successful"
else
    echo "❌ Connection string retrieval failed"
fi
Testing connection string retrieval...
WARNING: This command is experimental and under development. Reference and support levels: https://aka.ms/CLI_refstatus
✅ Connection string retrieval successful

luqma@Luqman-PC MINGW64 ~/OneDrive/Documents/VS Code
$ # Check resource group tags and configuration
az group show \
    --name ${RESOURCE_GROUP} \
    --query "{Name:name,Location:location,Tags:tags}" \
    --output table

# Check namespace configuration
az notification-hub namespace show \
    --resource-group ${RESOURCE_GROUP} \
    --name ${NH_NAMESPACE} \
    --query "{Name:name,Sku:sku.name,Status:status}" \
    --output table
Name               Location
-----------------  ----------
rg-notifications-  eastus
This command is experimental and under development. Reference and support levels: https://aka.ms/CLI_refstatus
Name                 Sku    Status
-------------------  -----  --------
nh-namespace-c41418  Free   Active