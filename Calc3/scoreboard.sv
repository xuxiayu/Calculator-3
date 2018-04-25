class calc_sb extends uvm_scoreboard;
   `uvm_component_utils(calc_sb)
     uvm_analysis_imp #(mon_trans,calc_sb) item_collected_export;
   mon_trans global_add[$:15];
   mon_trans global_shift[$:15];
   mon_trans global_resp[$];
   

   function new(string name,uvm_component parent);
      super.new(name,parent);
   endfunction // new

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      item_collected_export = new("item_collected_export", this);
   endfunction // build_phase

   function void write(mon_trans data);
      if(data.cmd_nResp == 1 && (data.op == `ADD||data.op ==`SUB||data.op ==`BEQUAL||data.op ==`BZERO)) begin
	 data.g2g = 0;
	 global_add.push_back(data);
      end
      else if(data.cmd_nResp == 1 && (data.op == `SHL||data.op ==`SHR||data.op ==`STORE||data.op ==`FETCH)) begin
	 data.g2g=0;
	 global_shift.push_back(data);
      end
      else if(data.cmd_nResp == 0)
	global_resp.push_back(data);
   endfunction // write

   task run_phase(uvm_phase phase);
      mon_trans trans;
      forever begin
	 wait(global_resp.size()>0);
	 trans = global_resp.pop_front();
	 /*
  	 uvm_report_info(get_type_name(),
			 $psprintf("\nop\t d1\t d2\t r1\t data_in \t resp\t data_out\t tag_in\t tag_out\t port id\n%h\t %h\t %h\t %h\t %h\t %h\t %h\t %h     \t %h\t %h",
				   trans.op,trans.d1,trans.d2,trans.r1,trans.data_in,trans.resp,trans.data_out,trans.tag_in,trans.tag_out,trans.port_id), UVM_LOW);*/
      end
   endtask // run_phase
endclass // calc_sb
