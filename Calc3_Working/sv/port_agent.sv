
`include "drvr_trans.sv"
`include "port_driver.sv"
`include "port_monitor.sv"


class port_agent extends uvm_agent;
   `uvm_component_utils(port_agent)

     int port_id;
   virtual port_if port_intf;
   virtual misc_if misc_intf;

   port_config cfg;
   drvr_sequencer seqcr;
   port_driver drvr;

   port_monitor mon;

   function new(string name ="port_agent",uvm_component parent=null);
      super.new(name,parent);
   endfunction // new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      cfg.port_id = port_id;

 
      if(!uvm_config_db #(virtual port_if)::get(this,"",$sformatf("p%0d",port_id),cfg.port_intf))
	`uvm_error(get_type_name(),"uvm_config_db::get port_inf failed");

      if(get_is_active())begin
	 seqcr = drvr_sequencer::type_id::create("seqcr",this);
	 drvr  = port_driver::type_id::create("drvr",this);
	 drvr.cfg_driver(cfg);
      end
      mon = port_monitor::type_id::create("mon",this);
      mon.cfg_monitor(cfg);

   endfunction // build_phase

   function void connect_phase(uvm_phase phase);
      if(get_is_active()) begin
	 drvr.seq_item_port.connect(seqcr.seq_item_export);
      end
   endfunction // connect_phase

endclass // port_agent
