resource "azurerm_policy_set_definition" "dev_set_enforced" {
  name                  = "pagopa_dev_set_enforced"
  policy_type           = "Custom"
  display_name          = "PagoPA policy enforced set/initiatives for dev management group"
  management_group_name = data.azurerm_management_group.dev_sl_pagamenti_servizi.name

  metadata = <<METADATA
    {
        "category": "${var.metadata_category_name}",
        "version": "v1.0.0"
    }
METADATA

  parameters = <<PARAMETERS
  {
    "listOfAllowedLocations": {
      "type": "Array",
      "metadata": {
        "description": "The list of locations that can be specified when deploying resources.",
        "strongType": "location",
        "displayName": "Allowed locations"
      },
      "defaultValue" : [""]
    }
  }
PARAMETERS

  # Allowed Locations
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
    parameter_values     = <<VALUE
    {
      "listOfAllowedLocations": {
        "value": "[parameters('listOfAllowedLocations')]"
      }
    }
    VALUE
  }
}

resource "azurerm_policy_set_definition" "dev_set_advice" {
  name                  = "pagopa_dev_set_advice"
  policy_type           = "Custom"
  display_name          = "PagoPA policy advice set/initiatives for dev management group"
  management_group_name = data.azurerm_management_group.dev_sl_pagamenti_servizi.name

  metadata = <<METADATA
    {
        "category": "${var.metadata_category_name}",
        "version": "v1.0.0"
    }
METADATA

  parameters = <<PARAMETERS
  {
    "listOfAllowedSKUs": {
      "type": "Array",
      "metadata": {
        "description": "The list of size SKUs that can be specified for virtual machines.",
        "displayName": "Allowed Size SKUs",
        "strongType": "VMSKUs"
      },
      "defaultValue" : [""]
    }
  }
PARAMETERS

  # Allowed SKUS
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/cccc23c7-8427-4f53-ad12-b6a63eb452b3"
    parameter_values     = <<VALUE
    {
      "listOfAllowedSKUs": {
        "value": "[parameters('listOfAllowedSKUs')]"
      }
    }
    VALUE
  }
}

#
# Asingment
#

locals {
  list_allowed_locations_dev = jsonencode(var.dev_allowed_locations)
  list_allow_skus_raw_dev    = jsonencode(var.dev_vm_skus_allowed)
}

# Enforce
resource "azurerm_management_group_policy_assignment" "dev_set_enforced_2_root_sl_pay" {
  name                 = "pa_devsetenf2rootslpay"
  display_name         = "PagoPA/DEV/SET/ENFORCE 2 Mgmt root sl servizi e pagamenti"
  policy_definition_id = azurerm_policy_set_definition.dev_set_enforced.id
  management_group_id  = data.azurerm_management_group.dev_sl_pagamenti_servizi.id

  location = var.location
  enforce  = true

  metadata = <<METADATA
  {
      "category": "${var.metadata_category_name}",
      "version": "v1.0.0"
  }
METADATA

  parameters = <<PARAMS
  {
      "listOfAllowedLocations": {
          "value": ${local.list_allowed_locations_dev}
      }
  }
PARAMS

  identity {
    type = "SystemAssigned"
  }
}

# Advice
resource "azurerm_management_group_policy_assignment" "dev_set_advice_2_root_sl_pay" {
  name                 = "pa_devsetadv2rootslpay"
  display_name         = "PagoPA/DEV/SET/ADVICE 2 Mgmt root sl servizi e pagamenti"
  policy_definition_id = azurerm_policy_set_definition.dev_set_advice.id
  management_group_id  = data.azurerm_management_group.dev_sl_pagamenti_servizi.id

  location = var.location
  enforce  = false

  metadata = <<METADATA
  {
      "category": "${var.metadata_category_name}",
      "version": "v1.0.0"
  }
METADATA

  parameters = <<PARAMS
  {
      "listOfAllowedSKUs": {
          "value": ${local.list_allow_skus_raw_dev}
      }
  }
PARAMS

  identity {
    type = "SystemAssigned"
  }
}
