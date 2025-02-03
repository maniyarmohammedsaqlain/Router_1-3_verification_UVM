module router(clock,resetn,data_in,read_enb_0,read_enb_1,read_enb_2,pkt_valid,data_out_0,data_out_1,data_out_2,vld_out_0,vld_out_1,vld_out_2,err,busy);

input clock,resetn,pkt_valid,read_enb_0,read_enb_1,read_enb_2;
input [7:0]data_in;

output vld_out_0,vld_out_1,vld_out_2,err,busy;
output [7:0] data_out_0,data_out_1,data_out_2;

wire [2:0] write_enb;
wire 	   full_0,empty_0,lfd_state,soft_reset_0;
wire 	   full_1,empty_1,soft_reset_1;
wire 	   full_2,empty_2,soft_reset_2;
wire [7:0] dout;

fifo f1(clock,resetn,dout,read_enb_0,write_enb[0],data_out_0,full_0,empty_0,lfd_state,soft_reset_0);
fifo f2(clock,resetn,dout,read_enb_1,write_enb[1],data_out_1,full_1,empty_1,lfd_state,soft_reset_1);
fifo f3(clock,resetn,dout,read_enb_2,write_enb[2],data_out_2,full_2,empty_2,lfd_state,soft_reset_2);

sync s1(clock,resetn,data_in[1:0],detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,vld_out_0,vld_out_1,vld_out_2,fifo_full,soft_reset_0,soft_reset_1,soft_reset_2,write_enb);

fsm fsm1(clock,resetn,pkt_valid,data_in[1:0],fifo_full,empty_0,empty_1,empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_pkt_valid,write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);

register r1(clock,resetn,pkt_valid,data_in,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,err,parity_done,low_pkt_valid,dout);

endmodule


module fifo(clock,resetn,data_in,read_enb,write_enb,data_out,full,empty,lfd_state,soft_reset);
                          
parameter width=9,depth=16;
input lfd_state;
input [width-2:0] data_in;
input clock,resetn,read_enb,write_enb,soft_reset;
reg [4:0]rd_pointer,wr_pointer;
output reg [width-2:0] data_out;
reg [6:0]count;

output full,empty;
integer i;

reg [width-1:0] mem[depth-1:0];
reg temp;

assign full=((wr_pointer[4] != rd_pointer[4]) && (wr_pointer[3:0]==rd_pointer[3:0]));
assign empty= wr_pointer==rd_pointer;

always@(posedge clock)
begin
  if(~resetn)
    temp=0;
  else 
    temp=lfd_state;
end

//write
always@(posedge clock)
begin 
  if(~resetn)
    begin 
      //data_out<=0;
      for(i=0;i<=15;i=i+1)
         mem[i]<=0;
    end
  else if(soft_reset)
    begin
      // data_out=0;
       for(i=0;i<=15;i=i+1)
        mem[i]<=0;
    end
  else if(write_enb && !full)
    begin
      if(lfd_state)
        {mem[wr_pointer[3:0]][8],mem[wr_pointer[3:0]][7:0]}<={temp,data_in};
    else
        {mem[wr_pointer[3:0]][8],mem[wr_pointer[3:0]][7:0]}<={temp,data_in};
     end
end

//read
always@(posedge clock)
begin 
     if(~resetn)
       begin 
         data_out <= 0;
        /* for(i=0;i<=15;i=i+1)
            mem[i]<=0;*/
       end
else if(soft_reset)
      begin
	      data_out <= 'bz;
      end
else if(read_enb && !empty)
      begin
         data_out <= mem[rd_pointer[3:0]][7:0];
      end
      else if(count==0 && data_out != 0)
      data_out <= 8'bzzzzzzzz;
end
         
//counter
always@(posedge clock)
begin
//if(~resetn)
//count<=0;
//else if(soft_reset)
//count<=0;
 if(read_enb && !empty)
     begin
      if(mem[rd_pointer[3:0]][8])
         begin
          count <= mem[rd_pointer[3:0]][7:2] +1;
          end
     else
       if(count!=0)
         begin
         count <= count-1;
         end
    end  
end
     
always@(posedge clock)
begin
  if(~resetn || soft_reset)
	begin
      rd_pointer <= 0;
      wr_pointer <= 0;
	end
	else
	begin
      if(write_enb && !full)
          wr_pointer <= wr_pointer+1;
      if(read_enb && !empty)
          rd_pointer <= rd_pointer+1;
	end
end

endmodule
module register(clock,resetn,pkt_valid,data_in,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,err,parity_done,low_packet_valid,dout);

input [7:0]data_in;
input clock,resetn,pkt_valid,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg;

output reg[7:0]dout;
output reg err,parity_done,low_packet_valid;

reg [7:0] full_state_byte,internal_parity,header,packet_parity;

