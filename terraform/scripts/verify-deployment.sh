#!/usr/bin/env bash
# verify-deployment.sh - Verify the deployment is working
set -e

echo "Verifying deployment..."
sleep 5

# Use same IP detection method as SSH provisioner
get_ip() {
  # Method 1: Extract from terraform state directly
  local ip=$(terraform show -json 2>/dev/null | jq -r '.values.root_module.child_modules[].resources[] | select(.type=="proxmox_virtual_environment_vm") | .values.ipv4_addresses[0][0]' 2>/dev/null || echo "")
  
  # Check if it's valid
  if [ -n "$ip" ] && [ "$ip" != "null" ] && [ "$ip" != "127.0.0.1" ]; then
    echo "$ip"
    return 0
  fi
  
  # Method 2: Extract from terraform show text output
  ip=$(terraform show 2>/dev/null | grep -A 5 "ipv4_addresses" | grep -o -E '([0-9]{1,3}\.){3}[0-9]{1,3}' | grep -v '127.0.0.1' | head -n 1)
  
  if [ -n "$ip" ]; then
    echo "$ip"
    return 0
  fi
  
  # Method 3: Try DNS resolution as fallback
  ip=$(ping -c 1 nedv1-serveconfig.local 2>/dev/null | head -n 1 | grep -o -E '([0-9]{1,3}\.){3}[0-9]{1,3}' || echo "")
  
  if [ -n "$ip" ]; then
    echo "$ip"
    return 0
  fi
  
  echo ""
  return 1
}

IP=$(get_ip)

if [ -n "$IP" ] && [ "$IP" != "127.0.0.1" ]; then
  echo "Testing service at http://$IP:5000/ping"
  if curl -f -s http://"$IP":5000/ping; then
    echo ""
    echo "✅ Basic health check successful!"
    
    # Test the config endpoint
    echo ""
    echo "Testing configuration endpoint..."
    echo "curl http://$IP:5000/pico_iot_config.json | head -10:"
    echo "---"
    curl -f -s http://"$IP":5000/pico_iot_config.json | head -10
    echo "---"
    echo ""
    # echo "✅ Deployment verification successful!"
    # echo "✅ Service is running at: http://$IP:5000"
    # echo "✅ Config endpoint: http://$IP:5000/pico_iot_config.json"
    # echo "✅ Server IP: $IP"
  else
    echo ""
    echo "❌ Health check failed - service may still be starting"
    echo "ℹ️  You can manually test: curl http://$IP:5000/ping"
    echo "ℹ️  Server IP: $IP"
    exit 1
  fi
else
  echo "❌ Could not determine valid IP for verification"
  exit 1
fi