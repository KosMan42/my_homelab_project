###############################################################
# main.tf — K3s кластер на Proxmox
# Топология: задаётся через vm_definitions в terraform.tfvars
###############################################################

resource "proxmox_vm_qemu" "vm" {
  for_each = var.vm_definitions

  name        = each.key
  vmid        = each.value.vmid
  target_node = var.target_node

  clone      = var.template
  full_clone = true

  cpu {
    sockets = 1
    cores   = each.value.cores
    type    = "x86-64-v2-AES"
  }

  bios   = "seabios"
  memory = each.value.memory
  scsihw = "virtio-scsi-single"

  serial {
    id = 0
  }

  disks {
    scsi {
      scsi0 {
        disk {
          storage  = var.vm_storage
          size     = "${each.value.disk}G"
          backup   = false
          discard  = true  # освобождать место при удалении файлов (trim)
          iothread = true  # отдельный поток I/O на диск — лучше производительность
        }
      }
    }

    ide {
      ide2 {
        cloudinit {
          storage = "data"  # хранилище для Cloud-Init образа
        }
      }
    }
  }

  network {
    id       = 0
    model    = "e1000"
    bridge   = "vmbr0"
    firewall = true
  }

  # Cloud-Init: пользователь, пароль, ключ, IP
  ciuser     = var.ci_user
  cipassword = var.ci_password
  sshkeys    = var.ssh_public_key
  ipconfig0  = "ip=${each.value.ip}/24,gw=${var.gateway}"

  agent    = 1      # QEMU guest agent — нужен для получения IP Terraform-ом
  boot     = "order=scsi0"
  onboot   = false  # не запускать автоматически при старте Proxmox
  vm_state = "running"
  tags     = "terraform,k3s,${each.value.role}"
}
