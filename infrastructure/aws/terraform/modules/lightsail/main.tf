resource "aws_lightsail_static_ip" "myweb" {
  name = var.static_ip_name
}
resource "aws_lightsail_instance" "myweb" {
  name                    = var.instance_name
  availability_zone       = "${var.region}a"
  blueprint_id            = var.ubuntu_version
  bundle_id               = var.bundle_id
  key_pair_name           = var.key_pair_name
  user_data               = var.user_data
  tags = {
        Site = var.site_name
        Client = var.client_name
    }
}
resource "aws_lightsail_static_ip_attachment" "myweb" {
  static_ip_name = "${aws_lightsail_static_ip.myweb.name}"
  instance_name  = "${aws_lightsail_instance.myweb.name}"
}

# Add a domain if var.site_name is not empty
# resource "aws_lightsail_domain" "myweb" {
#   domain_name = var.site_name
# }