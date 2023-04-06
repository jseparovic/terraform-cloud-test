
terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
}


variable "private_key" {
  description = "Private Key to use in SSH Connection"
  type        = string
}

variable "password" {
  description = "Password to use in SSH Connection"
  type        = string
}

variable "target_host" {
  description = "The target host"
  type        = string
}

variable "key_file" {
  description = "The private key file"
  type        = string
  default     = "terraform_id_rsa"
}

resource "local_sensitive_file" "private_key" {
  content = var.private_key
  filename = var.key_file
  file_permission = "0600"
}

provider "libvirt" {
  #uri   = "qemu+ssh://root:${var.password}@${var.target_host}/system?sshauth=ssh-password&no_verify=1"
  uri   = "qemu+ssh://root@${var.target_host}/system?sshauth=privkey&keyfile=${var.key_file}&no_verify=1"
}

resource "libvirt_volume" "vm-image" {
  name   = "vm-image"
  source = "/images/vm-image.qcow2"
}

resource "libvirt_volume" "remotehost-qcow2" {
  name     = "remotehost-qcow2"
  format   = "qcow2"
  size     = 17179869184
  base_volume_id = libvirt_volume.vm-image.id
}

resource "libvirt_domain" "remotehost-domain" {
  provider = libvirt
  name     = "vm-a"
  memory   = "8192"
  vcpu     = 4

  disk {
    volume_id = libvirt_volume.remotehost-qcow2.id
  }
}

