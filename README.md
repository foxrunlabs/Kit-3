# Kit-3 FPGA 8-bit Computer

**Kit-3** is an experimental FPGA-based 8-bit computer built around a **soft-core 65C02-compatible CPU**.

The project represents the third iteration of the Kit series of homebrew computers. Where Kit-1 and Kit-2 were built around physical W65C02 processors and external support hardware, Kit-3 explores moving the computer itself into programmable logic.

The repository contains the hardware-description-language (HDL) implementation, boot-loading support, and a Verilator-based environment for simulating the design in software.

> **Project status:** Kit-3 is an early experimental project. The `master` branch contains a single development commit and should be considered a work in progress rather than a finished computer platform. This README documents the architectural direction and the components present in the repository without implying functionality beyond the checked-in implementation.

## Overview

The central idea behind Kit-3 is to implement a 65C02-based computer as a digital system inside an FPGA:

```text
             Kit-3 FPGA
┌───────────────────────────────────┐
│                                   │
│       ┌───────────────────┐       │
│       │   Soft 65C02 CPU  │       │
│       └─────────┬─────────┘       │
│                 │                 │
│            System Bus             │
│                 │                 │
│        ┌────────┴────────┐        │
│        │                 │        │
│        ▼                 ▼        │
│      Memory          Peripherals  │
│                                   │
└───────────────────────────────────┘
                  │
                  ▼
          Physical I/O / FPGA
```

Rather than wiring a physical processor, memory, address-decoding logic, and peripheral ICs together on a circuit board, those digital components can be described in HDL and synthesized into programmable logic.

This preserves the architecture and programming model of an 8-bit computer while changing how the underlying hardware is implemented.

## Repository Structure

The `master` branch is organized into three principal areas:

```text
Kit-3/
├── bootload/       # Boot-loading support
├── hdl/            # FPGA hardware-description source
├── verilator/      # Host-side HDL simulation
└── .gitignore
```

Each directory represents a different part of the development workflow.

### `hdl`

Contains the hardware-description-language source used to describe the Kit-3 digital hardware.

This is the core of the FPGA implementation.

### `bootload`

Contains the supporting boot-loading portion of the project.

### `verilator`

Contains the host-side environment for exercising the HDL design with **Verilator**.

This allows portions of the digital system to be compiled and simulated on a conventional development computer rather than requiring every development iteration to run on physical FPGA hardware.

# From Kit-1 and Kit-2 to Kit-3

Kit-3 represents a larger architectural change than the transition between the first two Kit computers.

All three projects explore the same general problem—building a small computer around the 65C02 architecture—but at progressively different levels of hardware integration.

## Kit-1

Kit-1 uses a **physical W65C02** and traditional 65xx peripheral devices.

```text
                 ┌──► 65C51 ACIA
                 │
W65C02 ──────────┼──► 65C22 VIA
                 │
                 └──► SRAM

PIC ──► bootstrap ──► sleep
```

The PIC18F47K40 acts primarily as a "Virtual ROM": it loads the BIOS into RAM during reset and then steps aside.

Kit-1 is therefore closest to a traditional discrete-component 65xx computer.

## Kit-2

Kit-2 retains the **physical W65C02**, but moves more of the surrounding hardware functionality into the PIC.

```text
W65C02 ──────► SRAM
   │
   └─────────► PIC18F47K40
                  │
                  ├──► UART
                  ├──► storage interface
                  ├──► clock
                  └──► peripheral services
```

The PIC no longer disappears after bootstrap. It remains active as a support controller.

Kit-2 therefore explores a hybrid architecture combining a classic microprocessor with a modern microcontroller.

## Kit-3

Kit-3 takes the next conceptual step by moving the **processor architecture itself into programmable logic**:

```text
Kit-1                    Kit-2                    Kit-3

Physical CPU             Physical CPU             Soft CPU
    │                        │                       │
    ▼                        ▼                       ▼
W65C02                   W65C02                  FPGA logic
    │                        │                       │
    ▼                        ▼                       ▼
Discrete 65xx            PIC-based              HDL-defined
peripherals              support                computer
```

The progression can be summarized as:

```text
Discrete hardware
       │
       ▼
Hybrid hardware / firmware
       │
       ▼
Programmable logic
```

These are not simply three versions of the same circuit. They explore different ways of partitioning the functions that make up a computer.

