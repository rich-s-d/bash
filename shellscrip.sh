#!/bin/bash

ret=$?
index=0
results=()

# this function checks the status of ret (exit status) and populates the array results with either a 0 or 1.
updateResults () {
  results[${#results[@]}]=0
  if [ $ret -ne 0 ]; then
     results[$index]=1
  fi
  ((++index))
  printf %s " "
}

# Set AWS_PROFILE: change this hardcoded value (dev) when solution arrives.
printf %s "....Setting AWS_PROFILE"
export AWS_PROFILE=dev
printf %s "AWS_PROFILE="$AWS_PROFILE 

# Run tests
printf %s " "
printf %s "--------------EXECUTING INTEGRATION TESTS--------------"

cd src
printf %s "Executing sqs integration test"
python sqs_integration_test.py
updateResults

printf %s "Executing ssm parameters integration test"
python ssm_parameters_integration_test.py
updateResults

printf %s "Executing sqs triggers integration test"
python sqs_triggers_integration_test.py
updateResults

printf %s "Executing lambdas integration test"
python lambdas_integration_test.py
updateResults

printf %s "Executing sns subscriptions integration test"
python sns_subscriptions_integration_test.py
updateResults

printf %s "Executing IAM policy integration test for gis-backend"
python iam_policy_integration_test.py
updateResults

printf %s "Executing cluster integration test"
python cluster_integration_test.py
updateResults


printf %s "--------------EXECUTING HEALTH CHECKS--------------"
printf %s " "
printf %s "Executing database connection health check"
python database_connection_health_check.py
updateResults

# output.xml is generated in /src and appended to in each python script above.
printf %s "--------------PRINTING XML REPORT--------------"
printf %s "Printing output.xml"
cat output.xml


# This function checks if a value is present in the array results and exits accordingly with 1 or 0.
containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && exit 1; done
  exit 0
}

# Calling the function with value 1 on array results.
containsElement 1 "${results[@]}"
