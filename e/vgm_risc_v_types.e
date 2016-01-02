// Copyright 2016 Tudor Timisescu (verificationgentleman.com)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


<'
type len_e : [
  BIT32 = 0b11
] (bits:2);


// Integer Register-Immediate Instructions
type instr_e : [
  ADDI, SLTI, SLTIU,
  ANDI, ORI, XORI,
  SLLI, SRLI, SRAI,
  LUI, AUIPC
];

// Integer Register-Register Operations
extend instr_e : [
  ADD, SLT, SLTU,
  AND, OR, XOR,
  SLL, SRL,
  SUB, SRA
];

// Unconditional Jumps
extend instr_e : [
  JAL,
  JALR
];

// Conditional Branches
extend instr_e : [
  BEQ, BNE,
  BLT, BLTU,
  BGE, BGEU
];

// Load and Store Instructions
extend instr_e : [
  LW, LH, LHU, LB, LBU,
  SW, SH, SB
];

// Memory Model
extend instr_e : [
  FENCE, FENCE_I
];

// System Instructions
extend instr_e : [
  SCALL, SBREAK
];

// Timers and Counters
extend instr_e : [
  RDCYCLE, RDCYCLEH,
  RDTIME, RDTIMEH,
  RDINSTRET, RDINSTRETH
];


type format_e : [
  R_type, I_type, S_type, SB_type, U_type, UJ_type
];


// TODO update values
type opcode_e : [
  LOAD = 0b00_000,
  STORE = 0b01_000,
  BRANCH = 0b11_000,
  JALR = 0b11_001,
  MISC_MEM = 0b00_011,
  JAL = 0b11_011,
  OP_IMM = 0b00_100,
  OP = 0b01_100,
  SYSTEM = 0b11_100,
  AUIPC = 0b00_101,
  LUI = 0b01101
] (bits:5);


type reg_e : [
  x0, x1, x2, x3, x4, x5, x6, x7,
  x8, x9, x10, x11, x12, x13, x14, x15,
  x16, x17, x18, x19, x20, x21, x22, x23,
  x24, x25, x26, x27, x28, x29, x30, x31
] (bits:5);
'>
