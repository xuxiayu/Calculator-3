`include "data_defs.v"

interface port_if();
   parameter instr_wd = `INSTR_WIDTH;
   parameter data_wd = `DATA_WIDTH;
   parameter rsp_wd = `RESP_WIDTH;
   parameter tag_wd = `TAG_WIDTH;
   parameter reg_wd = `REGISTER_WIDTH;

   logic [0:data_wd-1] data_in, data_out;
   logic [0:instr_wd-1] op;
   logic [0:rsp_wd-1] 	resp;
   logic [0:tag_wd-1] 	tag_in,tag_out;
   logic [0:reg_wd-1] 	d1,d2,r1;
   
endinterface

interface misc_if();
   logic 			reset, clock;
endinterface
  
   
		     
		   