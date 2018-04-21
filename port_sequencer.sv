/* -----\/----- EXCLUDED -----\/-----
These are all the random fields defined in drvr_trans:
      `uvm_field_int(delay,     UVM_ALL_ON)
      `uvm_field_int(op,        UVM_ALL_ON)
      `uvm_field_int(data1,     UVM_ALL_ON)
      `uvm_field_int(data2,     UVM_ALL_ON)
 -----/\----- EXCLUDED -----/\----- */
class add_sequence extends uvm_sequence #(drvr_trans);
   `uvm_object_utils(add_sequence)

   int num_items;   
   
   function new(string name="");
      super.new(name);
   endfunction // new

   task body;
      if (starting_phase != null)
	starting_phase.raise_objection(this);

      repeat(num_items) begin
	 `uvm_do_with(req, {req.op == `ADD;});
      end
      
      if(starting_phase != null)
	starting_phase.drop_objection(this);
   endtask: body
endclass: add_sequence

// TODO:  You guys should be familar with this now...
// Add more sequences (now of type uvm_sequence #(drvr_trans) )

class sub_sequence extends uvm_sequence #(drvr_trans);
   `uvm_object_utils(sub_sequence)

   int num_items;   
   
   function new(string name="");
      super.new(name);
   endfunction // new

   task body;
      if (starting_phase != null)
	starting_phase.raise_objection(this);

      repeat(num_items) begin
	 `uvm_do_with(req, {req.op == `SUB;});
      end
      
      if(starting_phase != null)
	starting_phase.drop_objection(this);
   endtask: body
endclass: sub_sequence


class my_sequence extends uvm_sequence #(drvr_trans);
   `uvm_object_utils(my_sequence)

   int num_items = 500;   

   bit [0:3] op_max;
   bit [0:31] data1_max;
   bit [0:31] data2_max;
   
   bit [0:3]  op_min;
   bit [0:31] data1_min;
   bit [0:31] data2_min;
  
   
   function new(string name="");
      super.new(name);
   endfunction // new

   task body;
      if (starting_phase != null)
	starting_phase.raise_objection(this);

      repeat(num_items) begin
	 req = drvr_trans::type_id::create("req");
	 start_item(req);
         if( !req.randomize() with {
				    req.op inside {[op_min:op_max]};
				    req.data1 inside {[data1_min:data1_max]};
				    req.data2 inside {[data2_min:data2_max]};
				    req.delay == 0;
				    } 
	     )
	   `uvm_error(get_type_name(), "Randomize Failed");
         finish_item(req);
      end

      if(starting_phase != null)
	starting_phase.drop_objection(this);
   endtask: body
endclass: my_sequence


class add_shift_sequence extends uvm_sequence #(drvr_trans);
   `uvm_object_utils(add_shift_sequence)

   int num_items = 100;   

   bit [0:3] op_max;
   bit [0:31] data1_max;
   bit [0:31] data2_max;
   
   bit [0:3]  op_min;
   bit [0:31] data1_min;
   bit [0:31] data2_min;
  
   
   function new(string name="");
      super.new(name);
   endfunction // new

   task body;
      if (starting_phase != null)
	starting_phase.raise_objection(this);

      repeat(num_items) begin
	 req = drvr_trans::type_id::create("req");
	 start_item(req);
         if( !req.randomize() with {
				    req.op inside {1,2,5,6};
				    req.data1 inside {[data1_min:data1_max]};
				    req.data2 inside {[data2_min:data2_max]};
				    req.delay == 0;
				    } 
	     )
	   `uvm_error(get_type_name(), "Randomize Failed");
         finish_item(req);
      end

      if(starting_phase != null)
	starting_phase.drop_objection(this);
   endtask: body
endclass: add_shift_sequence

