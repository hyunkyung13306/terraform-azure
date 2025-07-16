variable "resource_group_name" {
  description = "kt-lhk-rg"
  type = string
  default = "kt-lhk-rg"
}
variable "location" {
  type = string
  default = "koreacentral"
}
variable "vnet_name" {
  type = string
  default = "kt-lhk-vnet"
}
variable "address_space" {
  type = list(string)
  default = [ "10.0.0.0/16" ]
}
variable "subnet_count" {
  default = 3
}
variable "nsg_name" {
  type = string
  default = "kt-lhk-nsg"
}
variable "linux_vm_name" {
  default = "kt-lhk-linux-vm"
}
variable "linux_admin_username" {
  default = "azureuser"
}
variable "linux_admin_password" {
  default = "P@ssw0rd1234!"
  sensitive = true
}
variable "linux_vm_size" {
  default = "standard_B1s"
}
variable "linux_vm_name_pip" {
  default = "kt-lhk-pip"
}
variable "windows_vm_name" {
  default = "kt-lhk-win-vm"
}
variable "windows_admin_username" {
  default = "azureuser"
}
variable "windows_admin_password" {
  default = "P@ssw0rd1234!!"
  sensitive = true
}
variable "windows_vm_size" {
  default = "standard_B2s"
}
variable "nsg_name_2" {
  type = string
  default = "kt-lhk-nsg2"
}
//App Service
variable "app_service_plan_name" {
  type    = string
  default = "kt-lhk-asp-testconor"
}

variable "app_service_name" {
  type    = string
  default = "kt-lhk-webapp-conor-test"
}
variable "storage_account_name" {
  type = string
  default = "ktlhkstorageaccount"
}