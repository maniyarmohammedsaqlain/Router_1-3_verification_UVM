`include "uvm_macros.svh";
import uvm_pkg::*;

class transaction extends uvm_sequence_item;
`uvm_object_utils(transaction);
logic [1:0]seq_num;
randc logic[1:0]data_in;
logic resetn;
logic detect_add;
logic full_0;
logic full_1;
logic full_2;
logic empty_0;
logic empty_1;
logic empty_2;
logic write_enb_reg;
logic read_enb_0;
logic read_enb_1;
logic read_enb_2;
logic vld_out_0;
logic vld_out_1;
logic vld_out_2;
logic soft_reset_0;
logic soft_reset_1;
logic soft_reset_2;
logic [2:0]write_enb;
logic fifo_full;
constraint data{data_in<3;}

function new(string path="trans");
super.new(path);
endfunction

endclass

class reset_dut extends uvm_sequence#(transaction);
`uvm_object_utils(reset_dut);
transaction trans;
function new(string path="reset_dut");
super.new(path);
endfunction

virtual task body();
  repeat(100)
begin
trans=transaction::type_id::create("trans");
start_item(trans);

assert(trans.randomize());
trans.seq_num=0;
`uvm_info("RESET","RESET DUT",UVM_NONE);
finish_item(trans);
end
endtask
endclass

class seq2 extends uvm_sequence#(transaction);
`uvm_object_utils(seq2);
transaction trans;
function new(string path="seq2");
super.new(path);
endfunction

virtual task body();
  repeat(100)
begin
trans=transaction::type_id::create("trans");
start_item(trans);
assert(trans.randomize());
trans.seq_num=1;
`uvm_info("SEQ_2","SEQ_2 to DUT",UVM_NONE);
finish_item(trans);
end
endtask
endclass

class seq3 extends uvm_sequence#(transaction);
`uvm_object_utils(seq3);
transaction trans;
function new(string path="seq3");
super.new(path);
endfunction

virtual task body();
  repeat(100)
begin
trans=transaction::type_id::create("trans");
start_item(trans);
assert(trans.randomize());
trans.seq_num=2;
`uvm_info("SEQ_3","SEQ_3 to DUT",UVM_NONE);
finish_item(trans);
end
endtask
endclass

class seq4 extends uvm_sequence#(transaction);
`uvm_object_utils(seq4);
transaction trans;
function new(string path="seq4");
super.new(path);
endfunction

virtual task body();
  repeat(100)
begin
trans=transaction::type_id::create("trans");
start_item(trans);
assert(trans.randomize());
trans.seq_num=3;
`uvm_info("SEQ_4","SEQ_4 to DUT",UVM_NONE);
finish_item(trans);
end
endtask
endclass

class driver extends uvm_driver#(transaction);
`uvm_component_utils(driver);

transaction trans;
virtual seq_int inf;

function new(string path="drv",uvm_component parent=null);
super.new(path,parent);
endfunction

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
trans=transaction::type_id::create("trans");

if(!uvm_config_db #(virtual seq_int)::get(this,"","inf",inf))
`uvm_info("DRV","CONFIG ERROR",UVM_NONE);
endfunction

task reset_dut();
begin
`uvm_info("DRV","RESET DUT",UVM_NONE);
inf.resetn=0;
inf.detect_add=0;
inf.full_0=0;
inf.full_1=0;
inf.full_2=0;
inf.empty_0=0;
inf.empty_1=0;
inf.empty_2=0;
inf.write_enb_reg=0;
inf.read_enb_0=0;
inf.read_enb_1=0;
inf.read_enb_2=0;
inf.data_in=0;
  `uvm_info("DRV_RST",$sformatf("DATA_IN=%d RST=%d,detect_add=%d,full_0=%d,full_1=%d,full_2=%d,empty_0=%d,empty_1=%d,empty_2=%d,write_enb_reg=%d,read_enb_0=%d,read_enb_1=%d,read_enb_2=%d",inf.data_in,inf.resetn,inf.detect_add,inf.full_0,inf.full_1,inf.full_2,inf.empty_0,inf.empty_1,inf.empty_2,
inf.write_enb_reg,inf.read_enb_0,inf.read_enb_1,inf.read_enb_2),UVM_NONE);
@(posedge inf.clock);
end
endtask

