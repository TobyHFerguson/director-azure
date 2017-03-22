[ -f secrets ] || {
cat -  >&2 -<<EOF
No file called "secrets" found'. It must contain this line:

AWS_SECRET_ACCESS_KEY=YOUR KEY VALUE HERE

and you need to replace 'YOUR KEY VALUE HERE' appropriately.

...exiting
EOF
exit 1
}

NUMBER=$1

. envars
. secrets

TMP_DIR=./tmp
OUTPUT_DIR=./output


trap "rm -rf ${TMP_DIR:?}" EXIT

mkdir -p ./tmp
mkdir -p ./output

SSH_PRIVATE_KEY_FILE=./tmp/pk.$$
SED_COMMANDS_FILE=./tmp/cmds.sed.$$
SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
TEMPLATE_DIR=${SCRIPTPATH:?}/../templates

sed -e 's|\(-----BEGIN RSA PRIVATE KEY-----\)|    privateKey: """\1|' -e 's|\(-----END RSA PRIVATE KEY-----\)|\1"""|' ${SSH_KEYFILE:?} >${SSH_PRIVATE_KEY_FILE:?}

## the sed command file
cat - > ${SED_COMMANDS_FILE:?} <<EOF
s|REPLACE_ME_ADLS_CLIENT_ID|${ADLS_CLIENT_ID:?}|g
s|REPLACE_ME_ADLS_CREDENTIAL|${ADLS_CREDENTIAL:?}|g
s|REPLACE_ME_ADLS_URI|${ADLS_URI:?}|g
s|REPLACE_ME_CLIENT_ID|${CLIENT_ID:?}|g
s|REPLACE_ME_CLIENT_SECRET|${CLIENT_SECRET:?}|g
s|REPLACE_ME_DIRECTOR_PASSWORD|${DIRECTOR_PASSWORD:?}|g
s|REPLACE_ME_DIRECTOR_USER|${DIRECTOR_USER:?}|g
s|REPLACE_ME_NETWORK_SECURITY_GROUP|${NETWORK_SECURITY_GROUP:?}|g
s|REPLACE_ME_OWNER|${OWNER:?}|g
s|REPLACE_ME_REGION|${REGION:?}|g
s|REPLACE_ME_RESOURCE_GROUP|${RESOURCE_GROUP:?}|g
s|REPLACE_ME_SUBSCRIPTION_ID|${SUBSCRIPTION_ID:?}|g
s|REPLACE_ME_SUBNET|${SUBNET:?}|g
s|REPLACE_ME_TENANT_ID|${TENANT_ID:?}|g
s|REPLACE_ME_VIRTUAL_NETWORK|${VIRTUAL_NETWORK:?}|g
s|REPLACE_ME_FQDN_SUFFIX|${FQDN_SUFFIX:?}|g
/REPLACE_ME_SSH_PRIVATE_KEY/{
r ${SSH_PRIVATE_KEY_FILE:?}
d
}
EOF

EXPAND_DIR=${TMP_DIR:?}/${RESOURCE_GROUP:?}
mkdir -p ${EXPAND_DIR:?}
ZIP_FILE=${OUTPUT_DIR:?}/${RESOURCE_GROUP:?}.zip

for t in $(ls ${TEMPLATE_DIR:?}/*.template)
do
    file=${EXPAND_DIR:?}/$(basename $t .template)
    sed -f ${SED_COMMANDS_FILE} $t >$file
done


cat >${EXPAND_DIR:?}/install_jq.sh <<EOF
(cd /tmp
curl -O http://stedolan.github.io/jq/download/linux64/jq
chmod +x ./jq
sudo mv jq /usr/bin
)
EOF

cp ${SSH_KEYFILE:?} ${EXPAND_DIR:?}/id_rsa
chmod 600 ${EXPAND_DIR:?}/id_rsa


chmod a+x ${EXPAND_DIR:?}/*.sh
zip -m -j ${ZIP_FILE:?} ${EXPAND_DIR:?}/*


    
