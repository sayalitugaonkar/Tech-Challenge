variable "AWS_REGION" {    
    default = "ap-south-1"
}



variable "AWS_AZ" {    
    default = "ap-south-1a"
}

variable "security_gp" {    
    default = "Linux_Security_Gp"
}

variable "ami" {    
    default = "ami-059a9b1093495222c" // Debian 10 (HVM), SSD Volume Type 
}

# variable "ami_bastion" {    
#     default = "ami-0b3ed0a3f4fadb26e" // Bastion
# }


