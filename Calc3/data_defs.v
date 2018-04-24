`define CLK_PERIOD 10

`define DATA_WIDTH 32
`define INSTR_WIDTH 4
`define RESP_WIDTH 2
`define TAG_WIDTH 2
`define REGISTER_WIDTH 4
`define DELAY_WIDTH 4
//ARITHMETIC CMDS
`define NO_OP  4'b0000
`define ADD 4'b0001
`define SUB 4'b0010

//SHIFT CMDS
`define SHL 4'b0101
`define SHR 4'b0110

//store fech cmds
`define STORE 4'b1001
`define FETCH 4'b1010
//branch cmds
`define BZERO 4'b1100
`define BEQUAL 4'b1101

`define SUCC 2'b01
`define UNDR_OVRFL 2'b10
`define INTERNAL_ERR 2'b11
`define MAX 32'b11111111111111111111111111111111
