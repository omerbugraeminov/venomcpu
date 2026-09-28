# Venom CPU

Venom is a simple 8-bit processor written from scratch in Verilog. It is a learning project: the goal is to understand how a CPU works by designing every part of it by hand. It is developed with Gowin EDA and targets the Sipeed Tang Nano 20K board.

## Overview

- 8-bit datapath
- 8 general-purpose 8-bit registers (R0–R7)
- Fixed-length 21-bit instruction word, 16 instructions
- Separate instruction memory and data memory (256 entries each)
- Single-cycle execution, except for multiply and divide, which stall the processor until they finish
- Conditional (BEQ, BNE) and unconditional (JUMP) branches

## Instruction format

```
 20      17 16    14 13    11 10     8 7              0
+----------+--------+--------+--------+----------------+
|  opcode  |  regA  |  regB  | outreg |      data      |
|  4 bits  | 3 bits | 3 bits | 3 bits |     8 bits     |
+----------+--------+--------+--------+----------------+
```

- `regA`, `regB`: source registers
- `outreg`: destination register
- `data`: immediate value, RAM address, or branch target, depending on the instruction

Unused fields are set to `0`.

## Instruction set

| Opcode | Mnemonic | Operation |
|--------|----------|-----------|
| `0000` | NOP   | No operation |
| `0001` | JUMP  | `PC ← data` |
| `0010` | ADD   | `R[outreg] ← R[regA] + R[regB]` |
| `0011` | SUB   | `R[outreg] ← R[regA] - R[regB]` |
| `0100` | MUL   | `R[outreg] ← R[regA] × R[regB]` (low 8 bits, multi-cycle) |
| `0101` | DIV   | `R[outreg] ← R[regA] / R[regB]` (quotient, multi-cycle, returns 0 when dividing by 0) |
| `0110` | XOR   | `R[outreg] ← R[regA] ^ R[regB]` |
| `0111` | AND   | `R[outreg] ← R[regA] & R[regB]` |
| `1000` | OR    | `R[outreg] ← R[regA] \| R[regB]` |
| `1001` | LOAD  | `R[outreg] ← RAM[data]` |
| `1010` | STORE | `RAM[data] ← R[regA]` |
| `1011` | LDI   | `R[outreg] ← data` |
| `1100` | BEQ   | if `R[regA] == R[regB]` then `PC ← data` |
| `1101` | HALT  | Stop execution (PC holds its value until reset) |
| `1110` | MOV   | `R[outreg] ← R[regA]` |
| `1111` | BNE   | if `R[regA] != R[regB]` then `PC ← data` |

## Architecture

```
            +------------+     +-------------+
  clk ----->|  pcounter  |---->|   instmem   |
            |            | PC  |             |
            +------------+     +------+------+
               ^    ^                 | 21 bits
      branch   |    | stall           v
               |    |          +--------------+
               |    |          | instructions |  splits the instruction into fields
               |    |          +------+-------+
               |    |                 | opcode, regA, regB, outreg, data
               |    |                 v
               |    |          +--------------+
               +----+----------| controlunit  |  generates control signals
                               +--------------+

        +-----------+        +----------------+        +-------------+
        |  regfile  |------->|      alu       |        | datamemory  |
        |  R0–R7    |  A, B  |                |        |  256 bytes  |
        +-----------+        +--------+-------+        +------+------+
              ^                       |                       |
              |                       v                       v
              |   +-------------------------------------------------+
              +---|  mux:  ALU result / RAM data / data field       |
                  +-------------------------------------------------+
```

The value written back to the register file comes from a 3-input mux:

- `00`: ALU result (arithmetic/logic instructions, MOV)
- `01`: data read from RAM (LOAD)
- `10`: the instruction's `data` field (LDI)

### Multi-cycle operations and stalling

The multiplier (`mul8bit.v`, shift-and-add) and divider (`div8bit.v`, repeated subtraction) take several cycles. When a MUL or DIV instruction is decoded:

1. A one-cycle `start` pulse is sent to the ALU and the `runi` flag is set.
2. The `stall` signal holds the PC and blocks register writes.
3. When the ALU raises `done`, the result is written back, `runi` is cleared, and the PC advances.

HALT reuses the same `stall` signal. Since the PC stops, the same HALT instruction is fetched on every cycle, so the CPU stays halted until reset.

### Branching

For BEQ and BNE the ALU computes `regA - regB`, and the `zero` flag is set when the result is zero. The PC's branch input is:

```verilog
jump || (beq && zero) || (bne && !zero)
```

## Source files

| File | Module | Description |
|------|--------|-------------|
| `src/datapath.v` | `datapath` | Top-level CPU module, connects all components |
| `src/pc.v` | `pcounter` | Program counter (reset, stall, branch) |
| `src/instructionmemory.v` | `instmem` | Instruction memory, the program lives here |
| `src/instructions.v` | `instructions` | Splits the instruction word into fields |
| `src/controlunit.v` | `controlunit` | Decodes the opcode into control signals |
| `src/registerfile.v` | `regfile` | 8 × 8-bit register file |
| `src/alu.v` | `alu` | Arithmetic/logic unit with `zero` and `done` flags |
| `src/adder8bit.v`, `adder4bit.v`, `adder2bit.v`, `fulladder.v`, `halfadder.v` | | Adder chain |
| `src/sub8bit.v` | `sub8bit` | Subtractor |
| `src/mul8bit.v` | `mul8bit` | Multi-cycle multiplier |
| `src/div8bit.v` | `div8bit` | Multi-cycle divider |
| `src/datamemory.v` | `datamemory` | 256-byte data memory |
| `src/mux.v` | `mux` | 3-input write-back mux |

## Example program

A loop that counts R1 from 0 to 5. Programs are written directly into `instructionmemory.v`:

```verilog
8'b00000000: outinst = 21'b1011_000_000_001_00000000; // LDI  R1, 0
8'b00000001: outinst = 21'b1011_000_000_010_00000101; // LDI  R2, 5
8'b00000010: outinst = 21'b1011_000_000_011_00000001; // LDI  R3, 1
8'b00000011: outinst = 21'b0010_001_011_001_00000000; // ADD  R1, R1, R3   (loop start)
8'b00000100: outinst = 21'b1111_001_010_000_00000011; // BNE  R1, R2, 3
8'b00000101: outinst = 21'b1011_000_000_100_01100011; // LDI  R4, 99
8'b00000110: outinst = 21'b1101_000_000_000_00000000; // HALT
```

When it finishes, R1 = 5, R4 = 99, and the CPU is halted at address 6.

## Simulation

With Icarus Verilog and a testbench that instantiates `datapath`:

```
iverilog -g2005 -o sim src/*.v testbench.v
vvp sim
```

Add `$dumpfile` / `$dumpvars` to the testbench to inspect waveforms in GTKWave.

## License

See [LICENSE](LICENSE).
