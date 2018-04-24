class port_config extends uvm_object;
   `uvm_object_utils(port_config)
     int port_id;
   virtual port_if port_intf;
   virtual misc_if misc_intf;

   function new(string name = "port_config");
      super.new(name);
   endfunction // new
endclass // port_config

     