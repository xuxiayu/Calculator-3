class base_sequence extends uvm_sequence#(drvr_trans);
   `uvm_object_utils(base_sequence)
     int num_items;
   rand bit [0:`INSTR_WIDTH] cmd;   
   rand bit [0:`REGISTER_WIDTH-1] dreg1;
   rand bit [0:`REGISTER_WIDTH-1] dreg2;
   rand bit [0:`REGISTER_WIDTH-1] rreg1;
   rand bit [0:`DATA_WIDTH-1] dat_in;
   
   function new(string name = "");
      super.new(name);
   endfunction // new
   
   virtual task body;
      if(starting_phase !=null)
	starting_phase.raise_objection(this);
      repeat(num_items) begin
	 req = drvr_trans::type_id::create("req");
	 start_item(req);
	 if(!req.randomize() with { })
	   `uvm_error(get_type_name(),"randomization failed");
         finish_item(req);
      end
      if(starting_phase !=null)
	starting_phase.drop_objection(this);
   endtask // body
endclass // my_sequence

class add_sequence extends base_sequence;
   
   `uvm_object_utils(add_sequence)
    function new(string name="");
       super.new(name);
    endfunction // new

   virtual task body;
      if(starting_phase !=null)
	starting_phase.raise_objection(this);
      repeat(num_items) begin
	 req = drvr_trans::type_id::create("req");
	 start_item(req);
	 if(!req.randomize() with {
				   req.op==cmd;
			           req.d1== dreg1;
				   req.d2== dreg2;
				   req.r1== rreg1;
				   req.data_in == dat_in;
				   })
	   `uvm_error(get_type_name(),"randomization failed");
         finish_item(req);
      end
      if(starting_phase !=null)
	starting_phase.drop_objection(this);
   endtask // body
endclass // my_sequence