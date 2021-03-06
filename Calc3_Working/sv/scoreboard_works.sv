class calc_sb extends uvm_scoreboard;
   `uvm_component_utils(calc_sb)
     uvm_analysis_imp #(mon_trans,calc_sb) item_collected_export;
   virtual misc_if misc_intf;
   typedef mon_trans queue_of_mon_trans[$];
   
   mon_trans global_add[$:15];
   mon_trans global_shift[$:15];
   mon_trans global_add_g2g[$:15];
   mon_trans global_shift_g2g[$:15];
   mon_trans global_resp[$];
   
   mon_trans collect_add[$:15];
   mon_trans collect_shift[$:15];
   mon_trans collect_add_g2g[$:15];
   mon_trans collect_shift_g2g[$:15];
   mon_trans collect_resp[$];
   
  
   

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
   
   function void write(mon_trans data);
      if(data.cmd_nResp == 1 && data.g2g ==0 && (data.op == `ADD||data.op ==`SUB||data.op ==`BEQUAL||data.op ==`BZERO)) begin
	 collect_add.push_back(data);
      end
      else if(data.cmd_nResp == 1 && data.g2g == 0 && (data.op == `SHL||data.op ==`SHR||data.op ==`STORE||data.op ==`FETCH)) begin
	 collect_shift.push_back(data);
      end
      else if(data.cmd_nResp == 1 && data.g2g == 1 && (data.op == `ADD||data.op ==`SUB||data.op ==`BEQUAL||data.op ==`BZERO)) begin
	 //find in global add array port id, tag, check conflict dispatch
	 collect_add_g2g.push_back(data);
      end
      else if(data.cmd_nResp == 1 && data.g2g == 1 && (data.op == `SHL||data.op ==`SHR||data.op ==`STORE||data.op ==`FETCH)) begin
	 //find in global add array port id, tag, check conflict dispatch
	 collect_shift_g2g.push_back(data);
      end
      else if(data.cmd_nResp == 0)
	collect_resp.push_back(data);
   endfunction // write
  
 function void print_q(queue_of_mon_trans q);
    for(int i =0; i<q.size();i++)begin
       uvm_report_info(get_type_name(),$psprintf("port id = %h tag = %h",q[i].port_id,q[i].tag_in), UVM_LOW);
    end
 endfunction

   
   function queue_of_mon_trans sort_q(queue_of_mon_trans q);
      
      queue_of_mon_trans temp_q;
      
      mon_trans temp  = mon_trans::type_id::create("temp",this);
      
      for(int i = 0; i<4; i++)begin
	 for(int j = 0; j<q.size();j++)begin
	    if(q[j].port_id == i)begin
	       temp = q[j];
	       temp_q.push_back(temp);
	    end
	 end   
      end
      return temp_q;
      
   endfunction // sort
   
   function void order_collectors();
      if(collect_add.size() >0)begin
//	 print_q(collect_add);     
	 collect_add= sort_q(collect_add);
	 print_q(collect_add);
      end
      /*
      collect_shift.sort();
      collect_add_g2g.sort();
      collect_shift_g2g.sort();
      collect_resp.sort();
      */
	

	
   endfunction
   task run_phase(uvm_phase phase);
      mon_trans trans;
      forever begin
	 @(negedge misc_intf.clock);
	 order_collectors();
	 
	// wait(global_resp.size()>0);
	 //trans = global_resp.pop_front();
	 /*
  	 uvm_report_info(get_type_name(),
			 $psprintf("\nop\t d1\t d2\t r1\t data_in \t resp\t data_out\t tag_in\t tag_out\t port id\n%h\t %h\t %h\t %h\t %h\t %h\t %h\t %h     \t %h\t %h",
				   trans.op,trans.d1,trans.d2,trans.r1,trans.data_in,trans.resp,trans.data_out,trans.tag_in,trans.tag_out,trans.port_id), UVM_LOW);*/
      end
   endtask // run_phase
endclass // calc_sb
