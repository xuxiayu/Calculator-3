class calc_sb extends uvm_scoreboard;
   `uvm_component_utils(calc_sb)

   virtual misc_if misc_intf;
   port_config cfg;

   function void cfg_monitor(port_config cg);
      misc_intf = cg.misc_intf;
   endfunction // cfg_monitor

   uvm_analysis_imp #(mon_trans,calc_sb) item_collected_export;

   mon_trans output_queue[$];
   mon_trans simulated_output_queue[$];
   mon_trans shift_table[$];
   mon_trans add_table[$];
   mon_trans invalid_table[$];

   int unsigned hold_table[4][4][9];
   int unsigned registers [16][2];
   int dispatch = 1;
   int toggle = 0;

   function new(string name,uvm_component parent);
      super.new(name,parent);
   endfunction // new

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      item_collected_export = new("item_collected_export", this);
      cfg = port_config::type_id::create("cfg",this);

      if(!uvm_config_db #(virtual misc_if)::get(this,"","misc_if", cfg.misc_intf))
         `uvm_error(get_type_name(),"uvm_config_db::get misc_intf failed");
   endfunction // build_phase

   function void write(mon_trans data);
      update_everything(data);
   endfunction // write

   task run_phase(uvm_phase phase);
      int count = output_queue.size();
      forever begin
         @(posedge misc_intf.clock) begin
            dispatch_logic();
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
            end // for (int counter = 0; counter < output_queue.size(); counter ++)
         end

      end

   endtask // run_phase


  
   // Functions
   function compare_output(mon_trans A, mon_trans B);
      if (A.port_id == B.port_id) begin
         if (A.resp == B.resp && A.tag_out == B.tag_out && A.data_out == B.data_out) begin
            return 1;
         end 
         else begin
            `uvm__error(get_type_name(), $sformatf("Oh no"));
         end
      end
      return 0;
   endfunction : compare_output

   virtual function void update_everything(mon_trans A);
      if (A.resp != 0) begin
         output_queue.push_back(A);
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

   virtual function void dispatch_logic(mon_trans A);
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
      
      mon_trans sim_trans;

      int valid_resp[4];


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
                  if (hold_table[shift_port_id][shift_tag][shift_d1] == add_r1 || hold_table[shift_port_id][shift_tag][shift_d2] == add_r1) begin
                     toggle = 1;
                     break;
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
                  if (hold_table[add_port_id][add_tag][add_d1] == shift_r1 || hold_table[add_port_id][add_tag][add_d2] == shift_r1) begin
                     toggle = 0;
                     break;
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
         valid_resp[shift_port_id] = 1;
         if (shift_op == 5) begin
            registers[shift_r1][0] = 5;
            registers[shift_r1][1] = registers[shift_d1][1] << registers[shift_d2][1][4:0];
            sim_trans.tag_out = shift_tag;
            sim_trans.port_id = shift_port_id;
            sim_trans.resp = 1;
            sim_trans.data_out = 0;
            simulated_output_queue.push_back(sim_trans);
         end // if (shift_op == 5)
         else if (shift_op == 6) begin
            registers[shift_r1][0] = 6;
            registers[shift_r1][1] = registers[shift_d1][1] >> registers[shift_d2][1][4:0];
            sim_trans.tag_out = shift_tag;
            sim_trans.port_id = shift_port_id;
            sim_trans.resp = 1;
            sim_trans.data_out = 0;
            simulated_output_queue.push_back(sim_trans);
         end // else if (shift_op == 6)
         else if (shift_op == 9) begin
            registers[shift_r1][0] = 9;
            registers[shift_r1][1] = shift_data_in; 
            sim_trans.tag_out = shift_tag;
            sim_trans.port_id = shift_port_id;
            sim_trans.resp = 1;
            sim_trans.data_out = 0;
            simulated_output_queue.push_back(sim_trans);
         end
         else if (shift_op == 10) begin
            fetch_cmd = registers[shift_r1][0];
            sim_trans.tag_out = shift_tag;
            sim_trans.port_id = shift_port_id;
            sim_trans.resp = 1;
            sim_trans.data_out = registers[shift_r1][1];
            sim_trans.op = registers[shift_r1][0];
            simulated_output_queue.push_back(sim_trans);
         end // else if (shift_op == 10)
      end // if (shift_found)

      if (add_found == 1) begin
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
            simulated_output_queue.push_back(sim_trans);
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
            simulated_output_queue.push_back(sim_trans);
         end // else if (add_op == 6)
         // ADD BRANCHING


      end // if (add_found)

      // Invalid removal
      for (int i = 0; i < 4; i++) begin
         if (valid_resp[i] == 0) begin
            for (int j = 0; j < invalid_table.size(); j++) begin
               if (invalid_table[j].port_id == i) begin
                  sim_trans.port_id = i;
                  sim_trans.data_out = 0;
                  sim_trans.resp = 1;
                  simulated_output_queue.push_back(sim_trans);
                  invalid_table.delete(j);
                  break;
               end // if (invalid_table[j].port_id == i)
            end // for (int j = 0; j < invalid_table.size(); j++)
         end // if (valid_resp[i] = 0)
      end // for (int i = 0; i < 4; i++)



   endfunction : dispatch_logic

   virtual function void update_hold_table(int port_id, int tag_remove);
      hold_table[port_id][tag_remove][4] = 0;
      for (int i = 0; i < 4; i++) begin
         hold_table[port_id][i][tag_remove] = 0;
         if (hold_table[port_id][i][0] == 0 && hold_table[port_id][i][1] == 0 && hold_table[port_id][i][2] == 0 && hold_table[port_id][i][3] == 0) begin
            hold_table[port_id][i][4] = 1;
         end // if (hold_table[A.port_id][A.tag_in][0] == 0 && hold_table[A.port_id][A.tag_in][1] == 0 && hold_table[A.port_id][A.tag_in][2] == 0 && hold_table[A.port_id][A.tag_in][3] == 0 &&)
      end // for (int i = 0; i < 4; i++)

      hold_table[port_id][tag_remove][4] = 0;
   endfunction : update_hold_table
endclass // calc_sb
