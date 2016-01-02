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
package vgm_risc_v;


struct instruction like any_sequence_item {
  const kind : instr_e;

  %len_e;
  %opcode : opcode_e;
  %args : instruction_args;
    keep type args.kind == kind;
};


struct instruction_args {
  const kind : instr_e;
  const format : format_e;
};


extend R_type instruction_args {
  rd : reg_e;
  rs1 : reg_e;
  rs2 : reg_e;

  private get_funct3() : uint(bits:3) is empty;
  private get_funct7() : uint(bits:7) is empty;

  do_pack(options : pack_options, l : *list of bit) is also {
    var L : list of bit = pack(packing.low, rd, get_funct3(), rs1, rs2,
      get_funct7());
    l.add(L);
  };

  do_unpack(options : pack_options, l: list of bit, begin: int) : int is only {
    var L : list of bit = l[begin..];
    var funct3 : uint(bits:3);
    var funct7 : uint(bits:7);
    unpack(packing.low, L, rd, funct3, rs1, rs2, funct7);
    result = begin + 5 + 3 + 5 + 5 + 7;
  };
};


extend I_type instruction_args {
  rd : reg_e;
  rs1 : reg_e;
  imm : uint(bits:12);

  private get_funct3() : uint(bits:3) is empty;

  do_pack(options : pack_options, l : *list of bit) is also {
    var L : list of bit = pack(packing.low, rd, get_funct3(), rs1, imm);
    l.add(L);
  };

  do_unpack(options : pack_options, l: list of bit, begin: int) : int is only {
    var L : list of bit = l[begin..];
    var funct3 : uint(bits:3);
    unpack(packing.low, L, rd, funct3, rs1, imm);
    result = begin + 5 + 3 + 5 + 12;
  };
};


extend S_type instruction_args {
  rs1 : reg_e;
  rs2 : reg_e;
  imm : uint(bits:12);

  private get_funct3() : uint(bits:3) is empty;

  do_pack(options : pack_options, l : *list of bit) is also {
    var L : list of bit = pack(packing.low, imm[4:0], get_funct3(), rs1, rs2,
      imm[11:5]);
    l.add(L);
  };

  do_unpack(options : pack_options, l: list of bit, begin: int) : int is only {
    var L : list of bit = l[begin..];
    var funct3 : uint(bits:3);
    unpack(packing.low, L, imm[4:0], funct3, rs1, rs2, imm[11:5]);
    result = begin + 5 + 3 + 5 + 5 + 7;
  };
};


extend SB_type instruction_args {
  rs1 : reg_e;
  rs2 : reg_e;
  imm : uint(bits:13);

  keep imm[0:0] == 0;

  private get_funct3() : uint(bits:3) is empty;

  do_pack(options : pack_options, l : *list of bit) is also {
    var L : list of bit = pack(packing.low, imm[11:11], imm[4:1], get_funct3(),
      rs1, rs2, imm[10:5], imm[12:12]);
    l.add(L);
  };

  do_unpack(options : pack_options, l: list of bit, begin: int) : int is only {
    var L : list of bit = l[begin..];
    var funct3 : uint(bits:3);
    unpack(packing.low, L, imm[4:0], imm[11:11], imm[4:1], funct3, rs1, rs2,
      imm[10:5], imm[12:12]);
    result = begin + 5 + 3 + 5 + 5 + 7;
  };
};


extend U_type instruction_args {
  rd : reg_e;
  imm : uint(bits:32);

  keep imm[11:0] == 0;

  do_pack(options : pack_options, l : *list of bit) is also {
    var L : list of bit = pack(packing.low, rd, imm[31:12]);
    l.add(L);
  };

  do_unpack(options : pack_options, l: list of bit, begin: int) : int is only {
    var L : list of bit = l[begin..];
    unpack(packing.low, L, rd, imm[31:12]);
    result = begin + 5 + 20;
  };
};


extend UJ_type instruction_args {
  rd : reg_e;
  imm : uint(bits:21);

  keep imm[0:0] == 0;

  do_pack(options : pack_options, l : *list of bit) is also {
    var L : list of bit = pack(packing.low, rd, imm[19:12], imm[11:11],
      imm[10:1], imm[20:20]);
    l.add(L);
  };

  do_unpack(options : pack_options, l: list of bit, begin: int) : int is only {
    var L : list of bit = l[begin..];
    unpack(packing.low, L, rd, imm[19:12], imm[11:11], imm[10:1], imm[20:20]);
    result = begin + 5 + 20;
  };
};
'>



// Integer Register-Immediate Instructions
<'
extend instruction {
  when [ ADDI, SLTI, SLTIU, ANDI, ORI, XORI ] {
    keep opcode == OP_IMM;
    keep type args is a I_type instruction_args;
  };

  when [ SLLI, SRLI, SRAI ] {
    keep opcode == OP_IMM;
    keep type args is a I_type instruction_args;
  };

  keep kind == LUI => opcode == LUI;
  keep kind == AUIPC => opcode == AUIPC;
  when [ LUI'kind, AUIPC'kind ] { keep type args is a U_type instruction_args };
};


extend I_type instruction_args {
  get_funct3() : uint(bits:3) is also {
    case (kind) {
      [ ADDI ] : { result = 0b000 };
      [ SLTI ] : { result = 0b010 };
      [ SLTIU ] : { result = 0b011 };
      [ XORI ] : { result = 0b100 };
      [ ANDI ] : { result = 0b111 };
      [ SLLI ] : { result = 0b001 };
      [ SRLI, SRAI ] : { result = 0b101 };
    };
  };

  keep kind in [ SLLI, SRLI ] => imm[11:5] == 0b0000000;
  keep kind == SRAI => imm[11:5] == 0b0100000;
};
'>



