# 5-Stage Pipelined MIPS-Style Processor (Verilog HDL)

**Status: work in progress.** I am extending my single-cycle design into a 5-stage pipeline. The building blocks are written; the pipeline registers, hazard handling, top-level module and testbench are still to do. This README is updated as each part is finished.

This project builds on my completed [Single-Cycle](https://github.com/jenischaudhary01/single-cycle-mips-processor) and [Multi-Cycle](https://github.com/jenischaudhary01/multi-cycle-processor) processors. It targets the same 22-instruction MIPS-style ISA and uses my custom two-pass C assembler to generate machine code.

---

## Progress

**Written**
- [x] 32-bit ALU (`alu.v`)
- [x] 32x32-bit register file (`register_file.v`)
- [x] Instruction memory (`memory_instruction.v`)
- [x] Data memory (`memory_data.v`)
- [x] Two-pass C assembler (`assembler.c`)

**To do**
- [ ] Control unit (main decoder and ALU control)
- [ ] Pipeline registers: IF/ID, ID/EX, EX/MEM, MEM/WB
- [ ] Forwarding unit (EX and MEM hazards)
- [ ] Hazard detection unit (load-use stall)
- [ ] Branch and jump flush logic
- [ ] Top-level pipelined module
- [ ] Testbench and test programs
- [ ] Verification against the multi-cycle processor's results for the same programs
- [ ] Waveform screenshots and results in this README

---

## Target architecture

```
    [ IF ] ------> [ ID ] ------> [ EX ] ------> [ MEM ] ------> [ WB ]
      |              |              |              |               |
  +-------+      +-------+      +-------+      +-------+       +-------+
  | IF/ID | ---> | ID/EX | ---> | EX/MEM| ---> | MEM/WB| ----> | RegWr |
  +-------+      +-------+      +-------+      +-------+       +-------+
```

- **IF:** PC sequencing and instruction fetch from a separate instruction memory
- **ID:** instruction decode, register file reads, immediate extension, control signals
- **EX:** ALU operation, branch target calculation, forwarded operand selection
- **MEM:** data memory read/write for `lw` and `sw`
- **WB:** write the ALU result or loaded data back to the register file

Separate instruction and data memories (Harvard style) avoid the structural hazard between instruction fetch and data access.

## Instruction set

Same 22-instruction MIPS-style subset as my other two processors:

| Category | Instructions | Format |
|:--|:--|:--|
| Arithmetic and logical | `add`, `sub`, `and`, `or`, `slt` | R-type |
| Shifts | `sll`, `srl` | R-type |
| Immediate | `addi`, `andi`, `ori`, `slti`, `lui` | I-type |
| Memory | `lw`, `sw` | I-type |
| Branches | `beq`, `bne`, `blez`, `bgtz`, `bltz`, `bgez` | I-type |
| Jumps | `j`, `jal`, `jr` | J-type / R-type |

## Planned hazard handling

- **Data hazards (RAW):** forward results from EX/MEM and MEM/WB to the ALU inputs
- **Load-use hazard:** detect a dependent instruction right after `lw`, insert a one-cycle bubble, and hold the PC and IF/ID register
- **Control hazards:** flush the instructions fetched after a taken branch or jump

## Planned repository structure

```
.
├── alu.v                    (done)
├── register_file.v          (done)
├── memory_instruction.v     (done)
├── memory_data.v            (done)
├── assembler.c              (done)
├── control_unit.v           (to do)
├── hazard_unit.v            (to do)
├── forwarding_unit.v        (to do)
├── pipeline registers       (to do)
├── mips_pipelined_top.v     (to do)
├── testbench/               (to do)
└── README.md
```

## Assembler

The two-pass assembler translates MIPS-style assembly (with label and branch/jump resolution) into hexadecimal machine code for use with `$readmemh`.

```
gcc -O2 assembler.c -o mips_asm
./mips_asm program.asm program.hex
```

## Simulation

Planned tools: Icarus Verilog and GTKWave. Compile and run instructions will be added once the top-level module and testbench are pushed.
