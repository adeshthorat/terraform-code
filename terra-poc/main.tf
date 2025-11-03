terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
  required_version = ">= 1.3.0"
}

provider "null" {}

# ------------------------
# Local test data
# ------------------------

resource "null_resource" "this" {
  for_each = tomap(local.server_types)
  triggers = {
    host   = each.value.host
    type   = each.value.type
    cpu    = each.value.cpu
    memory = each.value.memory

  }

}

resource "null_resource" "test" {
  triggers = {
    for_each = var.tags != null ? var.tags : []
    App      = null_resource.this.triggers.APP
  }
}

variable "check_server_type" {
  description = "Will check server type"
  type        = string
}


locals {
  check_server_type = (var.check_server_type == local.server_types.DB.type ? true : false)
}

output "check_server_type" {
  value = local.check_server_type

}

output "server_details" {
  value = { for k, v in null_resource.this : k => v.triggers.type }
}

output "server_host" {
  description = "List of Available host"
  value       = local.server_types.APP.host
}


output "try-test" { #evaluate result of all arguments and returns the result of first one with no error
  description = "checker"
  value       = try(local.server_types.DB.ram, null_resource.this, "NotFound")

}
# output "server_types_key" {
#   description = "List of available types"
#   value       = local.servers.prod.
# }
# output "server_types_value" {
#   description = "List of available types"
#   value       = local.servers.keys.value.type
# }

locals { #terraform object
  #server_type = toset(["APP", "DBS", "TST", "UAT"])

  tags = {
    app   = "gr"
    owner = "terra"
  }


  server_types = {
    DB = { #DB is key with 4 value attributes which we can call like each.value.host/each.value.type
      host   = "DBS",
      type   = "r5.xlarge",
      cpu    = "4"
      memory = "8Gi"
    }
    APP = {
      host   = "APP"
      type   = "t4.large"
      cpu    = "6"
      memory = "8Gi"
    }
  }
}


# locals { #terraform object
#   #server_type = toset(["APP", "DBS", "TST", "UAT"])
#   servers = { #key
#     web1 = "t2.micro"
#     web2 = "t3.micro"
#   }
# }

# output "server_typewithfor" {
#   value = { for k, v in local.servers : k => v.keys }
# }
