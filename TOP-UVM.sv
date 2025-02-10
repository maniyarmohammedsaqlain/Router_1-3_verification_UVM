`include "uvm_macros.svh";
import uvm_pkg::*;

class transaction extends uvm_sequence_item;
`uvm_object_utils(transaction);
randc logic [7:0]data_in;
logic [2:0]op;
logic resetn;
logic pkt_valid;
logic read_enb_0;
logic read_enb_1;
logic read_enb_2;
logic vld_out_0;
logic vld_out_1;
logic vld_out_2;
logic err;
logic busy;
logic [7:0]data_out_0;
logic [7:0]data_out_1;
logic [7:0]data_out_2;

function new(string path="trans");
super.new(path);
endfunction
endclass

class rst extends uvm_sequence#(transaction);
`uvm_object_utils(rst);
transaction trans;
function new(string path="rst");
super.new(path);
endfunction

virtual task body();
  repeat(50)
begin
trans=transaction::type_id::create("trans");
start_item(trans);
assert(trans.randomize());
trans.op=0;
`uvm_info("RST","RESET DETECTED",UVM_NONE);
finish_item(trans);
end
endtask
endclass

class seq1 extends uvm_sequence#(transaction);
`uvm_object_utils(seq1);
transaction trans;
function new(string path="seq1");
super.new(path);
endfunction

virtual task body();
  repeat(50)
begin
trans=transaction::type_id::create("trans");
start_item(trans);
assert(trans.randomize());
trans.op=1;
  `uvm_info("SEQ1","SEQ_1 APPLIED",UVM_NONE);
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
  repeat(50)
begin
trans=transaction::type_id::create("trans");
start_item(trans);
assert(trans.randomize());
trans.op=2;
  `uvm_info("SEQ2","SEQ_2 APPLIED",UVM_NONE);
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
  repeat(50)
begin
trans=transaction::type_id::create("trans");
start_item(trans);
assert(trans.randomize());
trans.op=3;
  `uvm_info("SEQ3","SEQ_3 APPLIED",UVM_NONE);
finish_item(trans);
end
endtask
endclass

class driver extends uvm_driver #(transaction);
`uvm_component_utils(driver);
transaction trans;
virtual router_int inf;
function new(string path="drv",uvm_component parent=null);
super.new(path,parent);
endfunction

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
trans=transaction::type_id::create("trans",this);

if(!uvm_config_db #(virtual router_int)::get(this,"","inf",inf))
`uvm_info("DRV","ERROR IN CONFIG OF DRIVER",UVM_NONE);

endfunction

task reset_dut();
begin
  `uvm_info("RST_DRV","RESET SEQUENCE APPLIED",UVM_NONE);
inf.resetn=0;
inf.pkt_valid=0;
inf.read_enb_0=0;
inf.read_enb_1=0;
inf.read_enb_2=0;
inf.data_in<=0;
  `uvm_info("RST_DRV",$sformatf("resetn=%d pkt_valid=%d read_enb0=%d read_enb1=%d read_enb2=%d data_in=%d",inf.resetn,inf.pkt_valid,inf.read_enb_0,inf.read_enb_1,inf.read_enb_2,inf.data_in),UVM_NONE);
@(posedge inf.clock);
@(posedge inf.clock);
@(posedge inf.clock);
@(posedge inf.clock);
end
endtask

task seq1_dut();

begin
  `uvm_info("SEQ1_DRV","SEQ1 SEQUENCE APPLIED",UVM_NONE);
inf.resetn=1;
inf.pkt_valid=1;
inf.read_enb_0=1;
inf.read_enb_1=1;
inf.read_enb_2=1;
inf.data_in=trans.data_in;
  `uvm_info("SEQ1_DRV",$sformatf("resetn=%d pkt_valid=%d read_enb0=%d read_enb1=%d read_enb2=%d data_in=%d",inf.resetn,inf.pkt_valid,inf.read_enb_0,inf.read_enb_1,inf.read_enb_2,inf.data_in),UVM_NONE);
@(posedge inf.clock);
@(posedge inf.clock);
@(posedge inf.clock);
@(posedge inf.clock);

end
endtask

task seq2_dut();

begin
  `uvm_info("SEQ2_DRV","SEQ2 SEQUENCE APPLIED",UVM_NONE);
inf.resetn=1;
inf.pkt_valid=1;
inf.read_enb_0=1;
inf.read_enb_1=1;
inf.read_enb_2=1;
inf.data_in=trans.data_in;
  `uvm_info("SEQ2_DRV",$sformatf("resetn=%d pkt_valid=%d read_enb0=%d read_enb1=%d read_enb2=%d data_in=%d",inf.resetn,inf.pkt_valid,inf.read_enb_0,inf.read_enb_1,inf.read_enb_2,inf.data_in),UVM_NONE);
@(posedge inf.clock);
@(posedge inf.clock);
@(posedge inf.clock);
@(posedge inf.clock);
end
endtask

