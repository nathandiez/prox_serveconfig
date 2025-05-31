#!/usr/bin/env bash
# sanitize-credentials.sh - Replace hardcoded credentials with placeholders for GitHub
set -e

echo "🔒 Sanitizing credentials for GitHub push..."
echo "=========================================="

# Track changes
changes_made=0

# Function to replace and report
replace_and_report() {
    local file="$1"
    local search="$2"
    local replace="$3"
    local description="$4"
    
    if [[ -f "$file" ]] && grep -q "$search" "$file"; then
        sed -i.bak "s|$search|$replace|g" "$file"
        echo "✅ $description in $file"
        ((changes_made++))
        # Remove backup file
        rm -f "$file.bak"
    fi
}

# 1. CRITICAL - Proxmox API Token
replace_and_report "set-proxmox-env.sh" \
    "029ff089-8e40-4bb5-b032-5a7e9bab1cb7" \
    "your-api-token" \
    "Replaced Proxmox API token"

# 2. HIGH - API Key in Config  
replace_and_report "config_files/pico_iot_config.json" \
    "SuperSecretKey123!ChangeMeLater" \
    "your-api-key" \
    "Replaced API key"

# 3. MEDIUM - Internal Network IPs
replace_and_report "set-proxmox-env.sh" \
    "192.168.5.5" \
    "your-proxmox-ip" \
    "Replaced Proxmox IP address"

replace_and_report "config_files/pico_iot_config.json" \
    "192.168.6.132" \
    "your-mqtt-broker-ip" \
    "Replaced MQTT broker IP"

# 4. LOW - Username References
replace_and_report "ansible/ansible.cfg" \
    "remote_user = nathan" \
    "remote_user = your-username" \
    "Replaced username in Ansible config"

# Replace nathan in YAML files (more careful replacement)
for yml_file in ansible/playbooks/*.yml; do
    if [[ -f "$yml_file" ]]; then
        if grep -q "default('nathan')" "$yml_file"; then
            sed -i.bak "s/default('nathan')/default('your-username')/g" "$yml_file"
            echo "✅ Replaced username default in $(basename "$yml_file")"
            ((changes_made++))
            rm -f "$yml_file.bak"
        fi
    fi
done

# 5. LOW - Internal Hostnames
replace_and_report "config_files/pico_iot_config.json" \
    "esdv1-serveconfig" \
    "your-config-server" \
    "Replaced internal hostname"

replace_and_report "ansible/playbooks/serve_config.yml" \
    "nedv1-serveconfig" \
    "your-config-server" \
    "Replaced target hostname"

# 6. Additional Azure URL (make it generic)
replace_and_report "config_files/pico_iot_config.json" \
    "https://iot-azure-api-app-raraid.azurewebsites.net/api/ingest" \
    "https://your-api-endpoint.com/api/ingest" \
    "Replaced Azure API endpoint"

echo ""
echo "=========================================="
if [[ $changes_made -gt 0 ]]; then
    echo "🎉 SUCCESS: Made $changes_made security changes"
    echo ""
    echo "📋 Summary of changes:"
    echo "   • Proxmox API token → 'your-api-token'"
    echo "   • API keys → 'your-api-key'"  
    echo "   • IP addresses → generic placeholders"
    echo "   • Usernames → 'your-username'"
    echo "   • Hostnames → 'your-config-server'"
    echo ""
    echo "✅ Repository is now safe to push to GitHub!"
    echo ""
    echo "📝 Next steps:"
    echo "   1. git add ."
    echo "   2. git commit -m 'Security: Replace hardcoded credentials with placeholders'"
    echo "   3. git push"
else
    echo "ℹ️  No credentials found to replace (already clean?)"
fi
echo "=========================================="