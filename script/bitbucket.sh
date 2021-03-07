#!/bin/sh -ex

function bitbucket_upload {

  local fpath=$1
  local fname=$2

  cd ${fpath}

  echo "Uploading ${fname}..."

  curl --write-out "%{response_code}" --insecure --netrc --request POST https://api.bitbucket.org/2.0/repositories/sas_team/sas.planet.bin/downloads -F files=@${fname}

  # https://everything.curl.dev/usingcurl/netrc
  #
  # The .netrc file is typically stored in a user's home directory.
  # On Windows, curl will look for it with the name _netrc in the %HOME% directory:
  # set HOME=%USERPROFILE%
  
}
