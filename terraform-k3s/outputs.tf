###############################################################
# outputs.tf — Что выводится после terraform apply
###############################################################

output "vm_info" {
  description = "Информация о созданных ВМ"
  value = {
    for name, vm in proxmox_vm_qemu.vm : name => {
      vmid = vm.vmid
      name = vm.name
      ip   = var.vm_definitions[name].ip
      role = var.vm_definitions[name].role
    }
  }
}

output "control_plane_ip" {
  description = "IP адрес Control Plane ноды"
  value = {
    for name, vm in proxmox_vm_qemu.vm :
    name => var.vm_definitions[name].ip
    if var.vm_definitions[name].role == "control-plane"
  }
}

output "worker_ips" {
  description = "IP адреса Worker нод"
  value = {
    for name, vm in proxmox_vm_qemu.vm :
    name => var.vm_definitions[name].ip
    if var.vm_definitions[name].role == "worker"
  }
}

output "gitlab_ip" {
  description = "IP адрес GitLab VM"
  value = {
    for name, vm in proxmox_vm_qemu.vm :
    name => var.vm_definitions[name].ip
    if var.vm_definitions[name].role == "gitlab"
  }
}

output "k3s_install_hint" {
  description = "Следующий шаг — установка k3s"
  value       = "После apply запусти: bash terra_kube/install-k3s.sh"
}
