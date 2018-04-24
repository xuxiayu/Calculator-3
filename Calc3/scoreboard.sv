class calc_sb extends uvm_scoreboard;
   `uvm_component_utils(calc_sb)
     uvm_analysis_imp #(mon_trans,calc_sb) item_collected_export;
   mon_trans queue[$];

   function new(string name,uvm_component parent);
      super.new(name,parent);
   endfunction // new

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      item_collected_export = new("item_collected_export", this);
   endfunction // build_phase

   function void write(mon_trans data);
      queue.push_back(data);
   endfunction // write

   task run_phase(uvm_phase phase);
      mon_trans trans;
      forever begin
	 wait(queue.size()>0);
	 trans = queue.pop_front();
 	 uvm_report_info(get_type_name(),
			 $psprintf("\nop\t d1\t d2\t r1\t data_in \t resp\t data_out\t tag_in\t tag_out\n%h\t %h\t %h\t %h\t %h\t %h\t %h\t %h     \t %h",
				   trans.op,trans.d1,trans.d2,trans.r1,trans.data_in,trans.resp,trans.data_out,trans.tag_in,trans.tag_out), UVM_LOW);
      end
   endtask // run_phase
endclass // calc_sb
