#!/bin/bash
#set -x

read -p "Enter key name: " key_name && echo $key_name
if [ -n "$key_name" ]
then 
   openssl genrsa -out "${key_name}.key" 2048
else
  echo "Enter name file key" && exit 1
fi

if [ $? == 0  ]
then
   read -p "Enter csr name: " csr_name && echo $csr_name
   if [ -z "$csr_name"]
   then
      rm "${key_name}.key"
      echo "Enter name file csr" && exit 1
   else
      openssl req -new -key "${key_name}.key" -out "${csr_name}.csr"
      echo "OK ${csr_name}"
   fi
fi


if [ $? == 0 ] 
then
   read -p "Enter certificate name: " crt_name
   read -p "Enter day valid certificate: " valid_day
   if [ -z "$crt_name" ] || [ -z "$valid_day" ]
   then
      rm "${key_name}.key" && rm "${csr_name}.csr" && \
      echo "Need enter name for certificate and valid day cetificate" && \
      exit 1
   else
      openssl x509 -req -days ${valid_day} -in ${csr_name}.csr -signkey ${key_name}.key -out ${crt_name}.crt
      echo "${crt_name}.crt create succeded"
   fi
fi
