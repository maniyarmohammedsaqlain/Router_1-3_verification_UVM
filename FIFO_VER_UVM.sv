`include "uvm_macros.svh";
import uvm_pkg::*;

class transaction extends uvm_sequence_item;

`uvm_object_utils(transaction);
randc logic [7:0]data_in;

logic [1:0]op;
logic lfd_state;
logic read_enb;
logic write_enb;
logic soft_reset;
logic resetn;
logic [7:0]data_out;
logic full;
logic empty;

function new(string path="trans");
super.new(path);
endfunction
endclass

//RESET OPERATION=0
class rst_seq extends uvm_sequence #(transaction);
`uvm_object_utils(rst_seq);
transaction trans;
function new(string path="rst_seq");
super.new(path);
endfunction
virtual task body();
repeat(5)
begin

trans=transaction::type_id::create("trans");
start_item(trans);
assert(trans.randomize);
trans.op=0;
`uvm_info("RST","MODE: RESET",UVM_NONE);
finish_item(trans);
end
endtask
endclass



//SOFT RESET OPERATION=1
class soft_rst_seq extends uvm_sequence #(transaction);
`uvm_object_utils(soft_rst_seq);
transaction trans;
function new(string path="soft_rst_seq");
super.new(path);
endfunction
virtual task body();
repeat(5)
begin

trans=transaction::type_id::create("trans");
start_item(trans);
assert(trans.randomize);
trans.op=1;
`uvm_info("SOFT_RST","MODE: SOFT_RESET",UVM_NONE);
finish_item(trans);
end
endtask
endclass


//WRITE DATA OPERATION=2
class wr_data extends uvm_sequence #(transaction);
`uvm_object_utils(wr_data);
transaction trans;
function new(string path="wr_data");
super.new(path);
endfunction
virtual task body();
repeat(5)
begin

trans=transaction::type_id::create("trans");
start_item(trans);
assert(trans.randomize);
trans.op=2;
`uvm_info("wr_data",$sformatf("MODE: WRITE DATAIN=%d",trans.data_in),UVM_NONE);
finish_item(trans);
end
endtask
endclass

//WRITE DATA OPERATION=3
class rd_data extends uvm_sequence #(transaction);
`uvm_object_utils(rd_data);
transaction trans;
function new(string path="rd_data");
super.new(path);
endfunction
virtual task body();
repeat(5)
begin

trans=transaction::type_id::create("trans");
start_item(trans);
assert(trans.randomize);
trans.op=3;
`uvm_info("rd_data",$sformatf("MODE: WRITE DATAOUT=%d",trans.data_out),UVM_NONE);
finish_item(trans);
end
endtask
endclass

class driver extends uvm_driver #(transaction);
`uvm_component_utils(driver);
transaction trans;
virtual inf_fifo inf;
function new(string path="drv",uvm_component parent=null);
super.new(path,parent);
endfunction

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
trans=transaction::type_id::create("trans");

if(!uvm_config_db #(virtual inf_fifo)::get(this,"","inf",inf))
`uvm_info("DRV","ERROR IN CONFIG DB OF DRV",UVM_NONE);
endfunction

task reset_dut();
begin
`uvm_info("DRV","DUT RESET",UVM_NONE);
inf.resetn<=0;
inf.data_in<=0;
inf.read_enb<=0;
inf.write_enb<=0;
inf.soft_reset<=0;
@(posedge inf.clock);
end
endtask

task soft_reset_dut();
begin
`uvm_info("DRV","SOFT DUT RESET",UVM_NONE);
inf.resetn<=0;
inf.data_in<=0;
inf.read_enb<=0;
inf.write_enb<=0;
inf.soft_reset<=1;
@(posedge inf.clock);
end
endtask

task write_dut();
begin
`uvm_info("DRV","DUT WRITE",UVM_NONE);
inf.lfd_state<=1;
inf.resetn<=1;
inf.read_enb<=0;
inf.write_enb<=1;
inf.soft_reset<=0;
inf.data_in<=trans.data_in;
@(posedge inf.clock);
end
endtask

task read_dut();
begin
//   #10;
  `uvm_info("DRV","DUT READ",UVM_NONE);
inf.lfd_state<=0;
inf.resetn<=1;
// inf.data_in<=trans.data_in;
inf.read_enb<=1;
inf.write_enb<=0;
inf.soft_reset<=0;
@(posedge inf.clock);
inf.read_enb<=0;
// inf.data_out<=trans.data_out;
end
endtask

virtual task run_phase(uvm_phase phase);
forever
begin
seq_item_port.get_next_item(trans);
if(trans.op==0)
begin
reset_dut();
end
else if(trans.op==1)
begin
soft_reset_dut();
end
else if(trans.op==2)
begin
write_dut();
end
else if(trans.op==3)
begin
read_dut();
end
seq_item_port.item_done(trans);
end
endtask
endclass

class monitor extends uvm_monitor;
`uvm_component_utils(monitor);

transaction trans;
virtual inf_fifo inf;
uvm_analysis_port #(transaction)send;

function new(string path="mon",uvm_component parent=null);
super.new(path,parent);
endfunction

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
trans=transaction::type_id::create("trans");
send=new("send",this);

if(!uvm_config_db #(virtual inf_fifo)::get(this,"","inf",inf))
`uvm_info("MON","ERROR IN CONFIG OF MON",UVM_NONE);
endfunction


