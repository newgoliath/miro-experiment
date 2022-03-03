#!/bin/bash

# (c) Copyright 2022, Judd Maltin
# license: GPLv3
# author: Judd Maltin

# Instructions:
#  Download the multisco.zip from Jenkins for your course.
#  Unzip the file into a directory you like

# usage:
# ./multisco2pdf.sh <full path to course> [output dir] [chrome compatible browser]
#
# If <output dir> missing, script will prefix basename with 'pdf_'
# I test on Brave.  Other browsers, YMMV

# requires:
# * macosx
# * brave browser
# * multisco.zip, unzipped


COURSE_PATH=$1
COURSE_PATH=${COURSE_PATH:-"$HOME/class_slides/ocp4_advanced_application_deployment"}

COURSE_NAME=$(basename ${COURSE_PATH})

OUTPUT_DIR=$2
OUTPUT_DIR=${OUTPUT_DIR:-"$(dirname ${COURSE_PATH})/pdf_${COURSE_NAME}/"}

CHROME_BROWSER=$3
CHROME_BROWSER=${CHROME_BROWSER:-"Brave Browser"}

mkdir ${OUTPUT_DIR}

echo Course Name: $COURSE_NAME
echo Course Path: $COURSE_PATH
echo Course Output Dir: $OUTPUT_DIR

for module in $(ls ${COURSE_PATH})
do
  echo "MODULE: ${module}"
  if [ -d ${COURSE_PATH}/${module} ]
  then
    for html_filename in $(ls ${COURSE_PATH}/${module}/*.html)
    do
      echo "HTML file: ${html_filename}"
      # build PDF filename from basename
      output_filename=$(basename ${html_filename} .html)
      # Slides files need module name to PDF filename
      if [ "${output_filename}" = "AllSlides" ]
      then
        output_filename="${module}_Slides"
        html_filename="${html_filename}?print-pdf"
      fi
      # Labs files already have module name in filename
      # build the full path destination
      output_filename="${OUTPUT_DIR}/${output_filename}.pdf"
      echo "PDF: ${output_filename}"

      open -n -a "${CHROME_BROWSER}" --args --profile-directory="Default" \
      --headless --disable-gpu --print-to-pdf=${output_filename} \
      file:///${html_filename}
      echo
    done
  fi
done
