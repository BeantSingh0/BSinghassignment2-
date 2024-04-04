#!/bin/bash

# Check if script is run with sudo
if [ "$(id -u)" != "0" ]; then
    echo "Error: This script must be run with sudo or as root."
    exit 1
fi

# Function to update netplan configuration
update_netplan_config() {
    cat <<EOL > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
    eth1:
      dhcp4: false
      addresses:
        - 192.168.16.21/24
EOL
    netplan apply
}

# Function to update /etc/hosts file
update_hosts_file() {
    sed -i '/server1/d' /etc/hosts
    echo "192.168.16.21 server1" >> /etc/hosts
}

# Function to install required software
install_software() {
    apt-get update
    apt-get install -y apache2 squid ufw
}

# Function to configure firewall
configure_firewall() {
    ufw allow in on eth0 to any port 22 proto tcp  # SSH on mgmt network
    ufw allow in on eth1 to any port 80 proto tcp  # HTTP on 192.168.16 network
    ufw allow in on eth1 to any port 3128 proto tcp  # Squid web proxy on 192.168.16 network
    ufw --force enable
}

# Function to create user accounts and configure SSH
create_users() {
    # Define SSH public keys
    dennis_public_key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm"
    aubrey_public_key="ssh-rsa <aubrey_public_key_here>"
    captain_public_key="ssh-rsa <captain_public_key_here>"
    snibbles_public_key="ssh-rsa <snibbles_public_key_here>"
    brownie_public_key="ssh-rsa <brownie_public_key_here>"
    scooter_public_key="ssh-rsa <scooter_public_key_here>"
    sandy_public_key="ssh-rsa <sandy_public_key_here>"
    perrier_public_key="ssh-rsa <perrier_public_key_here>"
    cindy_public_key="ssh-rsa <cindy_public_key_here>"
    tiger_public_key="ssh-rsa <tiger_public_key_here>"
    yoda_public_key="ssh-rsa <yoda_public_key_here>"

    # Create user accounts and configure SSH keys
    for user in dennis aubrey captain snibbles brownie scooter sandy perrier cindy tiger yoda; do
        if ! id "$user" &>/dev/null; then
            useradd -m -s /bin/bash "$user"
            mkdir -p "/home/$user/.ssh"
            echo "$dennis_public_key" > "/home/$user/.ssh/authorized_keys"
            chown -R "$user:$user" "/home/$user/.ssh"
            chmod 700 "/home/$user/.ssh"
            chmod 600 "/home/$user/.ssh/authorized_keys"
        fi
    done

    # Configure sudo access for dennis
    echo "dennis ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/dennis
    chmod 440 /etc/sudoers.d/dennis
}


# Main script execution
echo "=== Starting assignment2.sh ==="

# Update netplan configuration
echo "Updating netplan configuration..."
update_netplan_config
echo "Netplan configuration updated successfully."

# Update /etc/hosts file
echo "Updating /etc/hosts file..."
update_hosts_file
echo "/etc/hosts file updated successfully."

# Install required software
echo "Installing required software..."
install_software
echo "Required software installed successfully."

# Configure firewall
echo "Configuring firewall..."
configure_firewall
echo "Firewall configured successfully."

# Create user accounts and configure SSH
echo "Creating user accounts and configuring SSH..."
create_users
echo "User accounts created and SSH configured successfully."

echo "=== assignment2.sh completed successfully ==="
