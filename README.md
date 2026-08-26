# RISCV32I 5-Stage Pipelined CPU with AXI4-Lite Wrapper & AXI4-Lite UART Slave

RISC-V 32I CPU with a 5-stage pipeline designed in SystemVerilog. 32-Bit datapath, with 32 general purpose registers and memory-mapped AXI4 decoder. Designed to be synthesised with Vivado and run on a ZYNQ-7020 FPGA. UART RX does not currently work (known limitation).


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

![Block Diagram](https://github.com/tobywr/RISCV32I/blob/main/images/risc_v_pipelined_bd.svg "Block diagram")

## All Modules Structure

## Core + Wrapper Modules

- `riscv_top_core_wrapper.sv` : Top-level core wrapper, connects all pipeline stages + modules, and the axi4-lite master ports to form the complete processor.
- `riscv_pkg.sv` : shared package of opcode / funct3/ funct7 parameters, enums and global widths used across the design
- `pc.sv` : program counter, registers next address to fetch and handles stalls + branch/jump redirects.
- `pc_plus_4_adder.sv` : does what says on tin, adds 4 to pc value.
- `imem.sv` : instruction memory (256 x 32-bit words), pre-loaded from a .hex instruction file.
- `if_id_reg.sv` : IF/ID pipeline register, latches PC and instruction fetched, handles stall / flushes.
- `imm_ext.sv` : sign-extends immediate values for specific instruction types.
- `decoder.sv` : decodes opcode/funct3/funct7 and generates control signals for rest of the data path / ALU.
- `reg.sv` : 32x32-bit register file with two read ports and one write port. 0x0 hard coded to zero.
- `id_ex_reg.sv` : ID/EX pipeline register, latches decoded operands and control signals. Handles hold (due to axi), and stall / flush.
- `forward_a.sv`/`forward_b.sv` : forwarding muxes, select operand a/b from reg file, the EX/MEM alu result or the WB value
- `hazard_forward_unit.sv` : hazard detection unit, generates the load-use stall and the forward-A / forward-B select signals.
- `operand_a_selector.sv` / `operand_b_selector.sv` : selects respective ALU operand values.
- `branch_adder.sv` : computes the branch/jump/JALR target addresses and the pc_src redirect signal.
- `alu.sv` : arithmetic logic unit; performs ADD, SUB, ANd and pass-through
- `ex_mem_reg.sv` : EX/MEM pipeline reg, latches ALU result, store data and control signals; supports hold whilst axi transaction occuring
- `dmem.sv` : DATA memory, RAM. 1KB
- `axi_addr_decoder.sv` : Routes each load/store either to internal dmem or out to axi4-lite master, based on whether ALU result address falls inside DMEM
- `axi4_lite_master.sv` : AXI4-Lite master FSM (IDLE/AW/W/B/AR/R), turns decoded read/write request into an AXI4-Lite write and read channel transaction and asserts `busy` to stall the pipeline for the duration.
- `mem_wb_reg.sv` : MEM/WB pipeline reg, latches ALU result, memory/AXI read data and control signals for writeback.
- `writeback_mux.sv` : selects the value written back to the reg file - ALU result, memory/AXI read data or pc+4 (for jal / jalr)

## AXI Slave / UART modules

- `riscv_top_FPGA.sv` : top-level wrapper for FPGA synthesis, parameterizes CLK_FREQ / BAUD_RATE and instantiates the full AXI bus.
- `axi_top_level_slave_uart.sv` : Writes the cores AXI4-Lite master directly to the UART AXI4-Lite slave, forming a single-master, single-slave AXI4-Lite bus.
- `axi_uart_slave.sv` : AXI4-Lite slave FSM (IDLE/W_DATA/B) ; accepts a write TX, and forwards its low byte to the UART transmitter, instantates uart_tx.
- `uart_tx.sv` : UART Transmitter, serialises an 8-bit byte into an 8N1 frame at a configurable baud rate and clock frequency.
## FPGA Integration & Memory maps

the `riscv_top_FPGA.sv` module handles all FPGA specific logic. 

- __Clock__ : Entire design runs on one clock, `clk`.
- __Reset__ : Runs on external `rst_n` input via a GPIO button.

### Memory map
| Address         | R/W   | Description                                                |
| --------------- | ----- | ---------------------------------------------------------- |
| `0x000`-`0x3FF` | R/W   | Data Memory (RAM)                                          |
| `0x400`+        | Write | UART: Transmits the low byte of the store data over tx_out |

any load/store address `>= 0x400` (`MEM_WORDS * 4`) is routed onto the AXI4-Lite bus instead of the `dmem`; the uart slave doesnt decode the address further.

## Running the core and a program.

1. __Software__
   1. __Write assembly__ : Write your RISC-V assembly, Compile to Risc-V hex instructions and input to `program.hex` file. An example one is provided, include one instruction on each line. (8-hex-char length)
   2. __Adding instructions__ : Include the correct location of `program.hex` in the `imem.sv` file.
2. __Hardware (Vivado)__
   1. __Create Project__ : Add all files in `/rtl` to a new vivado project.
   2. __Contraints__ : Change the `PIN.xdc` constraints file to your boards correct pins, mapping `clk`, `rst_n` etc.
   3. __Synthesise + Implement__ : Run both. Generate a bitstream, program your FPGA.

### Expected result from provided `program.hex` :

- The CPU writes the ASCII string `Hello, World\n` out of `tx_out` one byte at a time (each `SW` to `0x400` triggers a UART transmission), at the default 115200 baud / 50MHz clock, then halts forever in an infinite `JAL` loop. Connect a USB-UART adapter to `tx_out` (115200-8-N-1) to view it on a serial terminal.
__Structure of `program.hex`__:


| Hex instruction | Function                                                              |
| --------------- | --------------------------------------------------------------------- |
| 40000113        | ADDI operation, loads address `0x400` (UART) into register `x2`       |
| 04800093        | ADDI operation, loads `0x48` (`'H'`) into register `x1`               |
| 00112023        | SW operation, stores byte in `x1` to address in `x2`, transmitting it |
| ...             | repeats for each character of `Hello, World\n`                        |
| 0000006F        | JAL operation, forms an infinite loop halting the CPU                 |
