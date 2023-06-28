#!/usr/bin/env bash

echoerr() { echo "$@" 1>&2; }

args="$@"
echoerr "arguments: $args"

# the rules file has to be the first argument
shift

#v="GET type=head"
#t=$(echo "$args" | egrep "GET /type") ;
#t=$(echo "$t" | sed 's|GET /type=||') ;
#echo $t


while true; 
  do { echo -ne "HTTP/1.1 200 OK\r\n"; echo "blah"; } | \
  nc -l -k -p 8080 | grep "GET /gpio" | \
  sed -e 's/%20/ /g' | \
  eval $( awk '{print substr($0,6,15) }') ;
done


# while true; 
#         do
#         { echo -ne "HTTP/1.0 200 OK\r\n\r\n\r\n" ; echo ; } | \
#         nc -lk -p 3000 | \
#         rulesstring=$(egrep "GET /type") ;
#         type=$(echo "$rulesstring" | sed 's|GET\s/type=||g') ;
#         echoerr "val $type\n" ;
#         echo $body ;
#         echo "val $type\n" ;
# #        bash ./map.sh $type & PID=$!; 
# #        wait $PID ;
# #        echoerr "mapping done\n" ;
# done



