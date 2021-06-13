//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Wishbone Interconnect                                       ////
////                                                              ////
////  This file is part of the YIFive cores project               ////
////  http://www.opencores.org/cores/yifive/                      ////
////                                                              ////
////  Description                                                 ////
////	1. 3 masters and 3 slaves share bus Wishbone connection   ////
////	2. This block implement simple round robine request       ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 12th June 2021, Dinesh A                            ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////



module wb_interconnect(
         input logic		clk_i, 
         input logic            rst_n,
         
         // Master 0 Interface
         input   logic	[31:0]	m0_wbd_dat_i,
         input   logic  [31:0]	m0_wbd_adr_i,
         input   logic  [3:0]	m0_wbd_sel_i,
         input   logic  	m0_wbd_we_i,
         input   logic  	m0_wbd_cyc_i,
         input   logic  	m0_wbd_stb_i,
         input   logic [3:0] 	m0_wbd_tid_i, // target id
         output  logic	[31:0]	m0_wbd_dat_o,
         output  logic		m0_wbd_ack_o,
         output  logic		m0_wbd_err_o,
         
         // Master 1 Interface
         input	logic [31:0]	m1_wbd_dat_i,
         input	logic [31:0]	m1_wbd_adr_i,
         input	logic [3:0]	m1_wbd_sel_i,
         input	logic 	        m1_wbd_we_i,
         input	logic 	        m1_wbd_cyc_i,
         input	logic 	        m1_wbd_stb_i,
         input  logic [3:0] 	m1_wbd_tid_i, // target id
         output	logic [31:0]	m1_wbd_dat_o,
         output	logic 	        m1_wbd_ack_o,
         output	logic 	        m1_wbd_err_o,
         
         // Master 2 Interface
         input	logic [31:0]	m2_wbd_dat_i,
         input	logic [31:0]	m2_wbd_adr_i,
         input	logic [3:0]	m2_wbd_sel_i,
         input	logic 	        m2_wbd_we_i,
         input	logic 	        m2_wbd_cyc_i,
         input	logic 	        m2_wbd_stb_i,
         input  logic [3:0] 	m2_wbd_tid_i, // target id
         output	logic [31:0]	m2_wbd_dat_o,
         output	logic 	        m2_wbd_ack_o,
         output	logic 	        m2_wbd_err_o,
         
         
         // Slave 0 Interface
         input	logic [31:0]	s0_wbd_dat_i,
         input	logic 	        s0_wbd_ack_i,
         input	logic 	        s0_wbd_err_i,
         output	logic [31:0]	s0_wbd_dat_o,
         output	logic [31:0]	s0_wbd_adr_o,
         output	logic [3:0]	s0_wbd_sel_o,
         output	logic 	        s0_wbd_we_o,
         output	logic 	        s0_wbd_cyc_o,
         output	logic 	        s0_wbd_stb_o,
         
         // Slave 1 Interface
         input	logic [31:0]	s1_wbd_dat_i,
         input	logic 	        s1_wbd_ack_i,
         input	logic 	        s1_wbd_err_i,
         output	logic [31:0]	s1_wbd_dat_o,
         output	logic [31:0]	s1_wbd_adr_o,
         output	logic [3:0]	s1_wbd_sel_o,
         output	logic 	        s1_wbd_we_o,
         output	logic 	        s1_wbd_cyc_o,
         output	logic 	        s1_wbd_stb_o,
         
         // Slave 2 Interface
         input	logic [31:0]	s2_wbd_dat_i,
         input	logic 	        s2_wbd_ack_i,
         input	logic 	        s2_wbd_err_i,
         output	logic [31:0]	s2_wbd_dat_o,
         output	logic [31:0]	s2_wbd_adr_o,
         output	logic [3:0]	s2_wbd_sel_o,
         output	logic 	        s2_wbd_we_o,
         output	logic 	        s2_wbd_cyc_o,
         output	logic 	        s2_wbd_stb_o
	);

////////////////////////////////////////////////////////////////////
//
// Type define
//


