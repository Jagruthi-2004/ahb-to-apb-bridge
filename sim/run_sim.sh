#!/bin/bash
# AHB to APB Bridge — Simulation Script
# Usage: ./sim/run_sim.sh

set -e

echo "==============================="
echo " AHB-to-APB Bridge Simulation  "
echo "==============================="

# Compile
echo "[1/3] Compiling..."
iverilog -o sim/ahb2apb_sim \
  -g2012 \
  src/ahb2apb.v \
  tb/ahb2apb_tb.v

# Run simulation
echo "[2/3] Running simulation..."
cd sim
vvp ahb2apb_sim

# Open waveform
echo "[3/3] Opening GTKWave..."
if command -v gtkwave &> /dev/null; then
    gtkwave ahb2apb_dump.vcd &
else
    echo "GTKWave not found. VCD file saved to sim/ahb2apb_dump.vcd"
fi

echo "Done."
```

---

### `.gitignore`
```
# Simulation outputs
sim/ahb2apb_sim
sim/*.vcd
sim/*.lxt
sim/*.vvp
*.log

# Vivado / Quartus / ISE
*.jou
*.xpr
*.bit
*.runs/
*.cache/
*.ip_user_files/
work/
*.xise
*.gise

# ModelSim
transcript
vsim.wlf
*.wlf

# Synopsys / Cadence
*.syn
*.mr
*.pvl
*.sdf
INCA_libs/

# OS
.DS_Store
Thumbs.db
