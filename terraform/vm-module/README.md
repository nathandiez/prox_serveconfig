# Proxmox Configuration Server

A complete Infrastructure-as-Code solution that automatically deploys a configuration server on Proxmox using Terraform and Ansible. The server hosts JSON configuration files for IoT devices over HTTP.

## 🎯 Project Overview

This project creates a lightweight VM that serves configuration files to IoT devices (Raspberry Pi Pico, ESP32, etc.) over HTTP. It demonstrates modern DevOps practices with infrastructure automation, configuration management, and integrated deployment workflows.

**Key Features:**
- 🏗️ **Infrastructure as Code** - Terraform manages VM lifecycle
- ⚙️ **Configuration Management** - Ansible handles software setup
- 🔄 **Integrated Deployment** - Single command deploys everything
- 📡 **HTTP Configuration Server** - Serves JSON configs to IoT devices
- 🛡️ **Production Ready** - Proper error handling and verification

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Your Machine  │    │   Proxmox Host   │    │  IoT Devices    │
│                 │    │                  │    │                 │
│ terraform apply │───▶│  Ubuntu 22.04 VM │◀───│ GET /config.json│
│                 │    │  Port 5000       │    │                 │
│ ansible-playbook│    │  Flask Server    │    │ Pico, ESP32,etc │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 📁 Project Structure

```
prox_servconfig/
├── terraform/                 # Infrastructure definitions
│   ├── main.tf               # Main Terraform configuration
│   ├── scripts/              # Deployment automation scripts
│   │   ├── wait-for-ssh.sh   # SSH readiness checker
│   │   ├── run-ansible.sh    # Ansible execution
│   │   └── verify-deployment.sh # Health verification
│   └── vm-module/            # Reusable VM module
├── ansible/                  # Configuration management
│   ├── playbooks/
│   │   └── serve_config.yml  # Main server setup playbook
│   └── inventory/
│       └── hosts             # Dynamic inventory (auto-generated)
├── config_files/             # JSON configurations served by the server
│   ├── pico_iot_config.json  # Raspberry Pi Pico configuration
│   ├── eiot_config.json      # ESP32 IoT configuration  
│   └── cooker_config.json    # Custom device configuration
├── src/                      # Application source code
│   ├── serve_config.py       # Flask configuration server
│   ├── requirements.txt      # Python dependencies
│   └── Dockerfile           # Container definition
├── deploy.sh                 # Quick deployment script
├── destroy.sh               # Clean teardown script
└── README.md                # This file
```

## 🚀 Quick Start

### Prerequisites

- **Proxmox VE** running and accessible
- **Terraform** v1.0+ installed
- **Ansible** v2.9+ installed  
- **jq** command-line JSON processor
- **SSH access** to Proxmox host

### 1. Environment Setup

```bash
# Clone and navigate to project
git clone <your-repo-url>
cd prox_servconfig

# Set Proxmox credentials
cp set-proxmox-env.sh.example set-proxmox-env.sh
nano set-proxmox-env.sh  # Add your credentials
source set-proxmox-env.sh
```

### 2. Deploy Everything

```bash
# Quick deployment (recommended)
./deploy.sh

# OR manual step-by-step
cd terraform
terraform init
terraform apply -var="enable_local-exec=true" -auto-approve
```

### 3. Verify Deployment

```bash
# Check service status
curl http://<VM_IP>:5000/ping

# Get configuration
curl http://<VM_IP>:5000/pico_iot_config.json
```

## 🛠️ Configuration Files

The server hosts these configuration endpoints:

| Endpoint                | Description                | Use Case                        |
| ----------------------- | -------------------------- | ------------------------------- |
| `/pico_iot_config.json` | Raspberry Pi Pico settings | IoT sensors, data collection    |
| `/eiot_config.json`     | ESP32 IoT configuration    | WiFi credentials, MQTT settings |
| `/cooker_config.json`   | Custom device settings     | Specialized hardware configs    |

### Example Configuration Structure

