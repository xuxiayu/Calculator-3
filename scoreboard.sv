`include "mon_trans_cg.sv"

class calc_sb extends uvm_scoreboard;
   `uvm_component_utils(calc_sb)
   uvm_analysis_imp #(mon_trans,calc_sb) item_collected_export;
   mon_trans queue[$];
   mon_trans_cg cov;
   
   bit [0:32] add_result_long;
   bit [0:32] expected_result;
   bit [0:32] MAX = 33'b011111111111111111111111111111111;
   
   bit 	      INFO = 0;
   bit 	      ERROR = 1;
//   bit [0:32]  shift_d2;

   int 	      shifter_size =0;
   int 	      adder_size =0;
   

   
   function new(string name = "calc_sb",uvm_component parent);
      super.new(name,parent);
   endfunction // new
   
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      item_collected_export = new("item_collected_export",this);
      cov = new;
//("cov",this);
   endfunction // build_phase
   
   function void write(mon_trans data);
      // Define what needs to be done when an APB packet is received
      // i.e. put packet into a fifo for later checking, etc
      queue.push_back(data);
   endfunction // write
   
   function void display_info(mon_trans trans, int val, string exp_equal_actual = "N/A", string overflow = "N/A", string underflow = "N/A");
      expected_result = 0;
      case(trans.op)
	`ADD: expected_result = trans.data1+trans.data2;
	`SUB: expected_result = trans.data1-trans.data2;
	`SHL: begin
	   expected_result = trans.data1 << trans.data2[27:31];
	   expected_result = 32'(expected_result);
	   
	end
	`SHR: begin
	   expected_result = trans.data1 >> trans.data2[27:31];
	   expected_result = 32'(expected_result);   
	end
	default: begin
	   expected_result = trans.result;
	end
      endcase // case (trans.op)
      
      case(val)
	INFO: begin

	   uvm_report_info(get_type_name(),
			   $psprintf("\nop\t\t data1\t\t\t data2\t\t\t expected result\t\t\t actual result\t\t\t same?\t\t overflow?\t\t underflow?\t\t resp\t tag\n%0d\t\t %h\t\t\t %h\t\t\t %h\t\t\t %h\t\t\t %s\t\t %s\t\t %s\t\t %0d\t %0d",
				     trans.op,trans.data1,trans.data2,expected_result,trans.result,exp_equal_actual,overflow,underflow,trans.resp,trans.tag_in), UVM_LOW);
	  
	  cov.sample(trans);
 
	end
	ERROR: begin
	   uvm_report_error(get_type_name(),
			   $psprintf("\nop\t\t data1\t\t\t data2\t\t\t expected result\t\t\t actual result\t\t\t same?\t\t overflow?\t\t underflow?\t\t resp\t tag\n%0d\t\t %h\t\t\t %h\t\t\t %h\t\t\t %h\t\t\t %s\t\t %s\t\t %s\t\t %0d\t %0d",
				     trans.op,trans.data1,trans.data2,expected_result,trans.result,exp_equal_actual,overflow,underflow,trans.resp,trans.tag_in), UVM_LOW);
	
	end
      endcase // case (val)
   endfunction // display_info

   //change with enum 
   function void check_add(mon_trans trans);
      add_result_long = trans.data1 + trans.data2;
      if((trans.data1 + trans.data2) == trans.result && trans.resp == 1) begin //valid 
	 display_info(trans,INFO,"YES","NO","NO");	 
      end
      else if(add_result_long > MAX && trans.resp == 2) begin //valid overflow resp
	 display_info(trans,INFO,"NO","YES","NO");
      end
      else if(trans.data1 + trans.data2 == trans.result && trans.resp != 1) // error wrong resp
	display_info(trans,ERROR,"YES","NO","NO"); 
      else if(add_result_long > MAX && trans.resp != 2) //error wrong resp for overflow 
	display_info(trans,ERROR,"NO","YES","NO");
      else
	display_info(trans,ERROR,"NO","NO","NO"); // data1 + data2 != result error 
   endfunction  

   function void check_sub(mon_trans trans);
      if((trans.data1 - trans.data2) == trans.result && trans.resp == 1) //valid 
	display_info(trans,INFO,"YES","NO","NO");
      else if(trans.data2 > trans.data1 && trans.resp == 2) //valid underflow resp
	display_info(trans,INFO,"NO","NO","YES");
      else if(trans.data1 - trans.data2 == trans.result && trans.resp != 1) // error wrong resp
	display_info(trans,ERROR,"YES","NO","NO"); 
      else if(trans.data2 > trans.data1 && trans.resp != 2) //error wrong resp for overflow 
	display_info(trans,ERROR,"NO","NO","YES");
      else
	display_info(trans,ERROR,"NO","NO","NO"); // data1 + data2 != result error 
   endfunction   
   
   function void check_shl(mon_trans trans);
      //shift_d2 = trans.data2 & 00000000000000000000000000011111; 
      if((trans.data1 << trans.data2[27:31]) == trans.result && trans.resp == 1) begin
	// uvm_report_info(get_type_name(),$psprintf("Entering 1 data1 = %b data2 = %b data2 truncated = %b",trans.data1,trans.data2,trans.data2[27:31]), UVM_LOW);
	 display_info(trans,INFO,"YES","NO","NO");
      end
      else if ((trans.data1 << trans.data2[27:31]) == trans.result && trans.resp !=1) begin
	//uvm_report_info(get_type_name(),$psprintf("Entering 2 data1 = %b data2 = %b data2 truncated = %b",trans.data1,trans.data2,trans.data2[27:31]), UVM_LOW);
	display_info(trans,ERROR,"YES","NO","NO"); // wrong error
      end
      else begin
	 //uvm_report_info(get_type_name(),$psprintf("Entering 3 data1 = %b data2 = %b data2 truncated = %b",trans.data1,trans.data2,trans.data2[27:31]), UVM_LOW);
	 display_info(trans,ERROR,"NO","NO","NO"); // data1<<data2 != result
      end//  
   endfunction // check_shl
   
   function void check_shr(mon_trans trans);
      if(trans.data1 >> trans.data2[27:31] == trans.result && trans.resp == 1)
	display_info(trans,INFO,"YES","NO","NO");
      else if (trans.data1 >> trans.data2[27:31] == trans.result && trans.resp !=1)
	display_info(trans,ERROR,"YES","NO","NO"); // wrong error
      else
	display_info(trans,ERROR,"NO","NO","NO"); // data1<<data2 != result 
   endfunction 
   
   function void check_invalid (mon_trans trans);
      if(trans.resp == 2)
	display_info(trans,INFO,"NO","NO","NO");
      else if (trans.resp !=2)
	display_info(trans,ERROR,"NO","NO","NO"); // wrong error
   endfunction // check_invalid
   
   function void check_result(mon_trans trans);
      case(trans.op)
	`ADD: begin
	   check_add(trans);
	   adder_size++;
	   
	end
	`SUB: begin
	   check_sub(trans);
	   adder_size++;
	   
	end
	`SHL:begin
	   check_shl(trans);  
	   shifter_size++;
	   
	end
	`SHR:begin
	   check_shr(trans);
	   shifter_size++;
	   
	end
	default: begin
	   check_invalid(trans);
	end 
      endcase 
   endfunction

   task run_phase(uvm_phase phase);
      //fork checker tasks and launch other functions
      mon_trans trans;
      
      forever begin
	 //get trans from monitor
	 wait(queue.size() > 0);
	 trans = queue.pop_front();
	 check_result(trans);
	 /*
	  if((trans.data1 + trans.data2) == trans.result) begin 
	    uvm_report_info(get_type_name(),$psprintf("Exp Result (%0d) ==  Actual Result (%0d) (for op %0d, data1 %0d, data2 %0d, tag %0d)",trans.data1+trans.data2,trans.result,trans.op,trans.data1,trans.data2,trans.tag_in), UVM_LOW); 
	   // $display("Result is as expected");
	 end   
	 else begin
	    uvm_report_error(get_type_name(),$psprintf("Exp Result (%0d) !=  Actual Result (%0d) (for op %0d, data1 %0d, data2 %0d, tag %0d)",trans.data1+trans.data2,trans.result,trans.op,trans.data1,trans.data2,trans.tag_in), UVM_LOW);
	 end
	  */
      end // forever begin
   endtask // run_phase
   
   virtual function void check_phase(uvm_phase phase);
   //compare between received packets or something similar
   
   endfunction // check_phase
endclass // calc_sb

