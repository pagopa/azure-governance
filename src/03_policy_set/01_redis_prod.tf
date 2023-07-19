locals {
  redis_prod = {
    metadata_category_name = "pagopa_prod"
  }
}

variable "redis_prod" {
  type = object({
    listofallowedskuname     = list(string)
    listofallowedskucapacity = list(string)
  })
  default = {
    listofallowedskuname     = ["Standard", "Premium"]
    listofallowedskucapacity = ["0", "1", "2"]
  }
  description = "List of redis policy set parameters"
}

resource "azurerm_policy_set_definition" "redis_prod" {
  name                = "redis_prod"
  policy_type         = "Custom"
  display_name        = "PagoPA Redis PROD"
  management_group_id = data.azurerm_management_group.pagopa.id

  metadata = <<METADATA
    {
        "category": "${local.redis_prod.metadata_category_name}",
        "version": "v1.0.0",
        "ASC": "true"
    }
METADATA

  policy_definition_reference {
    policy_definition_id = data.terraform_remote_state.policy_redis.outputs.redis_allowed_versions_id
  }

  policy_definition_reference {
    policy_definition_id = data.terraform_remote_state.policy_redis.outputs.redis_allowed_tls_id
  }

  policy_definition_reference {
    policy_definition_id = data.terraform_remote_state.policy_redis.outputs.redis_disable_nosslport_id
  }

  policy_definition_reference {
    policy_definition_id = data.terraform_remote_state.policy_redis.outputs.redis_allowed_sku_id
    reference_id         = local.redis.listofallowedsku
    parameter_values     = <<VALUE
    {
      "listOfAllowedSkuName": {
        "value": ${jsonencode(var.redis_prod.listofallowedskuname)}
      },
      "listOfAllowedSkuCapacity": {
        "value": ${jsonencode(var.redis_prod.listofallowedskucapacity)}
      }
    }
    VALUE
  }

}

output "redis_prod_id" {
  value = azurerm_policy_set_definition.redis_prod.id
}