task seq2_dut();
begin
`uvm_info("DRV","SEQ2 DUT",UVM_NONE);
inf.resetn=1;
inf.detect_add=1;
inf.full_0=0;
inf.full_1=1;
inf.full_2=0;
inf.empty_0=0;
inf.empty_1=1;
inf.empty_2=1;
inf.write_enb_reg=1;
inf.read_enb_0=0;
inf.read_enb_1=1;
inf.read_enb_2=1;
inf.data_in=1;
#1;
  `uvm_info("DRV_RST",$sformatf("DATA_IN=%d RST=%d,detect_add=%d,full_0=%d,full_1=%d,full_2=%d,empty_0=%d,empty_1=%d,empty_2=%d,write_enb_reg=%d,read_enb_0=%d,read_enb_1=%d,read_enb_2=%d",inf.data_in,inf.resetn,inf.detect_add,inf.full_0,inf.full_1,inf.full_2,inf.empty_0,inf.empty_1,inf.empty_2,
inf.write_enb_reg,inf.read_enb_0,inf.read_enb_1,inf.read_enb_2),UVM_NONE);
@(posedge inf.clock);
inf.detect_add<=0;
inf.write_enb_reg<=0;
inf.read_enb_0<=1;
end
endtask

task seq3_dut();
begin
`uvm_info("DRV","SEQ3 DUT",UVM_NONE);
inf.resetn=1;
inf.detect_add=1;
inf.full_0=0;
inf.full_1=0;
inf.full_2=1;
inf.empty_0=1;
inf.empty_1=0;
inf.empty_2=1;
inf.write_enb_reg=1;
inf.read_enb_0=1;
inf.read_enb_1=0;
 
inf.read_enb_2=1;
inf.data_in=2;
  #1;
  `uvm_info("DRV_SEQ3",$sformatf("DATA_IN=%d RST=%d,detect_add=%d,full_0=%d,full_1=%d,full_2=%d,empty_0=%d,empty_1=%d,empty_2=%d,write_enb_reg=%d,read_enb_0=%d,read_enb_1=%d,read_enb_2=%d",inf.data_in,inf.resetn,inf.detect_add,inf.full_0,inf.full_1,inf.full_2,inf.empty_0,inf.empty_1,inf.empty_2,inf.write_enb_reg,inf.read_enb_0,inf.read_enb_1,inf.read_enb_2),UVM_NONE);
@(posedge inf.clock);
inf.detect_add<=0;
inf.write_enb_reg<=0;
inf.read_enb_1<=1;
end
endtask

task seq4_dut();
begin
`uvm_info("DRV","SEQ4 DUT",UVM_NONE);
inf.resetn=1;
inf.detect_add=1;
inf.full_0=0;
inf.full_1=0;
inf.full_2=1;
inf.empty_0=1;
inf.empty_1=1;
inf.empty_2=0;
inf.write_enb_reg=1;
inf.read_enb_0=1;
inf.read_enb_1=1;
inf.read_enb_2=0;
inf.data_in=2;
#1;
  `uvm_info("DRV_SEQ4",$sformatf("DATA_IN=%d RST=%d,detect_add=%d,full_0=%d,full_1=%d,full_2=%d,empty_0=%d,empty_1=%d,empty_2=%d,write_enb_reg=%d,read_enb_0=%d,read_enb_1=%d,read_enb_2=%d",inf.data_in,inf.resetn,inf.detect_add,inf.full_0,inf.full_1,inf.full_2,inf.empty_0,inf.empty_1,inf.empty_2,
inf.write_enb_reg,inf.read_enb_0,inf.read_enb_1,inf.read_enb_2),UVM_NONE);
@(posedge inf.clock);
inf.detect_add<=0;
inf.write_enb_reg<=0;
inf.read_enb_2<=1;
end
endtask

