#!/bin/sh -ex

. ./script/bintray_config.sh
  
function bintray_upload {
  
  local local_file=$1
  local remote_file=$2
  local file_version=$3
  
  local CURL="curl --insecure -u${BINTRAY_USER}:${BINTRAY_API_KEY} -H Content-Type:application/json -H Accept:application/json"
  
  echo "Uploading ${local_file}..."
  local uploaded=` [ $(${CURL} --write-out %{http_code} --insecure --silent --output /dev/null -T ${local_file} -H X-Bintray-Package:${PCK_NAME} -H X-Bintray-Version:${file_version} ${API}/content/${BINTRAY_USER}/${BINTRAY_REPO}/${remote_file};publish=1;explode=1) -eq 201 ] `
    
  if ${uploaded}; then
    echo "Publishing ${remote_file}..."
    ${CURL} --insecure -X POST ${API}/content/${BINTRAY_USER}/${BINTRAY_REPO}/${PCK_NAME}/${file_version}/publish -d "{ \"discard\": \"false\" }"
  else
    echo "First you should upload your local_file ${local_file}"
  fi
}
