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

function check_install_prom {
  if [ -e /usr/local/bin/prometheus ]
  then
    echo "PROMETHEUS already install"; exit 1
  else
    echo "On server need prometheus install"
  fi
}


check_install_prom && sudo wget -O /opt/prometheus.tar.gz https://github.com/prometheus/prometheus/releases/download/v2.55.1/prometheus-2.55.1.linux-amd64.tar.gz && \
sudo tar -xzf /opt/prometheus.tar.gz  -C  /opt/ && sudo mv /opt/prometheus-2.55.1.linux-amd64 /opt/prometheus 

if [ -d /opt/prometheus ]
then
  check_user
  sudo mkdir /etc/prometheus
  sudo mkdir /var/lib/prometheus
  sudo chown prometheus:prometheus /etc/prometheus
  sudo chown prometheus:prometheus /var/lib/prometheus
  sudo chown -R prometheus:prometheus /opt/prometheus
  sudo mv /opt/prometheus/prometheus.yml /etc/prometheus/ && sudo mv /opt/prometheus/console* /etc/prometheus/
  sudo mv /opt/prometheus/prom* /usr/local/bin/
  sudo touch /etc/systemd/system/prometheus.service
fi

if [ -e /etc/systemd/system/prometheus.service ]
then
  touch /home/`whoami`/prometheus.service
  sudo echo "	
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecStart=/usr/local/bin/prometheus     --config.file=/etc/prometheus/prometheus.yml     --storage.tsdb.path=/var/lib/prometheus/data     --web.console.templates=/etc/prometheus/consoles     --web.console.libraries=/etc/prometheus/console_libraries
Restart=always
ExecReload=/bin/kill -HUP 


[Install]
WantedBy=multi-user.target" >> /home/`whoami`/prometheus.service
   sudo mv /home/`whoami`/prometheus.service /etc/systemd/system/prometheus.service && sudo chown root:root /etc/systemd/system/prometheus.service
fi 	

if [ -s /etc/systemd/system/prometheus.service ]
then
  sudo systemctl daemon-reload
  sudo systemctl enable prometheus.service --now
  systemctl status prometheus.service  | grep Active | awk -F ':' '{print $1,$2}'
fi



