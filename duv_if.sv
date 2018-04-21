`include "data_defs.v"

interface port_if();
   parameter   instr_wd  	=   `INSTR_WIDTH;
   parameter   reg_wd    	=   `REGISTER_WIDTH;
   parameter   rsp_wd    	=   `RESP_WIDTH;
   
   logic [0:reg_wd-1] 				data_in, data_out; 
   logic [0:instr_wd-1] 			op;
   logic [0:rsp_wd-1] 				resp; 
   logic [0:1] 					tag_in, tag_out;
   
endinterface

interface misc_if();  
   logic                                        reset, clock;   
endinterface
