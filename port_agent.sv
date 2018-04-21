// This is an agent that encapsulates a sequencer, driver, and monitor
`include "port_config.svp"
`include "drvr_trans.svp"
`include "port_driver.svp"
`include "port_monitor.sv"


// TODO: Need to include the monitor class

class port_agent extends uvm_agent;
   `uvm_component_utils(port_agent)

   int     port_id;
   virtual port_if port_intf;
   virtual misc_if misc_intf;   

   port_config     cfg;   
   drvr_sequencer seqcr;   
   port_driver     drvr;

   // TODO: This agent needs a monitor, regardless of being active!
   // ...
   port_monitor mon;
   
   function new(string name="port_agent", uvm_component parent=null);
      super.new(name, parent);
   endfunction // new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
      // get the port config db for this object..
      cfg = port_config::type_id::create("cfg", this);      
      cfg.port_id = port_id;
      cfg.bug_fix = 1;
      cfg.drive_x=1;
   
      if (! uvm_config_db #(virtual misc_if)::get(this, "", "misc_if", cfg.misc_intf) )
	`uvm_error(get_type_name(), "uvm_config_db::get misc_intf failed");
      if (! uvm_config_db #(virtual port_if)::get(this, "", $sformatf("p%0d", port_id), cfg.port_intf) )
	`uvm_error(get_type_name(), "uvm_config_db::get port_intf failed");      
      
      if (get_is_active())  begin
	 seqcr = drvr_sequencer::type_id::create("seqcr", this);	 
	 drvr = port_driver::type_id::create("drvr", this);
	 // Setup the drvr based on the config object
	 // Assign the virtual i/f's, assigns port id, min/max delays for driver, etc
	 drvr.cfg_driver(cfg);
      end
      
      // TODO: Regardless if agent is active or passive... create the monitor
      // ....
      mon = port_monitor::type_id::create("mon",this);
      mon.cfg_monitor(cfg);
      
   endfunction // build_phase
   
   function void connect_phase(uvm_phase phase);
      if (get_is_active()) begin
	// Connect the driver to the sequencer
	drvr.seq_item_port.connect(seqcr.seq_item_export);
      end
   endfunction // connect_phase
   
   
   
endclass // port_agent