// Integer Register-Register Operations
<'
extend instruction {
  when [
    ADD, SLT, SLTU,
    AND, OR, XOR,
    SLL, SRL,
    SUB, SRA
  ] {
    keep opcode == OP;
    keep type args is a R_type instruction_args;
  };
};


extend R_type instruction_args {
  get_funct3() : uint(bits:3) is also {
    case (kind) {
      [ ADD, SUB ] : { result = 0b000 };
      [ SLL ] : { result = 0b001 };
      [ SLT ] : { result = 0b010 };
      [ SLTU ] : { result = 0b011 };
      [ XOR ] : { result = 0b100 };
      [ SRLI, SRAI ] : { result = 0b101 };
      [ OR ] : { result = 0b110 };
      [ AND ] : { result = 0b111 };
    };
  };

  get_funct7() : uint(bits:7) is also {
    case (kind) {
      [ ADD, SLL, SLT, SLTU, XOR, SRL, OR, AND ] : { result = 0b0000000 };
      [ SUB, SRA ] : { result = 0b0100000 };
    };
  };
};
'>



// Unconditional Jumps
<'
extend instruction {
  when JAL'kind {
    keep opcode == JAL;
    keep type args is a U_type instruction_args;
  };

  when JALR'kind {
    keep opcode == JALR;
    keep type args is a I_type instruction_args;
  };
};


extend I_type instruction_args {
  get_funct3() : uint(bits:3) is also {
    case (kind) {
      [ JALR ] : { result = 0b000 };
    };
  };
};
'>



// Conditional Branches
<'
extend instruction {
  when [
    BEQ, BNE,
    BLT, BLTU,
    BGE, BGEU
  ] {
    keep opcode == BRANCH;
    keep type args is a SB_type instruction_args;
  };
};


extend SB_type instruction_args {
  get_funct3() : uint(bits:3) is also {
    case (kind) {
      [ BEQ ] : { result = 0b000 };
      [ BNE ] : { result = 0b001 };
      [ BLT ] : { result = 0b100 };
      [ BLTU ] : { result = 0b101 };
      [ BGE ] : { result = 0b110 };
      [ BGEU ] : { result = 0b111 };
    };
  };
};
'>



// Load and Store Instructions
<'
extend instruction {
  when [ LW, LH, LHU, LB, LBU ] {
    keep opcode == LOAD;
    keep type args is a I_type instruction_args;
  };

  when [ SW, SH, SB ] {
    keep opcode == STORE;
    keep type args is a S_type instruction_args;
  };
};


extend instruction_args {
  when I_type {
    get_funct3() : uint(bits:3) is also {
      case (kind) {
        [ LB ] : { result = 0b000 };
        [ LH ] : { result = 0b001 };
        [ LW ] : { result = 0b010 };
        [ LBU ] : { result = 0b100 };
        [ LHU ] : { result = 0b101 };
      };
    };
  };

  when S_type {
    get_funct3() : uint(bits:3) is also {
      case (kind) {
        [ SB ] : { result = 0b000 };
        [ SH ] : { result = 0b001 };
        [ SW ] : { result = 0b010 };
      };
    };
  };
};
'>



// Memory Model
<'
extend instruction {
  when [ FENCE, FENCE_I ] {
    keep opcode == MISC_MEM;
    keep type args is a I_type instruction_args;
  };
};


extend instruction_args {
  when I_type {
    keep kind in [ FENCE, FENCE_I ] => all of {
      rd == x0;
      rs1 == x0;
    };

    get_funct3() : uint(bits:3) is also {
      case (kind) {
        [ FENCE ] : { result = 0b000 };
        [ FENCE_I ] : { result = 0b001 };
      };
    };


    keep kind == FENCE => imm[11:8] == 0x0;
    keep kind == FENCE_I => imm == 0x0;
  };
};
'>



// System Instructions
<'
extend instruction {
  when [ SCALL, SBREAK ] {
    keep opcode == SYSTEM;
    keep type args is a I_type instruction_args;
  };
};


extend instruction_args {
  when I_type {
    keep kind in [ SCALL, SBREAK ] => all of {
      rd == x0;
      rs1 == x0;
    };

    get_funct3() : uint(bits:3) is also {
      case (kind) {
        [ SCALL, SBREAK ] : { result = 0b000 };
      };
    };

    keep kind == SCALL => imm == 0b000000000000;
    keep kind == SBREAK => imm == 0b000000000001;
  };
};
'>



// Timers and Counters
<'
extend instruction {
  when [
    RDCYCLE, RDCYCLEH,
    RDTIME, RDTIMEH,
    RDINSTRET, RDINSTRETH
  ] {
    keep opcode == SYSTEM;
    keep type args is a I_type instruction_args;
  };
};


extend instruction_args {
  when I_type {
    keep kind in [
      RDCYCLE, RDCYCLEH,
      RDTIME, RDTIMEH,
      RDINSTRET, RDINSTRETH
    ] => all of {
      rs1 == x0;
    };

    get_funct3() : uint(bits:3) is also {
      case (kind) {
        [ RDCYCLE, RDCYCLEH, RDTIME, RDTIMEH, RDINSTRET, RDINSTRETH ] : {
          result = 0b000 };
      };
    };

    keep kind == RDCYCLE => imm == 110000000000;
    keep kind == RDCYCLEH => imm == 110000000000;
    keep kind == RDTIME => imm == 110000000000;
    keep kind == RDTIMEH => imm == 110000000000;
    keep kind == RDINSTRET => imm == 110000000000;
    keep kind == RDINSTRETH => imm == 110000000000;
  };
};
'>
