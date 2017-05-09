sudo docker build -t gatling .
sudo docker run -d -p 4000:22 --name gatling gatling
sudo docker run -d -p 4001:22 --name gatling2 gatling
ssh root@localhost -p $PORT