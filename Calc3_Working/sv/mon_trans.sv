class mon_trans extends uvm_sequence_item;

   int port_id;
   int cmd_nResp;
   bit g2g;
   bit [0:`INSTR_WIDTH-1] op;
   bit [0:`TAG_WIDTH-1]   tag_in, tag_out;
   bit [0:`REGISTER_WIDTH-1] d1, d2, r1;
   bit [0:`DATA_WIDTH-1]     data_in,data_out;
   bit [0:`RESP_WIDTH-1]     resp;
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
     `uvm_field_int(resp_came, UVM_ALL_ON)
     `uvm_field_int(g2g, UVM_ALL_ON)
   `uvm_object_utils_end

     function new(string name="");
	super.new(name);
	
     endfunction
   
   function void set_g2g();
      g2g = 1;
   endfunction // set_latched
   function void clear();
      port_id = 0;
      cmd_nResp =0;
      g2g = 0;
      op = 0;
      tag_in = 0;
      tag_out = 0;
      d1 =0;
      d2 = 0;
      r1 = 0;
      data_in =0;
      data_out =0;
      resp =0;
   endfunction // clear
   
   function void print_mon_trans();
      uvm_report_info(get_type_name(),$psprintf("\nop\t d1\t d2\t r1\t data_in \t resp\t data_out\t tag_in\t tag_out\t port id\t g2g\n%h\t %h\t %h\t %h\t %h\t %h\t %h\t %h     \t %h      \t %h\t  %h",
				   op,d1,d2,r1,data_in,resp,data_out,tag_in,tag_out,port_id,g2g), UVM_LOW);

   endfunction // print_mon_trans
   
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
      return $sformatf("P%0d: op=%s, tag_in=%0d,tag_out=%0d,d1=%0d,d2=%0d,r1=%0d,data_in=%0d,data_out=%0d,resp=%0d", port_id, sOp, tag_in, tag_out, d1,d2,r1,data_in,data_out,sResp);
   endfunction //
endclass

   