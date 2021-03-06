// ***************************************************************************
// ***************************************************************************
// Copyright 2013(c) Analog Devices, Inc.
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//     - Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     - Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in
//       the documentation and/or other materials provided with the
//       distribution.
//     - Neither the name of Analog Devices, Inc. nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.
//     - The use of this software may or may not infringe the patent rights
//       of one or more patent holders.  This license does not release you
//       from the requirement that you obtain separate licenses from these
//       patent holders to use this software.
//     - Use of the software either in source or binary form, must be run
//       on or directly connected to an Analog Devices Inc. component.
//
// THIS SOFTWARE IS PROVIDED BY ANALOG DEVICES "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
// INCLUDING, BUT NOT LIMITED TO, NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A
// PARTICULAR PURPOSE ARE DISCLAIMED.
//
// IN NO EVENT SHALL ANALOG DEVICES BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, INTELLECTUAL PROPERTY
// RIGHTS, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// ***************************************************************************
// ***************************************************************************

module control_registers
(
//bus interface
    input              up_rstn,
    input              up_clk,
    input              up_sel,
    input              up_wr,
    input      [13:0]  up_addr,
    input      [31:0]  up_wdata,
    output reg [31:0]  up_rdata,
    output reg         up_ack,
//control
    input  [31:0]  err_i,
    output [31:0]  pwm_open_o,
    output [31:0]  reference_speed_o,
    output [31:0]  kp_o,
    output [31:0]  ki_o,
    output [31:0]  kp1_o,
    output [31:0]  ki1_o,
    output [31:0]  kd1_o,
    output         run_o,
    output         break_o,
    output         star_delta_o,
    output [1:0]   sensors_o,
    output [10:0]  gpo_o,
    output         oloop_matlab_o,
    output         calibrate_adcs_o
);

//------------------------------------------------------------------------------
//----------- Registers Declarations -------------------------------------------
//------------------------------------------------------------------------------
//internal registers
reg [31:0] control_r;
reg [31:0] reference_speed_r;
reg [31:0] kp_r;
reg [31:0] ki_r;
reg [31:0] kp1_r;
reg [31:0] ki1_r;
reg [31:0] kd1_r;
reg [31:0] pwm_open_r;
reg [31:0] pwm_break_r;
reg [31:0] status_r;
reg [31:0] reserved_r1;
reg [31:0] reserved_r2;
reg [10:0] gpo_r;

//------------------------------------------------------------------------------
//----------- Wires Declarations -----------------------------------------------
//------------------------------------------------------------------------------
//internal signals
wire        up_sel_s;
wire        up_wr_s;

//------------------------------------------------------------------------------
//----------- Assign/Always Blocks ---------------------------------------------
//------------------------------------------------------------------------------
//decode block select
assign up_sel_s = (up_addr[13:4] == 10'h00) ? up_sel : 1'b0;
assign up_wr_s = up_sel_s & up_wr;

assign run_o                    = control_r[0];     // Run the motor
assign break_o                  = control_r[2];     // Activate the Break circuit
assign star_delta_o             = control_r[4];     // Select between star [0] or delta [1] controller
assign sensors_o                = control_r[9:8];   // Select between Hall[00] and BEMF[01] sensors
assign calibrate_adcs_o         = control_r[16];
assign oloop_matlab_o           = control_r[12];   // Select between open loop control [0] and matlab control [1]
assign gpo_o                    = control_r[30:20];

assign pwm_open_o               = pwm_open_r;       // PWM value, for open loop control
assign reference_speed_o        = reference_speed_r;
assign kp_o                     = kp_r;
assign ki_o                     = ki_r;
assign kp1_o                    = kp1_r;
assign kd1_o                    = kd1_r;
assign ki1_o                    = ki1_r;


// processor write interface

always @(negedge up_rstn or posedge up_clk)
begin
   if (up_rstn == 0)
   begin
       control_r            <= 'h0;
       reference_speed_r    <= 'd1000;
       kp_r                 <= 'd35000;
       ki_r                 <= 'd30;
       kp1_r                <= 'd400000;
       ki1_r                <= 'd250;
       kd1_r                <= 'd200000;
       pwm_open_r           <= 'h5ff;
       pwm_break_r          <= 'd0;
       status_r             <= 'd0;
   end
   else
   begin
       if ((up_wr_s == 1'b1) && (up_addr[3:0] == 4'h3))
       begin
           reserved_r1          <= up_wdata;
       end
       if ((up_wr_s == 1'b1) && (up_addr[3:0] == 4'h4))
       begin
           control_r            <= up_wdata;
       end
       if ((up_wr_s == 1'b1) && (up_addr[3:0] == 4'h5))
       begin
           reference_speed_r    <= up_wdata;
       end
       if ((up_wr_s == 1'b1) && (up_addr[3:0] == 4'h6))
       begin
           kp_r                 <= up_wdata;
       end
       if ((up_wr_s == 1'b1) && (up_addr[3:0] == 4'h7))
       begin
           ki_r                 <= up_wdata;
       end
       if ((up_wr_s == 1'b1) && (up_addr[3:0] == 4'h8))
       begin
           reserved_r2          <= up_wdata;
       end
       if ((up_wr_s == 1'b1) && (up_addr[3:0] == 4'h9))
       begin
           kp1_r                <= up_wdata;
       end
       if ((up_wr_s == 1'b1) && (up_addr[3:0] == 4'ha))
       begin
           ki1_r                <= up_wdata;
       end
       if ((up_wr_s == 1'b1) && (up_addr[3:0] == 4'hb))
       begin
           kd1_r                <= up_wdata;
       end
       if ((up_wr_s == 1'b1) && (up_addr[3:0] == 4'hc))
       begin
           pwm_open_r          <= up_wdata;
       end
       if ((up_wr_s == 1'b1) && (up_addr[3:0] == 4'hd))
       begin
           pwm_break_r         <= up_wdata;
       end
       if ((up_wr_s == 1'b1) && (up_addr[3:0] == 4'he))
       begin
           status_r            <= up_wdata;
       end
   end
end

// processor read interface
//
always @(negedge up_rstn or posedge up_clk)
begin
    if (up_rstn == 0) begin
        up_ack <= 'd0;
        up_rdata <= 'd0;
    end
    else
    begin
        up_ack <= up_sel_s;
        if (up_sel_s == 1'b1) begin
            case (up_addr[3:0])
                4'h3: up_rdata <= reserved_r1;
                4'h4: up_rdata <= control_r;
                4'h5: up_rdata <= reference_speed_r;
                4'h6: up_rdata <= kp_r;
                4'h7: up_rdata <= ki_r;
                4'h8: up_rdata <= reserved_r2;
                4'h9: up_rdata <= kp1_r;
                4'ha: up_rdata <= ki1_r;
                4'hb: up_rdata <= kd1_r;
                4'hc: up_rdata <= pwm_open_r;
                4'hd: up_rdata <= pwm_break_r;
                4'he: up_rdata <= status_r;
                4'hf: up_rdata <= err_i;
                default: up_rdata <= 0;
            endcase
        end
        else
        begin
            up_rdata <= 32'd0;
        end
    end
end

endmodule
