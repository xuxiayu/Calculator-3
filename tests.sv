// This defines the sequences used by the following tests!
// User may want to add custom sequences to test different portions of the design!
`include "port_sequencer.sv"

// What should the base test be???
// Defined by the verification engineer - maybe the least constrained?  Maybe directed?
class base_test extends uvm_test;
   `uvm_component_utils(base_test)     
   top_env env;
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction // new
   
   function void build_phase(uvm_phase phase);
      env = top_env::type_id::create("env", this);
   endfunction // build_phase
   
   task run_phase(uvm_phase phase);
      add_sequence seq;
      seq = add_sequence::type_id::create("seq");
      seq.num_items = 25;
      
      // Randomize the sequence
      if (!seq.randomize() )
	`uvm_error(get_type_name(), "Sequence randomize failed");
      seq.starting_phase = phase;

      seq.start(env.agnts[0].seqcr);	 
   endtask // run_phase   
endclass:base_test // base_test

// Include any user tests that extend the base_test!

// TODO: User defined tests....  Remember, the base_test already has the env instantiated
// Now, just create the interesting scenarios!

class add_test extends base_test;
   `uvm_component_utils(add_test)
     function new(string name, uvm_component parent);
	super.new(name,parent);
     endfunction // new

   task run_phase(uvm_phase phase);
      add_sequence seq[4];

      foreach (seq[i])
	begin
	   seq[i] = add_sequence::type_id::create("seq");
	   seq[i].starting_phase = phase;
	   seq[i].num_items = 100;
	    
	end
      fork
	 begin
	    seq[0].start(env.agnts[0].seqcr);
	 end 
	 begin       
	    seq[1].start(env.agnts[1].seqcr);
	 end
	 begin
	    seq[2].start(env.agnts[2].seqcr);
	 end
	 begin 
	    seq[3].start(env.agnts[3].seqcr);	 
	 end
      join
   endtask // run_phase 
endclass // add_test


class sub_test extends base_test;
   `uvm_component_utils(sub_test)
     function new(string name, uvm_component parent);
	super.new(name,parent);
     endfunction // new

   task run_phase(uvm_phase phase);
      sub_sequence seq[4];

      foreach (seq[i])
	begin
	   seq[i] = sub_sequence::type_id::create("seq");
	   seq[i].starting_phase = phase;
	   seq[i].num_items = 25;
	    
	end
      fork
	 begin
	    seq[0].start(env.agnts[0].seqcr);
	 end 
	 begin       
	    seq[1].start(env.agnts[1].seqcr);
	 end
	 begin
	    seq[2].start(env.agnts[2].seqcr);
	 end
	 begin 
	    seq[3].start(env.agnts[3].seqcr);	 
	 end
      join
   endtask // run_phase 
endclass // sub_test


class valid_adds extends base_test;
   `uvm_component_utils(valid_adds)
     
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction // new
   
   task run_phase(uvm_phase phase);
      
      // USER TO DO!!!
      
      
      valid_add_sequence seq[4];
      foreach (seq[i])
	begin
	   seq[i] = valid_add_sequence::type_id::create("seq");
	   seq[i].starting_phase = phase;
	   
	   seq[i].op_max = 1;
	   seq[i].op_min = 1;
	   seq[i].data1_max = `MAX;
	   seq[i].data1_min = 0;
	   seq[i].data2_max = `MAX;
	   seq[i].data2_min = 0;

	   
	end
      fork
	 begin
	    seq[0].start(env.agnts[0].seqcr);	 
	 end 
	 begin       
	    seq[1].start(env.agnts[1].seqcr);	 
	 end
	 begin
	    seq[2].start(env.agnts[2].seqcr);	 
	 end
	 begin 
	    seq[3].start(env.agnts[3].seqcr);	 
	 end
      join
      
   endtask // run_phase      
   
endclass:valid_adds // test1


