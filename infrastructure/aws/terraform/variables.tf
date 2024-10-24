variable "region" {
  type = string
  default = "ap-south-1"
}

variable "profile" {
  type = string
  default = "default"
}

variable "vps_configuration_script_path" {
    type = string
    default = "./configuration/scripts/vps_configuration_script.sh"
}