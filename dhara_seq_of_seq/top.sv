`include "uvm.sv"
`include "duv_if.sv"
`include "top_pkg.sv"

module top;
   parameter simulation_cycle = 10;

   import uvm_pkg::*;
   import top_pkg::*;

   misc_if m_if();

   port_if p0_if();
   port_if p1_if();
   port_if p2_if();
   port_if p3_if();

   calc3_top duv(.reset(m_if.reset),
		 .clk(m_if.clock),
		 
		 .req0_tag_in(p0_if.tag_in),
		 .req0_cmd_in(p0_if.op),
		 .req0_d1(p0_if.d1),
		 .req0_d2(p0_if.d2),
		 .req0_r1(p0_if.r1),
		 .req0_data_in(p0_if.data_in),
		 .out_resp0(p0_if.resp),
		 .out_data0(p0_if.data_out),
		 .out_tag0(p0_if.tag_out),

		 .req1_tag_in(p1_if.tag_in),
		 .req1_cmd_in(p1_if.op),
		 .req1_d1(p1_if.d1),
		 .req1_d2(p1_if.d2),
		 .req1_r1(p1_if.r1),
		 .req1_data_in(p1_if.data_in),
		 .out_resp1(p1_if.resp),
		 .out_data1(p1_if.data_out),
		 .out_tag1(p1_if.tag_out),

		 .req2_tag_in(p2_if.tag_in),
		 .req2_cmd_in(p2_if.op),
		 .req2_d1(p2_if.d1),
		 .req2_d2(p2_if.d2),
		 .req2_r1(p2_if.r1),
		 .req2_data_in(p2_if.data_in),
		 .out_resp2(p2_if.resp),
		 .out_data2(p2_if.data_out),
		 .out_tag2(p2_if.tag_out),

		 .req3_tag_in(p3_if.tag_in),
		 .req3_cmd_in(p3_if.op),
		 .req3_d1(p3_if.d1),
		 .req3_d2(p3_if.d2),
		 .req3_r1(p3_if.r1),
		 .req3_data_in(p3_if.data_in),
		 .out_resp3(p3_if.resp),
		 .out_data3(p3_if.data_out),
		 .out_tag3(p3_if.tag_out)
		 );
   initial
     begin
	m_if.clock = 0;

	forever
	  begin
	     #(simulation_cycle/2)
	     m_if.clock = ~m_if.clock;

	  end
     end // initial begin

   initial
     begin
	uvm_config_db #(virtual misc_if)::set(null,"*","misc_if",m_if);
	uvm_config_db #(virtual misc_if)::set(null,"*","p0",p0_if);
	uvm_config_db #(virtual misc_if)::set(null,"*","p1",p1_if);
	uvm_config_db #(virtual misc_if)::set(null,"*","p2",p2_if);
	uvm_config_db #(virtual misc_if)::set(null,"*","p3",p3_if);

	uvm_top.finish_on_competion = 1;

	set_global_timeout(10000ns);

	run_test();

     end // initial begin
endmodule // top

	
			