class overflow extends base_test;
   `uvm_component_utils(overflow)
     
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction // new
   
   task run_phase(uvm_phase phase);
      
      // USER TO DO!!!
      
      
      overflow_sequence seq[4];
      foreach (seq[i])
	begin
	   seq[i] = overflow_sequence::type_id::create("seq");
	   seq[i].starting_phase = phase;
	   
	   seq[i].op_max = 1;
	   seq[i].op_min = 1;
	   seq[i].data1_max = `MAX;
	   seq[i].data1_min = 0;
	   seq[i].data2_max = `MAX;
	   seq[i].data2_min = 0;

	   
	end
      fork
	 begin
	    seq[0].start(env.agnts[0].seqcr);	 
	 end 
	 begin       
	    seq[1].start(env.agnts[1].seqcr);	 
	 end
	 begin
	    seq[2].start(env.agnts[2].seqcr);	 
	 end
	 begin 
	    seq[3].start(env.agnts[3].seqcr);	 
	 end
      join
      
   endtask // run_phase      
   
endclass:overflow // test1


class valid_subs extends base_test;
   `uvm_component_utils(valid_subs)
     
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction // new
   
   task run_phase(uvm_phase phase);
      
      // USER TO DO!!!
      
      
      valid_sub_sequence seq[4];
      foreach (seq[i])
	begin
	   seq[i] = valid_sub_sequence::type_id::create("seq");
	   seq[i].starting_phase = phase;
	   
	   seq[i].op_max = 2;
	   seq[i].op_min = 2;
	   seq[i].data1_max = `MAX;
	   seq[i].data1_min = 0;
	   seq[i].data2_max = `MAX;
	   seq[i].data2_min = 0;
	   
	end
      fork
	 begin
	    seq[0].start(env.agnts[0].seqcr);	 
	 end 
	 begin       
	    seq[1].start(env.agnts[1].seqcr);	 
	 end
	 begin
	    seq[2].start(env.agnts[2].seqcr);	 
	 end
	 begin 
	    seq[3].start(env.agnts[3].seqcr);	 
	 end
      join
      
   endtask // run_phase      
   
endclass:valid_subs // test1

class underflow extends base_test;
   `uvm_component_utils(underflow)
     
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction // new
   
   task run_phase(uvm_phase phase);
      
      // USER TO DO!!!
      
      
      underflow_sequence seq[4];
      foreach (seq[i])
	begin
	   seq[i] = underflow_sequence::type_id::create("seq");
	   seq[i].starting_phase = phase;
	   
	   seq[i].op_max = 2;
	   seq[i].op_min = 2;
	   seq[i].data1_max = `MAX;
	   seq[i].data1_min = 0;
	   seq[i].data2_max = `MAX;
	   seq[i].data2_min = 0;

	   
	end
      fork
	 begin
	    seq[0].start(env.agnts[0].seqcr);	 
	 end 
	 begin       
	    seq[1].start(env.agnts[1].seqcr);	 
	 end
	 begin
	    seq[2].start(env.agnts[2].seqcr);	 
	 end
	 begin 
	    seq[3].start(env.agnts[3].seqcr);	 
	 end
      join
      
   endtask // run_phase      
   
endclass:underflow // test1

class shl_test extends base_test;
   `uvm_component_utils(shl_test)
     
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction // new
   
   task run_phase(uvm_phase phase);
      
      // USER TO DO!!!
      
      
      my_sequence seq[4];
      foreach (seq[i])
	begin
	   seq[i] = my_sequence::type_id::create("seq");
	   seq[i].starting_phase = phase;
	   
	   seq[i].op_max = 5;
	   seq[i].op_min = 5;
	   seq[i].data1_max = `MAX;
	   seq[i].data1_min = 0;
	   seq[i].data2_max = `MAX;
	   seq[i].data2_min = 0;
	   
	end
      fork
	 begin
	    seq[0].start(env.agnts[0].seqcr);	 
	 end 
	 begin       
	    seq[1].start(env.agnts[1].seqcr);	 
	 end
	 begin
	    seq[2].start(env.agnts[2].seqcr);	 
	 end
	 begin 
	    seq[3].start(env.agnts[3].seqcr);	 
	 end
      join
      
   endtask // run_phase      
   
endclass:shl_test // test1

class shr_test extends base_test;
   `uvm_component_utils(shr_test)
     
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction // new
   
   task run_phase(uvm_phase phase);
      
      // USER TO DO!!!
      
      
      my_sequence seq[4];
      foreach (seq[i])
	begin
	   seq[i] = my_sequence::type_id::create("seq");
	   seq[i].starting_phase = phase;
	   
	   seq[i].op_max = 6;
	   seq[i].op_min = 6;
	   seq[i].data1_max = `MAX;
	   seq[i].data1_min = 0;
	   seq[i].data2_max = `MAX;
	   seq[i].data2_min = 0;
	   
	end
      fork
	 begin
	    seq[0].start(env.agnts[0].seqcr);	 
	 end 
	 begin       
	    seq[1].start(env.agnts[1].seqcr);	 
	 end
	 begin
	    seq[2].start(env.agnts[2].seqcr);	 
	 end
	 begin 
	    seq[3].start(env.agnts[3].seqcr);	 
	 end
      join
      
   endtask // run_phase      
   
endclass:shr_test // test1

class adder_test extends base_test;
   `uvm_component_utils(adder_test)
     
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction // new
   
   task run_phase(uvm_phase phase);
      
      // USER TO DO!!!
      
      
      my_sequence seq[4];
      foreach (seq[i])
	begin
	   seq[i] = my_sequence::type_id::create("seq");
	   seq[i].starting_phase = phase;
	   
	   seq[i].op_max = 2;
	   seq[i].op_min = 1;
	   seq[i].data1_max = `MAX;
	   seq[i].data1_min = 0;
	   seq[i].data2_max = `MAX;
	   seq[i].data2_min = 0;
	   
	end
      fork
	 begin
	    seq[0].start(env.agnts[0].seqcr);	 
	 end 
	 begin       
	    seq[1].start(env.agnts[1].seqcr);	 
	 end
	 begin
	    seq[2].start(env.agnts[2].seqcr);	 
	 end
	 begin 
	    seq[3].start(env.agnts[3].seqcr);	 
	 end
      join
      
   endtask // run_phase      
   
