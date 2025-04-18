####### Сбор ID для удаления ВМ #########

if read -p "Enter name: " instance && echo $instance
 then
   read id_instance <<< $(openstack server list --all --name  $instance | awk -F ' ' '{print $2}' | grep -vE "(^#|^$)" | grep -v ID) # ID instance
   if [ $? -eq 0 ]
   then
    read status <<<  $(openstack server show $id_instance | grep -i 'power_state' | awk -F '|' '{print $3}') #status machine (runnign or stoped)
    read id_disk1 <<< $(openstack server show $id_instance | grep -i  "volumes_attached" | grep -i 'id=' | awk -F "'" '{print $2}') # id volume disk1
    read id_disk2 <<< $(openstack server show $id_instance |  grep -i 'id=' | grep -v 'volumes_attached' | awk -F "'" '{print $2}') # id volume disk2
    read id_project <<< $(openstack server show $id_instance | grep -i 'project_id' | awk '{print $4}') # project id
    read id_port <<< $(openstack port list --server $id_instance | grep -i id | awk   '{print $2}' | grep -v ID) # port id
     if [ $? -eq 0 ]
     then
       echo Power_state: $status
       echo ___________JUST INFO ABOUT DISK_____________
       openstack server show $id_instance | grep -i  'id='
       echo ___________NEED INFO FOR DELETE MACHINE_________
       echo ID Instance: $id_instance
       echo ID Disk1: $id_disk1
       echo ID Disk2: $id_disk2
       echo ID Project: $id_project
       echo ID Port: $id_port
     fi
   fi
 fi

#### Удаление ВМ #####

if [ $status == Shutdown ]
then
  openstack server delete $id_instance
  openstack volume delete $id_disk2
  if [ $? == 0 ]
  then
    openstack server show $id_instance 2>&1 | grep -i 'no server'
    openstack volume show $id_disk1 2>&1 | grep -i 'no volume'
    openstack volume show $id_disk2 2>&1 | grep -i 'no volume'
    openstack port show $id_port 2>&1 | grep -i 'no port found'
    if [ $? == 0 ]
    then 
      openstack server list --project $id_project
    fi
  fi
fi