task run_phase(uvm_phase phase);
forever
begin
seq_item_port.get_next_item(trans);
if(trans.seq_num==0)
begin
reset_dut();
end
else if(trans.seq_num==1)
begin
seq2_dut();
end
else if(trans.seq_num==2)
begin
seq3_dut();
end
else if(trans.seq_num==3)
begin
seq4_dut();
end
seq_item_port.item_done(trans);
end
endtask
endclass


class monitor extends uvm_monitor;
`uvm_component_utils(monitor);

transaction trans;
virtual seq_int inf;
uvm_analysis_port #(transaction) send;

function new(string path="mon",uvm_component parent=null);
super.new(path,parent);
endfunction


virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
trans=transaction::type_id::create("trans");
send=new("send",this);


if(!uvm_config_db #(virtual seq_int)::get(this,"","inf",inf))
`uvm_info("MON","ERROR IN CONFIG OF UVM",UVM_NONE);
endfunction

virtual task run_phase(uvm_phase phase);
super.run_phase(phase);

forever
begin
@(posedge inf.clock);
if(!inf.resetn)
begin
trans.data_in=inf.data_in;
trans.resetn=inf.data_in;
trans.detect_add=inf.detect_add;
trans.full_0=inf.full_0;
trans.full_1=inf.full_1;
trans.full_2=inf.full_2;
trans.empty_0=inf.empty_0;
trans.empty_1=inf.empty_1;
trans.empty_2=inf.empty_2;
trans.write_enb_reg=inf.write_enb_reg;
trans.read_enb_0=inf.read_enb_0;
trans.read_enb_1=inf.read_enb_1;
trans.read_enb_2=inf.read_enb_2;
trans.seq_num=0;
trans.vld_out_0=inf.vld_out_0;
trans.vld_out_1=inf.vld_out_1;
trans.vld_out_2=inf.vld_out_2;
trans.soft_reset_0=inf.soft_reset_0;
trans.soft_reset_1=inf.soft_reset_1;
trans.soft_reset_2=inf.soft_reset_2;
trans.write_enb=inf.write_enb;
trans.fifo_full=inf.fifo_full;
`uvm_info("MON","RESET DETECTED",UVM_NONE);
`uvm_info("MON_RST",$sformatf("vld_out_0=%d vld_out_1=%d vld_out_2=%d soft_reset_0=%d soft_reset_1=%d soft_reset_2=%d write_enb=%d fifo_full=%d",trans.vld_out_0,trans.vld_out_1,trans.vld_out_2,trans.soft_reset_0,trans.soft_reset_1,trans.soft_reset_2,trans.write_enb,trans.fifo_full),UVM_NONE);
send.write(trans);
end

else if(inf.write_enb_reg && !inf.read_enb_0)
begin
trans.seq_num=1;
`uvm_info("MON","SEQ2 APPLIED",UVM_NONE);
trans.vld_out_0=inf.vld_out_0;
trans.vld_out_1=inf.vld_out_1;
trans.vld_out_2=inf.vld_out_2;
trans.soft_reset_0=inf.soft_reset_0;
trans.soft_reset_1=inf.soft_reset_1;
trans.soft_reset_2=inf.soft_reset_2;
trans.write_enb=inf.write_enb;
trans.fifo_full=inf.fifo_full;

  `uvm_info("MON_SEQ2",$sformatf("vld_out_0=%d vld_out_1=%d vld_out_2=%d soft_reset_0=%d soft_reset_1=%d soft_reset_2=%d write_enb=%d fifo_full=%d",
trans.vld_out_0,trans.vld_out_1,trans.vld_out_2,trans.soft_reset_0,trans.soft_reset_1,trans.soft_reset_2,inf.write_enb,trans.fifo_full),UVM_NONE);
send.write(trans);
end

