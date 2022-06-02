#!/bin/bash

# What it does
#  rsyncs class labs/slides from jenkins
#  logs into OCP Cluster
#  publishes course labs/slides to by creating a pod with web server
#  tells you the route to the labs/slides
#  Creates links to labs in LABLIST.csv for pasting into Miro via spreadsheet to create

# requirements:
# odo 1.x installed
# rsync
# opentlc user with jenkins.opentlc.com ssh access


CLASS_DIR=${HOME}/class_slides/
CLASS_NAME=${1:-"ocp4_advanced_application_deployment"} # eg. ocp4_advanced_application_deployment
PROJECT=${2:-"appdepl"}
INSTRUCTOR_INITIALS=${4:-"jm"} # instrctor initials used in Route to pod
OCP_USER=${3:-"jmaltin-redhat.com"}
OCP_CLUSTER=https://api.shared-dev4.dev4.openshift.opentlc.com:6443



rm -rf ${CLASS_DIR}/${CLASS_NAME}/*

echo
echo "running rsync..."

rsync -vvr ${OCP_USER}@jenkins.opentlc.com:/home/jenkins/jenkins_home/jobs/${CLASS_NAME}/lastSuccessful/archive/tempMultiSCOFiles/ ${CLASS_DIR}/${CLASS_NAME}/

# Setting up a slide server is super easy.

# cd into the downloaded slide directory
cd ${CLASS_DIR}/${CLASS_NAME}/

# odo login (to your target cluster)          # if you are not already logged in using "oc login"
odo login -u ${OCP_USER} ${OCP_CLUSTER}

# odo project create
# This creates a new project, you could switch to the right project using 'odo project set <project name>'
if $( odo project set $PROJECT > /dev/null)
then
  echo
  echo "Project $PROJECT already exists."
  echo
else
  echo $( odo project create $PROJECT )
fi

# nginx does not work with odo
if $( odo component describe $PROJECT > /dev/null );
then
  echo
  echo "slides component already created"
  echo
else
  echo $( odo create httpd $PROJECT --app vilt )
fi

if $( odo url create pt-${INSTRUCTOR_INITIALS}  --port 8080 > /dev/null );
then
  echo
  echo "URL Created: "
  echo
fi

echo $( odo push --force-build -v4 )
echo

echo $( odo url list )

echo

echo "Creating list of labs"

URL=$(odo describe url -o json | jq '.spec.urls.items[0].spec.host' | gsed s/\"//g )
echo "labs URL: $URL"

LAB_URL_LIST_FILENAME=${CLASS_DIR}/${CLASS_NAME}/LAB_URL_LIST.csv
echo "Lab URL List filename: ${LAB_URL_LIST_FILENAME}"

for LAB in $(find . -name "*Lab.html" | cut -d/ -f2- |  sort)
do
  echo "http://$URL/$LAB" >> ${LAB_URL_LIST_FILENAME}
done
