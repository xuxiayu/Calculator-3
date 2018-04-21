//Define the transaction between monitor and scoreboard

class mon_trans extends uvm_sequence_item;

   int port_id;
   int cmd_nResp;

   bit [0:3] op;
   bit [0:31] data1;
   bit [0:31] data2;

   bit [0:1]  resp;
   bit [0:31] result;

   bit [0:1]  tag_in;
   bit [0:1]  tag_out;
   bit [0:3]  delay;

   bit 	      resp_came;
   
   
   `uvm_object_utils_begin(mon_trans)
     `uvm_field_int(port_id,   UVM_ALL_ON)
     `uvm_field_int(cmd_nResp, UVM_ALL_ON)
     `uvm_field_int(op,        UVM_ALL_ON)
     `uvm_field_int(data1,     UVM_ALL_ON)
     `uvm_field_int(data2,     UVM_ALL_ON)
     `uvm_field_int(resp,      UVM_ALL_ON)
     `uvm_field_int(result,    UVM_ALL_ON)
     `uvm_field_int(tag_in,    UVM_ALL_ON)
     `uvm_field_int(tag_out,    UVM_ALL_ON)
     `uvm_field_int(delay,    UVM_ALL_ON)
     `uvm_field_int(resp_came, UVM_ALL_ON)   
   `uvm_object_utils_end
   
 
   function new(string name="");
      super.new(name);
   endfunction // new

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
	   
	`INV_OR_UNDR_OVRFL: begin
	   sResp = "INV_OR_INDR_OVRFL";
	end
      endcase // case (op)	    

      return $sformatf("P%0d: op=%s, data1=0x%8h, data2=0x%8h, tag_in, delay, resp=%s, result=0x%8h, tag_out", port_id, sOp, data1, data2, tag_in, delay, sResp, result, tag_out);
   endfunction //
endclass

   