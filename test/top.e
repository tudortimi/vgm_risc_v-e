<'
import e/vgm_risc_v_top;


extend sys {
  run() is also {
    var instr : instruction;
    var data : uint(bits:32);

    gen instr keeping { .kind == JALR; };
    print instr, instr.args;
    print pack(packing.low, instr);
    print instr.as_a(JALR'kind instruction).args.imm using bin;

    gen instr keeping {
      it is a JALR'kind instruction (jalr) and
        jalr.args.imm == 0xded;
    };
    print instr, instr.args;
    print instr.as_a(JALR'kind instruction).args.imm using hex;

    gen instr keeping {
      it is a LUI'kind instruction (lui) and
        lui.args.imm[31:16] == 0xbeef and
        lui.args.imm[15:12] == 0x0;
    };
    print instr;
    print pack(packing.low, instr);

    gen instr keeping {
      it is a ADD'kind instruction (add) and
        add.args.rd == x4 and
        add.args.rs1 == x2 and
        add.args.rs2 == x3;
    };
    print instr, instr.args;
    print pack(packing.low, instr);
  };
};
'>
