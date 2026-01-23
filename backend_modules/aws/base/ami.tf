data "aws_ami" "opensuse156o" {
  most_recent = true
  name_regex  = "^openSUSE-Leap-15-6-"
  owners      = ["679593333241"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "sles15sp4o" {
  most_recent = true
  name_regex  = "^suse-sles-15-sp4-byos-v"
  owners      = ["679593333241"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "sles15sp5o" {
  most_recent = true
  name_regex  = "^suse-sles-15-sp5-byos-v"
  owners      = ["679593333241"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "sles15sp5-paygo" {
  most_recent = true
  name_regex  = "^suse-sles-15-sp5-v[0-9]*-hvm"
  owners      = ["013907871322"] // aws-marketplace

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "sles15sp6-paygo" {
  most_recent = true
  name_regex  = "^suse-sles-15-sp6-v[0-9]*-hvm"
  owners      = ["013907871322"] // aws-marketplace

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "sles15sp6o" {
  most_recent = true
  name_regex  = "^suse-sles-15-sp6-byos-v"
  owners      = ["679593333241"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "sles15sp7-paygo" {
  most_recent = true
  name_regex  = "^suse-sles-15-sp7-v[0-9]*-hvm"
  owners      = ["013907871322"] // aws-marketplace

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "sles15sp7o" {
  most_recent = true
  name_regex  = "^suse-sles-15-sp7-byos-v"
  owners      = ["679593333241"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

// EMEA offers
data "aws_ami" "smlm-server-51-x86_64-ltd-paygo" {
  most_recent = true
  name_regex  = "^suse-multi-linux-manager-server-5-1-v[0-9].*(ltd).*$"
  owners      = ["679593333241"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "product-code"
    values = ["c48fapw1f0e4tvjukevqlbmf4"]
  }
}


data "aws_ami" "smlm-server-51-arm64-ltd-paygo" {
  most_recent = true
  name_regex  = "^suse-multi-linux-manager-server-5-1-v[0-9].*(ltd).*$"
  owners      = ["679593333241"]

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "product-code"
    values = ["umnofojstehgl6jnp9nspg7g"]
  }
}

data "aws_ami" "smlm-proxy-51-arm64-byos" {
  most_recent = true
  name_regex  = "^suse-multi-linux-manager-proxy-5-1-byos-v"
  owners      = ["679593333241"]

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }


  filter {
    name   = "product-code"
    values = ["713zi40zqboecsjmlxkf31iin"]
  }
}

data "aws_ami" "smlm-proxy-51-x86_64-byos" {
  most_recent = true
  name_regex  = "^suse-multi-linux-manager-proxy-5-1-byos-v"
  owners      = ["679593333241"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "product-code"
    values = ["q26lvbne2lnivd97mlx43j4u"]
  }
}


data "aws_ami" "sles12sp5" {
  most_recent = true
  name_regex  = "^suse-sles-12-sp5-byos-v"
  owners      = ["679593333241"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "sles12sp5-paygo" {
  most_recent = true
  name_regex  = "^suse-sles-12-sp5-v[0-9]*-hvm"
  owners      = ["013907871322"] // aws marketplace

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "rocky8" {
  most_recent = true
  name_regex  = "^Rocky-8-EC2-Base-8"
  owners      = ["792107900819"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "rocky9" {
  most_recent = true
  name_regex  = "^Rocky-9-EC2-Base-9"
  owners      = ["792107900819"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "ubuntu2204" {
  most_recent = true
  name_regex  = "^ubuntu/images/hvm-ssd/ubuntu-jammy-22.04"
  owners      = ["099720109477"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "ubuntu2404" {
  most_recent = true
  name_regex  = "^ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04"
  owners      = ["099720109477"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "rhel8" {
  most_recent = true
  name_regex  = "^RHEL-8.9.0_HVM-"
  owners      = ["309956199498"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "rhel9" {
  most_recent = true
  name_regex  = "^RHEL-9.5.0_HVM-"
  owners      = ["309956199498"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "slesforsap15sp5-paygo" {
  most_recent = true
  name_regex  = "^suse-sles-sap-15-sp5-v"
  owners      = ["679593333241"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