//dout
always@(posedge clock)
begin
  if(!resetn)
  dout<=0;
  else
  begin
   if(~(detect_add))
         begin
           if(~(lfd_state))
             begin
               if(~(ld_state && ~fifo_full))
                  begin
                     if(~(ld_state && fifo_full))
                        begin 
                          if(~(laf_state))
                            dout<=dout;
                          else
                            dout<=full_state_byte;
                        end
                       else
                         dout<=dout;
                   end
                 else
                   dout<=data_in;
             end
           else
              dout<=header;
         end
       else
          dout<=dout; 
  end
end

//fifo_full_byte
always@(posedge clock)
begin
  if(!resetn)
    full_state_byte<=0;
  else 
  begin
     if(ld_state && fifo_full)
          full_state_byte<=data_in;
      else
         full_state_byte<=full_state_byte;
  end
end

//Header
always@(posedge clock)
begin
  if(!resetn)
    header<=0;
  else 
  begin
    if(detect_add && pkt_valid && (data_in[1:0]!=3))
        header<=data_in;
    else
        header<=header;
  end
end

//parity
always@(posedge clock)
begin
  if(!resetn)
     internal_parity<=0;
  else 
  begin
  if(detect_add)
      internal_parity<=0;
  else if(lfd_state)
      internal_parity<= internal_parity ^ header ;
  else
    if(ld_state && pkt_valid && ~full_state)
        internal_parity<= internal_parity ^data_in;
  //else 
  //      internal_parity<=internal_parity;
  end
end

//low_packet_valid
always@(posedge clock)
begin
  if(!resetn)
    low_packet_valid<=0;
  else 
  begin
    if(rst_int_reg)
        low_packet_valid<=1'b0;
    else if(ld_state && ~(pkt_valid))
        low_packet_valid<=1'b1;
    else 
        low_packet_valid <= low_packet_valid;
  end
end


//paritydone
always@(posedge clock)
begin
  if(!resetn)
    parity_done<=0;
  else
  begin
    if(detect_add)
    parity_done <= 0;
    else if( (ld_state && ~(pkt_valid) && ~fifo_full) || (laf_state && (low_packet_valid) && ~parity_done))
          parity_done<=1'b1;
    else
          parity_done<=parity_done;
  end
end

//packet parity
always@(posedge clock)
begin
  if(!resetn)
    packet_parity<=0;
  else if(ld_state && ~pkt_valid)
    packet_parity<=data_in;
  else
    packet_parity<=packet_parity;
end

//error          
always@(posedge clock)
begin
  if(~resetn)
    err <= 0;
  else
    begin  
      if(parity_done)
      begin
        if(internal_parity==packet_parity)
         err<=1'b0;
        else
          err<=1'b1;         
      end
      else
        err<=1'b0;
    end
end


endmodule
module fsm(clock,resetn,pkt_valid,data_in,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid,write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);

input [1:0]data_in;

input clock,resetn,pkt_valid,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid;

output write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy;

parameter DECODE_ADDRESS= 3'b000,
          LOAD_FIRST_DATA= 3'b001,
          WAIT_TILL_EMPTY=3'b010,
          LOAD_DATA=3'b011,
          LOAD_PARITY=3'b100,
          FIFO_FULL_STATE=3'b101,
          LOAD_AFTER_FULL=3'b110,
          CHECK_PARITY_ERROR=3'b111;

reg[2:0] next_state,present_state; 

always@(posedge clock)
begin
  if(~resetn)
    present_state<= DECODE_ADDRESS;
 else if(soft_reset_0 || soft_reset_1 || soft_reset_2)
    present_state<=DECODE_ADDRESS;
  else
     present_state<= next_state;
end
 
