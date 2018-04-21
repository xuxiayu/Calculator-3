class port_monitor extends uvm_monitor;
   `uvm_component_utils(port_monitor);
   
   virtual   misc_if misc_intf;
   virtual   port_if port_intf;
  
   bit [0:1] tag_in;
   bit [0:1] tag_out;
   bit [0:1] prev_tag;
   bit [0:31] prev_data;

 //  bit [0:1] tag;
  
   int 	     num_cmds = 0;
   int 	     num_resp = 0;
   int 	     port_id;
   
//   semaphore sema[4];

   
   uvm_analysis_port#(mon_trans) item_collected_port;
   
   
   function new(string name,uvm_component parent=null);
      super.new(name,parent);
   endfunction
   
   virtual   function void build_phase (uvm_phase phase);
      super.build_phase(phase);
      item_collected_port = new("item_collected_port",this);
   endfunction // build_phase
   
   function void cfg_monitor(port_config cg);
      misc_intf = cg.misc_intf;
      port_intf = cg.port_intf;
      port_id = cg.port_id;
   endfunction

   //checks that the last tags got responses
   function void check_resp(mon_trans data[4]);
      foreach (data[i]) begin
	 if (data[i].resp_came != 1)
	   uvm_report_error(get_type_name(),$psprintf("responses tag = %0d did not come", data[i].tag_in), UVM_LOW);
      end
   endfunction
 
   virtual   task run_phase(uvm_phase phase);
      mon_trans data_obj[4];
      
      foreach (data_obj[i]) begin
	 data_obj[i] = mon_trans::type_id::create($sformatf("data_obj%0d",i),this);
	 data_obj[i].resp_came = 1;
	 
	 
      end
      
      ////foreach (sema[i]) begin
//	 sema[i]= new(1);
 //     end
   
      @(negedge misc_intf.reset);
      fork
	 begin
	    forever begin
	       @(negedge misc_intf.clock);
	       // wait(port_intf.op != `NO_OP);
	       
	       prev_data = port_intf.data_in;
	       prev_tag = port_intf.tag_in;
	       
	       if(port_intf.op != `NO_OP) begin
		  // sema[port_intf.tag_in].get();
		  
		  tag_in = port_intf.tag_in;
		  
		  if(data_obj[tag_in].resp_came == 1) begin
		     data_obj[tag_in].resp_came = 0;
		     data_obj[tag_in].op = port_intf.op;
		     data_obj[tag_in].data1 = port_intf.data_in;
		     data_obj[tag_in].tag_in = port_intf.tag_in;
		     num_cmds++;
		     
		     if(data_obj[tag_in].op == 1 || data_obj[tag_in].op == 2 || data_obj[tag_in].op == 5 || data_obj[tag_in].op == 6) begin
			@(negedge misc_intf.clock);
			//wait(port_intf.op == `NO_OP);
			
			if(port_intf.op == `NO_OP) begin
			   data_obj[tag_in].data2 = port_intf.data_in;
			   prev_data = port_intf.data_in;
			   prev_tag = tag_in;
			   
			end
			else if(port_intf.op != `NO_OP) begin
			   uvm_report_error(get_type_name(),$psprintf("2nd Cycle OP = %0d, should be 0", port_intf.op), UVM_LOW);	      
			end
		     end // if (data_obj[tag_in].op == 1 || data_obj[tag_in].op == 2 || data_obj[tag_in].op == 5 || data_obj[tag_in].op == 6)
		     //else
		     // data_obj[tag_in].resp_came = 1;
		  end // if (data_obj[tag_in].resp_came == 1)
		  else begin
		     uvm_report_error(get_type_name(),$psprintf("Tried to use a tag (%0d) which is already in use", tag_in), UVM_LOW);
		  end // else: !if(data_obj[tag_in].resp_came == 1)
	       end // if (port_intf.op != `NO_OP)
	       else if(port_intf.op == `NO_OP && (port_intf.data_in != prev_data ||port_intf.tag_in != prev_tag)) begin
		  uvm_report_error(get_type_name(),$psprintf("OP = 0, but data_in (%0d) != prev_data (%0d) || tag_in (%0d) != prev_tag_in (%0d)", port_intf.data_in, prev_data, port_intf.tag_in,prev_tag), UVM_LOW); 
	       end       
	    end // forever begin
	 end // fork begin
	 begin
	    
	    forever begin
	       @(negedge misc_intf.clock);
	       
	       if(port_intf.resp != 0) begin
		  
		  // sema[port_intf.tag_out].get();
		  
		  tag_out = port_intf.tag_out;
		  //data_obj[tag_out].resp_came = 0;
		  data_obj[tag_out].resp = port_intf.resp;
		  data_obj[tag_out].result = port_intf.data_out;
		  data_obj[tag_out].tag_out = port_intf.tag_out;
		  data_obj[tag_out].port_id = port_id;
		  
		  item_collected_port.write(data_obj[tag_out]);
		  
		  data_obj[tag_out].resp_came = 1;
		  
		  //sema[tag].put();
		  num_resp++; 
		  if(num_resp >  num_cmds) // error check for superfluous responese that have no cmds 
		    uvm_report_error(get_type_name(),$psprintf("you have more responses than commands (%0d > %0d)",num_resp,num_cmds),UVM_LOW);
		  
	       end // if (port_intf.resp != 0)
	       else if(port_intf.resp == 0 && port_intf.tag_out!=0) begin
		  uvm_report_error(get_type_name(),$psprintf("Superfluous outputs: RESP=0 but tag_out = %0d", port_intf.tag_out), UVM_LOW);
	       end
	    end // forever begin
	 end
      join
      check_resp(data_obj);
   endtask 
endclass // port_monitor	     
