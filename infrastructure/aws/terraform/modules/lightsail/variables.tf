variable "region" {
  type = string  
}

variable "static_ip_name" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "key_pair_name" {
  type = string
}

variable "site_name" {
    type = string
}

variable "ubuntu_version" {
    type = string
    default = "ubuntu_24_04"
}

variable "bundle_id" {
    type = string
    default = "small_3_1"
}

variable user_data {
    type = string
}

variable client_name {
    type = string
}

