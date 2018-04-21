// asserts reset for some period of time
// Monitors/Drivers need to wait until reset drops!   
`include "reset_driver.svp"   
`include "mon_trans.sv"   
// TODO: Need to include a scoreboard for checking - May need to include the monitor transacation
// that is used to connect the monitors to the scoreboard.

// Declares the port driver, port monitor, sequencer, and port config
`include "port_agent.sv"
`include "scoreboard.sv"
   
class top_env extends uvm_env;
   `uvm_component_utils(top_env)
     
   reset_driver rst_drv;
   
   port_agent agnts[4];
   // TODO: Instantiate the scoreboard
   calc_sb scb;
    
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction // new
   
   function void build_phase(uvm_phase phase);
      rst_drv = reset_driver::type_id::create("rst_drv", this);
      
      // Create the agents
      foreach(agnts[i]) begin
	 agnts[i] = port_agent::type_id::create($sformatf("agnt%0d", i), this);
	 // Assign the port id so that the agents can construct properly (get the correct virt i/f)
	 agnts[i].port_id = i;
      end // foreach (agnts[i])
      
      // TODO: Create the scoreboard for checking
      scb = calc_sb::type_id::create("scb", this);
   endfunction // build_phase

   // TODO:  The connect_phase needs to connect the scoreboard's item_collected_export to each 
   // of the agents monitor's item_collected_port
   function void connect_phase(uvm_phase phase);
      foreach(agnts[i]) begin
	 agnts[i].mon.item_collected_port.connect(scb.item_collected_export);
      end
   endfunction // connect_phase
   
endclass:top_env // top_env
