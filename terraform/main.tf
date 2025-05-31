# main.tf

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.76"
    }
  }
}

# Variable to control whether to run provisioners
variable "enable_local-exec" {
  description = "Whether to run the local-exec provisioners (IP detection and Ansible)"
  type        = bool
  default     = false
}

provider "proxmox" {
  endpoint = "https://192.168.5.6:8006"
  insecure = true
}

module "nedv1-serveconfig-vm" {
  source = "./vm-module"
  vm_name     = "nedv1-serveconfig"
  mac_address = "52:54:00:12:23:21"
  cores       = 1
  memory      = 1024
}

# Wait for VM to get IP and be accessible
resource "time_sleep" "wait_for_vm" {
  depends_on = [module.nedv1-serveconfig-vm]
  create_duration = "60s"
}

# Run Ansible playbook after VM is ready (conditional)
resource "null_resource" "run_ansible" {
  count = var.enable_local-exec ? 1 : 0

  depends_on = [
    time_sleep.wait_for_vm
  ]

  triggers = {
    vm_id = module.nedv1-serveconfig-vm.vm_id
  }

  # Wait for SSH and update inventory
  provisioner "local-exec" {
    command = "./scripts/wait-for-ssh.sh"
  }

  # Run Ansible playbook
  provisioner "local-exec" {
    command = "./scripts/run-ansible.sh"
  }

  # Verify deployment
  provisioner "local-exec" {
    command = "./scripts/verify-deployment.sh"
  }
}

# Outputs - find the real IP from the arrays
locals {
  all_ips = try(module.nedv1-serveconfig-vm.ipv4_addresses, [])
  
  valid_ip = try(
    flatten([
      for ip_array in local.all_ips : [
        for ip in ip_array : ip
        if ip != "127.0.0.1" && ip != "172.17.0.1" && ip != "" && ip != null
      ]
    ])[0],
    null
  )
}

output "vm_id" {
  value = module.nedv1-serveconfig-vm.vm_id
  description = "Proxmox VM ID"
}

output "vm_ip" {
  value = local.valid_ip != null ? local.valid_ip : "Not yet available - VM may still be starting"
  description = "VM IP address"
}

output "service_url" {
  value = local.valid_ip != null ? "http://${local.valid_ip}:5000" : "Not yet available - VM may still be starting"
  description = "Configuration service URL"
}

output "config_endpoint" {
  value = local.valid_ip != null ? "http://${local.valid_ip}:5000/pico_iot_config.json" : "Not yet available - VM may still be starting"
  description = "Configuration endpoint URL"
}