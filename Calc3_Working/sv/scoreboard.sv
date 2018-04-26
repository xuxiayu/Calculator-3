
class calc_sb extends uvm_scoreboard;
   `uvm_component_utils(calc_sb)

   virtual misc_if misc_intf;
   port_config cfg;

   function void cfg_scb(port_config cg);
      misc_intf = cg.misc_intf;
   endfunction // cfg_monitor

   uvm_analysis_imp #(mon_trans,calc_sb) item_collected_export;

   mon_trans output_queue[$];
   mon_trans simulated_output_queue[$];
   mon_trans shift_table[$];
   mon_trans add_table[$];
   mon_trans invalid_table[$];
   mon_trans sim_trans;
   mon_trans previous_add;
   mon_trans previous_shift;

   
   int unsigned hold_table[4][4][9];
   int unsigned registers [16][2];
   int dispatch = 1;
   int toggle = 0;
   int get_next_tag[4];
   int next_tag[4];
   

   int prev_shift_r1;

   int prev_add_r1;

   function new(string name,uvm_component parent);
      super.new(name,parent);
   endfunction // new

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      item_collected_export = new("item_collected_export", this);
      sim_trans = mon_trans::type_id::create("sim_trans", this);
      previous_add = mon_trans::type_id::create("previous_add", this);
      previous_shift = mon_trans::type_id::create("previous_shift", this);
   endfunction // build_phase

   function void write(mon_trans data);
      if (data.op != 0) begin
	 //`uvm_info(get_type_name(), $sformatf("Inputs: Port_ID: %0d, tag_in: %0d", data.port_id, data.tag_in), UVM_LOW);
      end
      
      update_everything(data);
   endfunction // write

   task run_phase(uvm_phase phase);
      int count = output_queue.size();
      
      
      forever begin
         @(posedge misc_intf.clock) begin
	    `uvm_info(get_type_name(), $sformatf("--------------------------------SIMULATED OUTPUTS-----------------------------------------"), UVM_LOW);
	    for (int i = 0; i < simulated_output_queue.size(); i++) begin
	       `uvm_info(get_type_name(), $sformatf("Sims: Port_ID: %0d, tag_out: %0d, op: %0d, resp: %0d, data_out: %0d", simulated_output_queue[i].port_id, simulated_output_queue[i].tag_out, simulated_output_queue[i].op, simulated_output_queue[i].resp, simulated_output_queue[i].data_out), UVM_LOW);
	    end

	    `uvm_info(get_type_name(), $sformatf("--------------------------------REAL OUTPUTS-----------------------------------------"), UVM_LOW);
	    
		      
	    for (int i = 0; i < output_queue.size(); i++) begin
	       `uvm_info(get_type_name(), $sformatf("Real Output: Port_ID: %0d, tag_out: %0d, data_out: %0d", output_queue[i].port_id, output_queue[i].tag_out, output_queue[i].data_out), UVM_LOW);	
	    end

	    if (output_queue.size() > simulated_output_queue.size()) begin
	       `uvm_error(get_type_name(), $sformatf("Too many outputs generated, likely due to bad dispatch or togic"));
	    end
	    

		

	    /*for (int i = 0; i < output_queue.size(); i++) begin
	       `uvm_info(get_type_name(), $sformatf("Real_Output: Port_ID: %0d, tag_out: %0d, resp: %0d, data: %0d", output_queue[i].port_id, output_queue[i].tag_out, output_queue[i].resp, output_queue[i].data_out), UVM_LOW);	
	    end

	    
            for (int i = 0; i < output_queue.size(); i++) begin
               for (int j = 0; j < output_queue.size(); j++) begin
                  if (compare_output(output_queue[i], simulated_output_queue[j]) == 1) begin
                     count = count - 1;
                     break;
                  end 

               end // for (int j = 0; j < output_queue.size(); j++)
            end // for (int i = 0; i < output_queue.size(); i++)

            // remove from both queues
            for (int counter = 0; counter < output_queue.size(); counter ++) begin
               output_queue.delete(0);
               simulated_output_queue.delete(0);
            end // for (int counter = 0; counter < output_queue.size(); counter ++)*/

	    dispatch_logic();
         end // @ (posedge misc_intf.clock)
	

      end

   endtask // run_phase


  
   // Functions
   function int compare_output(mon_trans A, B);
      if (A.port_id == B.port_id) begin
	 //`uvm_info(get_type_name(), $sformatf("Port_ID: %0d, resp: %0d, tag_out: %0d, data: %0d", A.port_id, A.resp, A.tag_out, A.data_out), UVM_LOW);
	 //`uvm_info(get_type_name(), $sformatf("S_Port_ID: %0d, Op: %0d, resp: %0d, tag_out: %0d, data: %0d", B.port_id, B.op, B.resp, B.tag_out, B.data_out), UVM_LOW);
         if (A.resp == B.resp && A.tag_out == B.tag_out && A.data_out == B.data_out) begin
            return 1;
         end 
         else begin
            `uvm_error(get_type_name(), $sformatf("Oh no"));
         end
      end
      return 0;
   endfunction : compare_output

   virtual function void update_everything(mon_trans A);
      if (A.resp != 0) begin
	 //`uvm_info(get_type_name(), $sformatf("Actual_Response: Port_ID: %0d, resp: %0d, tag_out: %0d, data: %0d", A.port_id, A.resp, A.tag_out, A.data_out), UVM_LOW);
         output_queue.push_back(A);
      end // if (A.resp != 0)

      if (A.op != 0) begin
         hold_table[A.port_id][A.tag_in][5] = A.op;
         hold_table[A.port_id][A.tag_in][6] = A.d1;
         hold_table[A.port_id][A.tag_in][7] = A.d2;
         hold_table[A.port_id][A.tag_in][8] = A.r1;
	 
	 
         for (int i = 0; i < 4; i++) begin
	    if (hold_table[A.port_id][i][5] == 1 || hold_table[A.port_id][i][5] == 2 ||hold_table[A.port_id][i][5] == 5 ||hold_table[A.port_id][i][5] == 6 ||hold_table[A.port_id][i][5] == 9 ||hold_table[A.port_id][i][5] == 10 ||hold_table[A.port_id][i][5] == 12 ||hold_table[A.port_id][i][5] == 13) begin

	    if (get_next_tag[A.port_id] == 1) begin
	       get_next_tag[A.port_id] = 0;
	       next_tag[A.port_id] = A.tag_in + 1;
	       
	     end
	 
	    if (A.op == 12 || A.op == 13) begin
	       get_next_tag[A.port_id] = 1;
	    end
	       
	    if (A.op == `STORE) begin
	       if (hold_table[A.port_id][i][5] == 10 ||hold_table[A.port_id][i][5] == 12 ) begin
		  if (A.r1 == hold_table[A.port_id][i][6]) begin
		     hold_table[A.port_id][A.tag_in][i] = 1;
		  end
	       end
	       else if (hold_table[A.port_id][i][5] == 13) begin
		  if (A.r1 == hold_table[A.port_id][i][6] || A.r1 == hold_table[A.port_id][i][7]) begin
		     hold_table[A.port_id][A.tag_in][i] = 1;
		  end
	       end

	       else if (hold_table[A.port_id][i][5] == 9) begin
		  if (A.r1 == hold_table[A.port_id][i][6] || A.d1 == hold_table[A.port_id][i][8]) begin
		     hold_table[A.port_id][A.tag_in][i] = 1;
		  end
	       end
	       
	       else if (A.r1 == hold_table[A.port_id][i][8] || A.r1 == hold_table[A.port_id][i][6] || A.r1 == hold_table[A.port_id][i][7] || A.d1 == hold_table[A.port_id][i][8]) begin
		   hold_table[A.port_id][A.tag_in][i] = 1;
	       end
	    end
	       
	    else if (A.op == `FETCH || A.op == 12) begin
	       if (hold_table[A.port_id][i][5] == 13 || hold_table[A.port_id][i][5] == 12 || hold_table[A.port_id][i][5] == 10) begin

	       end
	       
	       else if (A.d1 == hold_table[A.port_id][i][8]) begin
		   hold_table[A.port_id][A.tag_in][i] = 1;
	       end
	    end
	    else if (A.op == 13) begin
	       if (hold_table[A.port_id][i][5] == 13 || hold_table[A.port_id][i][5] == 12 || hold_table[A.port_id][i][5] == 10) begin
		  
	       end 
	       else if (A.d1 == hold_table[A.port_id][i][8] || A.d2 == hold_table[A.port_id][i][8]) begin
		  hold_table[A.port_id][A.tag_in][i] = 1;
	       end
	       
	       
	    end
	       
	    
            else if (A.r1 == hold_table[A.port_id][i][8] || A.d1 == hold_table[A.port_id][i][8] || A.d2 == hold_table[A.port_id][i][8] || A.r1 == hold_table[A.port_id][i][6] || A.r1 == hold_table[A.port_id][i][7]) begin
               hold_table[A.port_id][A.tag_in][i] = 1;
            end // if (A.r1 == hold_table[A.port_id][i][8] || A.d1 == hold_table[A.port_id][i][8] || A.d2 == hold_table[A.port_id][i][8])

	    end // if (hold_table[A.port_id][i][5] == 1 || hold_table[A.port_id][i][5] == 2 ||hold_table[A.port_id][i][5] == 5 ||hold_table[A.port_id][i][5] == 6 ||hold_table[A.port_id][i][5] == 9 ||hold_table[A.port_id][i][5] == 10 ||hold_table[A.port_id][i][5] == 12 ||hold_table[A.port_id][i][5] == 13)
		   
         end // for (int i = 0; i < 4; i++)
         hold_table[A.port_id][A.tag_in][A.tag_in] = 0;

         if (hold_table[A.port_id][A.tag_in][0] == 0 && hold_table[A.port_id][A.tag_in][1] == 0 && hold_table[A.port_id][A.tag_in][2] == 0 && hold_table[A.port_id][A.tag_in][3] == 0) begin
            hold_table[A.port_id][A.tag_in][4] = 1;
         end // if (hold_table[A.port_id][A.tag_in][0] == 0 && hold_table[A.port_id][A.tag_in][1] == 0 && hold_table[A.port_id][A.tag_in][2] == 0 && hold_table[A.port_id][A.tag_in][3] == 0 &&)
      end // if (A.op != 0)

      if (A.op == 1 || A.op == 2 || A.op == 12 || A.op == 13) begin
         add_table.push_back(A);
      end // if (A.op == 1 || A.op == 2)

      else if (A.op == 5 || A.op == 6 || A.op == 9 || A.op == 10) begin
         shift_table.push_back(A);
      end // if (A.op == 5 || A.op == 6 || A.op == 9 || A.op == 10)

      else if (A.op == 0) begin

      end // else if (A.op == 0)

      else begin
         invalid_table.push_back(A);
      end // else
   endfunction : update_everything

   virtual function void dispatch_logic();
      int add_index;
      bit [0:3] add_r1;
      bit [0:3] add_d1;
      bit [0:3] add_d2;
      bit [0:31] add_data_in;
      bit [0:1] add_port_id;
      bit [0:1] add_tag;
      bit [0:3] add_op;

      int shift_index;
      bit [0:3] shift_r1;
      bit [0:3] shift_d1;
      bit [0:3] shift_d2;
      bit [0:31] shift_data_in;
      bit [0:1] shift_port_id;
      bit [0:1] shift_tag;
      bit [0:3] shift_op;

      int add_found;
      int shift_found;

      int unsigned fetch_cmd;
      
      
   
      int valid_resp[4];

   int 	  port_used[4];
   
      // BRANCH SKIP
   for (int i = 0; i < 4; i++) begin
	    if (next_tag[i] > 0) begin
	       mon_trans temp = new();
	       
	       port_used[next_tag[i]-1] = 1;
	       next_tag[i] = 0;
	      
	       sim_trans.tag_out = next_tag[i]-1;
	       sim_trans.port_id = i;
	       sim_trans.resp = 3;
	       sim_trans.data_out = 0;
	       temp.copy(sim_trans);
               simulated_output_queue.push_back(temp);
	       
	       for (int j = 0; j < add_table.size(); j++) begin
		  if (add_table[j].port_id == sim_trans.port_id && add_table[j].tag_in == sim_trans.tag_out) begin
		     add_table.delete(j);
		     break;
		  end
	       end
	       for (int j = 0; j < shift_table.size(); j++) begin
		  if (shift_table[j].port_id == sim_trans.port_id && shift_table[j].tag_in == sim_trans.tag_out) begin
		     shift_table.delete(j);
		     break;
		  end
	       end
		   
		
 
	    end // if (next_tag[i] > 0)
   end // for (int i = 0; i < 4; i++)
   
   
      
      if (toggle == 0) begin
	 
         for (int add_queue = 0; add_queue < add_table.size(); add_queue++) begin
	 
	    
            if (hold_table[add_table[add_queue].port_id][add_table[add_queue].tag_in][4] == 1 && port_used[add_table[add_queue].port_id] == 0) begin
               add_index = add_queue;
               add_tag = add_table[add_queue].tag_in;
               add_port_id = add_table[add_queue].port_id;
               add_data_in = add_table[add_queue].data_in;
               add_op = hold_table[add_port_id][add_tag][5];
               add_d1 = hold_table[add_port_id][add_tag][6];
               add_d2 = hold_table[add_port_id][add_tag][7];
               add_r1 = hold_table[add_port_id][add_tag][8];
	       
	       
	       if (prev_shift_r1 != add_d1 && (prev_shift_r1 != add_d2 || add_op == 12) && prev_add_r1 != add_d2 && (prev_add_r1 != add_d2 || add_op == 12)) begin
		  
               // remove from queue
               add_table.delete(add_queue);

               // indicate a valid is found
               add_found = 1;

               update_hold_table(add_port_id, add_tag);
               break;
	       end // if (prev_shift_r1 != add_d1 && (prev_shift_r1 != add_d2 || add_op == 12))
	       
            end // if add_table_valid[add_queue] = 1
         end // for (int add_queue = 0; add_queue < add_table_valid.size(); add_queue++)

         // shift table
         for (int shift_queue = 0; shift_queue < shift_table.size(); shift_queue++) begin
            if (hold_table[shift_table[shift_queue].port_id][shift_table[shift_queue].tag_in][4] == 1 && port_used[shift_table[shift_queue].port_id] == 0) begin
               shift_tag = shift_table[shift_queue].tag_in;
               shift_port_id = shift_table[shift_queue].port_id;
               shift_data_in = shift_table[shift_queue].data_in;
               shift_op = hold_table[shift_port_id][shift_tag][5];
               shift_d1 = hold_table[shift_port_id][shift_tag][6];
               shift_d2 = hold_table[shift_port_id][shift_tag][7];
               shift_r1 = hold_table[shift_port_id][shift_tag][8];
               if (add_found == 1) begin
		  if (shift_port_id == add_port_id) begin

		  end
		  
                  else if (shift_r1 == add_r1 && shift_op != 10) begin
                     toggle = 1;
                     break;
                  end // if (hold_table[shift_table[shift_queue].port_id][shift_table[shift_queue].tag_in[6] == add_r1 ||)
		  else if (prev_shift_r1 != shift_d1 && (prev_shift_r1 != shift_d2|| shift_op == 10 || shift_op == 9) && prev_add_r1 != shift_d1 && (prev_add_r1 != shift_d2 || shift_op == 10 || shift_op == 9)) begin
		     // remove from queue
                     shift_table.delete(shift_queue);
                     // indicate a valid is found
                     shift_found = 1;
                     update_hold_table(shift_port_id, shift_tag);
                     break;
		  end
                  else begin
                     toggle = 1;
		     break;
		    
		
                  end // else
               end // if (add_found == 1)

               else begin // nothing valid in add table thus no possible conflict
                  
                  shift_table.delete(shift_queue);
                  // indicate a valid is found
                  shift_found = 1;
                  update_hold_table(shift_port_id, shift_tag);
                  break;
                  
               end // else

            end // if (hold_table[shift_table[shift_queue].port_id][shift_table[shift_queue].tag_in][4] == 1)
         end // for (int shift_queue = 0; shift_queue < shift_table.size(); shift_queue++)
      end // if (toggle == 0)

      // Toggle = 1
      else begin
         for (int shift_queue = 0; shift_queue < shift_table.size(); shift_queue++) begin
            if (hold_table[shift_table[shift_queue].port_id][shift_table[shift_queue].tag_in][4] == 1 && port_used[shift_table[shift_queue].port_id] == 0) begin
               shift_index = shift_queue;
               shift_tag = shift_table[shift_queue].tag_in;
               shift_port_id = shift_table[shift_queue].port_id;
               shift_data_in = shift_table[shift_queue].data_in;
               shift_op = hold_table[shift_port_id][shift_tag][5];
               shift_d1 = hold_table[shift_port_id][shift_tag][6];
               shift_d2 = hold_table[shift_port_id][shift_tag][7];
               shift_r1 = hold_table[shift_port_id][shift_tag][8];

	       if (prev_shift_r1 != shift_d1 && (prev_shift_r1 != shift_d2 || shift_op == 10 || shift_op == 9) && prev_add_r1 != shift_d1 && (prev_add_r1 != shift_d2|| shift_op == 10 || shift_op == 9)) begin
               // remove from queue
               shift_table.delete(shift_queue);

               // indicate a valid is found
               shift_found = 1;

               update_hold_table(shift_port_id, shift_tag);
               break;
	       end
            end // if shift_table_valid[shift_queue] = 1
         end // for (int shift_queue = 0; shift_queue < shift_table_valid.size(); shift_queue++)   

         for (int add_queue = 0; add_queue < add_table.size(); add_queue++) begin
            if (hold_table[add_table[add_queue].port_id][add_table[add_queue].tag_in][4] == 1 && port_used[add_table[add_queue].port_id] == 0) begin
               add_tag = add_table[add_queue].tag_in;
               add_port_id = add_table[add_queue].port_id;
               add_data_in = add_table[add_queue].data_in;
               add_op = hold_table[add_port_id][add_tag][5];
               add_d1 = hold_table[add_port_id][add_tag][6];
               add_d2 = hold_table[add_port_id][add_tag][7];
               add_r1 = hold_table[add_port_id][add_tag][8];
               if (shift_found == 1) begin
		  if (add_port_id == shift_port_id) begin

		  end
		  
                  else if (add_r1 == shift_r1) begin
                     toggle = 0;
                     break;
                  end // if (hold_table[add_table[add_queue].port_id][add_table[add_queue].tag_in[6] == shift_r1 ||)

		  if (prev_shift_r1 != add_d1 && (prev_shift_r1 != add_d2 || add_op == 12) && prev_add_r1 != add_d2 && (prev_add_r1 != add_d2 || add_op == 12)) begin
		     // remove from queue
                     add_table.delete(add_queue);
                     // indicate a valid is found
                     add_found = 1;
                     update_hold_table(add_port_id, add_tag);
                     break;
		  end
		  
                  else begin
                     toggle = 0;
		     break;
		     
                  end // else
               end // if (add_found == 1)

               else begin
                  
                  add_table.delete(add_queue);
                  // indicate a valid is found
                  add_found = 1;
                  update_hold_table(add_port_id, add_tag);
                  break;

               end // else

            end // if (hold_table[add_table[add_queue].port_id][add_table[add_queue].tag_in][4] == 1)
         end // for (int add_queue = 0; add_queue < add_table.size(); add_queue++)
      end // else

      // Generating Simulated Responses

      if (shift_found == 1) begin
	 mon_trans temp = new();
	 
         valid_resp[shift_port_id] = 1;
         if (shift_op == 5) begin
            registers[shift_r1][0] = 5;
            registers[shift_r1][1] = registers[shift_d1][1] << registers[shift_d2][1][4:0];
            sim_trans.tag_out = shift_tag;
            sim_trans.port_id = shift_port_id;
            sim_trans.resp = 1;
	    sim_trans.op = 5;
            sim_trans.data_out = 0;
	    temp.copy(sim_trans);
            simulated_output_queue.push_back(temp);
         end // if (shift_op == 5)
         else if (shift_op == 6) begin
            registers[shift_r1][0] = 6;
            registers[shift_r1][1] = registers[shift_d1][1] >> registers[shift_d2][1][4:0];
            sim_trans.tag_out = shift_tag;
            sim_trans.port_id = shift_port_id;
            sim_trans.resp = 1;
	    sim_trans.op = 6;
            sim_trans.data_out = 0;
	    temp.copy(sim_trans);
            simulated_output_queue.push_back(temp);
         end // else if (shift_op == 6)
         else if (shift_op == 9) begin
            registers[shift_r1][0] = 9;
            registers[shift_r1][1] = shift_data_in; 
            sim_trans.tag_out = shift_tag;
            sim_trans.port_id = shift_port_id;
            sim_trans.resp = 1;
            sim_trans.data_out = 0;
	    sim_trans.op = 9;
	    temp.copy(sim_trans);
            simulated_output_queue.push_back(temp);
         end
         else if (shift_op == 10) begin
            fetch_cmd = registers[shift_r1][0];
            sim_trans.tag_out = shift_tag;
            sim_trans.port_id = shift_port_id;
            sim_trans.resp = 1;
            sim_trans.data_out = registers[shift_r1][1];
            sim_trans.op = registers[shift_r1][0];
	    temp.copy(sim_trans);
            simulated_output_queue.push_back(temp);
         end // else if (shift_op == 10)
      end // if (shift_found)

      if (add_found == 1) begin
	 mon_trans temp = new();
	 
         valid_resp[add_port_id] = 1;
         if (add_op == 1) begin
            registers[add_r1][0] = 1;
            registers[add_r1][1] = registers[add_d1][1] + registers[add_d2][1];
            sim_trans.tag_out = add_tag;
            sim_trans.port_id = add_port_id;
            if (registers[add_r1][1] < registers[add_d1][1] || registers[add_r1][1] < registers[add_d2][1]) begin
               sim_trans.resp = 2;
            end
            else begin
               sim_trans.resp = 1;
            end // else
            sim_trans.data_out = 0;
	    sim_trans.op = 1;
	    temp.copy(sim_trans);
            simulated_output_queue.push_back(temp);
         end // if (add_op == 5)
         else if (add_op == 2) begin
            registers[add_r1][0] = 2;
            registers[add_r1][1] = registers[add_d1][1] - registers[add_d2][1];
            sim_trans.tag_out = add_tag;
            sim_trans.port_id = add_port_id;
            if (registers[add_r1][1] > registers[add_d1][1] || registers[add_r1][1] > registers[add_d2][1]) begin
               sim_trans.resp = 2;
            end
            else begin
               sim_trans.resp = 1;
            end // else
            sim_trans.data_out = 0;
	    sim_trans.op = 2;
	    temp.copy(sim_trans);
            simulated_output_queue.push_back(temp);
         end // else if (add_op == 6)
         // ADD BRANCHING
	 else if (add_op == 12) begin
	    mon_trans temp = new();
	    sim_trans.tag_out = add_tag;
	    sim_trans.port_id = add_port_id;
	    sim_trans.resp = 1;
	    if (registers[add_d1][1] == 0) begin
	       sim_trans.data_out = 1;
	       get_next_tag[sim_trans.port_id] = 1;
	       
	    end
	    else begin
	       sim_trans.data_out = 0;
	    end
	    temp.copy(sim_trans);
            simulated_output_queue.push_back(temp);
	   
	 end
	 else if (add_op == 13) begin
	    mon_trans temp = new();
	    sim_trans.tag_out = add_tag;
	    sim_trans.port_id = add_port_id;
	    sim_trans.resp = 1;
	    if (registers[add_d1][1] == registers[add_d2][1]) begin
	       sim_trans.data_out = 1;
	       get_next_tag[sim_trans.port_id] = 1;
	    end
	    else begin
	       sim_trans.data_out = 0;
	    end
	    temp.copy(sim_trans);
            simulated_output_queue.push_back(temp);
	 end
	 

	 //`uvm_info(get_type_name(), $sformatf("Simulated Dispatch: Port_ID: %0d, op: %0d, resp: %0d, tag_out: %0d, data: %0d", sim_trans.port_id, sim_trans.op, sim_trans.resp, sim_trans.tag_out, sim_trans.data_out), UVM_LOW);
      end // if (add_found)

      // Invalid removal
      for (int i = 0; i < 4; i++) begin
         if (valid_resp[i] == 0) begin
            for (int j = 0; j < invalid_table.size(); j++) begin
               if (invalid_table[j].port_id == i) begin
		  mon_trans temp = new();
                  sim_trans.port_id = i;
                  sim_trans.data_out = 0;
                  sim_trans.resp = 1;
		  temp.copy(sim_trans);
                  simulated_output_queue.push_back(temp);
                  invalid_table.delete(j);
                  break;
               end // if (invalid_table[j].port_id == i)
            end // for (int j = 0; j < invalid_table.size(); j++)
         end // if (valid_resp[i] = 0)
      end // for (int i = 0; i < 4; i++)


      if (add_found == 0 || (add_found == 1 && (add_op == 12 || add_op == 13))) begin
	 prev_add_r1 = 16;
      end
      else begin
	 prev_add_r1 = add_r1;
      end

      if (shift_found == 0 || (shift_found == 1 && shift_op == 10) ) begin
	 prev_shift_r1 = 16;
      end
      else begin
	 prev_shift_r1 = shift_r1;
      end
   
   
   
   
			     
   endfunction : dispatch_logic

   virtual function void update_hold_table(int port_id, int tag_remove);
      hold_table[port_id][tag_remove][4] = 0;
      hold_table[port_id][tag_remove][5] = 0;
      for (int i = 0; i < 4; i++) begin
         hold_table[port_id][i][tag_remove] = 0;
         if (hold_table[port_id][i][0] == 0 && hold_table[port_id][i][1] == 0 && hold_table[port_id][i][2] == 0 && hold_table[port_id][i][3] == 0) begin
            hold_table[port_id][i][4] = 1;
         end // if (hold_table[A.port_id][A.tag_in][0] == 0 && hold_table[A.port_id][A.tag_in][1] == 0 && hold_table[A.port_id][A.tag_in][2] == 0 && hold_table[A.port_id][A.tag_in][3] == 0 &&)
      end // for (int i = 0; i < 4; i++)

      hold_table[port_id][tag_remove][4] = 0;
   endfunction : update_hold_table
endclass // calc_sb
