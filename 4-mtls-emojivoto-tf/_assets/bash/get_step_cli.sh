printf ">> Installing SmallStep Step CLI .\n"

STEP_BUNDLE_URL=$(curl -s https://api.github.com/repos/smallstep/cli/releases/latest | jq -r -M '.assets[].browser_download_url | select(contains("amd64.deb"))')
STEP_BUNDLE_NAME="${STEP_BUNDLE_URL##*/}"

if [ -f "${STEP_BUNDLE_NAME}" ]; then
  printf ">> The $STEP_BUNDLE_NAME file exists. Nothing to download. \n"
else
  printf ">> The file doesn't exist. Downloading the $STEP_BUNDLE_NAME file. \n"
  wget -q $STEP_BUNDLE_URL
fi

sudo apt -yf install ./$STEP_BUNDLE_NAME mkcert
step version

printf "\n> Installation completed.\n\n"
