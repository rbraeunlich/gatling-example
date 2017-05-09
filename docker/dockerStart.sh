sudo docker build -t gatling .
sudo docker run -d -P --name gatling gatling && sudo docker port gatling 22
sudo docker run -d -P --name gatling2 gatling && sudo docker port gatling2 22
ssh root@localhost -p $PORT