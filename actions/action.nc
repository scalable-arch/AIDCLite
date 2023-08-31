#!/bin/bash

# $@: forward all input arguments to VCS
ncvlog +define+UNIT_SIM -sv -f $DESIGN_FILELIST -f $TB_FILELIST $@
ncelab TB_TOP
