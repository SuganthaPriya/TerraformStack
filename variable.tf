variable "resource_group" {
  description = "The name of the resource group in which to create the azure resources."
}
variable "hostname" {
  description = "VM name referenced also in storage-related names."
}
variable "dns_name" {
  description = " Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system."
}
variable "lb_ip_dns_name" {
  description = "DNS for Load Balancer IP"
}
variable "location" {
  description = "The location/region where the azure resources are created. Changing this forces a new resource to be created."
}
variable "virtual_network_name" {
  description = "The name for the virtual network."
  default     = "Myvnet"
}
variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}
variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.0.10.0/24"
}
# variable "storage_account_tier" {
#   description = "Defines the Tier of storage account to be created. Valid options are Standard and Premium."
#   default     = "Standard"
# }
# variable "storage_replication_type" {
#   description = "Defines the Replication Type to use for this storage account. Valid options include LRS, GRS etc."
#   default     = "LRS"
# }
variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_D1_v2"
}
variable "image_publisher" {
  description = "name of the publisher of the image (az vm image list)"
  default     = "MicrosoftWindowsServer"
}
variable "image_offer" {
  description = "the name of the offer (az vm image list)"
  default     = "WindowsServer"
}
variable "image_sku" {
  description = "image sku to apply (az vm image list)"
  default     = "2012-R2-Datacenter"
}
variable "image_version" {
  description = "version of the image to apply (az vm image list)"
  default     = "latest"
}
variable "VM_admin_username" {
  description = "administrator user name"
}
variable "VM_admin_password" {
  description = "administrator password (recommended to disable password auth)"
}
variable "database_name" {
    description = "The name of the Maria Database to be created."
}
variable "server_name" {
    description = "The name of the Maria Db Server."
}
variable "database_utf_charset" {
    description = "Specifies the Charset for the MariaDB Database, which needs to be a valid MariaDB Charset."
    default = "utf8"
}
variable "database_collation" {
    description = "Specifies the Collation for the MariaDB Database, which needs to be a valid MariaDB Collation."
    default = "utf8_general_ci"
}
variable "server_sku_name" {
    description = "Specifies the SKU Name for this MariaDB Server. The name of the SKU, follows the tier + family + cores pattern (e.g. B_Gen5_1, GP_Gen5_8)."
    default = "GP_Gen5_2"
}
variable "server_sku_capacity" {
    description = " The scale up/out capacity, representing server's compute units."
    default = "2"
}
variable "server_sku_tier" {
    description = "The tier of the particular SKU. Possible values are Basic, GeneralPurpose, and MemoryOptimized."
    default = "GeneralPurpose"
}
variable "server_sku_family" {
    description = "The family of the hardware (e.g. Gen5)"
    default = "Gen5"
}
variable "server_storage_mb" {
    description = "Max storage allowed for a server. Possible values are between 5120 MB (5GB) and 1024000MB (1TB) for the Basic SKU and between 5120 MB (5GB) and 4096000 MB (4TB) for General Purpose/Memory Optimized SKUs."
    default = "5120"
}
variable "server_login" {
    description = "The Administrator Login for the MariaDB Server. Changing this forces a new resource to be created."
}
variable "server_password" {
    description = "The Password associated with the administrator_login for the MariaDB Server."
}
variable "server_version" {
    description = "Specifies the version of MariaDB to use. The valid value is 10.2."
    default = "10.2"
}
variable "server_ssl_enforcement" {
    description = "Specifies if SSL should be enforced on connections. Possible values are Enabled and Disabled."
    default = "Enabled"
}
variable "vnet_rule_name" {
    description = "Specifies the Vnet Rule name"
    default = "mariadb-vnet-rule"
}
variable "firewall_rule" {
    description = "Specifies the firewall Rule name"
    default = "mariadb-firewall-rule"
}
variable "ip_name" {
    description = "Specifies the IP name"
    default="MyPublicIP"
}
variable "subnet_name" {
    description = "Specifies the Subnet name"
    default="Mysubnet"
}
variable "lb_name" {
    description = "Specifies the Load Balancer name"
    default="MyloadBalancer"
}