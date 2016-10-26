# Token
variable "digitalocean_keys" { }
variable "digitalocean_domain" { }
variable "digitalocean_region" { default = "lon1" }
variable "digitalocean_droplet_size" { default = "1gb" }
variable "count" { default=2 }

data "template_file" "puppetmaster_user_data" {
  template = "${file("${path.module}/templates/puppet.tpl")}"
  count = "${var.count}"
  vars {
    domain = "${var.digitalocean_domain}"
  }
}

resource "digitalocean_droplet" "puppetmaster" {
  count = "${var.count}"
  image = "centos-7-x64"
  name  = "puppetmaster-${count.index + 1}"
  region = "${var.digitalocean_region}"
  size = "${var.digitalocean_droplet_size}"
  private_networking = true
  ssh_keys = [ "${var.digitalocean_keys}" ]
  user_data = "${element(data.template_file.puppetmaster_user_data.*.rendered,count.index + 1)}"
}

resource "digitalocean_record" "puppetmaster" {
  count  = "${var.count}"
  domain = "${var.digitalocean_domain}"
  type   = "A"
  name   = "puppetmaster-${count.index+1}"
  value  = "${element(digitalocean_droplet.puppetmaster.*.ipv4_address_private, count.index)}"
}

output "addresses" {
  value = ["${digitalocean_droplet.puppetmaster.*.ipv4_address}"]
}