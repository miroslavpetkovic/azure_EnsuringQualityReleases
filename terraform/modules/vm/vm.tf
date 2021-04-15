resource "azurerm_network_interface" "test" {
  name                = "udacity-project-3-NIC"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip
  }
}

resource "azurerm_linux_virtual_machine" "test" {
  name                  = var.name
  location              = var.location
  resource_group_name   = var.resource_group
  size                  = "Standard_B2s"
  admin_username        = var.admin_username
# source_image_id       = var.packer_image
  disable_password_authentication = true

  network_interface_ids = [azurerm_network_interface.test.id]
  admin_ssh_key {
    username   = var.admin_username
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQChgRy/wwQYfOSK2gpqsLOik1GzGnDCy5oZ8Au2eGcK4LidTB3/OvKRhDKRqzJanQZCyeJPPbqxtC3kJhmCkYQt7WQzTXziEAZ2Gl1VZqYOLtLXGh2W4GAURmhUkog1LjCCN7c531e8v/3T4z7LzdIXzd8r+0WGcQ7mMIkPqQi1Fxhi9SDSvURvrm3uXMHeorGjJxpJzD3JuS5rbVasaGsgqEfnQat3qu3LN40JOVbfeQaIaSfLQZAIG1I+UZS9GD9HTLWd9MRxbzlEHhcL5rXeQ+emvkDsazZQd8h63qgmZQqtdP6AaBShQ2TBGaJe+fVXlC4zRgioZ6Mr7UA49ul5"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
    tags = {
    project_name = "QA"
    stage        = "Testing"
  }
}