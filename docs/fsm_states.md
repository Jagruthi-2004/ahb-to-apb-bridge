# FSM State Machine Documentation

## State Transition Diagram
```
                      valid=0
          ┌──────────────────────────────┐
          ▼                              │
        IDLE ──valid=1,hwrite=0──► READ ──► RENABLE
          │                                   │
          │ valid=1,hwrite=1                  │ valid=0 → IDLE
          ▼                                   │ valid=1,hwrite=0 → READ
        WWAIT                                 │ valid=1,hwrite=1 → WWAIT
        /    \
   valid=0  valid=1
      │        │
      ▼        ▼
    WRITE   WRITEP
    /   \      │
  v=0  v=1    ▼
   │    │   WENABLEP ──HWrite=1,v=0──► WRITE
   ▼    ▼               HWrite=1,v=1──► WRITEP
WENABLE WENABLEP         HWrite=0    ──► READ
```

## State Descriptions

### IDLE (000)
- Default state after reset
- `psel=0`, `penable=0`, `hready=1`
- Transitions on `valid` (hselapb=1 AND htrans=NONSEQ or SEQ)

### READ (001)
- APB setup phase for read
- Asserts `psel=1`, drives `paddr=haddr`, `pwrite=0`
- Deasserts `hready=0` to stall AHB master
- Always moves to RENABLE next cycle

### WWAIT (010)
- Captures AHB address phase for a write
- Latches `haddr → tmp_haddr`, `hwrite → HWrite`
- Does NOT assert psel yet (APB not started)
- Moves to WRITE or WRITEP based on whether next valid is pending

### WRITE (011)
- APB setup phase for write
- Drives `psel=1`, `paddr=tmp_haddr`, `pwdata=hwdata`, `pwrite=1`
- `hready=0` to stall AHB

### WRITEP (100)
- Pipelined write: a new valid transfer arrives while current write is in setup
- Latches next `haddr` and `hwrite` while driving current write to APB
- Always moves to WENABLEP

### WENABLE (101)
- APB enable phase, completes the write
- `penable=1`, `hready=1` — releases AHB master
- Returns to IDLE, READ, or WWAIT based on next transfer

### WENABLEP (110)
- Pipelined enable phase — completes current APB write
- Decides next state based on latched `HWrite` and current `valid`

### RENABLE (111)
- APB read enable phase
- `penable=1`, captures `hrdata = prdata`
- `hready=1` — data returned to AHB master
