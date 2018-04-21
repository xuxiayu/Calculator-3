class mon_trans extends uvm_sequence_item;

   int port_id;
   int cmd_nResp;

   bit [0:`INSTR_WIDTH-1] op;
   bit [0:`TAG_WIDTH-1]   tag_in, tag_out;
   bit [0:`REGISTER_WIDTH-1] d1, d2, r1;
   bit [0:`DATA_WIDTH-1]     data_in,data_out;
   bit [0:`RESP_WIDTH-1]     resp;
   bit [0:`DELAY_WIDTH-1]    delay;

   bit 			     resp_came;

   `uvm_object_utils_begin(mon_trans)
     `uvm_field_int(port_id, UVM_ALL_ON)
     `uvm_field_int(cmd_nResp, UVM_ALL_ON)
     `uvm_field_int(op, UVM_ALL_ON)
     `uvm_field_int(tag_in, UVM_ALL_ON)
     `uvm_field_int(tag_out, UVM_ALL_ON)
     `uvm_field_int(d1, UVM_ALL_ON)
     `uvm_field_int(d2, UVM_ALL_ON)
     `uvm_field_int(r1, UVM_ALL_ON)
     `uvm_field_int(data_in, UVM_ALL_ON)
     `uvm_field_int(data_out, UVM_ALL_ON)
     `uvm_field_int(resp, UVM_ALL_ON)
     `uvm_field_int(delay, UVM_ALL_ON)
     `uvm_field_int(resp_came, UVM_ALL_ON)
   `uvm_object_utils_end

     function new(stsring name);
	super.new(name);
     endfunction
   
   function string convert2string;
      string  sOp = "NO_OP";
      string  sResp = "INVALID";
      
      case (op)
	`NO_OP: begin
	   sOp = "NO_OP";
	end
	
	`ADD: begin
	   sOp = "ADD";
	end // case: `ADD
	
	`SUB: begin
	   sOp = "SUB";
	end // case: `SUB
	
	`SHL: begin
	   sOp = "SHL";	   
	end
	   
	`SHR: begin
	   sOp = "SHR";	   
	end

	default: begin
	   sOp = $sformatf("INV(0x%1h)", op);
	end
      endcase // case (op)	    
       
      case (resp)
	`SUCC: begin
	   sResp = "SUCCESS";
	end 
	   
	`UNDR_OVRFL: begin
	   sResp = "UNDR_OVRFL";
	end
      endcase // case (resp) 
      return $sformatf("P%0d: op=%s, tag_in=%0d,tag_out=%0d,d1=%0d,d2=%0d,r1=%0d,data_in=%0d,data_out=%0d,resp=%0d,delay=%0d", port_id, sOp, data1, data2, tag_in, delay, sResp, result, tag_out);
   endfunction //
endclass

   