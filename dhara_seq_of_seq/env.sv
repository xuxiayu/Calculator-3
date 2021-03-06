`include "reset_driver.sv"
`include "mon_trans.sv"
`include "port_agent.sv"
`include "scoreboard.sv"

class top_env extends uvm_env;
   `uvm_component_utlis(top_env)
     reset_driver rst_drv;
   port_agent agnts[4];

   calc_sb scb;

   function new(string name,uvm_component parent);
      super.new(name,parent);
   endfunction // new

   function void build_phase(uvm_phase phase);
      rst_drv = reset_driver::type_id::create("rst_drv",this);
      foreach(agnts[i]) begin
	 agnts[i] = port_agent::type_id::create($sformatf("agnt%0d",i),this);
	 agnts[i].port_id = i;
      end
      scb = calc_sb::type_id::create("scb",this);
   endfunction // build_phase

   function void connect_phase(uvm_phase phase);
      foreach(agnts[i])begin
	 agnts[i].mon.item_collected_port.connect(scb.item_collected_export);
      end
   endfunction // connect_phase

endclass // top_env
