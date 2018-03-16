#!/bin/bash

set -e
start=`date +%s`

PLAYPEN_PATH=/home/playpen
PLAYPEN="$PLAYPEN_PATH/PlayPen-1.1.2.jar"
JAVA_OPTS="-Dlog4j.configurationFile=$PLAYPEN_PATH/build-log.xml -jar $PLAYPEN";
PP_PREFIX="PP_${PP_TYPE}_"

PACKAGE=$PLAYPEN_NAME
PACKAGE_DIR=/home/packages/$PACKAGE
OUTPUT_DIR=/home/output
PACKAGE_OUTPUT_DIR="$PACKAGE_DIR/$PACKAGE_PATH"

function print_error {
  echo "$@" 1>&2;
}

function exit_error {
  print_error "$@"
  exit 1
}

function check_package {
  if [ ! -f $PLAYPEN ] ; then
    exit_error "Couldn't find PlayPen JAR on $PLAYPEN"
  fi

  if [ -z $PACKAGE ] ; then
    exit_error "The package name variable (PLAYPEN_NAME env variable) isn't set"
  fi

  if [ ! -d $PACKAGE_DIR ] ; then
    exit_error "Package directory for $PACKAGE doesn't exist on the git repo"
  fi

  if [ -z "$PACKAGE_PATH" ] ; then
    exit_error "Package output path inside git repo (PACKAGE_PATH env variable) isn't set"
  fi
}

function define_var {
  local real_key="$PP_PREFIX$1"

  if [ -z "${!real_key}" ] ; then
    exit_error "The $real_key PlayPen variable isn't set. Perhaps your environment type is incorrect?"
  fi

  declare -g PP_$1="${!real_key}"
}

function define_playpen_vars {
  define_var UUID
  define_var KEY
  define_var IP
  define_var PORT
  define_var USER
  define_var SSH_KEY
}

function update_git_repo {
  cd /home/packages
  git pull -q --ff-only
  echo "Updated git repo"

  # cd to previous dir
  cd ~-
}

function move_artifacts {
  mkdir -p $PACKAGE_OUTPUT_DIR
  local count=0

  for file in target/*.jar; do
    # Ignore Maven trash files
    if [[ $file != *"shaded"* && $file != *"original"* ]] ; then
      mv $file $PACKAGE_OUTPUT_DIR
      count=$((count + 1))
    fi
  done

  if [ $count == "0" ] ; then
    exit_error "Couldn't find any artifacts, perhaps they expired?"
  fi

  echo "Moved $count artifacts"
}

function create_ssh_tunnel {
  echo "$PP_SSH_KEY" > ~/.ssh/key_rsa
  chmod 400 ~/.ssh/key_rsa

  # Create SSH tunnel
  # Could use a UNIX socket, but they are broken on OverlayFS
  # (https://github.com/moby/moby/issues/12080)
  ssh -Cfo ExitOnForwardFailure=yes -o StrictHostKeyChecking=no -4 -NL "$PP_PORT:localhost:$PP_PORT" "$PP_USER@$PP_IP" -i ~/.ssh/key_rsa

  ssh_pid=$(pgrep -f "NL $PP_PORT:")
}

function close_ssh_tunnel {
  [ "$ssh_pid" ] || exit 1
}

function create_playpen_config {
  local name=$CI_JOB_NAME
  echo "{\"name\": \"$name\", \"uuid\": \"$PP_UUID\", \"key\": \"$PP_KEY\", \"coord-ip\": \"127.0.0.1\", \"coord-port\": $PP_PORT, \"resources\": {}, \"attributes\": [], \"strings\": {}, \"use-name-for-logs\": true}" > $PLAYPEN_PATH/local.json
  echo "Created local PlayPen coordinator config for $name"
}

function package {
  mkdir -p $OUTPUT_DIR
  java $JAVA_OPTS p3 pack $PACKAGE_DIR $OUTPUT_DIR

  # Get the output name, PlayPen always writes to "<name>_<version>.p3"
  P3_NAME=$(ls $OUTPUT_DIR | sort -n | head -1)

  if [ -z $P3_NAME ] ; then
    exit_error "Cannot find PlayPen P3 output file in $OUTPUT_DIR"
  fi
}

function upload {
  local filename=$P3_NAME
  local path="$OUTPUT_DIR/$P3_NAME"

  # Hide IP and port in logs
  local package_sha=`sha1sum "$path"`
  local network_sha=`echo -n "$PP_IP:$PP_PORT" | sha256sum`

  echo "Uploading package $filename (SHA1: $package_sha)"
  echo "Connecting to PlayPen network (SHA256: $network_sha)"

  java $JAVA_OPTS cli upload $path
}

check_package
define_playpen_vars

update_git_repo
move_artifacts

create_ssh_tunnel

create_playpen_config
package
upload

close_ssh_tunnel

# Log runtime
end=`date +%s`
runtime=`expr $end - $start`

echo "Success! Uploaded package in ${runtime}ms. Remember to restart some instances to update the package."