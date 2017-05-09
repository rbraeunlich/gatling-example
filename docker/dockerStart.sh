sudo docker build -t gatling .
sudo docker run -d -P --name gatling gatling && sudo docker port gatling 22
ssh root@localhost -p $PORT