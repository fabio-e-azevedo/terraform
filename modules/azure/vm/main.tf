# Configure the Microsoft Azure Provider

provider "azurerm" {
  version = "=1.28.0"
}

resource "azurerm_resource_group" "main" {
    name     = "${var.prefix}-resource"
    location = "${var.location}"

    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_network_watcher" "main" {
  name                = "myNetWatcher"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
}

resource "azurerm_virtual_network" "main" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "${azurerm_resource_group.main.location}"
    resource_group_name = "${azurerm_resource_group.main.name}"

    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_subnet" "main" {
    name                 = "mySubnet"
    resource_group_name  = "${azurerm_resource_group.main.name}"
    virtual_network_name = "${azurerm_virtual_network.main.name}"
    address_prefix       = "${var.ip_address}"
}

resource "azurerm_public_ip" "main" {
    name                         = "myPublicIP-${count.index + 1}"
    location                     = "${azurerm_resource_group.main.location}"
    resource_group_name          = "${azurerm_resource_group.main.name}"
    allocation_method            = "Dynamic"
    count                        = "${var.node_count}"

    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_network_security_group" "main" {
    name                = "myNetworkSecurityGroup"
    location            = "${azurerm_resource_group.main.location}"
    resource_group_name = "${azurerm_resource_group.main.name}"
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
        //resource_group_name        = "${azurerm_resource_group.main.name}"
    }

    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_network_interface" "main" {
    name                      = "myNIC"
    location                  = "${azurerm_resource_group.main.location}"
    resource_group_name       = "${azurerm_resource_group.main.name}"
    network_security_group_id = "${azurerm_network_security_group.main.id}"
    count                     = "${var.node_count}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.main.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.main.*.id[count.index]}"
    }

    depends_on = ["azurerm_network_security_group.main"] 
    tags {
        environment = "Terraform Demo"
    }
}

resource "azurerm_virtual_machine_extension" "main" {
  name                       = "myNetworkWatcher"
  location                   = "${azurerm_resource_group.main.location}"
  resource_group_name        = "${azurerm_resource_group.main.name}"
  virtual_machine_name       = "${azurerm_virtual_machine.main.*.name[count.index]}"
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  type                       = "NetworkWatcherAgentLinux"
  type_handler_version       = "1.4"
  auto_upgrade_minor_version = true
  count                      = "${var.node_count}"
}
/*
resource "azurerm_storage_account" "main" {
  name                     = "mystorageaccount"
  resource_group_name      = "${azurerm_resource_group.main.name}"
  location                 = "${azurerm_resource_group.main.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_packet_capture" "main" {
  name                 = "myPacketCapture"
  network_watcher_name = "${azurerm_network_watcher.main.name}"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  target_resource_id   = "${azurerm_virtual_machine.main.id}"
  
  storage_location {
    storage_account_id = "${azurerm_storage_account.main.id}"
  }

  depends_on = ["azurerm_virtual_machine_extension.main"]
}
*/

resource "azurerm_virtual_machine" "main" {
  name                  = "${upper(var.prefix)}${format("%02d", (count.index + var.start_number) + 1)}-VM"
  location              = "${azurerm_resource_group.main.location}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  network_interface_ids = ["${azurerm_network_interface.main.*.id[count.index]}"]
  vm_size               = "Standard_B1ls"
  count                 = "${var.node_count}"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myOsDisk1-${var.prefix}-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.prefix}"
    admin_username = "${var.username}"
    admin_password = "${var.password}"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "Terraform Demo"
  }
}

/*
data "azurerm_public_ip" "main" {
  name                = "${azurerm_public_ip.main.name}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  //resource_group_name = "${azurerm_virtual_machine.main.resource_group_name}"
}
output "public_ip_address" {
  value = "${data.azurerm_public_ip.main.ip_address}"
}
*/
