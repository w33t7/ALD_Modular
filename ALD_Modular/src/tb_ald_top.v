//-----------------------------------------------------------------------------
//
// Title       : \testbench_ald_top\ 
// Design      : ALD_Modular
// Author      : a210200969@unison.mx
// Company     : UNISON
//
//-----------------------------------------------------------------------------
//
// File        : c:/My_Designs/ALD_Modular/ALD_Modular/src/tb_ald_top.v
// Generated   : Sun Nov 22 18:15:50 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1ns/1ps

module tb_ald_top;

    reg         clk;
    reg         rst_n;
    reg         start;
    reg         pause;
    reg         fault_in;
    reg  [15:0] num_cycles;
    reg  [15:0] t_purge1_ms;
    reg  [15:0] t_tma_ms;
    reg  [15:0] t_purge2_ms;
    reg  [15:0] t_h2o_ms;

    wire        v1, v2, v3, v4;
    wire        alert_led, done_led;
    wire [2:0]  state_id, step_num;
    wire [7:0]  err_code;
    wire [15:0] cycles_done, cycles_rem;

    // TICKS_1MS = 10 para simular rápido en Active-HDL (en DE2 a 50 MHz va a 50000)
    ald_top #(
        .CLK_HZ(50000000),
        .TICKS_1MS(10)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .pause(pause),
        .fault_in(fault_in),
        .num_cycles(num_cycles),
        .t_purge1_ms(t_purge1_ms),
        .t_tma_ms(t_tma_ms),
        .t_purge2_ms(t_purge2_ms),
        .t_h2o_ms(t_h2o_ms),
        .v1(v1),
        .v2(v2),
        .v3(v3),
        .v4(v4),
        .alert_led(alert_led),
        .done_led(done_led),
        .state_id(state_id),
        .step_num(step_num),
        .err_code(err_code),
        .cycles_done(cycles_done),
        .cycles_rem(cycles_rem)
    );

    always #10 clk = ~clk;

    initial begin
        clk         = 1'b0;
        rst_n       = 1'b0;
        start       = 1'b0;
        pause       = 1'b0;
        fault_in    = 1'b0;
        num_cycles  = 16'd0;
        t_purge1_ms = 16'd5;
        t_tma_ms    = 16'd2;
        t_purge2_ms = 16'd5;
        t_h2o_ms    = 16'd2;

        #60;
        rst_n = 1'b1;

        // 1. Intento de arranque con N = 0 (debe quedarse en IDLE)
        #40;
        start = 1'b1;
        #100;
        start = 1'b0;
        #100;

        // 2. Arrancar 3 ciclos
        num_cycles = 16'd3;
        start      = 1'b1;

        // 3. Probar pausa
        #600;
        pause = 1'b1;
        #300;
        pause = 1'b0;

        // 4. Probar falla externa
        #600;
        fault_in = 1'b1;
        #200;
        fault_in = 1'b0;
        start    = 1'b0;

        // 5. Volver a arrancar y dejar completar hasta DONE
        #100;
        start = 1'b1;
        #5000;

        $stop;
    end

endmodule
