# ahb-to-apb-bridge
A synthesizable AHB-to-APB Bridge implemented in Verilog, compliant with the ARM AMBA 2.0 protocol specification. The bridge converts high-bandwidth AHB master transactions into low-power APB peripheral accesses.
# AHB to APB Bridge

A synthesizable **AHB-to-APB Bridge** implemented in Verilog, compliant with the
ARM AMBA 2.0 protocol specification. The bridge converts high-bandwidth AHB
master transactions into low-power APB peripheral accesses.

## Overview

The AHB (Advanced High-performance Bus) to APB (Advanced Peripheral Bus) bridge
acts as an AHB slave on the system bus side and as an APB master on the
peripheral side. It handles the protocol conversion including the mandatory
two-phase APB access (SETUP → ENABLE) and the pipelined nature of AHB.

##  Features

- ✅ Single read and write transfers
- ✅ Pipelined (back-to-back) transfers — WRITEP / WENABLEP states
- ✅ Burst read and burst write (SEQ + NONSEQ htrans)
- ✅ Active-low synchronous reset (`hresetn`)
- ✅ HREADY handshaking (stalls AHB master during APB access)
- ✅ Address and data phase latching (`tmp_haddr`, `tmp_hwdata`)
- ✅ 32-bit address and data bus

## File Structure
```
src/         → RTL source (ahb2apb.v)
tb/          → Testbench (ahb2apb_tb.v)
docs/        → Design documentation
sim/         → Simulation run scripts
```

## Port Description

### AHB Slave Interface (Inputs)

| Port      | Width | Direction | Description                        |
|-----------|-------|-----------|------------------------------------|
| hclk      | 1     | Input     | AHB clock                          |
| hresetn   | 1     | Input     | Active-low synchronous reset       |
| hselapb   | 1     | Input     | Slave select for this bridge       |
| haddr     | 32    | Input     | AHB address bus                    |
| hwrite    | 1     | Input     | 1 = Write, 0 = Read                |
| htrans    | 2     | Input     | Transfer type (IDLE/BUSY/NONSEQ/SEQ)|
| hwdata    | 32    | Input     | AHB write data                     |

### AHB Slave Interface (Outputs)

| Port    | Width | Direction | Description                        |
|---------|---------|-----------|------------------------------------|
| hresp   | 1     | Output    | Transfer response (always OKAY)    |
| hready  | 1     | Output    | Ready signal to AHB master         |
| hrdata  | 32    | Output    | AHB read data (from APB)           |

### APB Master Interface

| Port    | Width | Direction | Description                        |
|---------|---------|-----------|------------------------------------|
| prdata  | 32    | Input     | APB read data from peripheral      |
| psel    | 1     | Output    | APB peripheral select              |
| penable | 1     | Output    | APB enable (2nd phase)             |
| pwrite  | 1     | Output    | APB write enable                   |
| paddr   | 32    | Output    | APB address                        |
| pwdata  | 32    | Output    | APB write data                     |

## FSM States

| State     | Encoding | Description                                    |
|-----------|----------|------------------------------------------------|
| IDLE      | 3'b000   | No transfer, waiting for valid AHB transaction |
| READ      | 3'b001   | APB read setup phase                           |
| WWAIT     | 3'b010   | AHB write address phase latch                  |
| WRITE     | 3'b011   | APB write setup phase                          |
| WRITEP    | 3'b100   | Pipelined write setup phase                    |
| WENABLE   | 3'b101   | APB write enable phase                         |
| WENABLEP  | 3'b110   | Pipelined APB write enable phase               |
| RENABLE   | 3'b111   | APB read enable phase, captures prdata         |

##  Simulation

### Prerequisites
- Icarus Verilog: `sudo apt install iverilog`
- GTKWave: `sudo apt install gtkwave`

### Run Simulation
```bash
chmod +x sim/run_sim.sh
./sim/run_sim.sh
```

Or manually:
```bash
iverilog -o sim/ahb2apb_sim src/ahb2apb.v tb/ahb2apb_tb.v
vvp sim/ahb2apb_sim
gtkwave sim/ahb2apb_dump.vcd
```

### Test Cases in Testbench

| Test Case        | Address      | Data         | Description              |
|------------------|--------------|--------------|--------------------------|
| Single Read      | 0x0000_0010  | 0xDEAD_BEEF  | NONSEQ read transaction  |
| Single Write     | 0x0000_0020  | 0x1234_5678  | NONSEQ write transaction |
| Burst Read       | 0x0000_0100+ | 0xAAAA/BB/CC | 3-beat SEQ read          |
| Burst Write      | 0x0000_0200+ | 0x1111/2222/3333 | 3-beat SEQ write     |

## 📐 Protocol Timing

### Write Transfer
```
Cycle:    1         2         3         4
AHB:   [ADDR/CTRL][  DATA  ][        ][        ]
APB:              [SETUP   ][ENABLE  ]
HREADY:    1         0         1
psel:      0         1         1
penable:   0         0         1
```

### Read Transfer
```
Cycle:    1         2         3
AHB:   [ADDR/CTRL][        ][DATA captured]
APB:              [SETUP   ][ENABLE       ]
HREADY:    1         0         1
psel:      0         1         1
penable:   0         0         1
```
