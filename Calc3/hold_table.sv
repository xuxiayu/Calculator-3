class hold_table extends uvm_object;
   `uvm_object_utils(hold_table);
//   const static string type_name ="hold_table";
   
   
   mon_trans data[4];
   
   
   
//   virtual function string get_type_name();
//   return type_name;
//endfunction // get_type_name

//   virtual function uvm_object create(string name="");
 //  hold_table t = new(name);
 //  return t;
//endfunction
   
   function new(string name="");
      super.new(name);
      foreach(data[i])begin
         data[i] = mon_trans::type_id::create($sformatf("data%0d",i),this);
      end
   endfunction // new
   
   
   function void print_hold_table();
      
      $display("printing hold table");
      for(int i = 0; i<4;i++)begin
	 
	 
	 uvm_report_info(get_type_name(),
			    $psprintf("\nop\t d1\t d2\t r1\t data_in \t resp\t data_out\t tag_in\t tag_out\t port id\n%h\t %h\t %h\t %h\t %h\t %h\t %h\t %h     \t %h\t %h",
				      data[i].op,data[i].d1,data[i].d2,data[i].r1,data[i].data_in,data[i].resp,data[i].data_out,data[i].tag_in,data[i].tag_out,data[i].port_id), UVM_LOW);
      end
      
   endfunction // print_hold_table
   
   
endclass // hold_table
