
   covergroup mon_trans_cg with function sample(mon_trans data);
      option.name = "mon_trans_cg";
      option.per_instance = 1;
   
      PORT_ID: coverpoint data.port_id {
	 bins _0 = {0};
	 bins _1 = {1};
	 bins _2 = {2};
	 bins _3 = {3};
      }
      OP: coverpoint data.op {
	 bins ADD = {1};
	 bins SUB = {2};
	 bins SHL = {5};
	 bins SHR = {6};		    
	 bins INVALID = {[3:4],[7:15]};	  
      }
      DATA1: coverpoint data.data1 {
	 bins LOW = {[0:31]};
	 bins MED = {[32:(`MAX-32)]};
	 bins HIGH = {[`MAX-31:`MAX]};
      }
      DATA2: coverpoint data.data2 {
	 bins LOW = {[0:31]};
	 bins MED = {[32:(`MAX-32)]};
	 bins HIGH = {[`MAX-31:`MAX]};
      }
      RESP: coverpoint data.resp {
	 bins _1 = {1}; 
	 bins _2 = {2};
	 bins _3 = {3};
      }
      RESULT: coverpoint data.result {
	 bins LOW = {[0:31]};
	 bins MED = {[32:`MAX-32]};
	 bins HIGH ={[`MAX-31:`MAX]};
      }
     TAG: coverpoint data.tag_in {
	bins _0 = {0};
	bins _1 = {1};
	bins _2 = {2};
	bins _3 = {3};
     }
     PORT_OP_RESP: cross PORT_ID,OP,RESP {
	ignore_bins invalid_op =  binsof(PORT_ID) intersect {[0:3]} &&
				    binsof(OP)      intersect {[3:4],[7:15]} &&
				    binsof(RESP)    intersect {1};     		  
     }
    PORT_TAG_RESP: cross PORT_ID, TAG, RESP{} 
    
endgroup
