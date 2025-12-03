# RISCV32I Sincle-Cycle processor.

Simple RISC-V 32 I Single cycle processor designed in SystemVerilog. 32-Bit datapath, with 32 general purpose registers. Designed to be synthesized with Vivado and run on an FPGA. Deisng includes memory-mapped GPIO output for LEDs.

## Operation Codes implemented

| Instruction | Type   | Opcode     | funct3 | funct7     | Description                 |
| ----------- | ------ | ---------- | ------ | ---------- | --------------------------- |
| ADDI        | I-Type | 7'b0010011 | 3'b000 | n/a        | Add immediate               |
| ADD         | R-Type | 7'b0110011 | 3'b000 | 7'b0000000 | Add two registers           |
| SUB         | R-Type | 7'b0110011 | 3'b000 | 7'b0100000 | Subtract two register       |
| AND         | R-Type | 7'b0110011 | 3'b111 | 7'b0000000 | Bitwise AND of two register |
| LW          | I-Type | 7'b0000011 | 3'b010 | n/a        | Load word from memory       |
| SW          | S-Type | 7'b0100011 | 3'b010 | n/a        | Store Word to memory        |
| BEQ         | B-Type | 7'b1100011 | 3'b000 | n/a        | Branch if Equal             |
| JAL         | J-Type | 7'b1101111 | n/a    | n/a        | Jump and Link               |
| JALR        | I-Type | 7'b1100111 | 3'b000 | n/a        | Jump and Link register      |
| LUI         | U-Type | 7'b0110111 | n/a    | n/a        | Load upper immediate        |

## Architecture + Block diagram.

![Block Diagram](https://github.com/tobywr/RISCV32I/blob/main/images/Screenshot%20from%202025-09-08%2017-47-39.png "Block diagram")

### All Modules

- `riscv_fpga_top.sv`: Top-level wrapper for FPGA synthesis, instantiates CPU, handles reset synchronization and connects I/O.
- `riscv_top_core.sv`: Main cpu core, connects all datapaths and modules.
- `imem.sv`: Instruction memory, pre-loaded with `.hex` instruction file.
- `dmem.sv`: Data memory, RAM.
- `decoder.sv`: Decoded opcode instructions, generates control signals for other modules.
- `alu.sv`: Arithmetic logic unit, performs `AND`, `OR` etc.
- `register.sv`: 32-register module.
- `pc.sv`: Program counter with logic for branches / jumps.
- `imm_extender.sv`: Sign-extends immediate values from instructions.
- `operand_a_selector.sv`: Handles `LUI`, `JALR` and `JAL` operations.

## FPGA Integration & Memory maps

the `riscv_fpga_top.sv` module handles all FPGA specific logic. 

- __Clock__ : Entire design runs on one clock, `clk`.
- __Reset__ : Runs on external `rst_n` input via a GPIO button.

### Memory map
| Address         | R/W        | Description                                               |
| --------------- | ---------- | --------------------------------------------------------- |
| `0x000`-`0x0FF` | R/W        | Data Memory (RAM)                                         |
| `0x104`         | Write only | GPIO: Output, writes to `LED1` (bit 1) and `LED2` (bit 2) |

## Running the core and a program.

1. __Software__
   1. __Write assembly__ : Write your RISC-V assembly, Compile to Risc-V hex instructions and input to `program.hex` file. An example one is provided, include one instruction on each line. (8-hex-char length)
   2. __Adding instructions__ : Include the correct location of `program.hex` in the `imem.sv` file.
2. __Hardware (Vivado)__
   1. __Create Project__ : Add all files in `/rtl` to a new vivado project.
   2. __Contraints__ : Change the `PIN.xdc` constraints file to your boards correct pins, mapping `clk`, `rst_n` etc.
   3. __Synthesise + Implement__ : Run both. Generate a bitstream, program your FPGA.

### Expected result from provided `program.hex` :

- LEDs at pins specified in `PIN.xdc` file should light up, and stay lit forever.

__Structure of `program.hex`__:


| Hex instruction | Function                                                                                                              |
| --------------- | --------------------------------------------------------------------------------------------------------------------- |
| 00300293        | ADDI operation, adds 3 to the register address x5                                                                     |
| 10400313        | ADDI operation, adds 260 to register x6 (260 -> 0x104 (Address of GPIO out))                                          |
| 00532023        | SW operation, reads value from reg x5 (3), reads address from reg x6 (0x104), stores value 3 to memory address 0x104. |
| 0000006F        | JAL operation, forms an infinite loop halting the CPU.                                                                |
