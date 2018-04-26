`include "hold_table.sv"

class port_monitor extends uvm_monitor;
   `uvm_component_utils(port_monitor);
   virtual misc_if misc_intf;
   virtual port_if port_intf;

   int 	   port_id;
   bit [0:`TAG_WIDTH-1]   tag_in, tag_out;
   
   
   mon_trans items[4];
   int  size;
   mon_trans latched;
   mon_trans resp_found;
   mon_trans hold_table[4];
   
   uvm_analysis_port#(mon_trans) item_collected_port;

   function new(string name, uvm_component parent=null);
      super.new(name,parent);
   endfunction // new

   virtual 		  function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      item_collected_port = new("item_collected_port",this);
      foreach(hold_table[i])begin
        hold_table[i] = mon_trans::type_id::create($sformatf("hold_table%0d",i),this);
      end
   latched = mon_trans::type_id::create("latched",this);
   resp_found = mon_trans::type_id::create("resp_found",this);
endfunction // build_phase
   
   function void cfg_monitor(port_config cg);
      misc_intf = cg.misc_intf;
      port_intf = cg.port_intf;
      port_id = cg.port_id;
   endfunction // cfg_monitor
   
   function void write_input_to_latched();
      latched.op = port_intf.op;
      latched.d1 = port_intf.d1;
      latched.d2 = port_intf.d2;
      latched.r1 = port_intf.r1;
      latched.data_in = port_intf.data_in;
      latched.tag_in = port_intf.tag_in;
      latched.cmd_nResp = 1;
      latched.port_id = port_id;
      latched.set_latched();
      item_collected_port.write(latched);
   endfunction // write_input
   
   function void write_output();  
      bit [0:1] tag = port_intf.tag_out; 
      hold_table[tag].resp = port_intf.resp;
      hold_table[tag].tag_out = tag;
      hold_table[tag].data_out = port_intf.data_out;
      hold_table[tag].cmd_nResp = 0;
      item_collected_port.write(hold_table[tag]);
   endfunction; // write_output

   function void check_hold_table();
      print_hold_table();
   endfunction // check_hold_table
   
   function void print_hold_table();
      if(port_id == 0)begin
	 $display("printing hold table");
	 for(int i = 0; i<4;i++)begin
	    
	    
	    uvm_report_info(get_type_name(),
			    $psprintf("\nop\t d1\t d2\t r1\t data_in \t resp\t data_out\t tag_in\t tag_out\t port id\n%h\t %h\t %h\t %h\t %h\t %h\t %h\t %h     \t %h\t %h",
				      hold_table[i].op,hold_table[i].d1,hold_table[i].d2,hold_table[i].r1,hold_table[i].data_in,hold_table[i].resp,hold_table[i].data_out,hold_table[i].tag_in,hold_table[i].tag_out,hold_table[i].port_id), UVM_LOW);
	 end
      end
      
   endfunction // print_hold_table
   
   function void move_latched_to_hold_table();
      if(latched.latched == 1)begin
	 hold_table[latched.tag_in].copy(latched);
      end
   endfunction // move_latched_to_hold_table
   
   virtual task run_phase(uvm_phase phase);
      //mon_trans data[4];
     // foreach(data[i])begin
	// data[i] = mon_trans::type_id::create($sformatf("data%0d",i),this);
      //end

      @(negedge misc_intf.reset);
      fork
	 begin
	    forever begin
	       @(negedge misc_intf.clock);
	       //check_hold table
	       check_hold_table();
	       
	       //move latched items to hold table
	       move_latched_to_hold_table();
	       
	       //get input
	       if(port_intf.op != `NO_OP) begin
		  write_input_to_latched();
	       end
	       //move input to latched	       
	 
	    end // forever begin
	 end // fork begin
	 begin
	    forever begin
	       @(negedge misc_intf.clock);
	       if(port_intf.resp != 0) begin
		  write_output();
		  
	       end
	    end // forever begin
	 end // fork branch
      join
   endtask // run_phase
endclass // port_monitor

	 
		  
      