task seq3_dut();

begin
  `uvm_info("SEQ3_DRV","SEQ3 SEQUENCE APPLIED",UVM_NONE);
inf.resetn=1;
inf.pkt_valid=1;
inf.read_enb_0=1;
inf.read_enb_1=1;
inf.read_enb_2=1;
inf.data_in=trans.data_in;
  `uvm_info("SEQ3_DRV",$sformatf("resetn=%d pkt_valid=%d read_enb0=%d read_enb1=%d read_enb2=%d data_in=%d",inf.resetn,inf.pkt_valid,inf.read_enb_0,inf.read_enb_1,inf.read_enb_2,inf.data_in),UVM_NONE);
@(posedge inf.clock);
@(posedge inf.clock);
@(posedge inf.clock);
@(posedge inf.clock);
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
seq1_dut();
end
else if(trans.op==2)
begin
seq2_dut();
end
else if(trans.op==3)
begin
seq3_dut();
end
seq_item_port.item_done();
end
endtask
endclass


class monitor extends uvm_monitor;
`uvm_component_utils(monitor);
transaction trans;
virtual router_int inf;
uvm_analysis_port #(transaction)send;

function new(string path="mon",uvm_component parent=null);
super.new(path,parent);
endfunction

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
trans=transaction::type_id::create("trans");
send=new("send",this);

if(!uvm_config_db #(virtual router_int)::get(this,"","inf",inf))
`uvm_info("MON","ERROR IN CONFIG OF MON",UVM_NONE);
endfunction

virtual task run_phase(uvm_phase phase);
  
super.run_phase(phase);
forever
begin
@(posedge inf.clock)
if(inf.resetn==0)
begin
trans.op=0;
  @(posedge inf.clock);
    @(posedge inf.clock);
    @(posedge inf.clock);

  `uvm_info("MON_RST","RESET DETECTED",UVM_NONE);
send.write(trans);
end

else if(inf.read_enb_0==1)
begin
trans.op=1;
trans.resetn=inf.resetn;
trans.pkt_valid=inf.pkt_valid;
trans.read_enb_0=inf.read_enb_0;
trans.read_enb_1=inf.read_enb_1;
trans.read_enb_2=inf.read_enb_2;
trans.data_in=inf.data_in;
  @(posedge inf.clock);
    @(posedge inf.clock);
    @(posedge inf.clock);

trans.vld_out_0=inf.vld_out_0;
trans.vld_out_1=inf.vld_out_1;
trans.vld_out_2=inf.vld_out_2;
trans.err=inf.err;
trans.busy=inf.busy;
trans.data_out_0=inf.data_out_0;
trans.data_out_1=inf.data_out_1;
trans.data_out_2=inf.data_out_2;
`uvm_info("MON_SEQ1",$sformatf("Vld_out_0=%d vld_out_1=%d vld_out_2=%d err=%d busy=%d data_out_0=%d data_out_1=%d data_out_2=%d",trans.vld_out_0,trans.vld_out_1,trans.vld_out_2,trans.err,trans.busy,trans.data_out_0,trans.data_out_1,trans.data_out_2),UVM_NONE);
send.write(trans);
end

else if(inf.read_enb_1==1)
begin
trans.op=2;
trans.resetn=inf.resetn;
trans.pkt_valid=inf.pkt_valid;
trans.read_enb_0=inf.read_enb_0;
trans.read_enb_1=inf.read_enb_1;
trans.read_enb_2=inf.read_enb_2;
trans.data_in=inf.data_in;
  @(posedge inf.clock);
    @(posedge inf.clock);
    @(posedge inf.clock);

trans.vld_out_0=inf.vld_out_0;
trans.vld_out_1=inf.vld_out_1;
trans.vld_out_2=inf.vld_out_2;
trans.err=inf.err;
trans.busy=inf.busy;
trans.data_out_0=inf.data_out_0;
trans.data_out_1=inf.data_out_1;
trans.data_out_2=inf.data_out_2;
  `uvm_info("MON_SEQ2",$sformatf("Vld_out_0=%d vld_out_1=%d vld_out_2=%d err=%d busy=%d data_out_0=%d data_out_1=%d data_out_2=%d",trans.vld_out_0,trans.vld_out_1,trans.vld_out_2,trans.err,trans.busy,trans.data_out_0,trans.data_out_1,trans.data_out_2),UVM_NONE)
send.write(trans);
end

else if(inf.read_enb_2==1)
begin
trans.op=3;
trans.resetn=inf.resetn;
trans.pkt_valid=inf.pkt_valid;
trans.read_enb_0=inf.read_enb_0;
trans.read_enb_1=inf.read_enb_1;
trans.read_enb_2=inf.read_enb_2;
trans.data_in=inf.data_in;
  @(posedge inf.clock);
    @(posedge inf.clock);

trans.vld_out_0=inf.vld_out_0;
trans.vld_out_1=inf.vld_out_1;
trans.vld_out_2=inf.vld_out_2;
trans.err=inf.err;
trans.busy=inf.busy;
trans.data_out_0=inf.data_out_0;
trans.data_out_1=inf.data_out_1;
trans.data_out_2=inf.data_out_2;
  `uvm_info("MON_SEQ3",$sformatf("Vld_out_0=%d vld_out_1=%d vld_out_2=%d err=%d busy=%d data_out_0=%d, data_out_1=%d,data_out_2=%d",trans.vld_out_0,trans.vld_out_1,trans.vld_out_2,trans.err,trans.busy,trans.data_out_0,trans.data_out_1,trans.data_out_2),UVM_NONE)
