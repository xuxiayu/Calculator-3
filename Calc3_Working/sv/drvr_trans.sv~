class drvr_trans extends uvm_sequence_item;
   int port_id;
   
   rand bit [0:`INSTR_WIDTH-1] op;
   rand bit [0:`REGISTER_WIDTH-1] d1, d2, r1;
   rand bit [0:`DATA_WIDTH-1] data_in;

   bit [0:`TAG_WIDTH-1]   tag_in;
   rand int 		  delay;

   constraint c_delay {
      delay inside {[0:10]};
   }
     
   `uvm_object_utils_begin(drvr_trans)
     `uvm_field_int(port_id, UVM_ALL_ON)
     `uvm_field_int(tag_in, UVM_ALL_ON)
     `uvm_field_int(op, UVM_ALL_ON)
     `uvm_field_int(d1, UVM_ALL_ON)
     `uvm_field_int(d2, UVM_ALL_ON)
     `uvm_field_int(r1, UVM_ALL_ON)
     `uvm_field_int(data_in, UVM_ALL_ON)
     `uvm_field_int(delay, UVM_ALL_ON)
   `uvm_object_utils_end

     function new(string name ="");
	super.new(name);
     endfunction // new

     function string convert2string;
      string  sOp = "NO_OP";

      
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
 
      return $sformatf("P%0d: op=%s, tag_in=%0d,d1=%0d,d2=%0d,r1=%0d,data_in=%0d,delay=%0d", port_id, sOp, tag_in,d1, d2, r1,data_in,delay);
   endfunction //
endclass

typedef uvm_sequencer #(drvr_trans) drvr_sequencer;   