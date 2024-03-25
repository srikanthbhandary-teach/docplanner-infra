variable "cluster_name" {
  type    = string
  default = "docplanner-production"
}

variable "tags" {
  type = map(string)
  default = {
    "env"     = "production",
    "cluster" = "docplanner-production"
  }
}

variable "region" {
  type    = string
  default = "eu-north-1"
}

variable "cluster_version" {
  type    = string
  default = "1.29"
}