// WishBone Wr Interface
typedef struct packed { 
  logic	[31:0]	wbd_dat;
  logic  [31:0]	wbd_adr;
  logic  [3:0]	wbd_sel;
  logic  	wbd_we;
  logic  	wbd_cyc;
  logic  	wbd_stb;
  logic [3:0] 	wbd_tid; // target id
} type_wb_wr_intf;

// WishBone Rd Interface
typedef struct packed { 
  logic	[31:0]	wbd_dat;
  logic  	wbd_ack;
  logic  	wbd_err;
} type_wb_rd_intf;


// Master Write Interface
type_wb_wr_intf  m0_wb_wr;
type_wb_wr_intf  m1_wb_wr;
type_wb_wr_intf  m2_wb_wr;

// Master Read Interface
type_wb_rd_intf  m0_wb_rd;
type_wb_rd_intf  m1_wb_rd;
type_wb_rd_intf  m2_wb_rd;

// Slave Write Interface
type_wb_wr_intf  s0_wb_wr;
type_wb_wr_intf  s1_wb_wr;
type_wb_wr_intf  s2_wb_wr;

// Slave Read Interface
type_wb_rd_intf  s0_wb_rd;
type_wb_rd_intf  s1_wb_rd;
type_wb_rd_intf  s2_wb_rd;


type_wb_wr_intf  i_bus_m;  // Multiplexed Master I/F
type_wb_rd_intf  i_bus_s;  // Multiplexed Slave I/F


//----------------------------------------
// Master Mapping
// -------------------------------------
assign m0_wb_wr.wbd_dat = m0_wbd_dat_i;
assign m0_wb_wr.wbd_adr = m0_wbd_adr_i;
assign m0_wb_wr.wbd_sel = m0_wbd_sel_i;
assign m0_wb_wr.wbd_we  = m0_wbd_we_i;
assign m0_wb_wr.wbd_cyc = m0_wbd_cyc_i;
assign m0_wb_wr.wbd_stb = m0_wbd_stb_i;
assign m0_wb_wr.wbd_tid = m0_wbd_tid_i;

assign m1_wb_wr.wbd_dat = m1_wbd_dat_i;
assign m1_wb_wr.wbd_adr = m1_wbd_adr_i;
assign m1_wb_wr.wbd_sel = m1_wbd_sel_i;
assign m1_wb_wr.wbd_we  = m1_wbd_we_i;
assign m1_wb_wr.wbd_cyc = m1_wbd_cyc_i;
assign m1_wb_wr.wbd_stb = m1_wbd_stb_i;
assign m1_wb_wr.wbd_tid = m1_wbd_tid_i;

assign m2_wb_wr.wbd_dat = m2_wbd_dat_i;
assign m2_wb_wr.wbd_adr = m2_wbd_adr_i;
assign m2_wb_wr.wbd_sel = m2_wbd_sel_i;
assign m2_wb_wr.wbd_we  = m2_wbd_we_i;
assign m2_wb_wr.wbd_cyc = m2_wbd_cyc_i;
assign m2_wb_wr.wbd_stb = m2_wbd_stb_i;
assign m2_wb_wr.wbd_tid = m2_wbd_tid_i;

assign m0_wbd_dat_o  =  m0_wb_rd.wbd_dat;
assign m0_wbd_ack_o  =  m0_wb_rd.wbd_ack;
assign m0_wbd_err_o  =  m0_wb_rd.wbd_err;

assign m1_wbd_dat_o  =  m1_wb_rd.wbd_dat;
assign m1_wbd_ack_o  =  m1_wb_rd.wbd_ack;
assign m1_wbd_err_o  =  m1_wb_rd.wbd_err;

assign m2_wbd_dat_o  =  m2_wb_rd.wbd_dat;
assign m2_wbd_ack_o  =  m2_wb_rd.wbd_ack;
assign m2_wbd_err_o  =  m2_wb_rd.wbd_err;

assign s0_wb_rd.wbd_dat  = s0_wbd_dat_i ;
assign s0_wb_rd.wbd_ack  = s0_wbd_ack_i ;
assign s0_wb_rd.wbd_err  = s0_wbd_err_i ;

