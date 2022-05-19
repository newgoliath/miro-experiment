CLASS_DIR=/Users/jmaltin/class_slides/
CLASS_NAME=${1:-"ocp4_"}
PROJECT=${2:-"appdepl"}

tar cvzf ~/${CLASS_DIR}/${CLASS_NAME}.tar.gz ~/${CLASS_DIR}/${CLASS_NAME}/
rm -rf ~/${CLASS_DIR}/${CLASS_NAME}/*
cd ~/newgoliath/slide-fetch-push/
ansible-playbook slide-fetch.yml  -e course_name=$CLASS_NAME -e output_directory=${CLASS_DIR} -vv
# or, for multiple classes
# for repo in $CLASS_NAME
# do
#  ansible-playbook slide-fetch.yml  -e course_name=$CLASS_NAME -e output_directory=${CLASS_DIR} -vv
# done

# Setting up a slide server is super easy.

# cd into the downloaded slide directory
cd /${CLASS_DIR}/${CLASS_NAME}/

# odo login (to your target cluster)          # if you are not already logged in using "oc login"
odo login -u jmaltin-redhat.com https://api.shared-dev4.dev4.openshift.opentlc.com:6443

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

echo $( odo push --force-build -v4 )
echo

if $( odo url create pe-jm --port 8080 > /dev/null );
then
  echo
  echo "URL Created"
  echo
fi

echo $( odo url list )

echo "Creating list of labs"

URL=$(odo describe url -o json | jq '.spec.urls.items[0].spec.host' | gsed s/\"//g )
echo "labs URL: $URL"

echo "" > LABLIST.txt
for LAB in $(find . -name "*Lab.html" | cut -d/ -f2- |  sort)
do
  echo "http://$URL/$LAB" >> LABLIST.txt
done
