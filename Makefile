up:	
	docker-compose up -d --build
stop:
	docker-compose stop
down:
	docker-compose down
schema:
	docker exec mysql-m /bin/sh -c 'mysql -u root -pQwerty123 replication </scripts/users.sql'
dump:
	docker exec mysql-m /bin/sh -c 'mysql -u root -pQwerty123 replication > /dump/dump.sql'

ld:
	docker exec $(cn) /bin/sh -c 'mysql -u root -pQwerty123 replication < /dump/dump.sql'
