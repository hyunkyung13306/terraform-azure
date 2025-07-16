
resource "azurerm_resource_group" "rg" {
  name = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name = var.vnet_name
  address_space = var.address_space
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

#subnet 3개만들기
resource "azurerm_subnet" "subnet" {
  count                = var.subnet_count
  name                 = "kt-lhk-snet-0${count.index + 1}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [
    "10.0.${count.index + 1}.0/24"
  ]
}

#NSG
resource "azurerm_network_security_group" "nsg" {
  name = var.nsg_name
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

#NSG Rule
resource "azurerm_network_security_rule" "ssh" {
  name = "ssh"
  priority = 1001
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "22"
  source_address_prefix = "*"
  destination_address_prefix  = "*"
  resource_group_name = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

#NSG subnet
resource "azurerm_subnet_network_security_group_association" "subnet_nsg_01" {
  subnet_id                 = azurerm_subnet.subnet[0].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_network_interface" "linux_nic" {
  name                = "linux-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet[0].id  # 첫 번째 서브넷과 연결
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux_pip.id
  }
}

resource "azurerm_public_ip" "linux_pip" {
  name                = "linux-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}



#Linux VM
resource "azurerm_linux_virtual_machine" "linux_vm" {
  name = var.linux_vm_name
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  size = var.linux_vm_size
  admin_username = var.linux_admin_username
  admin_password = var.linux_admin_password
  network_interface_ids = [azurerm_network_interface.linux_nic.id]
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name = "${var.linux_vm_name}-osdisk"
  }
  source_image_reference {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-focal"
    sku = "20_04-lts"
    version = "latest"
  }
  disable_password_authentication = false
}



# NSG - Windows
resource "azurerm_network_security_group" "nsg2" {
  name                = var.nsg_name_2
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
# NSG Rule - Windows
resource "azurerm_network_security_rule" "rdp" {
  name                        = "RDP"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg2.name
}
#NSG subnet
resource "azurerm_subnet_network_security_group_association" "subnet_nsg_02" {
  subnet_id                 = azurerm_subnet.subnet[1].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
# Public IP - Windows
resource "azurerm_public_ip" "windows_pip" {
  name                = "${var.windows_vm_name}-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

#Windows VM
resource "azurerm_network_interface" "windows_nic" {
  name = "${var.windows_vm_name}-nic"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.subnet[1].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "windows_vm" {
  name = var.windows_vm_name
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  size = var.windows_vm_size
  admin_username = var.windows_admin_username
  admin_password = var.windows_admin_password
  network_interface_ids = [azurerm_network_interface.windows_nic.id]
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name = "${var.windows_vm_name}-osdisk"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2022-Datacenter"
    version = "latest"
  }
}
# 2. App Service Plan (Linux, B1 요금제)
resource "azurerm_service_plan" "asp" {
  name                = var.app_service_plan_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku_name = "B1"
  os_type  = "Linux" # 또는 "Windows"
}

# 3. App Service (Web App)
resource "azurerm_linux_web_app" "webapp" {
  name                = var.app_service_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.asp.id
  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }
}
resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    environment = "staging"
  }
}
