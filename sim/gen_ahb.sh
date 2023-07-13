#!/bin/bash

cd gen_amba/gen_amba_ahb
make cleanupall
make
./gen_amba_ahb --mst=2 --slv=2 --out=../../sverilog/AHB_BUS_M2_S2.sv
