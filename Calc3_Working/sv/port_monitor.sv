class port_monitor extends uvm_monitor;
   `uvm_component_utils(port_monitor);
   virtual misc_if misc_intf;
   virtual port_if port_intf;

   int 	   port_id;
   bit [0:`TAG_WIDTH-1]   tag_in, tag_out;
   
   uvm_analysis_port#(mon_trans) item_collected_port;

   function new(string name, uvm_component parent=null);
      super.new(name,parent);
   endfunction // new

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      item_collected_port = new("item_collected_port",this);
   endfunction // build_phase
   
   function void cfg_monitor(port_config cg);
      misc_intf = cg.misc_intf;
      port_intf = cg.port_intf;
      port_id = cg.port_id;
   endfunction // cfg_monitor
   
   function mon_trans write_input(mon_trans obj);
      obj.op = port_intf.op;
      obj.d1 = port_intf.d1;
      obj.d2 = port_intf.d2;
      obj.r1 = port_intf.r1;
      obj.data_in = port_intf.data_in;
      obj.tag_in = tag_in;
      obj.cmd_nResp = 1;
      obj.port_id = port_id;
      return obj;     
   endfunction // write_input
   
   function mon_trans write_output(mon_trans obj);   
      obj.resp = port_intf.resp;
      obj.tag_out = tag_out;
      obj.data_out = port_intf.data_out;
      obj.op = 0;
      return obj;
   endfunction; // write_output
   
   virtual task run_phase(uvm_phase phase);
      mon_trans data[4];
      foreach(data[i])begin
	 data[i] = mon_trans::type_id::create($sformatf("data%0d",i),this);
      end

      @(negedge misc_intf.reset);
      fork
	 begin
	    forever begin
	       @(negedge misc_intf.clock);
	       if(port_intf.op!=`NO_OP) begin
		  tag_in = port_intf.tag_in;
		  data[tag_in] = write_input(data[tag_in]);
		  item_collected_port.write(data[tag_in]);
	       end // if (port_intf.op!=`NO_OP)
	    end // forever begin
	 end // fork begin
	 begin
	    forever begin
	       @(negedge misc_intf.clock);
	       if(port_intf.resp != 0) begin
		  tag_out = port_intf.tag_out;
		  data[tag_out] = write_output(data[tag_out]);
		  item_collected_port.write(data[tag_out]);
	       end
	    end // forever begin
	 end // fork branch
      join
   endtask // run_phase
endclass // port_monitor

	 
	     