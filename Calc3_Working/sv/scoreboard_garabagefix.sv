class calc_sb extends uvm_scoreboard;
   `uvm_component_utils(calc_sb)
     uvm_analysis_imp #(mon_trans,calc_sb) item_collected_export;
   virtual misc_if misc_intf;
   //typedef mon_trans queue_of_mon_trans[$];
   
   mon_trans global_add[$];
   mon_trans global_shift[$];
   mon_trans global_resp[$];
   
   function new(string name,uvm_component parent);
      super.new(name,parent);
   endfunction // new

   virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     item_collected_export = new("item_collected_export", this);
  
   
   endfunction // build_phase

   function void cfg_scb(port_config cg);
      misc_intf = cg.misc_intf;
   endfunction // cfg_scb
   
   function void write(mon_trans item);
      mon_trans  data = new();
      data.copy(item);
      
      if(data.cmd_nResp == 1 && data.g2g ==0 && (data.op == `ADD||data.op ==`SUB||data.op ==`BEQUAL||data.op ==`BZERO)) begin
	global_add.push_back(data);
      end
      else if(data.cmd_nResp == 1 && data.g2g == 0 && (data.op == `SHL||data.op ==`SHR||data.op ==`STORE||data.op ==`FETCH)) begin
	 global_shift.push_back(data);
      end
      else if(data.cmd_nResp == 1 && data.g2g == 1 && (data.op == `ADD||data.op ==`SUB||data.op ==`BEQUAL||data.op ==`BZERO)) begin
	 //set g2g on global table to 1
	 set_g2g_in_global(data);
      end
      else if(data.cmd_nResp == 1 && data.g2g == 1 && (data.op == `SHL||data.op ==`SHR||data.op ==`STORE||data.op ==`FETCH)) begin
	 //find in global add array port id, tag, check conflict dispatch
	 set_g2g_in_global(data);
      end
      else if(data.cmd_nResp == 0)
	global_resp.push_back(data);
   endfunction // write
  

   function void set_g2g_in_global(mon_trans data);
      if(data.op == `ADD||data.op ==`SUB||data.op ==`BEQUAL||data.op ==`BZERO) begin
	 for(int i =0; i < global_add.size();i++)begin
	    if(global_add[i].port_id == data.port_id && global_add[i].tag_in == data.tag_in)begin
	       global_add[i].g2g =1;
	    end
	 end
      end
      else if(data.op == `SHL||data.op ==`SHR||data.op ==`STORE||data.op ==`FETCH) begin
	 for(int i =0; i < global_shift.size();i++)begin
	    if(global_shift[i].port_id == data.port_id && global_shift[i].tag_in == data.tag_in)begin
	       global_shift[i].g2g =1;
	    end
	 end
      end
   endfunction
   

   task run_phase(uvm_phase phase);
      mon_trans trans;
      forever begin
	 @(negedge misc_intf.clock);
	 $display("%0d",global_add.size());
	 

	 if(global_add.size() >0)begin
	    $display("printing gobal add");
	    print_q(global_add);

	 end
	 else
	   $display("gobal add is empty");
	 if(global_shift.size() > 0)begin
	    $display("printing gobal shift");
	    print_q(global_shift);
	 end
	 else 
	   $display("gobal shift is empty");

	 //order_collectors();
	 //move_from_collectors_to_global_tables();
	 
	// wait(global_resp.size()>0);
	// trans = global_resp.pop_front();
	 /*
  	 uvm_report_info(get_type_name(),
			 $psprintf("\nop\t d1\t d2\t r1\t data_in \t resp\t data_out\t tag_in\t tag_out\t port id\n%h\t %h\t %h\t %h\t %h\t %h\t %h\t %h     \t %h\t %h",
				   trans.op,trans.d1,trans.d2,trans.r1,trans.data_in,trans.resp,trans.data_out,trans.tag_in,trans.tag_out,trans.port_id), UVM_LOW);*/
      end
   endtask // run_phase
endclass // calc_sb
