class calc_sb extends uvm_scoreboard;
   `uvm_component_utils(calc_sb)
   uvm_analysis_imp #(mon_trans,calc_sb) item_collected_export;
   

   mon_trans shift_table[$];
   mon_trans add_table[$];

   int hold_table[4][4][9];
   int registers [16][2];

   int dispatch = 1;
   int mon_trans holder;

   int toggle;

   function new(string name,uvm_component parent);
      super.new(name,parent);
   endfunction // new

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      item_collected_export = new("item_collected_export", this);
   endfunction // build_phase

   function void write(mon_trans data);
      update_everything(data);
   endfunction // write

   virtual function void update_everything(mon_trans A);
      if (A.resp != 0) begin
         // Check for dispatch and holder
         if (dispatch = 1) begin
            dispatch_logic(A);
         end // if (dispatch = 1)
      end // if (A.resp != 0)

      if (A.op != 0) begin
         hold_table[A.port_id][A.tag_in][5] = A.op;
         hold_table[A.port_id][A.tag_in][6] = A.d1;
         hold_table[A.port_id][A.tag_in][7] = A.d2;
         hold_table[A.port_id][A.tag_in][8] = A.r1;
         for (int i = 0; i < 4; i++) begin
            if (A.r1 == hold_table[A.port_id][i][8] || A.d1 == hold_table[A.port_id][i][8] || A.d2 == hold_table[A.port_id][i][8]) begin
               hold_table[A.port_id][A.tag_in][i] = hold_table[A.port_id][i][4];
            end // if (A.r1 == hold_table[A.port_id][i][8] || A.d1 == hold_table[A.port_id][i][8] || A.d2 == hold_table[A.port_id][i][8])
         end // for (int i = 0; i < 4; i++)
         hold_table[A.port_id][A.tag_in][A.tag_in] = 0;

         if (hold_table[A.port_id][A.tag_in][0] == 0 && hold_table[A.port_id][A.tag_in][1] == 0 && hold_table[A.port_id][A.tag_in][2] == 0 && hold_table[A.port_id][A.tag_in][3] == 0) begin
            hold_table[A.port_id][A.tag_in][4] = 1;
         end // if (hold_table[A.port_id][A.tag_in][0] == 0 && hold_table[A.port_id][A.tag_in][1] == 0 && hold_table[A.port_id][A.tag_in][2] == 0 && hold_table[A.port_id][A.tag_in][3] == 0 &&)
      end // if (A.op != 0)

      if (A.op == 1 || A.op == 2 || A.op == 12 || A.op == 13) begin
         add_table.push_back(A);
         // add_table_valid.push_back(hold_table[A.port_id][A.tag_in][A.tag_in]);
         // add_table_port_id.push_back(A.port_id);
         // add_table_tag.push_back(A.tag_in);
      end // if (A.op == 1 || A.op == 2)

      if (A.op == 5 || A.op == 6 || A.op == 9 || A.op == 10) begin
         shift_table.push_back(A);
         // shift_table_valid.push_back(hold_table[A.port_id][A.tag_in][A.tag_in])
         // shift_table_port_id.push_back(A.port_id);
         // shift_table_tag.push_back(A.tag_in);
      end // if (A.op == 5 || A.op == 6 || A.op == 9 || A.op == 10)

   endfunction : write_to_hold_table

   virtual function void dispatch_logic(mon_trans A);
      int add_index;
      int add_r1;
      int add_d1;
      int add_d2;
      int add_data_in;
      int add_port_id;
      int add_tag;
      int add_op;

      int shift_index;
      int shift_r1;
      int shift_d1;
      int shift_d2;
      int shift_data_in;
      int shift_port_id;
      int shift_tag;
      int shift_op;

      int add_found;
      int shift_found;

      if (toggle == 0) begin
         for (int add_queue = 0; add_queue < add_table.size(); add_queue++) begin
            if (hold_table[add_table[add_queue].port_id][add_table[add_queue].tag_in][4] == 1) begin
               add_index = add_queue;
               add_tag = add_table[add_queue].tag_in;
               add_port_id = add_table[add_queue].port_id;
               add_data_in = add_table[add_queue].data_in;
               add_op = hold_table[add_port_id][add_tag][5];
               add_d1 = hold_table[add_port_id][add_tag][6];
               add_d2 = hold_table[add_port_id][add_tag][7];
               add_r1 = hold_table[add_port_id][add_tag][8];

               // remove from queue
               add_table.delete(add_queue);

               // indicate a valid is found
               add_found = 1;

               update_hold_table(add_port_id, add_tag);
               break;
            end // if add_table_valid[add_queue] = 1
         end // for (int add_queue = 0; add_queue < add_table_valid.size(); add_queue++)

         // shift table
         for (int shift_queue = 0; shift_queue < shift_table.size(); shift_queue++) begin
            if (hold_table[shift_table[shift_queue].port_id][shift_table[shift_queue].tag_in][4] == 1) begin
               shift_tag = shift_table[shift_queue].tag_in;
               shift_port_id = shift_table[shift_queue].port_id;
               shift_data_in = shift_table[shift_queue].data_in;
               shift_op = hold_table[shift_port_id][shift_tag][5];
               shift_d1 = hold_table[shift_port_id][shift_tag][6];
               shift_d2 = hold_table[shift_port_id][shift_tag][7];
               shift_r1 = hold_table[shift_port_id][shift_tag][8];
               if (add_found == 1) begin
                  if (hold_table[shift_port_id][shift_d1] == add_r1 || hold_table[shift_port_id][shift_d2] == add_r1) begin
                     toggle = 1;
                  end // if (hold_table[shift_table[shift_queue].port_id][shift_table[shift_queue].tag_in[6] == add_r1 ||)
                  else begin
                     // remove from queue
                     shift_table.delete(shift_queue);
                     // indicate a valid is found
                     shift_found = 1;
                     update_hold_table(shift_port_id, shift_tag);
                     break;
                  end // else
               end // if (add_found == 1)

               else begin
                  if (hold_table[shift_port_id][shift_d1] == add_r1 || hold_table[shift_port_id][shift_d2] == add_r1) begin
                     toggle = toggle;
                  end // if (hold_table[shift_table[shift_queue].port_id][shift_table[shift_queue].tag_in[6] == add_r1 ||)
                  else begin
                     shift_table.delete(shift_queue);
                     // indicate a valid is found
                     shift_found = 1;
                     update_hold_table(shift_port_id, shift_tag);
                     break;
                  end // else
               end // else

            end // if (hold_table[shift_table[shift_queue].port_id][shift_table[shift_queue].tag_in][4] == 1)
         end // for (int shift_queue = 0; shift_queue < shift_table.size(); shift_queue++)
      end // if (toggle == 0)


      else begin
         for (int shift_queue = 0; shift_queue < shift_table.size(); shift_queue++) begin
            if (hold_table[shift_table[shift_queue].port_id][shift_table[shift_queue].tag_in][4] == 1) begin
               shift_index = shift_queue;
               shift_tag = shift_table[shift_queue].tag_in;
               shift_port_id = shift_table[shift_queue].port_id;
               shift_data_in = shift_table[shift_queue].data_in;
               shift_op = hold_table[shift_port_id][shift_tag][5];
               shift_d1 = hold_table[shift_port_id][shift_tag][6];
               shift_d2 = hold_table[shift_port_id][shift_tag][7];
               shift_r1 = hold_table[shift_port_id][shift_tag][8];

               // remove from queue
               shift_table.delete(shift_queue);

               // indicate a valid is found
               shift_found = 1;

               update_hold_table(shift_port_id, shift_tag);
               break;
            end // if shift_table_valid[shift_queue] = 1
         end // for (int shift_queue = 0; shift_queue < shift_table_valid.size(); shift_queue++)   

         for (int add_queue = 0; add_queue < add_table.size(); add_queue++) begin
            if (hold_table[add_table[add_queue].port_id][add_table[add_queue].tag_in][4] == 1) begin
               add_tag = add_table[add_queue].tag_in;
               add_port_id = add_table[add_queue].port_id;
               add_data_in = add_table[add_queue].data_in;
               add_op = hold_table[add_port_id][add_tag][5];
               add_d1 = hold_table[add_port_id][add_tag][6];
               add_d2 = hold_table[add_port_id][add_tag][7];
               add_r1 = hold_table[add_port_id][add_tag][8];
               if (shift_found == 1) begin
                  if (hold_table[add_port_id][add_d1] == shift_r1 || hold_table[add_port_id][add_d2] == shift_r1) begin
                     toggle = 0;
                  end // if (hold_table[add_table[add_queue].port_id][add_table[add_queue].tag_in[6] == shift_r1 ||)
                  else begin
                     // remove from queue
                     add_table.delete(add_queue);
                     // indicate a valid is found
                     add_found = 1;
                     update_hold_table(add_port_id, add_tag);
                     break;
                  end // else
               end // if (add_found == 1)

               else begin
                  if (hold_table[add_port_id][add_d1] == shift_r1 || hold_table[add_port_id][add_d2] == shift_r1) begin
                     toggle = toggle;
                  end // if (hold_table[add_table[add_queue].port_id][add_table[add_queue].tag_in[6] == shift_r1 ||)
                  else begin
                     add_table.delete(add_queue);
                     // indicate a valid is found
                     add_found = 1;
                     update_hold_table(add_port_id, add_tag);
                     break;
                  end // else
               end // else

            end // if (hold_table[add_table[add_queue].port_id][add_table[add_queue].tag_in][4] == 1)
         end // for (int add_queue = 0; add_queue < add_table.size(); add_queue++)
      end // else

      if (shift_found + add_found < 2) begin
         dispatch = 1;
      end // if (shift_found + add_found < 2)

      int fetch_cmd;
      int fetch_data;
      // Write to Registers
      // NEED TO WORK
      //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      //
      if (shift_found == 1) begin
         if (shift_op == 5) begin
            registers[shift_r1][0] = 5;
            registers[shift_r1][1] = registers[shift_d1][1] << registers[shift_d2][1];
         end // if (shift_op == 5)
         else if (shift_op == 6) begin
            registers[shift_r1][0] = 6;
            registers[shift_r1][1] = registers[shift_d1][1] >> registers[shift_d2][1];
         end // else if (shift_op == 6)
         else if (shift_op == 9) begin
            registers[shift_r1][0] = 9;
            registers[shift_r1][1] = shift_data_in; 
         end
         else if (shift_op == 10) begin
            fetch_cmd = registers[shift_r1][0];
            fetch_data = registers[shift_r1][1];
         end // else if (shift_op == 10)
      end // if (shift_found)

      if (add_found == 1) begin
         if (add_op == 1) begin
            registers[add_r1][0] = 1;
            registers[add_r1][1] = registers[add_d1][1] + registers[add_d2][1];
         end // if (add_op == 5)
         else if (add_op == 2) begin
            registers[add_r1][0] = 2;
            registers[add_r1][1] = registers[add_d1][1] - registers[add_d2][1];
         end // else if (add_op == 6)
         // else if (add_op == 12) begin
            
         // end
         // else if (add_op == 13) begin
            
         // end // else if (add_op == 13)
      end // if (add_found)

   endfunction : dispatch_logic

   virtual function void update_hold_table(int port_id, int tag_remove);
      hold_table[port_id][tag_remove][4] = 0;
      for (int i = 0; i < 4; i++) begin
         hold_table[port_id][i][tag_remove] = 0;
         if (hold_table[port_id][i][0] == 0 && hold_table[port_id][i][1] == 0 && hold_table[port_id][i][2] == 0 && hold_table[port_id][i][3] == 0) begin
            hold_table[port_id][i][4] = 1;
         end // if (hold_table[A.port_id][A.tag_in][0] == 0 && hold_table[A.port_id][A.tag_in][1] == 0 && hold_table[A.port_id][A.tag_in][2] == 0 && hold_table[A.port_id][A.tag_in][3] == 0 &&)
         end // for (int i = 0; i < 4; i++)
      end // for (int i = 0; i < 4; i++)
   endfunction : update_hold_table



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
