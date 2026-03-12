# Signal Description

## `valid` Signal
```verilog
valid = hselapb && (htrans == NONSEQ || htrans == SEQ)
```

`valid` is a combinational signal that indicates a legitimate AHB transfer
is being requested to this bridge. Both NONSEQ (2'b10) and SEQ (2'b11)
htrans types are accepted.

## `htrans` Encoding

| htrans | Name   | Meaning                              |
|--------|--------|--------------------------------------|
| 2'b00  | IDLE   | No transfer                          |
| 2'b01  | BUSY   | Master busy (not used by bridge)     |
| 2'b10  | NONSEQ | First beat of a new transfer         |
| 2'b11  | SEQ    | Continuation of burst transfer       |

## Pipelining Notes

AHB is a pipelined bus — the address phase of the next transfer overlaps
with the data phase of the current one. The bridge handles this with:

- `tmp_haddr` — latches the address during WWAIT so it's available in WRITE
- `HWrite` — latches hwrite during WWAIT for use in WENABLEP state
- WRITEP / WENABLEP states — dedicated states for back-to-back write transfers

## Reset Behavior

`hresetn` is active-low. On reset:
- FSM moves to IDLE state
- `hresp` is cleared to 0 (OKAY response)
- All APB outputs deassert (handled by IDLE state logic)
