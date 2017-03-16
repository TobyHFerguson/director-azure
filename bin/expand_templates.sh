[ -f secrets ] || {
cat -  >&2 -<<EOF
No file called "secrets" found'. It must contain this line:

AWS_SECRET_ACCESS_KEY=YOUR KEY VALUE HERE

and you need to replace 'YOUR KEY VALUE HERE' appropriately.

...exiting
EOF
exit 1
}

. envars
. secrets

mkdir -p ./tmp
SSH_PRIVATE_KEY_FILE=./tmp/pk.$$
SED_COMMANDS_FILE=./tmp/cmds.sed.$$
SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
TEMPLATE_DIR=${SCRIPTPATH:?}/../templates

sed -e 's|\(-----BEGIN RSA PRIVATE KEY-----\)|    privateKey: """\1|' -e 's|\(-----END RSA PRIVATE KEY-----\)|\1"""|' ${SSH_KEYFILE:?} >${SSH_PRIVATE_KEY_FILE:?}

## the sed command file
cat - > ${SED_COMMANDS_FILE:?} <<EOF
s|REPLACE_ME_ADLS_CLIENT_ID|${ADLS_CLIENT_ID:?}|g
s|REPLACE_ME_ADLS_CREDENTIAL|${ADLS_CREDENTIAL:?}|g
s|REPLACE_ME_CLIENT_ID|${CLIENT_ID:?}|g
s|REPLACE_ME_REGION|${REGION:?}|g
s|REPLACE_ME_SUBSCRIPTION_ID|${SUBSCRIPTION_ID:?}|g
s|REPLACE_ME_TENANT_ID|${TENANT_ID:?}|g
s|REPLACE_ME_CLIENT_SECRET|${CLIENT_SECRET:?}|g
s|REPLACE_ME_OWNER|${OWNER:?}|g
s|REPLACE_ME_ADLS_GLOBAL_STORE|${ADLS_GLOBAL_STORE:?}|g
s|REPLACE_ME_ADLS_MY_STORE|${ADLS_MY_STORE:?}|g
/REPLACE_ME_SSH_PRIVATE_KEY/{
r ${SSH_PRIVATE_KEY_FILE:?}
d
}
EOF

for t in $(ls ${TEMPLATE_DIR:?}/*.template)
do
    file=$(basename $t .template)
    sed -f ${SED_COMMANDS_FILE} $t >$file
done

    