else if(inf.write_enb_reg && !inf.read_enb_1)
begin
trans.seq_num=2;
`uvm_info("MON","SEQ3 APPLIED",UVM_NONE);
trans.vld_out_0=inf.vld_out_0;
trans.vld_out_1=inf.vld_out_1;
trans.vld_out_2=inf.vld_out_2;
trans.soft_reset_0=inf.soft_reset_0;
trans.soft_reset_1=inf.soft_reset_1;
trans.soft_reset_2=inf.soft_reset_2;
trans.write_enb=inf.write_enb;
trans.fifo_full=inf.fifo_full;

  `uvm_info("MON_SEQ3",$sformatf("vld_out_0=%d vld_out_1=%d vld_out_2=%d soft_reset_0=%d soft_reset_1=%d soft_reset_2=%d write_enb=%d fifo_full=%d",
trans.vld_out_0,trans.vld_out_1,trans.vld_out_2,trans.soft_reset_0,trans.soft_reset_1,trans.soft_reset_2,trans.write_enb,trans.fifo_full),UVM_NONE);
send.write(trans);
end

else if(inf.write_enb_reg && !inf.read_enb_2)
begin
trans.seq_num=3;
`uvm_info("MON","SEQ4 APPLIED",UVM_NONE);
trans.vld_out_0=inf.vld_out_0;
trans.vld_out_1=inf.vld_out_1;
trans.vld_out_2=inf.vld_out_2;
trans.soft_reset_0=inf.soft_reset_0;
trans.soft_reset_1=inf.soft_reset_1;
trans.soft_reset_2=inf.soft_reset_2;
trans.write_enb=inf.write_enb;
trans.fifo_full=inf.fifo_full;

  `uvm_info("MON_SEQ4",$sformatf("vld_out_0=%d vld_out_1=%d vld_out_2=%d soft_reset_0=%d soft_reset_1=%d soft_reset_2=%d write_enb=%d fifo_full=%d",
trans.vld_out_0,trans.vld_out_1,trans.vld_out_2,trans.soft_reset_0,trans.soft_reset_1,trans.soft_reset_2,trans.write_enb,trans.fifo_full),UVM_NONE);
send.write(trans);
end
end
endtask
endclass

class scoreboard extends uvm_scoreboard;
`uvm_component_utils(scoreboard);

transaction trans;
uvm_analysis_imp #(transaction,scoreboard)recv;

function new(string path="sco",uvm_component parent=null);
super.new(path,parent);
endfunction

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
recv=new("recv",this);
trans=transaction::type_id::create("trans",this);
endfunction

virtual function void write(transaction tr);
begin
trans=tr;
if(trans.seq_num==0)
begin
`uvm_info("SCO","RESET DETECTED",UVM_NONE);
`uvm_info("SCO","-------------------------------",UVM_NONE);
end

if(trans.seq_num==1)
begin
  if(trans.vld_out_0 && !trans.vld_out_1 && !trans.vld_out_2 && trans.soft_reset_0 && !trans.soft_reset_1 && !trans.soft_reset_2 && trans.write_enb==2 && trans.fifo_full)
begin
`uvm_info("SCO","PASSED",UVM_NONE);
`uvm_info("SCO","-------------------------------",UVM_NONE);

end
else
begin
`uvm_info("SCO","FAILED",UVM_NONE);
`uvm_info("SCO","-------------------------------",UVM_NONE);

end
end

else if(trans.seq_num==2)
begin
  if(!trans.vld_out_0 && trans.vld_out_1 && !trans.vld_out_2 && trans.write_enb==4 && trans.soft_reset_0 && trans.soft_reset_1 && !trans.soft_reset_2  && trans.fifo_full)
begin
`uvm_info("SCO","PASSED",UVM_NONE);
`uvm_info("SCO","-------------------------------",UVM_NONE);
end
else
begin
`uvm_info("SCO","FAILED",UVM_NONE);
`uvm_info("SCO","-------------------------------",UVM_NONE);

end
end

else if(trans.seq_num==3)
begin
if(!trans.vld_out_0 && !trans.vld_out_1 && trans.vld_out_2 && trans.soft_reset_0 && trans.soft_reset_1 && trans.soft_reset_2 && trans.fifo_full)
begin
`uvm_info("SCO","PASSED",UVM_NONE);
`uvm_info("SCO","-------------------------------",UVM_NONE);
end
else
begin
`uvm_info("SCO","FAILED",UVM_NONE);
`uvm_info("SCO","-------------------------------",UVM_NONE);

end
end
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


class coverage extends uvm_subscriber #(transaction);
`uvm_component_utils(coverage);
transaction trans;

