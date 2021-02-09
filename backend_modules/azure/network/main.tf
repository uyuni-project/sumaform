/*
  This module sets up a class B VPC sliced into two subnets, one public and one private.
  The private network has no Internet access.
  The public network has an Internet Gateway and accepts SSH connections from a whitelist of trusted IPs.
*/
/*TODO: add tags*/
resource "azurerm_resource_group" "suma-rg" {
  name     = "${var.name_prefix}-resources"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "suma-vn" {
  count = var.create_network ? 1 : 0
  name                = "${var.name_prefix}-network"
  resource_group_name = azurerm_resource_group.suma-rg.name
  location            = azurerm_resource_group.suma-rg.location
  address_space       = ["172.16.0.0/16"]
}

resource "azurerm_subnet" "public-sn" {
  count = var.create_network ? 1 : 0
  name                 = "${var.name_prefix}-public-sn"
  virtual_network_name = "${azurerm_virtual_network.suma-vn[0].name}"
  resource_group_name  = "${azurerm_resource_group.suma-rg.name}"
  address_prefixes     = ["172.16.0.0/24"]
}

resource "azurerm_subnet" "private-sn" {
  count = var.create_network ? 1 : 0
  name                 = "${var.name_prefix}-private-sn"
  virtual_network_name = "${azurerm_virtual_network.suma-vn[0].name}"
  resource_group_name  = "${azurerm_resource_group.suma-rg.name}"
  address_prefixes     = ["172.16.1.0/24"]
}

resource "azurerm_subnet" "private-additional-sn" {
  count = var.create_network? 1: 0

  name                 = "${var.name_prefix}-private-additional-sn"
  virtual_network_name = "${azurerm_virtual_network.suma-vn[0].name}"
  resource_group_name  = "${azurerm_resource_group.suma-rg.name}"
  address_prefixes     = [var.additional_network]
}

resource "azurerm_route_table" "public-rt" {
  count = var.create_network? 1: 0
  name                = "${var.name_prefix}-public-rt"
  resource_group_name = "${azurerm_resource_group.suma-rg.name}"
  location            = "${azurerm_resource_group.suma-rg.location}"
  route {
    name                   = "all-out"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "Internet"
  }
  route {
    name                   = "internal-traffic"
    address_prefix         = "172.16.0.0/16"
    next_hop_type          = "VnetLocal"
  }

}

resource "azurerm_subnet_route_table_association" "public-rtas" {
  count = var.create_network? 1: 0
  subnet_id      = "${azurerm_subnet.public-sn[0].id}"
  route_table_id = "${azurerm_route_table.public-rt[0].id}"
}


resource "azurerm_subnet_route_table_association" "private-rtas" {
  count = var.create_network? 1: 0
  subnet_id      = "${azurerm_subnet.private-sn[0].id}"
  route_table_id = "${azurerm_route_table.public-rt[0].id}"
}

resource "azurerm_subnet_route_table_association" "private-additional-rtas" {
  count = var.create_network? 1: 0
  subnet_id      = "${azurerm_subnet.private-additional-sn[0].id}"
  route_table_id = "${azurerm_route_table.public-rt[0].id}"
}

resource "azurerm_network_security_group" "public-nsg" {
  count = var.create_network? 1: 0

  name                = "${var.name_prefix}-public-nsg"
  resource_group_name = "${azurerm_resource_group.suma-rg.name}"
  location            = "${azurerm_resource_group.suma-rg.location}"
}

# NOTE: this allows SSH from any network
resource "azurerm_network_security_rule" "ssh" {
  count = var.create_network? 1: 0

  name                        = "ssh"
  resource_group_name         = "${azurerm_resource_group.suma-rg.name}"
  network_security_group_name = "${azurerm_network_security_group.public-nsg[0].name}"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.ssh_allowed_ips
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "https" {
  count = var.create_network? 1: 0

  name                        = "https"
  resource_group_name         = "${azurerm_resource_group.suma-rg.name}"
  network_security_group_name = "${azurerm_network_security_group.public-nsg[0].name}"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_subnet_network_security_group_association" "public-nsg-association" {
  count = var.create_network? 1: 0

  subnet_id                 = "${azurerm_subnet.public-sn[0].id}"
  network_security_group_id = "${azurerm_network_security_group.public-nsg[0].id}"
}

 resource "azurerm_network_security_group" "private-nsg" {
  count = var.create_network? 1: 0
  name                = "${var.name_prefix}-private-nsg"
  resource_group_name = "${azurerm_resource_group.suma-rg.name}"
  location            = "${azurerm_resource_group.suma-rg.location}"
}

resource "azurerm_network_security_group" "private-additional-nsg" {
  count = var.create_network? 1: 0
  name                = "${var.name_prefix}-private-nsg"
  resource_group_name = "${azurerm_resource_group.suma-rg.name}"
  location            = "${azurerm_resource_group.suma-rg.location}"
}

resource "azurerm_subnet_network_security_group_association" "private-additonal-nsg-association" {
  count = var.create_network? 1: 0
  subnet_id                 = "${azurerm_subnet.private-additional-sn[0].id}"
  network_security_group_id = "${azurerm_network_security_group.private-additional-nsg[0].id}"
}

resource "azurerm_subnet_network_security_group_association" "private-nsg-association" {
  count = var.create_network? 1: 0
  subnet_id                 = "${azurerm_subnet.private-sn[0].id}"
  network_security_group_id = "${azurerm_network_security_group.private-nsg[0].id}"
}

resource "azurerm_public_ip" "nat-pubIP" {
  count = var.create_network? 1: 0
  name                = "nat-gateway-pubIP"
  resource_group_name = "${azurerm_resource_group.suma-rg.name}"
  location            = "${azurerm_resource_group.suma-rg.location}"
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}

resource "azurerm_nat_gateway" "suma-ngw" {
  count = var.create_network? 1: 0
  name                = "${var.name_prefix}-ngw"
  resource_group_name = "${azurerm_resource_group.suma-rg.name}"
  location            = "${azurerm_resource_group.suma-rg.location}"
}

resource "azurerm_nat_gateway_public_ip_association" "ngw-pubip-association" {
  count = var.create_network? 1: 0
  nat_gateway_id       = azurerm_nat_gateway.suma-ngw[0].id
  public_ip_address_id = azurerm_public_ip.nat-pubIP[0].id
}


resource "azurerm_subnet_nat_gateway_association" "suma-ngw-association" {
  count = var.create_network? 1: 0
  subnet_id      = "${azurerm_subnet.private-sn[0].id}"
  nat_gateway_id = "${azurerm_nat_gateway.suma-ngw[0].id}"
}

output "configuration" {
  depends_on = [azurerm_subnet_route_table_association.private-rtas, azurerm_subnet_route_table_association.private-additional-rtas , azurerm_subnet_route_table_association.public-rtas]
  value = var.create_network ? {
    public_subnet_id          = length(azurerm_subnet.public-sn) > 0? azurerm_subnet.public-sn[0].id: null
    private_subnet_id         = length(azurerm_subnet.private-sn) > 0? azurerm_subnet.private-sn[0].id: null
    private_additional_subnet_id = length(azurerm_subnet.private-additional-sn) > 0? azurerm_subnet.private-additional-sn[0].id: null
    public_security_group_id  = length(azurerm_network_security_group.public-nsg) > 0? azurerm_network_security_group.public-nsg[0].id: null
    private_security_group_id = length(azurerm_network_security_group.private-nsg) > 0? azurerm_network_security_group.private-nsg[0].id: null
    private_additional_security_group_id = length(azurerm_network_security_group.private-additional-nsg) > 0? azurerm_network_security_group.private-additional-nsg[0].id: null
    resource_group_name = azurerm_resource_group.suma-rg.name
  } : {}
}
