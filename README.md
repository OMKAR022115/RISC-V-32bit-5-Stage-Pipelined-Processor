# 🚀 RISC-V 32-bit 5-Stage Pipelined Processor

> A 32-bit RISC-V processor designed in Verilog HDL featuring a classic 5-stage pipeline architecture with simulation and FPGA implementation.

<p align="center">

![Verilog](https://img.shields.io/badge/Language-Verilog-blue?style=for-the-badge)

![Architecture](https://img.shields.io/badge/Architecture-RISC--V-success?style=for-the-badge)

![Pipeline](https://img.shields.io/badge/Pipeline-5--Stage-orange?style=for-the-badge)

![FPGA](https://img.shields.io/badge/FPGA-Ready-red?style=for-the-badge)

</p>

---

# 📌 Project Overview

This project presents the design and implementation of a **32-bit RISC-V processor** based on a **5-stage pipelined architecture** using **Verilog HDL**. The processor executes RISC-V instructions through Instruction Fetch, Instruction Decode, Execute, Memory Access, and Write Back stages, improving instruction throughput while maintaining a modular hardware design suitable for FPGA implementation.

---
# 🏛️ Processor Architecture

The processor is based on the **RISC-V RV32I instruction set architecture** and implements a **5-stage pipelined datapath**. Each stage performs a dedicated operation, enabling multiple instructions to execute concurrently and improving overall throughput.

### Pipeline Stages

| Stage | Description |
|-------|-------------|
| IF | Instruction Fetch |
| ID | Instruction Decode & Register Read |
| EX | Execute / ALU Operations |
| MEM | Data Memory Access |
| WB | Write Back to Register File |

# 📈 Performance Summary

| Parameter | Result |
|-----------|--------|
| Architecture | RISC-V RV32I |
| Processor Width | 32-bit |
| Pipeline Stages | 5 |
| HDL | Verilog |
| Maximum Operating Frequency | **180.61 MHz** |
| Minimum Clock Period | **5.537 ns** |
| RTL Simulation | ✅ Passed |
| Functional Verification | ✅ Passed |
| Timing Analysis | ✅ Passed |
| FPGA Compatible | ✅ Yes |

# ✨ Features

- 32-bit RISC-V Architecture
- Five-stage pipeline
- Modular Verilog HDL design
- Register File
- ALU
- Control Unit
- Immediate Generator
- Instruction Memory
- Data Memory
- FPGA compatible
- RTL Simulation
---

# 🏗 Pipeline Stages

- Instruction Fetch (IF)
- Instruction Decode (ID)
- Execute (EX)
- Memory Access (MEM)
- Write Back (WB)
---

# 🛠 Tools Used

- Verilog HDL
- Xilinx Vivado
- ModelSim / QuestaSim
- FPGA Development Board
---

# 📂 Repository Structure

```text
Verilog/
Testbench/
Simulation/
Documentation/
README.md
LICENSE
``
# 🚀 Future Improvements

- Hazard Detection Unit
- Forwarding Unit
- Branch Prediction
- Cache Memory
- Performance Optimization

# 📊 Results

The developed 32-bit RISC-V processor was successfully designed, simulated, and verified using Verilog HDL. Individual pipeline stages and supporting modules were tested independently before being integrated into the complete processor. Simulation results confirmed correct execution of supported RISC-V instructions, proper pipeline operation, and successful data flow between all five stages.

### Key Results

- ✅ Successfully implemented a 32-bit RISC-V processor.
- ✅ Verified all five pipeline stages (IF, ID, EX, MEM, WB).
- ✅ Correct execution of arithmetic and logical instructions.
- ✅ Functional Register File, ALU, Control Unit, and Data Memory.
- ✅ RTL design successfully synthesized and verified.
- ✅ Simulation waveforms confirmed correct processor functionality.
- ✅ FPGA-compatible modular hardware design.

  # 🎯 Learning Outcomes

This project provided practical experience in computer architecture and digital hardware design through the implementation of a pipelined RISC-V processor.

### Skills Gained

- ✔ Understanding of RISC-V Instruction Set Architecture (ISA)
- ✔ Design of a 32-bit pipelined processor
- ✔ Verilog HDL coding and modular design
- ✔ Pipeline implementation (IF, ID, EX, MEM, WB)
- ✔ ALU and Control Unit design
- ✔ Register File implementation
- ✔ Memory interface design
- ✔ RTL simulation and debugging

  ### Technical Knowledge Acquired

- Computer Architecture
- Digital Logic Design
- RTL Design Methodology
- FPGA Design Flow
- Hardware Debugging
- Processor Datapath Design
- Control Signal Generation
- Pipeline Execution
- Verilog HDL Best Practices


# 👨‍💻 Authors

**Omkar Angadi Saikiran R Baddi Kiran Y Alur Omkareshwar M K**

Electronics & Communication Engineering

FPGA | Verilog | RISC-V | Embedded Systems | VLSI
