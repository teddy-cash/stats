#!/usr/bin/bash

. $HOME/.asdf/asdf.sh
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
(cd $SCRIPT_DIR && $(which yarn) run deploy)
date
