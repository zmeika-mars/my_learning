#!/bin/bash
second_server="user@192.168.0.2  -i /home/user/.ssh/lin_rb_id"

function connect {
  ssh ${second_server} $1
}

function final_autocomplete {
    COMPREPLY=(add_group add_users off_group on_group help)
    cur="${COMP_WORDS}"
    subcommands_1="add_group add_users off_group on_group help"

     if [[ ${COMP_CWORD} == 1 ]]
    then
        COMPREPLY=( $(compgen -W "${subcommands_1}" -- ${cur}) )
        return 0
    fi
}

complete -F final_autocomplete manage.sh

function check_arguments {
   if [ $# -eq 0 ];
   then 
     echo "HELP (HOWTO)"
     echo 
     echo "Options add_group witch argument name group, create group"
     echo "Example: ./manage.sh add_group <group_name>"
     echo "Options add_user with argument group name and user plus equired number of users."
     echo "Example: ./manage.sh add_users <group_name> <user_name> <count_users>"
     echo "Block all users in specified group"
     echo "Example: ./manage.sh off_group <group_name>"
     echo "Unblock all users in specified group"
     echo "Example: ./manage.sh on_group <group_name>"
   fi
}

function create_user {
     local count=1
     local count2=$3
     local group=$1
     local user_name=$2
     if cat /etc/group | grep -w ${group} &> /dev/null
     then
       while [[ ${count} -le ${count2} ]]
       do
         for number in "$(( count++ ))"
         do
           password=`cat /dev/urandom | tr -dc "A-Za-z0-9" | head -c 10 | xargs echo;`
	   sudo useradd -N -m -s /bin/bash ${user_name}${number}
	   sudo usermod -a -G ${group} ${user_name}${number} 
	   echo ${user_name}${number}:${password} | sudo chpasswd 
           echo ${user_name}${number} ${password} 

	   #sync remote host
	   connect "sudo useradd -N -m -s /bin/bash ${user_name}${number}"
	   connect "sudo usermod -a -G ${group} ${user_name}${number}"
	   connect "echo ${user_name}${number}:${password} | sudo chpasswd"
         done
       done
     else
       echo group ${group} not exists!
     fi
}

function groups {
  local add_group=$@

  if [ $# -eq 0 ]
  then
    echo enter group name; exit 1
  elif cat /etc/group | grep -w ${add_group} &> /dev/null 
  then
    echo group ${add_group} not already exists; exit 2
  else
    sudo groupadd ${add_group} 2> /dev/null && echo "group ${add_group} succesfull create"
    connect "sudo groupadd ${add_group} 2> /dev/null"
  fi
}


function group_off {
   local group=$1 
   if cat /etc/group | grep -w ${group} &> /dev/null
   then
     echo "group ${group} exists"
     for user in $(cat /etc/group | grep -w ${group} | awk -F ':' '{print $4}' | tr  ',' ' '); 
     do 
       sudo passwd -l ${user} > /dev/null; 
       echo "${user} block"; 
       connect "sudo passwd -l ${user} > /dev/null";
     done
   else
     echo group not exist; exit 3 
   fi

}

function group_on {
   local group=$1 
   if cat /etc/group | grep -w ${group} &> /dev/null
   then
     echo "group ${group} exists"
     for user in $(cat /etc/group | grep -w ${group} | awk -F ':' '{print $4}' | tr  ',' ' '); 
     do 
        sudo passwd -u ${user} > /dev/null; 
	echo "${user} unblock"; 
	connect "sudo passwd -u ${user} > /dev/null"; 
     done
   else
     echo group not exist; exit 3
   fi

}

case $1 in
    add_group) groups $2 ;;
    add_users) create_user $2 $3 $4 ;;
    off_group) group_off $2 ;;
    on_group) group_on $2;;
    help) check_arguments ;; 
    *) check_arguments
esac

