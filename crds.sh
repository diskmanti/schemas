#! /bin/bash

#############
#   CRDs   #
############

# Check if python3 is installed
if ! command -v python3 &>/dev/null; then
	printf "python3 is required for this utility and it is not installed on your machine"
fi

# Check if kubectl is installed
if ! command -v kubectl &>/dev/null; then
	printf "kubectl is required for this utility, and is not installed on your machine"
	exit 1
fi

# Check if the pyyaml module is installed

if ! echo 'import yaml' | python3 &>/dev/null; then
	printf "the python3 module 'yaml' is required, and is not installed on your machine.\n"
	#printf "would you like to install it? y/n"
	while true; do
		read -rp "Do you wish to install this program? (y/n) " yn
		case $yn in
		[Yy]) pip3 install pyyaml break ;;
		"") pip3 install pyyaml break ;;
		[Nn]) echo "Exiting..." exit ;;
		*) echo "Please answer 'y' (yes) or 'n' (no)." ;;
		esac
	done
fi

# Create temp folder for CRDs
TMP_CRD_DIR=tmp
mkdir -p "$TMP_CRD_DIR"

# Extract CRDs from cluster
NUM_OF_CRDS=0
while read -r crd; do
	resourceKind=${crd%% *}
	kubectl get crds "$resourceKind" --output yaml >"$TMP_CRD_DIR/$resourceKind".yaml 2>&1
	# let NUM_OF_CRDS++
	((NUM_OF_CRDS++))
done < <(kubectl get crds 2>&1 | sed -n '/NAME/,$p' | tail -n +2)

# Download converter script
# curl --fail https://raw.githubusercontent.com/yannh/kubeconform/master/scripts/openapi2jsonschema.py --output "$TMP_CRD_DIR"/openapi2jsonschema.py 2>/dev/null

# Create final schemas directory
SCHEMAS_DIR=crdSchemas
mkdir -p "$SCHEMAS_DIR"
# cd "$SCHEMAS_DIR" || exit

# Convert crds to jsonSchema
python3 scripts/openapi2jsonschema.py "$TMP_CRD_DIR"/*.yaml
conversionResult=$?

# Copy and rename files to support kubeval
rm -rf "$SCHEMAS_DIR"/master-standalone
mkdir -p "$SCHEMAS_DIR"/master-standalone
cp ./*.json "$SCHEMAS_DIR"
cp ./*.json "$SCHEMAS_DIR"/master-standalone
rm ./*.json
find "$SCHEMAS_DIR"/master-standalone -name '*json' -exec bash -c ' mv -f $0 ${0/\_/-stable-}' {} \;

# CYAN='\033[0;36m'
# GREEN='\033[0;32m'
GREEN=$(tput setaf 2)
# NC='\033[0m' # No Color
# NC=$(tput sgr0)

if [ "$conversionResult" == 0 ]; then
	printf "%sSuccessfully converted $NUM_OF_CRDS CRDs to JSON schema\n" "$GREEN"
	# printf "\nTo validate a CR using various tools, run the relevant command:\n"
	# printf "\n- ${CYAN}datree:${NC}\n\$ datree test /path/to/file\n"
	# printf "\n- ${CYAN}kubeconform:${NC}\n\$ kubeconform -summary -output json -schema-location default -schema-location '$HOME/.datree/crdSchemas/{{ .ResourceKind }}_{{ .ResourceAPIVersion }}.json' /path/to/file\n"
	# printf "\n- ${CYAN}kubeval:${NC}\n\$ kubeval --additional-schema-locations file:\"$HOME/.datree/crdSchemas\" /path/to/file\n\n"
fi

rm -rf "$TMP_CRD_DIR"
