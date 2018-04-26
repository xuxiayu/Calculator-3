`include "port_sequencer.sv"
class base_test extends uvm_test;
   bit onPort[4];
   bit [0:3] sub_seq[$];
   bit 	     randomize_sub_seq;
   bit [0:3] registers[16];
   rand bit [0:`DATA_WIDTH-1] data_in;
   
   `uvm_component_utils(base_test)
     top_env env;
   function new(string name,uvm_component parent);
      super.new(name,parent);
   endfunction // new

   function void turn_on_ports(bit p0,bit p1,bit p2,bit p3);
      if(p0 == 1)
	onPort[0]=1;
      else
	onPort[0]=0;
      if(p1 == 1)
	onPort[1]=1;
      else
	onPort[1] =0;
      if(p2 == 1)
	onPort[2]=1;
      else
	onPort[2] =0;
      if(p3 == 1)
	onPort[3]=1;
      else
	onPort[3] =0;
   endfunction // turn_on_ports

   function void build_phase(uvm_phase phase);
      env = top_env::type_id::create("env",this);
   endfunction // build_phase

   virtual task run_phase(uvm_phase phase);
     base_sequence seq;
      seq = base_sequence::type_id::create("seq");
      seq.num_items = 25;
      if(!seq.randomize())
	`uvm_error(get_type_name(),"Sequence randomize failed");
      seq.starting_phase = phase;
      seq.start(env.agnts[0].seqcr);
   endtask // run_phase
endclass // base_test

class b_test extends base_test; 
   `uvm_component_utils(b_test)
     function new(string name,uvm_component parent);
	super.new(name,parent);
	turn_on_ports(1,1,1,1);
	sub_seq = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
	registers = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
	registers.shuffle();
	randomize_sub_seq = 1;
	if(!this.randomize())
	  `uvm_error(get_type_name(),"Sequenc randomize failed");
     endfunction // new
   
   virtual task run_phase(uvm_phase phase);     
      b_sequence seq[4];
      foreach(seq[i])begin
	 seq[i] = b_sequence::type_id::create($sformatf("seq%0d",i),this);
      end
      fork 
	 begin
	    for(int index=0;index<4;index++)begin
	       fork
		  automatic int idx = index;
		  begin
		     if(onPort[idx] == 1)begin
			repeat(25) begin
			   foreach(sub_seq[i])begin
			      if(randomize_sub_seq == 1)
				sub_seq.shuffle();
			      seq[idx].num_items = 1;
			      if(!seq[idx].randomize() with {seq[idx].cmd==sub_seq[i];
							     seq[idx].dreg1 inside {registers[0+idx*4],registers[1+idx*4],registers[2+idx*4],registers[3+idx*4]};
							     seq[idx].dreg2 inside {registers[0+idx*4],registers[1+idx*4],registers[2+idx*4],registers[3+idx*4]};
							     seq[idx].rreg1 inside {registers[0+idx*4],registers[1+idx*4],registers[2+idx*4],registers[3+idx*4]};
							     seq[idx].dat_in==data_in;
							     })
				`uvm_error(get_type_name(),"Sequenc randomize failed");
                              seq[idx].starting_phase = phase;
                              seq[idx].start(env.agnts[idx].seqcr);
                           end
			end
		     end
                  end
	       join_none;
	    end // for (int index=0;index<4;index++)
	    wait fork;
	    end // fork begin
      join
   endtask // run_phase 
endclass // base_test

class valid_cmds_test extends b_test;
`uvm_component_utils(valid_cmds_test)
     function new(string name,uvm_component parent);
	super.new(name,parent);
	sub_seq = {`ADD, `SUB, `SHL, `SHR, `BEQUAL,`BZERO,`STORE,`FETCH};
     endfunction // new
   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
   endtask // run_phase
endclass // adder_test

class adder_alu_test extends b_test;
`uvm_component_utils(adder_alu_test)
     function new(string name,uvm_component parent);
	super.new(name,parent);
	sub_seq = {`ADD, `SUB,`BEQUAL,`BZERO};
     endfunction // new
   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
   endtask // run_phase
endclass // adder_test

class shifter_alu_test extends b_test;
`uvm_component_utils(shifter_alu_test)
     function new(string name,uvm_component parent);
	super.new(name,parent);
	sub_seq = {`SHL, `SHR,`STORE,`FETCH};
     endfunction // new
   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
   endtask // run_phase
endclass // adder_test

class SF_test extends b_test;
`uvm_component_utils(SF_test)
     function new(string name,uvm_component parent);
	super.new(name,parent);
	sub_seq = {`STORE,`FETCH};
     endfunction // new
   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
   endtask // run_phase
endclass // adder_test

class branch_test extends b_test;
`uvm_component_utils(branch_test)
     function new(string name,uvm_component parent);
	super.new(name,parent);
	sub_seq = {`BZERO};
     endfunction // new
   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
   endtask // run_phase
endclass // adder_test

class add_test extends b_test;
`uvm_component_utils(add_test)
     function new(string name,uvm_component parent);
	super.new(name,parent);
	sub_seq = {`ADD,`SUB};
     endfunction // new
   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
   endtask // run_phase
endclass // adder_test

class shift_test extends b_test;
`uvm_component_utils(shift_test)
     function new(string name,uvm_component parent);
	super.new(name,parent);
	sub_seq = {`SHL,`SHR};
     endfunction // new
   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
   endtask // run_phase
endclass // adder_test

class invalid_test extends b_test;
`uvm_component_utils(invalid_test)
     function new(string name,uvm_component parent);
	super.new(name,parent);
	sub_seq = {3,4,7,8,11,14,15};
     endfunction // new
   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
   endtask // run_phase
endclass // adder_test

//Single port test
class b0_test extends b_test;
`uvm_component_utils(b0_test)
     function new(string name,uvm_component parent);
	super.new(name,parent);
	turn_on_ports(1,0,0,0);
     endfunction // new
   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
   endtask // run_phase
endclass // adder_test


class AS_test extends base_test; 
   `uvm_component_utils(AS_test)
     function new(string name,uvm_component parent);
	super.new(name,parent);
	turn_on_ports(1,0,0,1);
	sub_seq = {`ADD};	
	randomize_sub_seq = 0;
	if(!this.randomize())
	  `uvm_error(get_type_name(),"Sequenc randomize failed");
     endfunction // new
   
   virtual task run_phase(uvm_phase phase);     
      b_sequence seq[4];
      foreach(seq[i])begin
	 seq[i] = b_sequence::type_id::create($sformatf("seq%0d",i),this);
      end
      fork 
	 begin
	    for(int index=0;index<4;index++)begin
	       fork
		  automatic int idx = index;
		  begin
		     if(onPort[idx] == 1)begin
			repeat(25) begin
			   foreach(sub_seq[i])begin
			      if(randomize_sub_seq == 1)
				sub_seq.shuffle();
			      seq[idx].num_items = 1;
			      if(!seq[idx].randomize() with {seq[idx].cmd==idx+2;
							     seq[idx].dreg1 == 1;
							     seq[idx].dreg2 == 2;
							     seq[idx].rreg1 == 3; 
							     seq[idx].dat_in==data_in;
							     })
				`uvm_error(get_type_name(),"Sequenc randomize failed");
                              seq[idx].starting_phase = phase;
                              seq[idx].start(env.agnts[idx].seqcr);
                           end
			end
		     end
                  end
	       join_none;
	    end // for (int index=0;index<4;index++)
	    wait fork;
	    end // fork begin
      join
   endtask // run_phase 
endclass // base_test