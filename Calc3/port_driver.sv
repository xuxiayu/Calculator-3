class port_driver extends uvm_driver #(drvr_trans);
   `uvm_component_utils(port_driver)
   virtual port_if port_intf;
   virtual   misc_if misc_intf;
   int 	     port_id;
   bit [0:1] queue[$] = {00,01,10,11};
   

   function new(string name,uvm_component parent = null);
      super.new(name,parent);
   endfunction // new

   function void cfg_driver(port_config cg);
      misc_intf = cg.misc_intf;
      port_intf = cg.port_intf;
      port_id = cg.port_id;
   endfunction // cfg_driver

   task run_phase(uvm_phase phase);
      super.run_phase(phase);
      port_intf.op<=`NO_OP;
      port_intf.d1 <= 1; //data.d1;
      port_intf.d2 <= 2;//data.d2;
      port_intf.r1 <= 3; //data.r1;
      port_intf.data_in <= 0; //data.data_in;
      port_intf.tag_in <=0;

   
      
      @(negedge misc_intf.reset);
      fork 
	 begin
	    forever begin
	       wait(queue.size()>0);
	       `uvm_info(get_type_name(),$sformatf("Waiting for data from sequencer"),UVM_MEDIUM);
	       seq_item_port.get_next_item(req);
	       drive_item(req);
	       seq_item_port.item_done();
	    end
	 end
	 begin
	    forever begin
	       @(negedge misc_intf.clock);
	       if(port_intf.resp !=0) begin
		  queue.push_back(port_intf.tag_out);
	       end
	    end
	 end
      join
   endtask // run_phase
   
   virtual task drive_item(drvr_trans data);
     
      @(negedge misc_intf.clock);
      port_intf.op <= data.op;
      port_intf.d1 <= data.d1;
      port_intf.d2 <= data.d2;
      port_intf.r1 <= data.r1;
      port_intf.data_in <= data.data_in;
      port_intf.tag_in <=queue.pop_front();
      @(negedge misc_intf.clock);
   endtask // drive_item
endclass // port_driver


  