```json
{
  "device_name": "pico_sensor_01",
  "wifi_ssid": "IoT_Network",
  "wifi_password": "secure_password",
  "mqtt_broker": "192.168.1.100",
  "mqtt_port": 1883,
  "sensor_interval": 30,
  "deep_sleep_enabled": true
}
```

## 🔧 Advanced Usage

### Updating Configurations

```bash
# Edit configuration files
nano config_files/pico_iot_config.json

# Deploy changes
./update_configs.sh
```

### Development Mode

```bash
# Deploy without provisioners (faster for testing)
cd terraform
terraform apply -auto-approve

# Run provisioners separately
terraform apply -var="enable_local-exec=true" -auto-approve
```

### Scaling and Customization

```bash
# Modify VM resources
nano terraform/vm-module/variables.tf

# Add new configuration files
cp config_files/pico_iot_config.json config_files/new_device_config.json
# Update ansible/playbooks/serve_config.yml to include new file
```

## 🛡️ Key Components

### Terraform Infrastructure

- **VM Module**: Reusable Proxmox VM definition
- **Local-exec Provisioners**: Automated deployment pipeline
- **State Management**: Tracks infrastructure changes
- **Output Values**: Provides service URLs and IP addresses

### Ansible Configuration

- **Idempotent Playbooks**: Safe to run multiple times
- **Dynamic Inventory**: Automatically updated with VM IP
- **Service Management**: systemd service for reliability
- **Docker Deployment**: Containerized for consistency

### Deployment Automation

- **SSH Readiness**: Waits for VM to be accessible
- **Health Verification**: Tests endpoints before completion
- **Error Handling**: Graceful failure recovery
- **Timing Coordination**: Proper dependency management

## 🎛️ Environment Variables

Required environment variables (set in `set-proxmox-env.sh`):

```bash
export PROXMOX_VE_ENDPOINT="https://your-proxmox-host:8006"
export PROXMOX_VE_USERNAME="your-username@pam"
export PROXMOX_VE_PASSWORD="your-password"
export PROXMOX_VE_INSECURE="true"  # For self-signed certificates
```

## 🚨 Troubleshooting

### Common Issues

**VM Creation Fails**
```bash
# Check Proxmox connectivity
curl -k $PROXMOX_VE_ENDPOINT/api2/json/version

# Verify credentials
source set-proxmox-env.sh && env | grep PROXMOX
```

**SSH Connection Issues**
```bash
# Manual SSH test
ssh nathan@<VM_IP>

# Check VM console in Proxmox web interface
```

**Service Not Responding**
```bash
# Check service status on VM
ssh nathan@<VM_IP> 'sudo systemctl status serve-config'

# View service logs
ssh nathan@<VM_IP> 'sudo journalctl -u serve-config -f'
```

**Ansible Fails**
```bash
# Run Ansible manually
cd ansible
ansible-playbook -i inventory/hosts playbooks/serve_config.yml -v
```

### Debug Commands

```bash
# Show Terraform state
terraform show

# Test scripts individually  
cd terraform
./scripts/wait-for-ssh.sh
./scripts/verify-deployment.sh

# Check Ansible connectivity
ansible all -i inventory/hosts -m ping
```

## 🧹 Cleanup

```bash
# Complete teardown
./destroy.sh

# OR manual cleanup
cd terraform
terraform destroy -auto-approve
```

## 🔄 Development Workflow

1. **Make Changes**: Edit configuration files or code
2. **Test Locally**: Use `docker run` to test Flask app
3. **Deploy**: Run `./deploy.sh` or targeted terraform commands
4. **Verify**: Check endpoints and service health
5. **Iterate**: Repeat as needed

## 📚 Learn More

This project demonstrates several DevOps concepts:

- **Infrastructure as Code** with Terraform
- **Configuration Management** with Ansible  
- **Containerization** with Docker
- **Service Discovery** and health checks
- **GitOps** workflows and automation

Perfect for learning modern infrastructure automation while solving a real IoT configuration challenge!

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Happy automating!** 🚀 If you run into issues, check the troubleshooting section or open an issue.