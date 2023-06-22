#!/usr/bin/env bash
ncat -l -k 0.0.0.0 3000 --sh-exec "/t.sh $(env)"