assign s1_wb_rd.wbd_dat  = s1_wbd_dat_i ;
assign s1_wb_rd.wbd_ack  = s1_wbd_ack_i ;
assign s1_wb_rd.wbd_err  = s1_wbd_err_i ;

assign s2_wb_rd.wbd_dat  = s2_wbd_dat_i ;
assign s2_wb_rd.wbd_ack  = s2_wbd_ack_i ;
assign s2_wb_rd.wbd_err  = s2_wbd_err_i ;


//----------------------------------------
// Slave Mapping
// -------------------------------------

assign  s0_wbd_dat_o =  s0_wb_wr.wbd_dat ;
assign  s0_wbd_adr_o =  s0_wb_wr.wbd_adr ;
assign  s0_wbd_sel_o =  s0_wb_wr.wbd_sel ;
assign  s0_wbd_we_o  =  s0_wb_wr.wbd_we  ;
assign  s0_wbd_cyc_o =  s0_wb_wr.wbd_cyc ;
assign  s0_wbd_stb_o =  s0_wb_wr.wbd_stb ;
                     
assign  s1_wbd_dat_o =  s1_wb_wr.wbd_dat ;
assign  s1_wbd_adr_o =  s1_wb_wr.wbd_adr ;
assign  s1_wbd_sel_o =  s1_wb_wr.wbd_sel ;
assign  s1_wbd_we_o  =  s1_wb_wr.wbd_we  ;
assign  s1_wbd_cyc_o =  s1_wb_wr.wbd_cyc ;
assign  s1_wbd_stb_o =  s1_wb_wr.wbd_stb ;
                     
assign  s2_wbd_dat_o =  s2_wb_wr.wbd_dat ;
assign  s2_wbd_adr_o =  s2_wb_wr.wbd_adr ;
assign  s2_wbd_sel_o =  s2_wb_wr.wbd_sel ;
assign  s2_wbd_we_o  =  s2_wb_wr.wbd_we  ;
assign  s2_wbd_cyc_o =  s2_wb_wr.wbd_cyc ;
assign  s2_wbd_stb_o =  s2_wb_wr.wbd_stb ;

//
// arbitor 
//
logic [1:0]  gnt;

wb_arb	u_wb_arb(
	.clk(clk_i), 
	.rstn(rst_n),
	.req({	m2_wbd_cyc_i,
		m1_wbd_cyc_i,
		m0_wbd_cyc_i}),
	.gnt(gnt)
);


// Generate Multiplexed Master Interface based on grant
always_comb begin
     case(gnt)
        3'h0:	   i_bus_m = m0_wb_wr;
        3'h1:	   i_bus_m = m1_wb_wr;
        3'h2:	   i_bus_m = m2_wb_wr;
        default:   i_bus_m = m0_wb_wr;
     endcase			
end


// Generate Multiplexed Slave Interface based on target Id
wire [3:0] wbd_tid =  i_bus_m.wbd_tid; // to fix iverilog warning
always_comb begin
     case(wbd_tid)
        3'h0:	   i_bus_s = s0_wb_rd;
        3'h1:	   i_bus_s = s1_wb_rd;
        3'h2:	   i_bus_s = s2_wb_rd;
        default:   i_bus_s = s0_wb_rd;
     endcase			
end


// Connect Master => Slave
assign  s0_wb_wr = (i_bus_m.wbd_tid == 2'b00) ? i_bus_m : 'h0;
assign  s1_wb_wr = (i_bus_m.wbd_tid == 2'b01) ? i_bus_m : 'h0;
assign  s2_wb_wr = (i_bus_m.wbd_tid == 2'b10) ? i_bus_m : 'h0;

// Connect Slave to Master
assign  m0_wb_rd = (gnt == 2'b00) ? i_bus_s : 'h0;
assign  m1_wb_rd = (gnt == 2'b01) ? i_bus_s : 'h0;
assign  m2_wb_rd = (gnt == 2'b10) ? i_bus_s : 'h0;



endmodule

