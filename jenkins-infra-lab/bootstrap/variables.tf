variable "region"{
    type = string
    description = "AWS region"
    default = "eu-central-1" 
}
variable "project"{
    type = string
    description = "Terraform state resources"
    default = "jenkins-lab"
}
locals{
    name = var.project
}