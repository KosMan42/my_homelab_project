###############################################################
# variables.tf — K3s кластер на Proxmox
###############################################################

# --- Proxmox подключение ---

variable "pm_api_url" {
  description = "URL Proxmox API, например: https://192.168.1.122:8006/api2/json"
  type        = string
}

variable "pm_token_id" {
  description = "API Token ID, например: root@pam!terraform"
  type        = string
  sensitive   = true
}

variable "pm_token_secret" {
  description = "API Token Secret (UUID)"
  type        = string
  sensitive   = true
}

# --- Proxmox инфраструктура ---

variable "target_node" {
  description = "Имя ноды Proxmox (видно в левой панели)"
  type        = string
  default     = "srv"
}

variable "template" {
  description = "Имя Cloud-Init шаблона в Proxmox"
  type        = string
  default     = "srv-cloud-init"
}

variable "vm_storage" {
  description = "Хранилище для дисков ВМ"
  type        = string
  default     = "storage_VM"
}

# --- Cloud-Init ---

variable "ssh_public_key" {
  description = "SSH публичный ключ для Cloud-Init (содержимое .pub файла)"
  type        = string
}

variable "ci_user" {
  description = "Имя пользователя Cloud-Init внутри ВМ"
  type        = string
  default     = "user"
}

variable "ci_password" {
  description = "Пароль пользователя Cloud-Init внутри ВМ"
  type        = string
  sensitive   = true
}

# --- Определения ВМ ---

variable "vm_definitions" {
  description = "Map всех ВМ кластера: имя → параметры"
  type = map(object({
    vmid   = number
    ip     = string
    memory = number  # в мегабайтах
    cores  = number
    role   = string  # "control-plane", "worker" или "gitlab"
    disk   = number  # размер диска в GB
  }))
}

variable "gateway" {
  description = "Шлюз по умолчанию"
  type        = string
  default     = "192.168.1.1"
}
