
if (( "$#" == 0 )); then
   echo "Must enter port number greater than 1000"
   exit 1
fi

port="$1"
dataDir="/home/pg/data"
logDir="/var/log/pg"
runDir="/run/postgresql"

#Prepare to run & run

doas mkdir -p "$runDir"
doas chown postgres:postgres "$runDir"
doas chmod 2775 "$runDir"
doas chown postgres "$runDir"
doas -u postgres \
   /usr/bin/pg_ctl -l "$logDir/log" -D "$dataDir" -o "-p $port" start
