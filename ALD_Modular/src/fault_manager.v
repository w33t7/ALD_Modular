//-----------------------------------------------------------------------------
//
// Title       : \fault_manager\ 
// Design      : ALD_Modular
// Author      : a210200969@unison.mx
// Company     : UNISON
//
//-----------------------------------------------------------------------------
//
// File        : c:/My_Designs/ALD_Modular/ALD_Modular/src/fault_manager.v
// Generated   : Sun Nov 22 15:12:59 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1ns/1ps

module fault_manager (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       fault_in,
    input  wire       interlock_err,
    input  wire       clear_fault,
    output reg        fault_active,
    output reg        alert_led,
    output reg  [7:0] err_code
);

    localparam [7:0]
        ERR_NONE      = 8'h00,
        ERR_EXT_FAULT = 8'h01,
        ERR_INTERLOCK = 8'h02;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fault_active <= 1'b0;
            alert_led    <= 1'b0;
            err_code     <= ERR_NONE;
        end else if (interlock_err) begin
            fault_active <= 1'b1;
            alert_led    <= 1'b1;
            err_code     <= ERR_INTERLOCK;
        end else if (fault_in) begin
            fault_active <= 1'b1;
            alert_led    <= 1'b1;
            err_code     <= ERR_EXT_FAULT;
        end else if (clear_fault && !fault_in) begin
            fault_active <= 1'b0;
            alert_led    <= 1'b0;
            err_code     <= ERR_NONE;
        end
    end

endmodule