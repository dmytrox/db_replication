#!/bin/bash

make down
rm -rf ./data
make up
make schema
make dump

until docker exec mysql-m sh -c 'mysql -u root -pQwerty123 -e ";"'
do
    echo "Waiting for mysql-m database connection..."
    sleep 4
done

priv_stmt='GRANT REPLICATION SLAVE ON *.* TO "slave1"@"%" IDENTIFIED BY "qwerty"; FLUSH PRIVILEGES;'
docker exec mysql-m sh -c "mysql -u root -pQwerty123 -e '$priv_stmt'"

priv_stmt='GRANT REPLICATION SLAVE ON *.* TO "slave2"@"%" IDENTIFIED BY "qwerty"; FLUSH PRIVILEGES;'
docker exec mysql-m sh -c "mysql -u root -pQwerty123 -e '$priv_stmt'"

until docker-compose exec mysql-s1 sh -c 'mysql -u root -pQwerty123 -e ";"'
do
    echo "Waiting for mysql-s1 database connection..."
    sleep 4
done

make ld cn=mysql-s1
make ld cn=mysql-s2

docker-ip() {
    docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$@"
}

MS_STATUS=`docker exec mysql-m sh -c 'mysql -u root -pQwerty123 -e "SHOW MASTER STATUS"'`
CURRENT_LOG=`echo $MS_STATUS | awk '{print $6}'`
CURRENT_POS=`echo $MS_STATUS | awk '{print $7}'`

start_slave_stmt="CHANGE MASTER TO MASTER_HOST='$(docker-ip mysql_master)',MASTER_USER='slave1',MASTER_PASSWORD='qwerty',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
start_slave_cmd1='mysql -u root -e -pQwerty123 "'
start_slave_cmd1+="$start_slave_stmt"
start_slave_cmd1+='"'
docker exec mysql-s1 sh -c "$start_slave_cmd1"

docker exec mysql-s1 sh -c "mysql -u root -e -pQwerty123 'SHOW SLAVE STATUS \G'"

start_slave_stmt="CHANGE MASTER TO MASTER_HOST='$(docker-ip mysql_master)',MASTER_USER='slave2',MASTER_PASSWORD='qwerty',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
start_slave_cmd2='mysql -u root -e -pQwerty123 "'
start_slave_cmd2+="$start_slave_stmt"
start_slave_cmd2+='"'
docker exec mysql-s2 sh -c "$start_slave_cmd2"

docker exec mysql-s2 sh -c "mysql -u root -e -pQwerty123 'SHOW SLAVE STATUS \G'"
