`include "port_config.sv"
`include "reset_driver.sv"
`include "mon_trans.sv"
`include "port_agent.sv"
`include "scoreboard.sv"

class top_env extends uvm_env;
   `uvm_component_utils(top_env)
     reset_driver rst_drv;
   port_agent agnts[4];
   port_config cfg;
   virtual misc_if misc_intf;
   calc_sb scb;
   
   function new(string name,uvm_component parent);
      super.new(name,parent);
   endfunction // new
   
   function void build_phase(uvm_phase phase);
      rst_drv = reset_driver::type_id::create("rst_drv",this);
      cfg = port_config::type_id::create("cfg",this);
      if(!uvm_config_db #(virtual misc_if)::get(this,"","misc_if", cfg.misc_intf))
	`uvm_error(get_type_name(),"uvm_config_db::get misc_intf failed");
      foreach(agnts[i]) begin
	 agnts[i] = port_agent::type_id::create($sformatf("agnt%0d",i),this);
	 agnts[i].port_id = i;
	 agnts[i].cfg=(cfg);	 
      end
      scb = calc_sb::type_id::create("scb",this);
      scb.cfg_scb(cfg);
   endfunction // build_phase

   function void connect_phase(uvm_phase phase);
      foreach(agnts[i])begin
	 agnts[i].mon.item_collected_port.connect(scb.item_collected_export);
      end
   endfunction // connect_phase

endclass // top_env
