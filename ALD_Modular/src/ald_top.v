//-----------------------------------------------------------------------------
//
// Title       : \ald_top\ 
// Design      : ALD_Modular
// Author      : a210200969@unison.mx
// Company     : UNISON
//
//-----------------------------------------------------------------------------
//
// File        : c:/My_Designs/ALD_Modular/ALD_Modular/src/ald_top.v
// Generated   : Sun Nov 22 15:13:30 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------
`timescale 1ns/1ps

module ald_top #(
    parameter CLK_HZ    = 50000000,
    parameter TICKS_1MS = 50000
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire        pause,
    input  wire        fault_in,
    input  wire [15:0] num_cycles,
    input  wire [15:0] t_purge1_ms,
    input  wire [15:0] t_tma_ms,
    input  wire [15:0] t_purge2_ms,
    input  wire [15:0] t_h2o_ms,
    output wire        v1,
    output wire        v2,
    output wire        v3,
    output wire        v4,
    output wire        alert_led,
    output wire        done_led,
    output wire [2:0]  state_id,
    output wire [2:0]  step_num,
    output wire [7:0]  err_code,
    output wire [15:0] cycles_done,
    output wire [15:0] cycles_rem
);

    wire v1_req, v2_req, v3_req, v4_req;
    wire fault_active;
    wire interlock_err;
    wire clear_fault;

    assign clear_fault = (!start) && (!fault_in);

    ald_fsm_core #(
        .CLK_HZ(CLK_HZ),
        .TICKS_1MS(TICKS_1MS)
    ) u_fsm_core (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .pause(pause),
        .fault_active(fault_active),
        .num_cycles(num_cycles),
        .t_purge1_ms(t_purge1_ms),
        .t_tma_ms(t_tma_ms),
        .t_purge2_ms(t_purge2_ms),
        .t_h2o_ms(t_h2o_ms),
        .v1_req(v1_req),
        .v2_req(v2_req),
        .v3_req(v3_req),
        .v4_req(v4_req),
        .done_led(done_led),
        .state_id(state_id),
        .step_num(step_num),
        .cycles_done(cycles_done),
        .cycles_rem(cycles_rem)
    );

    valve_safety_ctrl u_valve_safety (
        .v1_req(v1_req),
        .v2_req(v2_req),
        .v3_req(v3_req),
        .v4_req(v4_req),
        .fault_active(fault_active),
        .v1_out(v1),
        .v2_out(v2),
        .v3_out(v3),
        .v4_out(v4),
        .interlock_err(interlock_err)
    );

    fault_manager u_fault_mgr (
        .clk(clk),
        .rst_n(rst_n),
        .fault_in(fault_in),
        .interlock_err(interlock_err),
        .clear_fault(clear_fault),
        .fault_active(fault_active),
        .alert_led(alert_led),
        .err_code(err_code)
    );

endmodule