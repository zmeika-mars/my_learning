#!/bin/bash

function check_user {
   check_usr=$(cat /etc/passwd | awk -F ':' '{print $1}' | grep prometheus) 
   if [ prometheus == "$check_usr" ]
   then
     echo "User ${check_usr} exists"
   else
     sudo useradd --no-create-home --shell /bin/false prometheus &&  echo " User prometheus  create"
   fi
}

function check_exists_ndexp {
  if [ -e /usr/local/bin/node_exporter ]
  then
    echo "node exporter already install"; exit 1
  else 
    echo "On server need node exporter"
  fi
}


check_exists_ndexp && sudo wget -O /opt/node_exporter.tar.gz https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz >> /dev/null && \
sudo tar -xzf /opt/node_exporter.tar.gz  -C  /opt/ && sudo mv /opt/node_exporter-1.8.2.linux-amd64 /opt/node_exporter

if [ -d /opt/node_exporter ] 
then
  sudo mv /opt/node_exporter/node_exporter /usr/local/bin/
  check_user
  sudo chown prometheus:prometheus /usr/local/bin/node_exporter
  sudo rm -rf /opt/node_exporter*
fi 



if [ -e /usr/local/bin/node_exporter ]
then 
  touch /home/`whoami`/node_exporter.service
  echo "
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecStart=/usr/local/bin/node_exporter
Restart=always
ExecReload=/bin/kill -HUP


[Install]
WantedBy=multi-user.target" >> /home/`whoami`/node_exporter.service
   sudo mv /home/`whoami`/node_exporter.service /etc/systemd/system/node_exporter.service && sudo chown root:root /etc/systemd/system/node_exporter.service
fi

if [ -s /etc/systemd/system/node_exporter.service ]
then 
  sudo systemctl daemon-reload
  sudo systemctl enable node_exporter.service --now
  systemctl status node_exporter.service  | grep Active | awk -F ':' '{print $1,$2}'
fi 
