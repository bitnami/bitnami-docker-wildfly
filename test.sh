#!/usr/bin/env bats

WILDFLY_DEFAULT_USER=manager
WILDFLY_DEFAULT_PASSWORD=password
WILDFLY_USER=test_user
WILDFLY_PASSWORD=test_password

# source the helper script
APP_NAME=wildfly
VOL_PREFIX=/bitnami/$APP_NAME
VOLUMES=$VOL_PREFIX
SLEEP_TIME=15
load tests/docker_helper

# Link to container and execute jboss-cli
# $1: name of the container to link to
# ${@:2}: command to execute
jboss_client() {
  container_link_and_run_command $1 jboss-cli.sh --controller=$APP_NAME:9990 "${@:2}"
}

# Cleans up all running/stopped containers and host mounted volumes
cleanup_environment() {
  container_remove_full default
}

# Teardown called at the end of each test
teardown() {
  cleanup_environment
}

# cleanup the environment before starting the tests
cleanup_environment

@test "Ports 8080 and 9990 exposed and accepting external connections" {
  container_create default -d

  run curl_client default -i http://$APP_NAME:8080
  [[ "$output" =~ '200 OK' ]]

  run curl_client default -i http://$APP_NAME:9990
  [[ "$output" =~ '200 OK' ]]
}

@test "Can't access management area without password" {
  container_create default -d

  run curl_client default -i --digest http://$WILDFLY_DEFAULT_USER@$APP_NAME:9990/management
  [[ "$output" =~ '401 Unauthorized' ]]
}

@test "Manager created with default password" {
  container_create default -d

  run curl_client default -i --digest http://$WILDFLY_DEFAULT_USER:$WILDFLY_DEFAULT_PASSWORD@$APP_NAME:9990/management
  [[ "$output" =~ '200 OK' ]]
}

@test "Can assign custom password to manager" {
  container_create default -d \
    -e WILDFLY_PASSWORD=$WILDFLY_PASSWORD

  run curl_client default -i --digest http://$WILDFLY_DEFAULT_USER:$WILDFLY_PASSWORD@$APP_NAME:9990/management
  [[ "$output" =~ '200 OK' ]]
}

@test "Can create custom user with manager role" {
  container_create default -d \
    -e WILDFLY_USER=$WILDFLY_USER \
    -e WILDFLY_PASSWORD=$WILDFLY_PASSWORD

  run curl_client default -i --digest http://$WILDFLY_USER:$WILDFLY_PASSWORD@$APP_NAME:9990/management
  [[ "$output" =~ '200 OK' ]]
}

@test "jboss-cli.sh can connect to Wildfly server" {
  container_create default -d

  run jboss_client default --connect --user=$WILDFLY_DEFAULT_USER --password=$WILDFLY_DEFAULT_PASSWORD --command=version
  [ $status = 0 ]
}

@test "jboss-cli.sh can't access Wildfly server without password" {
  container_create default -d

  run jboss_client default --connect --user=$WILDFLY_DEFAULT_USER --command=version
  [[ "$output" =~ "Unable to authenticate against controller" ]]
}

@test "Password is preserved after restart" {
  container_create default -d \
    -e WILDFLY_PASSWORD=$WILDFLY_PASSWORD

  # restart container
  container_restart default

  run curl_client default -i --digest http://$WILDFLY_DEFAULT_USER:$WILDFLY_PASSWORD@$APP_NAME:9990/management
  [[ "$output" =~ '200 OK' ]]
}

@test "If host mounted, password and settings are preserved after deletion" {
  skip

  container_create_with_host_volumes default -d \
    -e WILDFLY_PASSWORD=$WILDFLY_PASSWORD

  # remove container
  container_remove default

  # recreate container without specifying any env parameters
  container_create_with_host_volumes default -d

  run curl_client default -i --digest http://$WILDFLY_DEFAULT_USER:$WILDFLY_PASSWORD@$APP_NAME:9990/management
  [[ "$output" =~ '200 OK' ]]
}

@test "All the volumes exposed" {
  container_create default -d

  run container_inspect default --format {{.Mounts}}
  [[ "$output" =~ "$VOL_PREFIX" ]]
}

@test "Data gets generated in volume if bind mounted in the host" {
  container_create_with_host_volumes default -d \
    -e WILDFLY_PASSWORD=$WILDFLY_PASSWORD

  run container_exec default ls -la $VOL_PREFIX/conf/
  [[ "$output" =~ "standalone.xml" ]]

  run container_exec default ls -la $VOL_PREFIX/standalone/
  [[ "$output" =~ "deployments" ]]
}

@test "If host mounted, password and settings are preserved after deletion" {
  container_create_with_host_volumes default -d \
    -e WILDFLY_PASSWORD=$WILDFLY_PASSWORD

  container_remove default
  container_create_with_host_volumes default -d

  run curl_client default -i --digest http://$WILDFLY_DEFAULT_USER:$WILDFLY_PASSWORD@$APP_NAME:9990/management
  [[ "$output" =~ '200 OK' ]]
}

@test "Deploy sample application on standalone" {
  container_create default -d

  # download sample app into the deployments directory and allow it some time to come up
  container_exec default curl --noproxy localhost --retry 5 \
    https://raw.githubusercontent.com/goldmann/wildfly-docker-deployment-example/master/node-info.war \
    -o $VOL_PREFIX/standalone/deployments/node-info.war
  sleep $SLEEP_TIME

  # test the deployment
  run curl_client default -i http://$APP_NAME:8080/node-info/
  [[ "$output" =~ '200 OK' ]]
}
