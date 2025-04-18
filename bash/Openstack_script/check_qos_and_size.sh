# id инстанса 
openstack server list --all --name p0spbc-pgc007lk | grep -vie '^$'  | awk '{print $2}' | grep -vie '^$' | grep -vi "ID"


# id инстанса V2
idinst <<< $(openstack server show $id_instance  | grep -iw id | grep -vi 'id=' | awk '{print $4}')
# id project
odproj <<< openstack server show $id_instance | grep -iw 'project_id' | awk '{print $4}'

QoS на сервере 
openstack volume list --project $id_project --long -c 'Type' -c 'Attached to' | grep $id_instance



if read -p "Enter name: " instance && echo $instance
 then
    read id_instance <<< $(openstack server list --all --name  $instance | awk -F ' ' '{print $2}' | grep -vE "(^#|^$)" | grep -v ID) # ID instance
    if [ $? == 0 ]
    then
       read odproj <<< $(openstack server show $id_instance | grep -iw 'project_id' | awk '{print $4}')
       if [ $? == 0 ]
       then 
	  echo -e "\n"$instance
          openstack volume list --project $odproj --long -c 'Type' -c 'Attached to' -c 'Size' | grep $id_instance
	  echo -e "\n"
       fi
    fi
  fi
       



qossrv="$PWD/srvlist.txt"

while read instance; do
   if [ -n "$instance" ];
   then
      read id_instance <<< $(openstack server list --all --name  $instance | awk -F ' ' '{print $2}' | grep -vE "(^#|^$)" | grep -v ID) # ID instancei
      if [ $? -eq  0 ] && [ -n $id_instance ]
      then
         read odproj <<< $(openstack server show $id_instance  | grep -iw 'project_id' | awk '{print $4}')
         if [ $? -eq 0  ] && [ -n "$odproj" ]
         then
           echo -e "\n"$instance
           openstack volume list --project $odproj --long -c 'Type' -c 'Attached to' -c 'Size' | grep $id_instance
           echo -e "\n"
           sed -i "s/${instance}//g" $PWD/srvlist.txt && sed -ie '/^[[:space:]]*$/d' "$PWD/srvlist.txt"
         else
           echo "$instance not found in these contradictions" > /dev/null
         fi
       fi
    fi
done < "$qossrv"





   
qossrv="$PWD/srvlist.txt"

while read instance; do
   if [ -n "$instance" ]; then
       
    read id_instance <<< $(openstack server list --all --name  $instance | awk -F ' ' '{print $2}' | grep -vE "(^#|^$)" | grep -v ID) # ID instance
    if [ $? == 0 ]
    then
       read odproj <<< $(openstack server show $id_instance | grep -iw 'project_id' | awk '{print $4}')
       if [ $? == 0 ]
       then 
	  echo -e "\n"$instance
          openstack volume list --project $odproj --long -c 'Type' -c 'Attached to' -c 'Size' | grep $id_instance
	  echo -e "\n"
          sed -i "s/${instance}//g" $PWD/srvlist.txt && sed -ie '/^[[:space:]]*$/d' "$PWD/srvlist.txt"
          if [ $? != 0 ]
          then
            echo "$instance not found in these contradictions"
          fi
       fi
    fi
  fi
done < "$qossrv"
   