virtual task run_phase(uvm_phase phase);
super.run_phase(phase);
forever
begin
@(posedge inf.clock);
if(~inf.resetn)
begin
trans.op=0;
`uvm_info("MON","RESET DETECTED",UVM_NONE);
send.write(trans);
end
else if(inf.soft_reset)
begin
trans.op=1;
`uvm_info("MON","SOFT RESET DETECTED",UVM_NONE);
end

else

begin
if(inf.write_enb)
begin
trans.op=2;
trans.data_in=inf.data_in;
trans.write_enb=1;
trans.full=inf.full;
trans.empty=inf.empty;
`uvm_info("MON",$sformatf("DATA WRITE DIN:%0d",trans.data_in),UVM_NONE);
send.write(trans);
end

else if(inf.read_enb)
begin
trans.op=3;

trans.read_enb=1;
trans.full=inf.full;
trans.empty=inf.empty;
//   @(posedge inf.clock);
  #10;
trans.data_out=inf.data_out;
  
`uvm_info("MON",$sformatf("DATA READ DOUT:%0d",trans.data_out),UVM_NONE);
send.write(trans);
end
end
end
endtask
endclass

class sco extends uvm_scoreboard;
`uvm_component_utils(sco);

transaction trans;
uvm_analysis_imp#(transaction,sco)recv;

bit[7:0]mem[$];
bit[7:0] data_rd;

function new(string path="sco",uvm_component parent=null);
super.new(path,parent);
endfunction

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
recv=new("recv",this);
trans=transaction::type_id::create("trans",this);
endfunction

virtual function void write(transaction tr);
trans=tr;
if(trans.op==0)
begin
`uvm_info("SCO","RESET DETECTED",UVM_NONE);
`uvm_info("SCO","------------------------------------------------------",UVM_NONE);
end

else if(trans.op==1)
begin
`uvm_info("SCO","SOFT RESET DETECTED",UVM_NONE);
`uvm_info("SCO","------------------------------------------------------",UVM_NONE);
end

else if(trans.op==2)
begin
  if(trans.full==0)

begin
mem.push_front(trans.data_in);
`uvm_info("SCB",$sformatf("DATA STORED IN FIFO"),UVM_NONE);
end

else

begin
`uvm_info("SCB",$sformatf("FIFO IS FULL"),UVM_NONE);
end

`uvm_info("FINISH","---------------------------------------",UVM_NONE);
end

else if(trans.op==3)

begin
  if(trans.empty==0)
begin
data_rd=mem.pop_back();
if(trans.data_out==data_rd)

begin
`uvm_info("SCB","DATA MATCHED",UVM_NONE);
end

else
begin
`uvm_info("SCB","DATA MISMATCHED",UVM_NONE);
end

end
else
`uvm_info("STATUS","FIFO IS EMPTY",UVM_NONE);
`uvm_info("FINISH","-------------------------------------------",UVM_NONE);
end
endfunction
endclass

class agent extends uvm_agent;
`uvm_component_utils(agent);

driver drv;
monitor mon;
uvm_sequencer#(transaction)seqr;

function new(string path="agent",uvm_component parent=null);
super.new(path,parent);
endfunction

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);

drv=driver::type_id::create("drv",this);
mon=monitor::type_id::create("mon",this);
seqr=uvm_sequencer#(transaction)::type_id::create("seqr",this);
endfunction

virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
drv.seq_item_port.connect(seqr.seq_item_export);
endfunction

endclass

class env extends uvm_env;
`uvm_component_utils(env);

agent a;
sco scb;
function new(string path="env",uvm_component parent=null);
super.new(path,parent);
endfunction

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
a=agent::type_id::create("a",this);
scb=sco::type_id::create("scb",this);
endfunction

virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
a.mon.send.connect(scb.recv);
endfunction
endclass

class test extends uvm_test;
`uvm_component_utils(test);
env e;
rst_seq rseq;
soft_rst_seq srseq;
wr_data wrdseq;
rd_data rddseq;

function new(string path="test",uvm_component parent=null);
super.new(path,parent);
endfunction

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
e=env::type_id::create("e",this);
rseq=rst_seq::type_id::create("rseq",this);
srseq=soft_rst_seq::type_id::create("srseq",this);
wrdseq=wr_data::type_id::create("wrdseq",this);
rddseq=rd_data::type_id::create("rddseq",this);
endfunction

virtual task run_phase(uvm_phase phase);
phase.raise_objection(this);
rseq.start(e.a.seqr);
srseq.start(e.a.seqr);
wrdseq.start(e.a.seqr);
rddseq.start(e.a.seqr);
phase.drop_objection(this);
endtask
endclass

module tb;
inf_fifo inf();
fifo DUT(inf.clock,inf.resetn,inf.data_in,inf.read_enb,inf.write_enb,inf.data_out,
inf.full,inf.empty,inf.lfd_state,inf.soft_reset);

initial
begin
inf.clock=0;
end

always
#10 inf.clock=~inf.clock;



initial
begin
uvm_config_db #(virtual inf_fifo)::set(null,"*","inf",inf);
run_test("test");
end
endmodule
