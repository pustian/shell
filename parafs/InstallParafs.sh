#!/bin/bash

#������װrpm��
My_DIR=$1
source $My_DIR/variable.sh

cat $InstallParafsFiles | while read line
do
	  #��װrmp���
		rpm -ivh  ${line} --force
done

