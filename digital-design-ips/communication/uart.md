# UART Controller – Verilog HDL

## Overview
UART Transmitter and Receiver designed in Verilog with configurable baud rate.

## Features
- FSM-based TX and RX
- Parameterized baud-rate generator
- Framing error detection
- Self-checking testbench 

## Simulation
- Tool: Xilinx Vivado
- Verified TX/RX loopback functionality

## How to Run
1. Open Vivado
2. Add RTL and TB
3. Run simulation

# UART Communication Protocol

## Overview
UART (Universal Asynchronous Receiver Transmitter) is a serial communication protocol used for transmitting and receiving data between digital systems such as microcontrollers, FPGA boards, sensors, and computers.

UART uses asynchronous communication, meaning no separate clock signal is required between transmitter and receiver.

---

# Features
- Full duplex communication
- Asynchronous serial communication
- Configurable baud rate
- Simple hardware interface
- Widely used in embedded systems and FPGA designs

---

# UART Frame Format

A UART frame consists of:

| Field        | Bits |
|--------------|------|
| Start Bit    | 1    |
| Data Bits    | 5–9  |
| Parity Bit   | Optional |
| Stop Bits    | 1 or 2 |

Example (8N1 format):

```text
Start | D0 D1 D2 D3 D4 D5 D6 D7 | Stop
  0   |        8 Data Bits      |  1
## Author
Dechamma I S
