#!/bin/bash

# (c) Copyright 2021, Judd Maltin
# license: GPLv3
# author: Judd Maltin
# requires: macosx, brave browser

# COURSE = a multisco.zip, unzipped
COURSE_NAME=$1
COURSE_NAME=${COURSE_NAME:-'ocp4_advanced_deployment'}

#COURSE_DIR=$2
COURSE_DIR=${COURSE_DIR:-"${HOME}/class_slides/${COURSE_NAME}/"}

OUTPUT_DIR=$2
OUTPUT_DIR=${OUTPUT_DIR:-"${HOME}/class_slides/pdf_${COURSE_NAME}/"}

mkdir ${OUTPUT_DIR}

echo $COURSE_NAME
echo $COURSE_DIR
echo $OUTPUT_DIR

for module in $(ls ${COURSE_DIR})
do
  echo "MODULE: ${module}"
  if [ -d ${COURSE_DIR}/${module} ]
  then
    for html_filename in $(ls ${COURSE_DIR}${module}/*.html)
    do
      echo "HTML: ${html_filename}"
      # build PDF filename from basename
      output_filename=$(basename ${html_filename} .html)
      # add module name to PDF filename for source file AllSlides.html
      if [ "${output_filename}" = "AllSlides" ]
      then
        output_filename="${module}_Slides"
        html_filename="${html_filename}?print-pdf"
      fi
      # build the full path destination
      output_filename="${OUTPUT_DIR}/${output_filename}.pdf"
      echo "PDF: ${output_filename}"

      #file:///Users/jmaltin/class_slides/ocp4_advanced_application_deployment/01_Class_Intro/AllSlides.html

      open -n -a "Brave Browser" --args --profile-directory="Default" \
      --headless --disable-gpu --print-to-pdf=${output_filename} \
      file:///${html_filename}
      echo
    done
  fi
done
