# director-azure 
## Overview
A repo to build up director images on azure

This uses templating to build up two aws conf files and some scripts.

The templates uses shell environment variables from the two files `envars` and `secrets`. The format of these files are simple bash
envariable definitions (i.e. `VARIABLE_NAME=VARIABLE_VALUE`)

## Instructions
Modify `envars` and create `secrets` to setup your environment

`secrets` should contain the following:

```sh
# The Azure CLIENT_SECRET
CLIENT_SECRET=
# The Azure ADLS_CREDENTIAL
ADLS_CREDENTIAL=
```

Run `bin/create_templates.sh` to process all the template files (found in the `templates` directory) and create output files in the current directory

## Git
Variables which are safe to check into git are in the `envars` file.

Variables which are supposed to be private (and not checked into git) should be stored in the `secrets` file.

## Rationale
"This seems a little overcomplicated, why do things this way and not simply provide a conf file?" I hear you ask.

Firstly, I wanted to separate out the secrets from the non-secrets, so that I can avoid checking in secrets into a public git. I could've done that simply using the HOCON include facility. 

However, the secrets need to be substituted right into the middle of a multi-line string, and HOCON doesn't support that. So if I'm to separate out the secrets file and then do some kind of substitution it just made sense to be more complete in the substitutions.

However I concede this might be overengineered - maybe I should use the sed script only where absolutely necessary ... I'll file an issue :-)

## Bugs
This has been written very specifically with the `cloud-lab` in mind and it has grown organically.

Originally the idea was to offer many choices of what could be changed, but it turns out that almost everything is a constant. This hasn't been reflected fully in the code.
