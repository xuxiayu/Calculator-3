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
   
   virtual task run_phase(uvm_phase phase);
      mon_trans req;
      req.port_id = port_id;
  //     req[0] = monitor_trans::type_id::create("req", this);
      // req[1] = monitor_trans::type_id::create("req", this);
      // req[2] = monitor_trans::type_id::create("req", this);
      // req[3] = monitor_trans::type_id::create("req", this);
      int tag_in;
      int op;
      int data_in;
      int r1;
      int d1;
      int d2;
      int data_out;
      int resp;
      int tag_out;
      int state = 0;

      forever begin
         @(negedge misc_intf.clock) begin
            if (misc_intf.reset == 0) begin
               if (state == 0) begin
                  if (port_intf.op != 0) begin
                     tag_in = port_intf.tag_in;
                     op = port_intf.op;
                     data_in = port_intf.data_in;
                     r1 = port_intf.r1;
                     d1 = port_intf.d1;
                     d2 = port_intf.d2;
                     state = 1;
                  else
                     state = 0;
                  end // if (port_intf.op != 0)
                  if (port_intf.resp != 0) begin
                     req.resp = port_intf.resp;
                     req.data_out = port_intf.data_out;
                     req.tag_out = port_intf.tag_out;
                     mon_analysis_port.write(req);
                     req.resp = 0;
                     req.data_out = 0;
                     req.tag_out = 0;
                  end // if (port_intf.resp != 0)
               end // if (state == 0)
               
               else if (state == 1) begin
                  if (req.op != 0) begin
                     `uvm_fatal(get_type_name(), $sformatf("Tag: %d is being used before clearing.", tag_in));
                  end // if (req[tag_in].op != 0)
                  req.tag_in = tag_in;
                  req.op = op;
                  req.data_in = data_in;
                  req.r1 = r1;
                  req.d1 = d1;
                  req.d2 = d2;
                  req.resp = port_intf.resp;
                  req.data_out = port_intf.data_out;
                  req.tag_out = port_intf.tag_out;

                  mon_analysis_port.write(req);
                  // reset
                  req.tag_in = 0;
                  req.op = 0;
                  req.data_in = 0;
                  req.r1 = 0;
                  req.d1 = 0;
                  req.d2 = 0;
                  req.resp = 0;
                  req.data_out = 0;
                  req.tag_out = 0;
                  state = 0;

               end // if (state == 1)

            end // if (misc_intf.reset == 0)
         end
      end // forever
   endtask // run_phase
endclass // port_monitor

	 
		  
      
