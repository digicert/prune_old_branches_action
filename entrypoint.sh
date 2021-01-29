#!/bin/bash

export IFS=$'\n'
SECONDS=$((86400*$1))
TIME=$(($(date +%s)-$SECONDS))

OUT=""
for i in $(git for-each-ref refs/remotes/origin --sort=committerdate  --format='%(HEAD)%(color:yellow)%(refname:short)%(color:reset) %(color:green)%(committerdate:raw)%(color:reset)')
do
    export IFS=$' '
    elements=($i)
    
    if [ $TIME -gt ${elements[1]} ]
    then
        export IFS="/"
	inner_elements=(${elements[0]})
        git push origin --delete ${inner_elements[1]}
        #echo ${inner_elements[1]}
        OUT="${OUT}, ${inner_elements[1]}"
    fi
done
echo ${OUT}
echo "::set-output name=branches::$OUT"