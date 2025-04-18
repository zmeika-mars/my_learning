openstack server list --all --name $name_inc
openstack volume create --type ceph_hdd_ir700@1000iw200@300 --size 8 SRT6396817
openstack server add volume 7e8c73e3-2d6b-45c0-ac6a-0704a925ba1d 409871b4-7a29-4455-94ec-9d9f9be6bf2e --device /dev/sdc


### Добавление диска ####

if read -p "Enter name: " name_inc && echo $name_inc
then 
   read id_instance <<< $(openstack server list --all --name  $name_inc | awk -F ' ' '{print $2}' | grep -vE "(^#|^$)" | grep -v ID) # ID instance
   openstack server show $id_instance |  grep -i 'id='
   if [ $? == 0 ]
   then
     openstack volume type list | grep -vi false | awk '{print $4}' | grep -vi name | grep -vE "(^#|^$)"
     if [ $? == 0 ]
     then
       read -p "select volume type: " voltype && echo $voltype
       read -p "select volume size: " volsize && echo $volsize  
       read -p "select volume name: " volname && echo $volname
       openstack volume create --type $voltype --size $volsize $volname
       if [ $? == 0 ]
       then
         read id_newdisk <<< $(openstack volume list --all --name $volname | awk '{print $2,$12}'  | grep -v '|' | grep -vE "(^#|^$)" | grep -i $id_instance | awk '{print $1}')
         read -p "select letter disk: " letter && echo $letter
         openstack server add volume $id_instance $id_newdisk --device /dev/sd$letter
         if [ $? == 0 ]
         then 
           openstack server show $id_instance |  grep -i 'id='
         fi
       fi
     fi
   fi 
fi

        

     
     
     
   

