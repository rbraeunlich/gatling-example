#!/bin/bash
##################################################################################################################
#Gatling scale out/cluster run script:
#Before running this script some assumptions are made:
#1) Check  read/write permissions on all folders declared in this script.
#2) Gatling installation (GATLING_HOME variable) is the same on all hosts
#3) Assuming all hosts has the same user name (if not change in script)
##################################################################################################################

if [ -z "$1" ]
    then
        echo "Must provide param for test class"
        exit 1
fi

#Assuming same user name for all hosts
USER_NAME='root'

#Remote hosts list
HOSTS=( localhost:32782 localhost:32783 )

#Simulation options

#Assuming all Gatling installation in same path (with write permissions)
GATLING_HOME=gatling/gatling-charts-highcharts-bundle-2.2.5
GATLING_RUNNER=$GATLING_HOME/bin/gatling.sh

#Change to your simulation class name
SIMULATION_NAME=$1

GATLING_REPORT_DIR=$GATLING_HOME/results/
GATHER_REPORTS_DIR=gatling/reports/
GATLING_LIB_DIR=$GATLING_HOME/lib

echo "Starting Gatling cluster run for simulation: $SIMULATION_NAME"

echo "Cleaning previous runs from localhost"
rm -rf $GATHER_REPORTS_DIR
mkdir -p $GATHER_REPORTS_DIR

for HOST in "${HOSTS[@]}"
do
  echo "Copying simulation JARs to host: $HOST"
  IFS=: read -r address port <<< "$HOST"
  scp -i id_rsa -P $port $GATLING_LIB_DIR/gatling-example_2.11-0.1.0-SNAPSHOT-tests.jar $USER_NAME@$address:/$GATLING_LIB_DIR
done


for HOST in "${HOSTS[@]}"
do
  echo "Cleaning previous runs from host: $HOST"
  IFS=: read -r address port <<< "$HOST"
  ssh -n -f -i id_rsa $USER_NAME@$address -p $port "sh -c 'rm -rf $GATLING_REPORT_DIR'"
done

rm -rf $GATLING_REPORT_DIR

for HOST in "${HOSTS[@]}"
do
   echo "Running simulation on host: $HOST"
  IFS=: read -r address port <<< "$HOST"
  ssh -n -f -i id_rsa $USER_NAME@$address -p $port "sh -c 'nohup /$GATLING_RUNNER -nr -s $SIMULATION_NAME > gatling-run.log 2>&1 &'"
done

$GATLING_RUNNER -nr -s $SIMULATION_NAME > gatling-run-localhost.log

echo "Gathering result file from localhost"
ls -t $GATLING_REPORT_DIR | head -n 1 | xargs -I {} mv ${GATLING_REPORT_DIR}{} ${GATLING_REPORT_DIR}report
cp ${GATLING_REPORT_DIR}report/simulation.log ${GATHER_REPORTS_DIR}simulation.log

for HOST in "${HOSTS[@]}"
do
  echo "Gathering result file from host: $HOST"
  IFS=: read -r address port <<< "$HOST"
  ssh -n -f -i id_rsa $USER_NAME@$address -p $port "sh -c 'ls -t /$GATLING_REPORT_DIR | head -n 1 | xargs -I {} mv /${GATLING_REPORT_DIR}{} /${GATLING_REPORT_DIR}report'"
  scp -i id_rsa -P $port $USER_NAME@$address:/${GATLING_REPORT_DIR}report/simulation.log ${GATHER_REPORTS_DIR}simulation-${HOST}.log
done

for HOST in "${HOSTS[@]}"
do
  echo "Gathering run log file from host: $HOST"
  scp -i id_rsa -P $port $USER_NAME@$address:/gatling-run.log ./gatling-run-${HOST}.log
done

mv $GATHER_REPORTS_DIR $GATLING_REPORT_DIR
echo "Aggregating simulations"
$GATLING_RUNNER -ro reports