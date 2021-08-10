#!/bin/bash
# Author: Judd Maltin


# Output Directory create function
function OUTPUT_DIR_FUNC(){
  if [ ! -d "${1}" ]; then
    mkdir "${1}"
  fi
  read -e -p "Enter Class Name : " CLASS_NAME
  if [ -d "${1}/${CLASS_NAME}" ]; then
    echo "${CLASS_NAME}: class is already exist in '$HOME/tmp'"
    read -p "Do you want to override and continue y/n : " ANS
    if [ "${ANS}" == "y" ]; then
      rm -rf "${1}/${CLASS_NAME}" 
      rm -rf ${1}/${CLASS_NAME}_PDF 2>/dev/null
    else
      echo
      exit 1
    fi
    echo
  fi
  if [ ! -d "${1}/${CLASS_NAME}_PDF" ]; then
    mkdir ${1}/${CLASS_NAME}_PDF
  fi
  OUTPUT_PDF_DIR="${1}/${CLASS_NAME}_PDF"
}

# Unzip function
function UNZIP_FUNC(){
  read -e -p "Enter absolute path of Zip file : " ZIP_FILE_PATH
  if [  -f "${ZIP_FILE_PATH}" ]; then
    unzip -o -q  ${ZIP_FILE_PATH} -d ${HOME}/tmp/ 
    ZIP_DIR=$(basename ${ZIP_FILE_PATH} .zip)
    mv ${1}/${ZIP_DIR} ${1}/${CLASS_NAME}
    CLASS="${1}/${CLASS_NAME}"
  else
    echo -e "\n${ZIP_FILE_PATH} - File doesn't exist\n"
    exit 1
  fi
}

# Browser function
function CHOOSE_BROWSER(){
  PS3="Select your browser: "
  select browser in "Google Chrome" "Brave Browser"
  do
    BROWSER=${browser}
    break
  done
}

# Main function
function MAIN(){        
  for module in $(ls ${CLASS})
  do      
    echo "MODULE: ${module}"
    echo 
    if [ -d ${CLASS}/${module} ]
    then 
      for html in $(ls ${CLASS}/${module}/*.html)
      do  
        echo "HTML: ${html}"
        output_file=$(basename ${html} .html)
        if [ "${output_file}" = "AllSlides" ]; then
          output_file="${module}_Slides"
          html="${html}?print-pdf"
        fi
        output_file="${output_file}.pdf"
          
        open -n -a "${BROWSER}" \
          --args \
          --profile-directory="Default" \
          --headless \
          --disable-gpu \
          --print-to-pdf=${OUTPUT_PDF_DIR}/${output_file} \
          file:///${html}
      done
    fi   
  done
 }


OUTPUT_DIR="${HOME}/tmp"
OUTPUT_DIR_FUNC ${OUTPUT_DIR}
UNZIP_FUNC ${OUTPUT_DIR}
CHOOSE_BROWSER
MAIN
open ${OUTPUT_PDF_DIR}




