resource "azurerm_policy_set_definition" "log_analytics_uat" {
  name                = "log_analytics_uat"
  policy_type         = "Custom"
  display_name        = "PagoPA Log Analytics UAT"
  management_group_id = data.azurerm_management_group.pagopa.id

  metadata = jsonencode({
    category = "pagopa_uat"
    version  = "v1.0.0"
    ASC      = "true"
  })

  policy_definition_reference {
    policy_definition_id = data.terraform_remote_state.policy_log_analytics.outputs.log_analytics_bound_daily_quota_id
    parameter_values     = jsonencode({})
  }

  # Azure Monitor Logs for Application Insights should be linked to a Log Analytics workspace
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/d550e854-df1a-4de9-bf44-cd894b39a95e"
    parameter_values     = jsonencode({})
  }
}

output "log_analytics_uat_id" {
  value = azurerm_policy_set_definition.log_analytics_uat.id
}
