sudo docker run --name mongo-config1 -d --net mongo-sh mongo --replSet "rsConfig" --configsvr
sudo docker run --name mongo-config2 -d --net mongo-sh mongo --replSet "rsConfig" --configsvr
sudo docker run --name mongo-config3 -d --net mongo-sh mongo --replSet "rsConfig" --configsvr
sudo docker exec -it mongo-config1 bash
mongo --host mongo-config1 --port 27019
config = {
      "_id" : "rsConfig",
      "configsvr": true,
      "members" : [
          {
              "_id" : 0,
              "host" : "mongo-config1:27019"
          },
          {
              "_id" : 1,
              "host" : "mongo-config2:27019"
          },
          {
              "_id" : 2,
              "host" : "mongo-config3:27019"
          }
      ]
  }
rs.initiate(config)
exit
exit

sudo docker run --name mongo-shard11 -d --net mongo-sh mongo --replSet "rsShard1" --shardsvr
sudo docker run --name mongo-shard12 -d --net mongo-sh mongo --replSet "rsShard1" --shardsvr
sudo docker run --name mongo-shard13 -d --net mongo-sh mongo --replSet "rsShard1" --shardsvr
sudo docker exec -it mongo-shard11 bash
mongo --host mongo-shard11 --port 27018
config = {
      "_id" : "rsShard1",
      "members" : [
          {
              "_id" : 0,
              "host" : "mongo-shard11:27018"
          },
          {
              "_id" : 1,
              "host" : "mongo-shard12:27018"
          },
          {
              "_id" : 2,
              "host" : "mongo-shard13:27018"
          }
      ]
  }
rs.initiate(config)
exit
exit

sudo docker run  --name mongo-router -d --net mongo-sh mongo  mongos --configdb rsConfig/mongo-config1:27019,mongo-config2:27019,mongo-config3:27019 -p 27017:27017 --bind_ip_all

docker exec -it mongo-router mongo
sh.addShard( "rsShard1/mongo-shard11:27018")
sh.enableSharding("shdb")
sh.shardCollection("shdb.users", { _id : "hashed" })
sh.shardCollection("shdb.products", { _id : "hashed" })
sh.shardCollection("shdb.carts", { _id : "hashed" })
exit
exit

sudo docker cp CLionProjects/MongoDB_Simple_App/json_generator_script/database_carts.json mongo-router:/tmp/database_carts.json
sudo docker cp CLionProjects/MongoDB_Simple_App/json_generator_script/database_products.json mongo-router:/tmp/database_products.json
sudo docker cp CLionProjects/MongoDB_Simple_App/json_generator_script/database_users.json mongo-router:/tmp/database_users.json
sudo docker exec mongo-router mongoimport -d shdb -c carts --file /tmp/database_carts.json
sudo docker exec mongo-router mongoimport -d shdb -c carts --file /tmp/database_users.json
sudo docker exec mongo-router mongoimport -d shdb -c carts --file /tmp/database_products.json