# Why a Soft-Core 65C02?

A **soft-core processor** is a CPU implemented as configurable digital logic rather than as a dedicated physical processor IC.

In a conventional Kit computer:

```text
65C02 instructions
        │
        ▼
Physical W65C02
        │
        ▼
External buses and peripherals
```

In Kit-3:

```text
65C02 instructions
        │
        ▼
Soft 65C02 CPU
        │
        ▼
FPGA logic
```

The programmer can still interact with a 65C02-style processor architecture, but the processor itself is now part of the FPGA design.

This creates opportunities that do not exist when using a fixed processor IC.

The surrounding computer architecture can be changed by modifying HDL rather than rewiring physical components.

# Hardware Description Languages

FPGA development differs fundamentally from conventional software development.

Ordinary software describes a sequence of operations executed by an existing processor:

```text
Source Code
    │
    ▼
Compiler
    │
    ▼
Machine Code
    │
    ▼
CPU executes instructions
```

HDL instead describes digital hardware:

```text
HDL Source
    │
    ▼
Synthesis
    │
    ▼
Digital Logic
    │
    ▼
FPGA Configuration
```

Concepts such as registers, buses, state machines, counters, multiplexers, and control signals become actual synthesized digital structures.

Kit-3 therefore operates at a lower level of abstraction than the software and firmware portions of Kit-1 and Kit-2.

# FPGA Architecture

A soft-core computer can integrate components that would otherwise require multiple physical devices:

```text
Traditional 65C02 Computer
──────────────────────────

┌───────┐
│  CPU  │
└───┬───┘
    │
════╪════════ System Bus ═════════
    │
 ┌──┴───┐   ┌────────┐   ┌────────────┐
 │Memory│   │Address │   │Peripheral  │
 │      │   │Decode  │   │Devices     │
 └──────┘   └────────┘   └────────────┘


FPGA Computer
─────────────

┌──────────────────────────────────┐
│              FPGA                │
│                                  │
│  ┌─────┐                         │
│  │ CPU │                         │
│  └──┬──┘                         │
│     │                            │
│  ═══╪════ Internal Bus ═══════   │
│     │                            │
│  ┌──┴───┐  ┌──────┐  ┌──────┐  │
│  │Memory│  │Decode│  │ I/O  │  │
│  └──────┘  └──────┘  └──────┘  │
│                                  │
└──────────────────────────────────┘
```

The architectural concepts remain recognizable, but the physical implementation changes substantially.

# Verilator Simulation

The repository includes a dedicated `verilator` directory for host-side simulation of the HDL design.

**Verilator** translates synthesizable Verilog/SystemVerilog into a software model that can be compiled and executed on a conventional computer.

Conceptually:

```text
                  HDL Source
                      │
             ┌────────┴────────┐
             │                 │
             ▼                 ▼
       FPGA Synthesis       Verilator
             │                 │
             ▼                 ▼
      Physical FPGA       C++ Model
                               │
                               ▼
                        Host Simulation
```

This creates two complementary development paths.

The synthesized design can ultimately execute in real programmable logic, while the Verilator model can be used to inspect and test digital behavior during development.

## Why Simulate?

Hardware simulation provides several advantages during FPGA development:

- shorter development iterations
- visibility into internal digital state
- repeatable test conditions
- automated testing opportunities
- debugging before FPGA programming
- reduced dependence on physical hardware
- separation of logic errors from board-level problems

This continues an idea already present in the earlier Kit projects: low-level system software and hardware should be testable independently where practical.

Kit-1 and Kit-2 used **py65** to simulate the 65C02 software environment.

Kit-3 moves the simulation boundary lower:

```text
Kit-1 / Kit-2

65C02 software
      │
      ▼
   py65
      │
      ▼
Simulated CPU


Kit-3

HDL computer
      │
      ▼
 Verilator
      │
      ▼
Simulated digital hardware
```

The change reflects the different nature of the project. Once the processor itself becomes part of the design, simulation must account for the digital hardware rather than only the software running on it.

# Boot Loading

The repository contains a separate `bootload` component for the system's boot-loading functionality.

Bootstrapping is a recurring design problem throughout the Kit series.

A processor cannot begin useful execution until the machine establishes an initial program and system state:

```text
Power On
    │
    ▼
Establish initial state
    │
    ▼
Make bootstrap code available
    │
    ▼
Reset / initialize CPU
    │
    ▼
Begin program execution
```