always@(*)
begin
  next_state=present_state;
  case(present_state)
  DECODE_ADDRESS: begin
                 if((pkt_valid && (data_in[1:0]==2'd0) && fifo_empty_0) || 
                   (pkt_valid && (data_in[1:0]==2'd1) && fifo_empty_1) ||
                   (pkt_valid && (data_in[1:0]==2'd2) && fifo_empty_2))
                 next_state= LOAD_FIRST_DATA;
                 if((pkt_valid && (data_in[1:0]==2'd0) && ~fifo_empty_0) || 
                   (pkt_valid && (data_in[1:0]==2'd1) && ~fifo_empty_1) ||
                   (pkt_valid && (data_in[1:0]==2'd2) && ~fifo_empty_2))
                  next_state=WAIT_TILL_EMPTY;
                end

  LOAD_FIRST_DATA: next_state= LOAD_DATA;
 
  WAIT_TILL_EMPTY: begin
                 if(fifo_empty_0 || fifo_empty_1 || fifo_empty_2)
                   next_state=LOAD_FIRST_DATA;
                 if(~(fifo_empty_0) || ~(fifo_empty_1) || ~(fifo_empty_2))
                   next_state= WAIT_TILL_EMPTY;
                  end
  LOAD_DATA:  begin
            if(fifo_full==1'b1)
              next_state=FIFO_FULL_STATE;
            if(fifo_full==1'b0 && pkt_valid==1'b0)
              next_state=LOAD_PARITY;  
            end
  LOAD_PARITY: next_state= CHECK_PARITY_ERROR;

  FIFO_FULL_STATE:begin
                 if(fifo_full==1'b0)
                    next_state=LOAD_AFTER_FULL;
                 if(fifo_full==1'b1)
                    next_state=FIFO_FULL_STATE;
                  end
  LOAD_AFTER_FULL:begin 
                if(parity_done==1'b0 && low_packet_valid==1'b1)
                   next_state=LOAD_PARITY;
                 if(parity_done==1'b0 && low_packet_valid==1'b0)
                   next_state=LOAD_DATA;
                 if(parity_done)
                   next_state=DECODE_ADDRESS;
                 end
  CHECK_PARITY_ERROR: begin
                     if(!fifo_full)
                      next_state= DECODE_ADDRESS;
                    if(fifo_full)
                      next_state= FIFO_FULL_STATE; 
                     end
  endcase
end

assign detect_add= (present_state==DECODE_ADDRESS); 

assign lfd_state=(present_state==LOAD_FIRST_DATA);

assign busy= ((present_state==LOAD_FIRST_DATA)||(present_state==LOAD_PARITY)||(present_state==FIFO_FULL_STATE)||(present_state==LOAD_AFTER_FULL)||(present_state==WAIT_TILL_EMPTY)||(present_state==CHECK_PARITY_ERROR));

assign ld_state= (present_state==LOAD_DATA);

assign write_enb_reg= ((present_state==LOAD_DATA)||(present_state==LOAD_PARITY)||(present_state==LOAD_AFTER_FULL));

assign full_state=(present_state==FIFO_FULL_STATE);

assign laf_state=(present_state==LOAD_AFTER_FULL);

assign rst_int_reg=(present_state==CHECK_PARITY_ERROR);

endmodule

module sync(clock,resetn,data_in,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,vld_out_0,vld_out_1,vld_out_2,fifo_full,soft_reset_0,soft_reset_1,soft_reset_2,write_enb);

input clock,resetn,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg,read_enb_0,read_enb_1,read_enb_2;

output vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2;
output reg[2:0] write_enb;
output reg fifo_full;

reg [1:0]temp;
reg [5:0]count0,count1,count2;
input [1:0]data_in;
reg soft_reset_0;
reg soft_reset_1;
reg soft_reset_2;


always@(temp or full_0 or full_1 or full_2)
begin
  case(temp)
    2'b00: fifo_full=full_0;
    2'b01: fifo_full=full_1;
    2'b10: fifo_full=full_2;
    default: fifo_full=0;
  endcase
end

always@(posedge clock)
begin
  if(!resetn)
   temp<=0;
  else if(detect_add)
    temp<=data_in;
  else 
    temp<=temp;
end

always@(temp or write_enb or write_enb_reg)
begin
  if(write_enb_reg)
    begin
      case(temp)
        2'b00: write_enb=3'b001;
        2'b01: write_enb=3'b010;
        2'b10: write_enb=3'b100;
      default: write_enb=3'b000;
      endcase
    end
	 else write_enb=0;
end

assign vld_out_0=~empty_0;
assign vld_out_1=~empty_1;
assign vld_out_2=~empty_2;

always@(posedge clock)
begin
  if(!resetn)
    begin
      count0<=0;
      soft_reset_0<=0;
    end
  else if(!read_enb_0 && vld_out_0)
    begin
      if(count0<29)
         count0<=count0+1;
      if(count0>=29)
         soft_reset_0<=1'b1;
      if(read_enb_0)
         count0<=0;
    end
end 


always@(posedge clock)
begin
  if(!resetn)
    begin
      count1<=0;
      soft_reset_1<=0;
     end
  else if(!read_enb_1 && vld_out_1)
    begin
      if(count1<29)
         count1<=count1+1;
      if(count1>=29)
         soft_reset_1<=1'b1;
      if(read_enb_1)
         count1<=0;
    end
end 

always@(posedge clock)
begin
  if(!resetn)
    begin
      count2<=0;
      soft_reset_2<=0;
     end
  else if(!read_enb_2 && vld_out_2)
    begin
      if(count2<29)
         count2<=count2+1;
      if(count2>=29)
         soft_reset_2<=1'b1;
      if(read_enb_2)
         count2<=0;
    end
end 
endmodule
