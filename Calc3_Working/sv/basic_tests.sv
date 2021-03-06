class branch_test extends base_test;    
   `uvm_component_utils(branch_test)
     function new(string name,uvm_component parent);
	super.new(name,parent);
	turn_on_ports(1,1,1,1);
	sub_seq = {`BEQUAL,`BZERO};
	randomize_sub_seq = 1;
     endfunction // new   
   virtual task run_phase(uvm_phase phase);     
      add_sequence seq[4];
      foreach(seq[i])begin
	 seq[i] = add_sequence::type_id::create($sformatf("seq%0d",i),this);
      end
      fork 
	 begin
	    for(int index=0;index<4;index++)begin
	       fork
		  automatic int idx = index;
		  begin
		     if(onPort[idx] == 1)begin
			repeat(25) begin
			   if(randomize_sub_seq == 1)
			     sub_seq.shuffle();	      
			   foreach(sub_seq[i])begin
			      seq[idx].num_items = 1;
			      if(!seq[idx].randomize() with {seq[idx].cmd==sub_seq[i];
							   seq[idx].dreg1 inside {[reg_min:reg_max]};
							   seq[idx].dreg2 inside {[reg_min:reg_max]};;
							   seq[idx].rreg1 inside {[reg_min:reg_max]};;
							   seq[idx].dat_in inside{[data_in_min:data_in_max]};
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