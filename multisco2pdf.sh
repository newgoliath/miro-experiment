#!/bin/bash

# author: Judd Maltin

# CLASS = a multisco.zip, unzipped

CLASS="$HOME/class_slides/ocp4_advanced_application_deployment/"
OUTPUT_DIR="$HOME/tmp/"


for module in $(ls ${CLASS})
do
  echo "MODULE: ${module}"
  echo
  if [ -d ${CLASS}${module} ]
  then
    for html in $(ls ${CLASS}${module}/*.html)
    do
      echo "HTML: ${html}"
      output_file=$(basename ${html} .html)
      if [ "${output_file}" = "AllSlides" ]
      then
        output_file="${module}_Slides"
        html="${html}?print-pdf"
      fi
      output_file="${output_file}.pdf"

#file:///Users/jmaltin/class_slides/ocp4_advanced_application_deployment/01_Class_Intro/AllSlides.html


      open -n -a "Brave Browser" --args --profile-directory="Default" \
      --headless --disable-gpu --print-to-pdf=${OUTPUT_DIR}${output_file} \
      file:///${html}
    done
  fi
done

