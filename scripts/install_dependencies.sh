#!/bin/bash

set -e

CATALINA_HOME=/usr/share/tomcat10.0.8-codedeploy
TOMCAT_VERSION=10.0.8

# Tar file name
TOMCAT_CORE_TAR_FILENAME="apache-tomcat-$TOMCAT_VERSION.tar.gz"
# Download URL for Tomcat10 core
TOMCAT_CORE_DOWNLOAD_URL="https://archive.apache.org/dist/tomcat/tomcat-10/v10.0.8/bin/apache-tomcat-10.0.8.tar.gz"
# The top-level directory after unpacking the tar file
TOMCAT_CORE_UNPACKED_DIRNAME="apache-tomcat-$TOMCAT_VERSION"


# Check whether there exists a valid instance
# of Tomcat installed at the specified directory
[[ -d $CATALINA_HOME ]] && { service tomcat status; } && {
    echo "Tomcat10 is already installed at $CATALINA_HOME. Skip reinstalling it."
    exit 0
}

# Clear install directory
if [ -d $CATALINA_HOME ]; then
    rm -rf $CATALINA_HOME
fi
mkdir -p $CATALINA_HOME

# Download the latest Tomcat10 version
cd /opt
{ which wget; } || { apt install wget; }
wget $TOMCAT_CORE_DOWNLOAD_URL
if [[ -d /opt/$TOMCAT_CORE_UNPACKED_DIRNAME ]]; then
    rm -rf /opt/$TOMCAT_CORE_UNPACKED_DIRNAME
fi
tar xzvf $TOMCAT_CORE_TAR_FILENAME

# Copy over to the CATALINA_HOME
cp -r /opt/$TOMCAT_CORE_UNPACKED_DIRNAME/* $CATALINA_HOME

# Install Java if not yet installed
{ which java; } || { apt install default-jdk -y; }

# Create the service tomcat.service script
cat > /etc/systemd/system/tomcat.service <<'EOF'
[Unit]
Description=Tomcat
After=network.target

[Service]
Type=forking

User=root
Group=root

Environment="JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
exit 0
EOF

# Change permission mode for the service script
chmod 755 /etc/systemd/system/tomcat.service
