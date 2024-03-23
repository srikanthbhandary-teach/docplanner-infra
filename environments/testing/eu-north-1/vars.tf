variable "cluster_name" {
    type = string
    default = "docplanner-testing"  
}

variable "tags" {
    type = map(string)
    default = {
      "env" = "testing",
      "cluster" = "docplanner-testing"
    }
}

variable "region"{
    type = string
    default = "eu-north-1"
}