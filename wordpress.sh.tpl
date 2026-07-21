#!/bin/bash



# --- FORCEFULLY REMOVE RPM/DNF LOCKS IMMEDIATELY ---
echo "Forcefully removing any active package manager lock files..."
sudo rm -f /var/lib/rpm/.rpm.lock
sudo rm -f /var/run/yum.pid
sudo rm -f /var/cache/dnf/*
sudo rm -f /var/lib/dnf/metadata_lock.pid

# Set a password for ec2-user so you can log in via Serial Console
echo "ec2-user:TemporaryPassword123!" | sudo chpasswd

# Install SSM Agent Force

echo "Installing AWS SSM Agent..."
dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable --now amazon-ssm-agent

#Installing LAMP STACK

sudo dnf update -y
sudo dnf install -y wget httpd php php-fpm php-mysqli php-json php-devel php-gd php-xml php-mbstring

#Starting the PHP and APACHE services

sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl start php-fpm
sudo systemctl enable php-fpm

#Installing wordpress

cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz

#Clean out directory and copying wordpress files

sudo rm -rf /var/www/html/*
sudo cp -r wordpress/* /var/www/html/

#Creating a wp-config.php file

sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

#Injecting Database variables

sudo sed -i "s/database_name_here/${db_name}/g" /var/www/html/wp-config.php
sudo sed -i "s/username_here/${db_user}/g" /var/www/html/wp-config.php
sudo sed -i "s/password_here/${db_password}/g" /var/www/html/wp-config.php
sudo sed -i "s/localhost/${db_endpoint}/g" /var/www/html/wp-config.php



# --- INJECT SSL PROXY FIX FOR ALB ---
# This inserts the proxy rules on line 2, immediately after the <?php tag
sudo sed -i '2i \\n// Detect AWS ALB SSL termination and force HTTPS\nif (isset($_SERVER["HTTP_X_FORWARDED_PROTO"]) \&\& $_SERVER["HTTP_X_FORWARDED_PROTO"] === "https") {\n    $_SERVER["HTTPS"] = "on";\n}\ndefine("FORCE_SSL_ADMIN", true);\n' /var/www/html/wp-config.php


#Setting up correct owners and permission

sudo chown -R apache:apache /var/www/html/
sudo chmod -R 755 /var/www/html/

# Rename the welcome file so Apache ignores it on boot
sudo mv /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/welcome.conf.bak

#Restart Apache

sudo systemctl restart httpd