variable "cluster_name" {
    type = string
    default = "docplanner-production"  
}

variable "tags" {
    type = map(string)
    default = {
      "env" = "production",
      "cluster" = "docplanner-production"
    }
}

variable "region"{
    type = string
    default = "eu-west-2"
}
