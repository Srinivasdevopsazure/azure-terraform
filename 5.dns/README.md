Terraform will automatically recover a soft-deleted Key Vault during Creation if one is found - you can opt out of this using the features block within the Provider block.

**The key_vault** block in the Azure provider for Terraform is used to configure the behavior of Terraform when managing Azure Key Vaults.

An **Azure Key Vault** is a service that provides centralized storage and management of cryptographic keys, secrets, and certificates. It is commonly used to store sensitive information, such as passwords, API keys, and certificates, in a **secure and encrypted** manner.

The key_vault block in the Azure provider allows you to configure the behavior of Terraform when managing Azure Key Vaults. The following are the two properties in the key_vault block:

**purge_soft_delete_on_destroy:** This property is a boolean value that determines whether Terraform should permanently delete a Key Vault when it is destroyed. By default, when you delete a Key Vault in Azure, it is moved to a soft-delete state, where it is recoverable for a certain period of time. If this property is set to true, Terraform will permanently delete the Key Vault when it is destroyed.

**recover_soft_deleted_key_vaults:** This property is a boolean value that determines whether Terraform should recover soft-deleted Key Vaults. By default, when you delete a Key Vault in Azure, it is moved to a soft-delete state, where it is recoverable for a certain period of time. If this property is set to true, Terraform will recover the Key Vault if it is in a soft-deleted state.

The **purge_soft_delete_on_destroy and recover_soft_deleted_key_vaults** properties in the key_vault block are independent of each other and serve different purposes.

When **purge_soft_delete_on_destroy is set to true**, Terraform will permanently delete the Key Vault when it is destroyed, and the Key Vault will not be recoverable.

On the other hand, when **recover_soft_deleted_key_vaults is set to true**, Terraform will recover soft-deleted Key Vaults if they exist. This means that if a Key Vault has been deleted in Azure and is still in a soft-delete state, Terraform will recover it. This option does not affect the behavior of Terraform when destroying Key Vaults.

In other words, purge_soft_delete_on_destroy determines the behavior of Terraform when destroying Key Vaults, while recover_soft_deleted_key_vaults determines the behavior of Terraform when creating or updating Key Vaults.
The **recover_soft_deleted_key_vaults** option only applies to Key Vaults that are in a soft-delete state and have not been permanently deleted using the purge_soft_delete_on_destroy option.

If a Key Vault has been deleted using the purge_soft_delete_on_destroy option, it cannot be recovered using the recover_soft_deleted_key_vaults option, as the Key Vault and its contents have been permanently deleted.

**azurerm_client_config**
The azurerm_client_config data source in Terraform is used to retrieve the current Azure client configuration for the Terraform provider for Azure. This data source provides information about the Azure environment, such as the subscription ID, tenant ID, and environment, which are used by the Terraform provider to authenticate to Azure and interact with Azure resources.

The purpose of this resource is to provide a convenient way to retrieve the current Azure client configuration without having to hard-code the values in your Terraform configuration. By using the azurerm_client_config data source, you can ensure that your Terraform configuration uses the correct Azure client configuration, even if the values change over time.

The tenant_id property is used to specify the tenant ID for the Azure AD, and the object_id is used to specify the unique identifier for the Azure AD object. The key_permissions, secret_permissions, and storage_permissions properties define the specific permissions that are being granted to the Azure AD object, such as "Get" for retrieving keys or secrets.

**access policy**
when you create an access policy for an Azure Key Vault, you must specify an identity, and a Service Principal is a recommended identity to use. This is because the access policy controls who can perform actions on the Key Vault, such as reading or writing secrets, and you want to ensure that those actions are performed in a secure and controlled manner.

A Service Principal is a secure way to represent the identity of an application or service that needs access to Azure resources. By using a Service Principal, you can grant specific permissions to the application or service, and you can also control the permissions that are granted, for example, by revoking or modifying the access policy.

In short, the use of a Service Principal is required when creating an access policy for an Azure Key Vault to ensure that access to the Key Vault is secure and controlled, and to allow you to grant specific permissions to an application or service that needs access to the Key Vault.
**azuread_client_config**
