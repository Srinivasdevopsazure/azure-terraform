###############################################################################################
###    While developers can securely store the secrets in Azure Key Vault,                  ###
###    services need a way to access Azure Key Vault. Managed identities provide an         ###
###    automatically managed identity in Azure Active Directory (Azure AD) for applications ###
###    to use when connecting to resources that support Azure AD authentication.            ###
###    Applications can use managed identities to obtain Azure AD tokens without having to  ### 
###    manage any credentials.                                                              ###
###############################################################################################
# https://medium.com/@thomaswatsonv1/using-user-assigned-managed-identities-in-azure-automation-runbooks-94000904e8b0
# https://www.youtube.com/watch?v=QIXbyInGXd8

# data "azurerm_client_config" "current" {}
# data "azuread_client_config" "current" {}
# data "azurerm_subscription" "primary" {}

# Create user managed identity and assign it to vault and application gateway