#!/bin/bash

# $@: forward all input arguments to VCS
ncvlog -sv -f $DESIGN_FILELIST $@
