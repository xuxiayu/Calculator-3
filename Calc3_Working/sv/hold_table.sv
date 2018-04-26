class hold_table extends uvm_component;
   `uvm_component_utils(hold_table)
   
      
   
   mon_trans data[4];
   bit valid[4];
   bit block[4];
   bit [0:1] blocking_tags[4];
   int  check_order[4][3] = '{'{3,2,1},'{0,3,2},'{1,0,3},'{2,1,0}};
   
   
   
   
   

   
   function new(string name,uvm_component parent);
      super.new(name,parent);
   endfunction // new
   
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);      
      foreach(data[i])begin
         data[i] = mon_trans::type_id::create($sformatf("data%0d",i),this);
	 valid[i]= 0'b0;
	 block[i] =0'b0;
	 blocking_tags[i] = 2'b00;
      end
   endfunction // build_phase
   
   function void clear(bit[0:1] t);
      data[t].clear();
      valid[t] = 0;
      block[t] = 0;
      unblock_data(t);
      blocking_tags[t] = 2'b00;	 
   endfunction     

   function void unblock_data(bit [0:1] tag);
      for(int i = 0; i<4; i++) begin
	 if(blocking_tags[i] == tag)begin
	    block[i] = 0;
	    blocking_tags[i] = 2'b00;
	 end
      end
   endfunction

   function void  set_g2g();
      for(int i = 0; i<4;i++)begin
	 if(valid[i]==1)begin
	    check_for_conflict(i);
	 end
      end 
    endfunction // set_g2g
   
   function void check_for_conflict(int i);
      for(int j = 0; j<3; j++)begin
	 int k = check_order[i][j];
	 if(valid[k] == 1) begin
	    if(data[i].d1 == data[k].r1 || data[i].d2 == data[k].r1 || data[i].r1 == data[k].r1)begin
	       block[i]=1;
	       blocking_tags[i] = data[k].tag_in;
	       break;
	    end
	 end
      end
   endfunction
   
   function void print_hold_table();
      
      $display("printing hold table");
      for(int i = 0; i<4;i++)begin
	 uvm_report_info(get_type_name(),
			 $psprintf("\nop\t d1\t d2\t r1\t data_in \t resp\t data_out\t tag_in\t tag_out\t port id  \t valid\t block\t blocking tags\t g2g\n%h\t %h\t %h\t %h\t %h\t %h\t %h\t %h     \t %h      \t %h\t  %h    \t %h    \t %h           \t  %h",
				   data[i].op,data[i].d1,data[i].d2,data[i].r1,data[i].data_in,data[i].resp,data[i].data_out,data[i].tag_in,data[i].tag_out,data[i].port_id,valid[i],block[i],blocking_tags[i],data[i].g2g), UVM_LOW);
      end
      
   endfunction // print_hold_table
   
endclass // hold_table
