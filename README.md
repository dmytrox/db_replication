# DataBase Replication

To run the app put this command in your terminal

```
./build.sh
```
It will make this steps:

- Run docker containers(Master, Slave, Slave)

- Create Schema

- Dump Schema 

- Create slave User

- Write dump to the slaves.

- Execute slaves scripts in slave containers 


# Results

>Try to turn off mysql-s1.
 - Mysql-s2 slave will continue working and process queries.

>Try to remove a column in database on slave node.
  
 - Column was removed from cluster mysql-s2, changes are applied only in slave cluster cluster still working and can handle queries.