endclass:adder_test // test1

class shifter_test extends base_test;
   `uvm_component_utils(shifter_test)
     
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction // new
   
   task run_phase(uvm_phase phase);
      
      // USER TO DO!!!
      
      
      my_sequence seq[4];
      foreach (seq[i])
	begin
	   seq[i] = my_sequence::type_id::create("seq");
	   seq[i].starting_phase = phase;
	   
	   seq[i].op_max = 6;
	   seq[i].op_min = 5;
	   seq[i].data1_max = `MAX;
	   seq[i].data1_min = 0;
	   seq[i].data2_max = `MAX;
	   seq[i].data2_min = 0;
	   
	end
      fork
	 begin
	    seq[0].start(env.agnts[0].seqcr);	 
	 end 
	 begin       
	    seq[1].start(env.agnts[1].seqcr);	 
	 end
	 begin
	    seq[2].start(env.agnts[2].seqcr);	 
	 end
	 begin 
	    seq[3].start(env.agnts[3].seqcr);	 
	 end
      join
      
   endtask // run_phase      
   
endclass:shifter_test // test1

class shifter_test_constrained extends base_test;
   `uvm_component_utils(shifter_test_constrained)
     
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction // new
   
   task run_phase(uvm_phase phase);
      
      // USER TO DO!!!
      
      
      my_sequence seq[4];
      foreach (seq[i])
	begin
	   seq[i] = my_sequence::type_id::create("seq");
	   seq[i].starting_phase = phase;
	   
	   seq[i].op_max = 6;
	   seq[i].op_min = 5;
	   seq[i].data1_max = `MAX;
	   seq[i].data1_min = 0;
	   seq[i].data2_max = 31;
	   seq[i].data2_min = 0;
	   
	end
      fork
	 begin
	    seq[0].start(env.agnts[0].seqcr);	 
	 end 
	 begin       
	    seq[1].start(env.agnts[1].seqcr);	 
	 end
	 begin
	    seq[2].start(env.agnts[2].seqcr);	 
	 end
	 begin 
	    seq[3].start(env.agnts[3].seqcr);	 
	 end
      join
      
   endtask // run_phase      
   
endclass:shifter_test_constrained // test1

class valid_adder_shifter_test extends base_test;
   `uvm_component_utils(valid_adder_shifter_test)
     
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction // new
   
   task run_phase(uvm_phase phase);
      
      // USER TO DO!!!
      
      
      add_shift_sequence seq[4];
      foreach (seq[i])
	begin
	   seq[i] =add_shift_sequence::type_id::create("seq");
	   seq[i].starting_phase = phase;
	   
	   seq[i].op_max = 15;
	   seq[i].op_min = 0;
	   seq[i].data1_max = `MAX;
	   seq[i].data1_min = 0;
	   seq[i].data2_max = `MAX;
	   seq[i].data2_min = 0;
	   
	end
      fork
	 begin
	    seq[0].start(env.agnts[0].seqcr);	 
	 end 
	 begin       
	    seq[1].start(env.agnts[1].seqcr);	 
	 end
	 begin
	    seq[2].start(env.agnts[2].seqcr);	 
	 end
	 begin 
	    seq[3].start(env.agnts[3].seqcr);	 
	 end
      join
      
   endtask // run_phase      
   
endclass:valid_adder_shifter_test // test1

