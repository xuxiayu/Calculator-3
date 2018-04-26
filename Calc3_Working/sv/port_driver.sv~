class port_driver extends uvm_driver #(drvr_trans);
   `uvm_component_utils(port_driver)
     virtual port_if port_intf;
   virtual   misc_if misc_intf;
   int 	     port_id;
   bit [0:1] av_tags[$];
   semaphore sem;
   
   function new(string name,uvm_component parent = null);
      super.new(name,parent);
      av_tags.push_back(2'b00);
      av_tags.push_back(2'b01);
      av_tags.push_back(2'b10);
      av_tags.push_back(2'b11);
      
      sem = new(1);
   endfunction // new

   function void cfg_driver(port_config cg);
      misc_intf = cg.misc_intf;
      port_intf = cg.port_intf;
      port_id = cg.port_id;
   endfunction // cfg_driver
   
   task print_tags();
      if(port_id ==0) begin
	 for(int i = 0; i<av_tags.size();i++)begin
	     uvm_report_info(get_type_name(),$psprintf("%0d",av_tags[i]), UVM_LOW);
     	 end
      end
   endtask
   
   
   task run_phase(uvm_phase phase);
      super.run_phase(phase);
      port_intf.op <= `NO_OP;
      port_intf.d1 <= 0;
      port_intf.d2 <= 0;
      port_intf.r1 <= 0;
      port_intf.data_in<=0;
      
      @(negedge misc_intf.reset);
      fork
	 begin
	    forever begin
	       @(negedge misc_intf.clock);
	       if(av_tags.size()>0) begin
		  seq_item_port.get_next_item(req);
		  sem.get(1);	  
		 // uvm_report_info(get_type_name(),$psprintf("driving request, here are the available tags before assigning to req:"), UVM_LOW);
		 // print_tags();
		  port_intf.tag_in <= av_tags.pop_front();
		 // uvm_report_info(get_type_name(),$psprintf("driving req, here are the available tags after assigning to req:"), UVM_LOW);
		  //print_tags();
		  sem.put(1);
		  port_intf.op <= req.op;
		  port_intf.d1 <= req.d1;
		  port_intf.d2 <= req.d2;
		  port_intf.r1 <= req.r1;
		  port_intf.data_in <= req.data_in;
		  seq_item_port.item_done();
		  @(negedge misc_intf.clock);
		  port_intf.op<=0; // deadcycle
	       end
	    end
	 end // fork begin

	 begin
	    forever begin
	       @(negedge misc_intf.clock);
	       if(port_intf.resp!=0) begin
		  sem.get(1);
		 // uvm_report_info(get_type_name(),$psprintf("resp received, here are the available tags before making resp's tag available again:"), UVM_LOW);
		 // print_tags();
		  av_tags.push_back(port_intf.tag_out);
		 // uvm_report_info(get_type_name(),$psprintf("resp received, here are the available tags after making resp's tag available again:"), UVM_LOW);
		  //print_tags();
		  sem.put(1);
	       end
	    end // forever begin
	 end // fork branch
      join
      
   endtask // run_phase
endclass // port_driver


  