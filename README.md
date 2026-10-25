# 5-Stage Pipelined MIPS-Style Processor (Verilog HDL)

A synthesizable 32-bit 5-stage pipelined RISC processor designed and implemented in Verilog HDL. The core implements a classic Harvard memory architecture with separate instruction and data memories to eliminate structural hazards, supported by inter-stage pipeline registers and hardware hazard mitigation units.

This project builds directly upon the architecture of my completed [Single-Cycle](https://github.com/jenischaudhary01/single-cycle-mips-processor) and [Multi-Cycle](https://github.com/jenischaudhary01/multi-cycle-processor) processors, supporting the same 22-instruction MIPS-style ISA and verified using my custom two-pass C assembler.

---

## Architecture & Datapath

The core implements a classic 5-stage RISC pipeline execution model:

```text
    [ IF ] ------> [ ID ] ------> [ EX ] ------> [ MEM ] ------> [ WB ]
      |              |              |              |               |
  +-------+      +-------+      +-------+      +-------+       +-------+
  | IF/ID | ---> | ID/EX | ---> | EX/MEM| ---> | MEM/WB| ----> | RegWr |
  +-------+      +-------+      +-------+      +-------+       +-------+
      ^              |              |              |
      |          +-------+          |              |
      +--------- |Hazard | <--------+--------------+
      (Stall/    |Unit   |    (Forwarding Paths)
       Flush)    +-------+
```

### 1. Pipeline Stages
* **Instruction Fetch (IF):** Program Counter (PC) sequencing, next-PC selection, and word-aligned instruction fetches from dedicated `instruction_memory`.
* **Instruction Decode & Register Read (ID):** Opcode/funct decoding, dual-port register file reads, sign/zero extension, and control signal generation.
* **Execute & Address Calculation (EX):** Arithmetic and logical ALU operations, branch target computation, and execution-stage operand bypass selection.
* **Memory Access (MEM):** Synchronous write and asynchronous read access to dedicated `data_memory` for `lw` and `sw` operations.
* **Writeback (WB):** Commits the final ALU output or memory read data back to the register file.

### 2. Harvard Memory Model
To prevent pipeline structural hazards (where Stage 1 `IF` and Stage 4 `MEM` access memory concurrently in the same clock cycle), the processor uses independent memory blocks:
* `instruction_memory.v`: Dedicated code memory with asynchronous reads.
* `data_memory.v`: Dedicated data storage supporting synchronous writes and asynchronous reads.

---

## Instruction Set Architecture (ISA)

The processor supports a 22-instruction MIPS-style subset:

| Category | Instructions Supported | Encoding Format |
| :--- | :--- | :--- |
| **Arithmetic & Logical** | `add`, `sub`, `and`, `or`, `slt` | R-Type |
| **Shift Operations** | `sll`, `srl` | R-Type |
| **Immediate Operations** | `addi`, `andi`, `ori`, `slti`, `lui` | I-Type |
| **Memory Access** | `lw`, `sw` | I-Type |
| **Branches** | `beq`, `bne`, `blez`, `bgtz`, `bltz`, `bgez` | I-Type |
| **Jumps** | `j`, `jal`, `jr` | J-Type / R-Type |

---

## Hazard Handling Strategy

* **Data Hazards (RAW):**
  * **EX Hazard Forwarding:** Bypasses results from the `EX/MEM` pipeline register to the ALU inputs in the `EX` stage.
  * **MEM Hazard Forwarding:** Bypasses results from the `MEM/WB` pipeline register to the ALU inputs in the `EX` stage.
  * **Load-Use Stalling:** A dedicated Hazard Detection Unit identifies when an instruction immediately following a `lw` depends on the loaded value. It injects a 1-cycle bubble (NOP) and freezes the `PC` and `IF/ID` registers.
* **Control Hazards (Branches & Jumps):**
  * Branch resolution generates a pipeline flush signal on mispredicted or taken branches to clear speculatively fetched instructions in `IF/ID` and `ID/EX`.

---

## Repository Structure

```text
.
├── rtl/
│   ├── alu.v                     # 32-bit Arithmetic Logic Unit
│   ├── register_file.v           # 32x32-bit dual-read, single-write register file
│   ├── instruction_memory.v      # Harvard instruction memory (ROM/RAM)
│   ├── data_memory.v             # Harvard data memory (RAM)
│   ├── control_unit.v            # Main decoder and ALU control logic
│   ├── hazard_unit.v             # Load-use hazard detection and stall generator
│   ├── forwarding_unit.v         # Data forwarding multiplexer control logic
│   ├── pipeline_regs/
│   │   ├── if_id_reg.v           # IF -> ID pipeline latch
│   │   ├── id_ex_reg.v           # ID -> EX pipeline latch
│   │   ├── ex_mem_reg.v          # EX -> MEM pipeline latch
│   │   └── mem_wb_reg.v          # MEM -> WB pipeline latch
│   └── mips_pipelined_top.v      # Top-level datapath and control module
├── testbench/
│   ├── top_tb.v                  # Verification testbench with clock/reset stimulus
│   └── programs/                 # Assembly and hex test routines
├── assembler/
│   └── assembler.c               # Two-pass custom C assembler
└── README.md
```

---

## Current Development Status

- [x] 32-bit Arithmetic Logic Unit (`alu.v`)
- [x] 32x32-bit Dual-read Register File (`register_file.v`)
- [x] Separate Harvard Instruction and Data Memory units (`instruction_memory.v`, `data_memory.v`)
- [x] Inter-stage pipeline register specifications (`if_id`, `id_ex`, `ex_mem`, `mem_wb`)
- [ ] Hazard Detection Unit integration (Load-Use stalling)
- [ ] EX and MEM forwarding unit implementation
- [ ] Branch and Jump control flush integration
- [ ] Comprehensive verification against multi-cycle reference outputs

---

## Simulation and Verification

### Prerequisites
* **Icarus Verilog (`iverilog`)**
* **GTKWave**

### Running the Testbench
Compile and execute the simulation using `iverilog`:

```bash
# 1. Compile the top-level design, pipeline stages, and testbench
iverilog -o sim/pipelined_cpu.out rtl/*.v rtl/pipeline_regs/*.v testbench/top_tb.v

# 2. Run simulation
vvp sim/pipelined_cpu.out

# 3. View waveforms
gtkwave sim/waveform.vcd
```

---

## Tooling: Custom C Assembler
The repository includes a two-pass assembler written in C (`assembler/assembler.c`) that translates MIPS-style assembly into hexadecimal machine code compatible with `$readmemh`.

```bash
# Compile the assembler
gcc -O2 assembler/assembler.c -o assembler/mips_asm

# Assemble a program
./assembler/mips_asm testbench/programs/test_program.asm testbench/programs/program.hex