covergroup my_cov;
option.per_instance=1;

coverpoint (trans.data_in)
{
bins low_data_in={[0:1]};
bins high_data_in={[2:3]};
}
coverpoint trans.detect_add;

coverpoint trans.full_0;

coverpoint trans.full_1;

coverpoint trans.full_2;

coverpoint trans.empty_0;

coverpoint trans.empty_1;

coverpoint trans.empty_2;

coverpoint trans.write_enb_reg;

coverpoint trans.read_enb_0;

coverpoint trans.read_enb_1;
coverpoint trans.read_enb_2;


endgroup
function new(string path="cov",uvm_component parent=null);
super.new(path,parent);
my_cov=new();
endfunction

function void write(transaction t);
trans=t;
my_cov.sample();
endfunction
function void report_phase(uvm_phase phase);
  `uvm_info("COV",$sformatf("Coverage is %0.2f %%", my_cov.get_coverage()),UVM_NONE);
  endfunction

endclass

class env extends uvm_env;
`uvm_component_utils(env);

agent a;
scoreboard scb;
coverage cov;
function new(string path="env",uvm_component parent=null);
super.new(path,parent);
endfunction

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
a=agent::type_id::create("a",this);
scb=scoreboard::type_id::create("scb",this);
cov=coverage::type_id::create("cov",this);
endfunction

virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
a.mon.send.connect(scb.recv);
a.mon.send.connect(cov.analysis_export);
endfunction
endclass


class test extends uvm_test;
`uvm_component_utils(test);
env e;
reset_dut rdut;
seq2 s2;
seq3 s3;
seq4 s4;

function new(string path="test",uvm_component parent=null);
super.new(path,parent);
endfunction


virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
e=env::type_id::create("e",this);
rdut=reset_dut::type_id::create("rdut",this);
s2=seq2::type_id::create("s2",this);
s3=seq3::type_id::create("s3",this);
s4=seq4::type_id::create("s4",this);
endfunction

virtual task run_phase(uvm_phase phase);
phase.raise_objection(this);
rdut.start(e.a.seqr);
s2.start(e.a.seqr);
s3.start(e.a.seqr);
s4.start(e.a.seqr);
phase.drop_objection(this);
endtask
endclass

module tb;

seq_int inf();

sync dut(inf.clock,inf.resetn,inf.data_in,inf.detect_add,
inf.full_0,inf.full_1,inf.full_2,inf.empty_0,inf.empty_1,inf.empty_2,
inf.write_enb_reg,inf.read_enb_0,inf.read_enb_1,inf.read_enb_2,
inf.vld_out_0,inf.vld_out_1,inf.vld_out_2,inf.fifo_full,
inf.soft_reset_0,inf.soft_reset_1,inf.soft_reset_2,inf.write_enb);

initial
begin
inf.clock=0;
end

always
#100 inf.clock=~inf.clock;

initial
begin
uvm_config_db #(virtual seq_int)::set(null,"*","inf",inf);
run_test("test");
end
endmodule
