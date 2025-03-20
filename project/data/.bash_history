cd /data/db
ls
mongoimport --db usmap --collection states --file us-states.json --jsonArray
mongoimport --host 127.0.0.1 --port 27017 --db usmap --collection states --file us-states.json --jsonArray
mongosh --host localhost --port 27017
exit
cd /data/db
ls
mongoimport --db usmap --collection states --file us-states.json --jsonArray
exit
