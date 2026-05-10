# terraform-k3s

Terraform-конфигурация для автоматического развёртывания K3s-кластера на Proxmox с CI/CD через GitLab.

## Топология

| VM            | RAM   | CPU | Диск  | Роль          |
|---------------|-------|-----|-------|---------------|
| k3s-cp        | 4 GB  | 2   | 32 GB | control-plane |
| k3s-worker-01 | 2 GB  | 2   | 32 GB | worker        |
| k3s-worker-02 | 2 GB  | 2   | 32 GB | worker        |
| srv-gitlab    | 12 GB | 4   | 100 GB| gitlab        |

## Требования

- Terraform >= 1.13.0
- Proxmox с настроенным API-токеном
- Cloud-Init шаблон ВМ в Proxmox
- SSH-ключи: приватный и публичный

## Переменные

### Несекретные (`cluster.tfvars`, коммитится в git)

| Переменная      | Описание                              |
|-----------------|---------------------------------------|
| `ci_user`       | Имя пользователя Cloud-Init           |
| `target_node`   | Имя ноды Proxmox                      |
| `template`      | Имя Cloud-Init шаблона                |
| `vm_storage`    | Хранилище для дисков ВМ               |
| `gateway`       | Шлюз по умолчанию                     |
| `vm_definitions`| Топология кластера (vmid, ip, ресурсы)|

### Секретные (`terraform.tfvars`, не коммитится)

| Переменная       | Описание                    |
|------------------|-----------------------------|
| `pm_api_url`     | URL Proxmox API             |
| `pm_token_id`    | ID токена Proxmox           |
| `pm_token_secret`| UUID токена Proxmox         |
| `ci_password`    | Пароль пользователя в ВМ   |
| `ssh_public_key` | Публичный SSH-ключ          |

## CI/CD Pipeline

Pipeline запускается автоматически при каждом пуше и MR:

| Стейдж     | Команда                                   | Описание                  |
|------------|-------------------------------------------|---------------------------|
| `validate` | `terraform init && terraform validate`    | Проверка синтаксиса       |
| `plan`     | `terraform plan -var-file=cluster.tfvars` | Предварительный просмотр  |

Секретные переменные передаются через GitLab CI/CD Variables с префиксом `TF_VAR_`.

## Быстрый старт

```bash
# 1. Создать terraform.tfvars с секретами (см. таблицу выше)

# 2. Создать ВМ
terraform init
terraform plan -var-file=cluster.tfvars
terraform apply -var-file=cluster.tfvars
```

## Структура

```
├── main.tf          # ресурс proxmox_vm_qemu (for_each по vm_definitions)
├── variables.tf     # объявления переменных
├── outputs.tf       # IP по роли (control-plane / worker)
├── providers.tf     # провайдер Telmate/proxmox
├── cluster.tfvars   # несекретные параметры кластера
└── .gitlab-ci.yml   # pipeline: validate + plan
```

## Настройка API-токена в Proxmox

1. Datacenter → Permissions → API Tokens → Add
2. Снять галку «Privilege Separation»
3. Скопировать UUID токена в переменную `pm_token_secret`