class invalid_test extends base_test;
   `uvm_component_utils(invalid_test)
     
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction // new
   
   task run_phase(uvm_phase phase);
      
      // USER TO DO!!!
      
      
      invalid_sequence seq[4];
      foreach (seq[i])
	begin
	   seq[i] = invalid_sequence::type_id::create("seq");
	   seq[i].starting_phase = phase;
	   
	   seq[i].op_max = 15;
	   seq[i].op_min = 0;
	   seq[i].data1_max = `MAX;
	   seq[i].data1_min = 0;
	   seq[i].data2_max = `MAX;
	   seq[i].data2_min = 0;
	   
	end
      fork
	 begin
	    seq[0].start(env.agnts[0].seqcr);	 
	 end 
	 begin       
	    seq[1].start(env.agnts[1].seqcr);	 
	 end
	 begin
	    seq[2].start(env.agnts[2].seqcr);	 
	 end
	 begin 
	    seq[3].start(env.agnts[3].seqcr);	 
	 end
      join
      
   endtask // run_phase      
   
endclass:invalid_test // test1

class ks_test extends base_test;
   `uvm_component_utils(ks_test)
     
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction // new
   
   task run_phase(uvm_phase phase);
      
      // USER TO DO!!!
      
      
      my_sequence seq[4];
      foreach (seq[i])
	begin
	   seq[i] = my_sequence::type_id::create("seq");
	   seq[i].starting_phase = phase;
	   
	   seq[i].op_max = 15;
	   seq[i].op_min = 0;
	   seq[i].data1_max = `MAX;
	   seq[i].data1_min = 0;
	   seq[i].data2_max = `MAX;
	   seq[i].data2_min = 0;
	   
	end
      fork
	 begin
	    seq[0].start(env.agnts[0].seqcr);	 
	 end 
	 begin       
	    seq[1].start(env.agnts[1].seqcr);	 
	 end
	 begin
	    seq[2].start(env.agnts[2].seqcr);	 
	 end
	 begin 
	    seq[3].start(env.agnts[3].seqcr);	 
	 end
      join
      
   endtask // run_phase      
   
endclass:ks_test // test1

class no_op_test extends base_test;
   `uvm_component_utils(no_op_test)
     
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction // new
   
   task run_phase(uvm_phase phase);
      
      // USER TO DO!!!
      
      
      my_sequence seq[4];
      foreach (seq[i])
	begin
	   seq[i] = my_sequence::type_id::create("seq");
	   seq[i].starting_phase = phase;
	   seq[i].op_max = 0;
	   seq[i].op_min = 0;
	   seq[i].data1_max = `MAX;
	   seq[i].data1_min = 0;
	   seq[i].data2_max = `MAX;
	   seq[i].data2_min = 0;
	   
	end
      fork
	 begin
	    seq[0].start(env.agnts[0].seqcr);	 
	 end 
	 begin       
	    seq[1].start(env.agnts[1].seqcr);	 
	 end
	 begin
	    seq[2].start(env.agnts[2].seqcr);	 
	 end
	 begin 
	    seq[3].start(env.agnts[3].seqcr);	 
	 end
      join
      
   endtask // run_phase      
   
endclass:no_op_test // test1      

class ks_low_data_test extends base_test;
   `uvm_component_utils(ks_low_data_test)
     
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction // new
   
   task run_phase(uvm_phase phase);
      
      // USER TO DO!!!
      
      
      my_sequence seq[4];
      foreach (seq[i])
	begin
	   seq[i] =my_sequence::type_id::create("seq");
	   seq[i].starting_phase = phase;
	   
	   seq[i].op_max = 15;
	   seq[i].op_min = 0;
	   seq[i].data1_max = 31;
	   seq[i].data1_min = 0;
	   seq[i].data2_max = 31;
	   seq[i].data2_min = 0;
	   
	end
      fork
	 begin
	    seq[0].start(env.agnts[0].seqcr);	 
	 end 
	 begin       
	    seq[1].start(env.agnts[1].seqcr);	 
	 end
	 begin
	    seq[2].start(env.agnts[2].seqcr);	 
	 end
	 begin 
	    seq[3].start(env.agnts[3].seqcr);	 
	 end
      join
      
   endtask // run_phase      
   
endclass:ks_low_data_test // test1

class ks_high_data_test extends base_test;
   `uvm_component_utils(ks_high_data_test)
     
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction // new
   
   task run_phase(uvm_phase phase);
      
      // USER TO DO!!!
      
      
      my_sequence seq[4];
      foreach (seq[i])
	begin
	   seq[i] =my_sequence::type_id::create("seq");
	   seq[i].starting_phase = phase;
	   
	   seq[i].op_max = 15;
	   seq[i].op_min = 0;
	   seq[i].data1_max = `MAX;
	   seq[i].data1_min = `MAX - 31;
	   
	   seq[i].data2_max = `MAX;
	   
	   seq[i].data2_min = `MAX-31;
	   
	end
      fork
	 begin
	    seq[0].start(env.agnts[0].seqcr);	 
	 end 
	 begin       
	    seq[1].start(env.agnts[1].seqcr);	 
	 end
	 begin
	    seq[2].start(env.agnts[2].seqcr);	 
	 end
	 begin 
	    seq[3].start(env.agnts[3].seqcr);	 
	 end
      join
      
   endtask // run_phase      
   
endclass:ks_high_data_test // test1
