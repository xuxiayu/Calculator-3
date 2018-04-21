`define 	CLK_PERIOD			10

`define     REGISTER_WIDTH      32  
`define     INSTR_WIDTH          4
`define     RESP_WIDTH           2

// ARITHMETIC
`define     NO_OP	        4'b0000
`define     ADD		        4'b0001
`define     SUB		        4'b0010
// SHIFTING
`define     SHL         	4'b0101
`define     SHR         	4'b0110
// RESPONSE
`define     SUCC                2'b01
`define     INV_OR_UNDR_OVRFL   2'b10
`define     INTERNAL_ERR        2'b11


//DHARA//
//DATA
`define     MAX         	32'b11111111111111111111111111111111
`define     MAX_MINUS_ONE         	32'b11111111111111111111111111111110
`define     MAX_OP         	4'b1111
//DHARA//