send.write(trans);
end
end
endtask
endclass

class scoreboard extends uvm_scoreboard;

`uvm_component_utils(scoreboard);

transaction trans;
uvm_analysis_imp#(transaction,scoreboard)recv;


function new(string path="scoreboard",uvm_component parent=null);
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
`uvm_info("SCB","RESET DETECTED",UVM_NONE);
`uvm_info("SCB","--------------------------------------------",UVM_NONE);
end

else if(trans.op==1)
if(trans.vld_out_0 && (trans.data_in==trans.data_out_0))
begin
`uvm_info("SCB","PASSED",UVM_NONE);
  `uvm_info("SCB",$sformatf("DATAIN=%d DATAOUT=%d",trans.data_in,trans.data_out_0),UVM_NONE);
`uvm_info("SCB","-------------------------------",UVM_NONE);
end
else
begin
`uvm_info("SCB","FAILED",UVM_NONE);
   `uvm_info("SCB",$sformatf("DATAIN=%d DATAOUT=%d",trans.data_in,trans.data_out_0),UVM_NONE);
`uvm_info("SCB","-------------------------------",UVM_NONE);
end

else if(trans.op==2)
if(trans.vld_out_1 && (trans.data_in==trans.data_out_1))
begin
`uvm_info("SCB","PASSED",UVM_NONE);
  `uvm_info("SCB",$sformatf("DATAIN=%d DATAOUT=%d",trans.data_in,trans.data_out_1),UVM_NONE);
`uvm_info("SCB","-------------------------------",UVM_NONE);
end
else
begin
`uvm_info("SCB","FAILED",UVM_NONE);
  `uvm_info("SCB",$sformatf("DATAIN=%d DATAOUT=%d",trans.data_in,trans.data_out_1),UVM_NONE);
`uvm_info("SCB","-------------------------------",UVM_NONE);
end

else if(trans.op==3)
if(trans.vld_out_2 && (trans.data_in==trans.data_out_2))
begin
`uvm_info("SCB","PASSED",UVM_NONE);
  `uvm_info("SCB",$sformatf("DATAIN=%d DATAOUT=%d",trans.data_in,trans.data_out_2),UVM_NONE);

`uvm_info("SCB","-------------------------------",UVM_NONE);
end
else
begin
`uvm_info("SCB","FAILED",UVM_NONE);
  `uvm_info("SCB",$sformatf("DATAIN=%d DATAOUT=%d",trans.data_in,trans.data_out_2),UVM_NONE);

`uvm_info("SCB","-------------------------------",UVM_NONE);
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
scoreboard scb;
function new(string path="env",uvm_component parent=null);
super.new(path,parent);
endfunction

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
a=agent::type_id::create("a",this);
scb=scoreboard::type_id::create("scb",this);
endfunction

virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
a.mon.send.connect(scb.recv);
endfunction
endclass




class test extends uvm_test;
`uvm_component_utils(test);
env e;
rst rst_seq;
seq1 s1;
seq2 s2;
seq3 s3;


function new(string path="test",uvm_component parent=null);
super.new(path,parent);
endfunction

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
e=env::type_id::create("e",this);
rst_seq=rst::type_id::create("rst_seq",this);
s1=seq1::type_id::create("s1",this);
s2=seq2::type_id::create("s2",this);
s3=seq3::type_id::create("s3",this);
endfunction

virtual task run_phase(uvm_phase phase);
phase.raise_objection(this);
rst_seq.start(e.a.seqr);
s1.start(e.a.seqr);
s2.start(e.a.seqr);
s3.start(e.a.seqr);
phase.drop_objection(this);
endtask
endclass

module tb;
router_int inf();
router DUT(inf.clock,inf.resetn,inf.data_in,inf.read_enb_0,inf.read_enb_1,inf.read_enb_2,inf.pkt_valid,inf.data_out_0,inf.data_out_1,inf.data_out_2,inf.vld_out_0,inf.vld_out_1,inf.vld_out_2,inf.err,inf.busy);

initial
begin
inf.clock=0;
end

always
#10 inf.clock=~inf.clock;



initial
begin
uvm_config_db #(virtual router_int)::set(null,"*","inf",inf);
run_test("test");
end
endmodule