class valid_add_sequence extends uvm_sequence #(drvr_trans);
   `uvm_object_utils(valid_add_sequence)

   int num_items = 100;   

   bit [0:3] op_max;
   bit [0:31] data1_max;
   bit [0:31] data2_max;
   
   bit [0:3]  op_min;
   bit [0:31] data1_min;
   bit [0:31] data2_min;
     
   
   function new(string name="");
      super.new(name);
   endfunction // new

   task body;
      if (starting_phase != null)
	starting_phase.raise_objection(this);

      repeat(num_items) begin
	 req = drvr_trans::type_id::create("req");
	 start_item(req);
         if( !req.randomize() with {
				    req.op inside {[op_min:op_max]};
				    req.data1 inside {[data1_min:data1_max]};
				    req.data2 inside {[data2_min:`MAX-req.data1]};
				    } 
	     )
	   `uvm_error(get_type_name(), "Randomize Failed");
         finish_item(req);
      end

      if(starting_phase != null)
	starting_phase.drop_objection(this);
   endtask: body
endclass: valid_add_sequence


class overflow_sequence extends uvm_sequence #(drvr_trans);
   `uvm_object_utils(overflow_sequence)

   int num_items = 100;   

   bit [0:3] op_max;
   bit [0:31] data1_max;
   bit [0:31] data2_max;
   
   bit [0:3]  op_min;
   bit [0:31] data1_min;
   bit [0:31] data2_min;
     
   
   function new(string name="");
      super.new(name);
   endfunction // new

   task body;
      if (starting_phase != null)
	starting_phase.raise_objection(this);

      repeat(num_items) begin
	 req = drvr_trans::type_id::create("req");
	 start_item(req);
         if( !req.randomize() with {
				    req.op inside {[op_min:op_max]};
				    req.data1 inside {[data1_min:data1_max]};
				    req.data2 inside {[`MAX-req.data1+1:`MAX]};
				    } 
	     )
	   `uvm_error(get_type_name(), "Randomize Failed");
         finish_item(req);
      end

      if(starting_phase != null)
	starting_phase.drop_objection(this);
   endtask: body
endclass: overflow_sequence 


class valid_sub_sequence extends uvm_sequence #(drvr_trans);
   `uvm_object_utils(valid_sub_sequence)

   int num_items = 100;   

   bit [0:3] op_max;
   bit [0:31] data1_max;
   bit [0:31] data2_max;
   
   bit [0:3]  op_min;
   bit [0:31] data1_min;
   bit [0:31] data2_min;
     
   
   function new(string name="");
      super.new(name);
   endfunction // new

   task body;
      if (starting_phase != null)
	starting_phase.raise_objection(this);

      repeat(num_items) begin
	 req = drvr_trans::type_id::create("req");
	 start_item(req);
         if( !req.randomize() with {
				    req.op inside {[op_min:op_max]};
				    req.data1 inside {[data1_min:data1_max]};
				    req.data2 inside {[data2_min:req.data1]};
				    } 
	     )
	   `uvm_error(get_type_name(), "Randomize Failed");
         finish_item(req);
      end

      if(starting_phase != null)
	starting_phase.drop_objection(this);
   endtask: body
endclass: valid_sub_sequence


class underflow_sequence extends uvm_sequence #(drvr_trans);
   `uvm_object_utils(underflow_sequence)

   int num_items = 100;   

   bit [0:3] op_max;
   bit [0:31] data1_max;
   bit [0:31] data2_max;
   
   bit [0:3]  op_min;
   bit [0:31] data1_min;
   bit [0:31] data2_min;
     
   
   function new(string name="");
      super.new(name);
   endfunction // new

   task body;
      if (starting_phase != null)
	starting_phase.raise_objection(this);

      repeat(num_items) begin
	 req = drvr_trans::type_id::create("req");
	 start_item(req);
         if( !req.randomize() with {
				    req.op inside {[op_min:op_max]};
				    req.data1 inside {[data1_min:data1_max]};
				    req.data2 inside {[req.data1+1:`MAX]};
				    } 
	     )
	   `uvm_error(get_type_name(), "Randomize Failed");
         finish_item(req);
      end

      if(starting_phase != null)
	starting_phase.drop_objection(this);
   endtask: body
endclass: underflow_sequence 


class data_equal extends uvm_sequence #(drvr_trans);
   `uvm_object_utils(data_equal)

   int num_items = 100;   

   bit [0:3] op_max;
   bit [0:31] data1_max;
   bit [0:31] data2_max;
   
   bit [0:3]  op_min;
   bit [0:31] data1_min;
   bit [0:31] data2_min;
     
   
   function new(string name="");
      super.new(name);
   endfunction // new

   task body;
      if (starting_phase != null)
	starting_phase.raise_objection(this);

      repeat(num_items) begin
	 req = drvr_trans::type_id::create("req");
	 start_item(req);
         if( !req.randomize() with {
				    req.op inside {[op_min:op_max]};
				    req.data2 inside {[data2_min:data2_max]};
				    req.data1 == req.data2;
				    } 
	     )
	   `uvm_error(get_type_name(), "Randomize Failed");
         finish_item(req);
      end

      if(starting_phase != null)
	starting_phase.drop_objection(this);
   endtask: body
endclass: data_equal

class invalid_sequence extends uvm_sequence #(drvr_trans);
   `uvm_object_utils(invalid_sequence)

   int num_items = 100;   

   bit [0:3] op_max;
   bit [0:31] data1_max;
   bit [0:31] data2_max;
   
   bit [0:3]  op_min;
   bit [0:31] data1_min;
   bit [0:31] data2_min;
     
   
   function new(string name="");
      super.new(name);
   endfunction // new

   task body;
      if (starting_phase != null)
	starting_phase.raise_objection(this);

      repeat(num_items) begin
	 req = drvr_trans::type_id::create("req");
	 start_item(req);
         if( !req.randomize() with {
				    req.op inside {3,4,[7:15]};
				    req.data1 inside {[data1_min:data1_max]};
				    req.data2 inside {[data2_min:data2_max]};
				    req.delay == 0;
				    } 
	     )
	   `uvm_error(get_type_name(), "Randomize Failed");
         finish_item(req);
      end

      if(starting_phase != null)
	starting_phase.drop_objection(this);
   endtask: body
endclass: invalid_sequence