Kit-1 solved this with a PIC-based Virtual ROM.

Kit-2 expanded the PIC's role to initialize memory and remain active as a support controller.

Kit-3 revisits the same problem in an FPGA-based architecture, where the processor, memory interface, and supporting digital logic are themselves part of the programmable design.

# Design Progression

Taken together, the Kit projects explore three different approaches to implementing a small computer.

| Architecture | Kit-1 | Kit-2 | Kit-3 |
| --- | --- | --- | --- |
| CPU | Physical W65C02 | Physical W65C02 | Soft-core 65C02 |
| Primary implementation | Discrete ICs | CPU + microcontroller | FPGA |
| Support logic | Traditional 65xx devices | PIC firmware | Programmable logic |
| Bootstrap approach | PIC Virtual ROM | PIC memory initialization | FPGA/bootload architecture |
| Simulation focus | 65C02 software | 65C02 software | HDL/digital hardware |
| Primary exploration | Classic microcomputer | Hardware/firmware integration | FPGA computer architecture |

The progression is not simply about reducing component count.

Each project moves the boundary between **hardware and programmable behavior**:

```text
Kit-1
Hardware ━━━━━━━━━━━━━━━━ Firmware ━━

Kit-2
Hardware ━━━━━━━━━━ Firmware ━━━━━━━━

Kit-3
Programmable hardware ━━━━━━━━━━━━━━━
```

Kit-3 effectively asks a different version of the design question explored by its predecessors:

> **What does a 65C02 computer look like when the processor and surrounding digital architecture become programmable hardware?**

# Development Areas

The project touches several areas of computer engineering.

### FPGA development

The computer is expressed as synthesizable digital logic rather than assembled entirely from fixed-function ICs.

### Processor architecture

A 65C02-compatible CPU is part of the programmable system, exposing the relationship between instruction execution and the underlying digital implementation.

### Digital-system design

The project requires the coordination of processor, memory, buses, control signals, and peripheral logic.

### Hardware description

HDL is used to describe concurrent digital behavior rather than conventional sequential software.

### System integration

The processor core is only one part of the computer. It must interact correctly with memory and the surrounding logic to form a functioning system.

### Bootstrapping

As with the previous Kit machines, the system must establish a usable initial state before the CPU can execute meaningful software.

### Hardware simulation

Verilator provides a means to exercise the HDL implementation without relying exclusively on FPGA hardware.

### Hardware/software boundaries

The project explores where functionality resides when a computer transitions from discrete hardware to programmable logic.

# Relationship to the Kit Series

The three Kit projects provide a progression through different forms of computer implementation:

```text
                   KIT SERIES

                     65C02
                       │
          ┌────────────┼────────────┐
          │            │            │
          ▼            ▼            ▼

       Kit-1         Kit-2        Kit-3
          │            │            │
          ▼            ▼            ▼

      Discrete       Hybrid        FPGA
      Hardware     CPU + MCU    Soft-Core CPU
          │            │            │
          ▼            ▼            ▼

       Wiring       Firmware        HDL
```

**Kit-1** explores a traditional 65C02 computer built from discrete processor, memory, and peripheral devices.

**Kit-2** explores hardware/software co-design by retaining the physical 65C02 while consolidating support functions into a PIC microcontroller.

**Kit-3** moves the computer into programmable logic and replaces the physical processor with a soft-core implementation.

Together, the projects document an exploration of computer architecture across three implementation technologies rather than merely three revisions of the same machine.

# Project Status

Kit-3 is an **early-stage experimental project**.

The `master` branch contains a single development commit organized around:

- FPGA/HDL source
- boot-loading support
- Verilator simulation

Unlike Kit-1, the repository does not represent a documented finished computer system. Unlike the original design documentation associated with Kit-2, this README intentionally avoids assigning unverified capabilities or planned functionality to the implementation.

Kit-3 is best understood as an exploration of the next architectural step in the Kit series: moving from a physical 65C02 computer toward a computer implemented as programmable digital logic.

Even in its incomplete state, the project demonstrates the progression from:

```text
physical processor
       │
       ▼
microcontroller-assisted processor
       │
       ▼
soft-core processor in FPGA
```

and extends the Kit series from computer construction and embedded firmware into FPGA and digital-logic design.

## License

See the repository source and project files for applicable licensing information.