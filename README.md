# *8-Bit-5-Stage-Microprocessor-Design*

`CURRENT STATUS : stable`

## Basic features

* Five stage (8 bit) pipelined processor with a unique data path and a control unit. 
* The stages included Instruction Fetch, Instruction Decode, Instruction Execute, Memory and Write Back.
* It has 17 instructions which can perform operations on operands in Registers/Immediate.
* Handles Jump operations based on the status/overflow flags. 
* The Architecture has 16-bit address bus and can handle a total memory space of 64KB. Allocated 32KB for ROM & 32KB for RAM.
* The User program is stored in ROM and fetched by the processor.
* Designed an assembler which can convert the Assembly language program into machine level language.
* Designed a Memory-controller for effectively mapping data space. 
* Designed 32KB RAM & ROM modules.
* Performed simulation based verification in system Verilog where the simulator reads the assembly program from .txt file and converts into Hex code and stores in ROM

## Design

### Architecture

![architecture](https://cloud.githubusercontent.com/assets/18235088/24574795/06f78cba-164d-11e7-831c-959243be27b0.png)

### Instruction Format

![image](https://cloud.githubusercontent.com/assets/18235088/24574961/8cf2e8d0-164f-11e7-9f0a-70e03ff128c2.png)

### Opcodes

![image](https://cloud.githubusercontent.com/assets/18235088/24574966/a63ed7d6-164f-11e7-9098-9ea1dd53b27e.png)

## Getting Started

Download all the project files into your local system.

### Prerequisites

`Mentor Questasim\Modelsim`

## Project Status/TODO

- [x] Compiles
- [x] Simulated `all instructions`

## Project Setup

This project has been developed with Mentor Questasim.

## Authors

* **Vinod Sake** - [Github](https://github.com/vinodsake)

## License

This project is licensed under the open-source license
