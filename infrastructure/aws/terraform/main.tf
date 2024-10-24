provider "aws" {
    region = var.region
    # profile = var.profile
}

# 1. VPS on lightsail
data "template_file" "user_data" {
    template = file(var.vps_configuration_script_path)
}

module "myportfolioserver" {
    source = "./modules/lightsail"
    region = var.region
    static_ip_name = "static-ip_myportfolio_application"
    instance_name = "site_myportfolio_application"
    key_pair_name = "my_portfolio_github_actions_terraform"
    site_name = "vip3rtech6069.com"
    user_data = data.template_file.user_data.rendered
    client_name = "myportfolio"
}