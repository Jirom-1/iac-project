data "aws_availability_zones" "available" {
  state = "available"
}

# Creating VPC
resource "aws_vpc" "default_vpc" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "default"
}

############################################################# PUBLIC SUBNET ######################################################################


#create subnets
resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = "${aws_vpc.default_vpc.id}"
  cidr_block             = "${var.public_subnet_cidr_1}"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = "${aws_vpc.default_vpc.id}"
  cidr_block             = "${var.public_subnet_cidr_2}"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "public-subnet-3" {
  vpc_id                  = "${aws_vpc.default_vpc.id}"
  cidr_block             = "${var.public_subnet_cidr_3}"
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "public-subnet-3"
  }
}

#Create Internet Gateway
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = "${aws_vpc.default_vpc.id}"
}

# Creating Route Table for Public Subnet
resource "aws_route_table" "public-subnet-1-route-table" {
    vpc_id = aws_vpc.default_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet-gateway.id
    }

    tags = {
        Name = "public-subnet-1-igw-route-table"
    }
}

resource "aws_route_table" "public-subnet-2-route-table" {
    vpc_id = aws_vpc.default_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet-gateway.id
    }

    tags = {
        Name = "public-subnet-2-igw-route-table"
    }
}

resource "aws_route_table" "public-subnet-3-route-table" {
    vpc_id = aws_vpc.default_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet-gateway.id
    }

    tags = {
        Name = "public-subnet-3-igw-route-table"
    }
}

resource "aws_route_table_association" "public-subnet-1-route-table-association" {
    subnet_id = aws_subnet.public-subnet-1.id
    route_table_id = aws_route_table.public-subnet-1-route-table.id
}

resource "aws_route_table_association" "public-subnet-2-route-table-association" {
    subnet_id = aws_subnet.public-subnet-2.id
    route_table_id = aws_route_table.public-subnet-2-route-table.id
}

resource "aws_route_table_association" "public-subnet-3-route-table-association" {
    subnet_id = aws_subnet.public-subnet-3.id
    route_table_id = aws_route_table.public-subnet-3-route-table.id
}

# # Creating NAT Gateway
# resource "aws_eip" "nat-gateway-elastic-ip" {
#   domain = "vpc"
# }

# resource "aws_nat_gateway" "nat-gateway" {
#   allocation_id = aws_eip.nat-gateway-elastic-ip.id
#   subnet_id     = aws_subnet.public-subnet.id
# }






############################################################# PRIVATE SUBNET ######################################################################
# resource "aws_subnet" "private-subnet" {
#   vpc_id                  = "${aws_vpc.default_vpc.id}"
#   cidr_block             = "${var.private_subnet_cidr}"
#   tags = {
#     Name = "private-subnet"
#   }
# }

# # Creating NAT gateway Route Table for Private Subnet
# resource "aws_route_table" "nat-gateway-route-table" {
#     vpc_id = aws_vpc.default_vpc.id
#     route {
#             cidr_block = "0.0.0.0/0"
#             nat_gateway_id = aws_nat_gateway.nat-gateway.id
#     }

#     tags = {
#         Name = "private-subnet-nat-gateway-route-table"
#     }
# }

# resource "aws_route_table_association" "nat-gateway-private-subnet-association" {
#     subnet_id = aws_subnet.private-subnet.id
#     route_table_id = aws_route_table.nat-gateway-route-table.id
# }