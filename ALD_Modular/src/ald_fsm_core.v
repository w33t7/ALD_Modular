//-----------------------------------------------------------------------------
//
// Title       : \ald_fsm_core\ 
// Design      : ALD_Modular
// Author      : a210200969@unison.mx
// Company     : UNISON
//
//-----------------------------------------------------------------------------
//
// File        : c:/My_Designs/ALD_Modular/ALD_Modular/src/ald_fsm_core.v
// Generated   : Sun Nov 22 15:11:37 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1ns/1ps

module ald_fsm_core #(
    parameter CLK_HZ    = 50000000,
    parameter TICKS_1MS = 50000
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire        pause,
    input  wire        fault_active,
    input  wire [15:0] num_cycles,
    input  wire [15:0] t_purge1_ms,
    input  wire [15:0] t_tma_ms,
    input  wire [15:0] t_purge2_ms,
    input  wire [15:0] t_h2o_ms,
    output reg         v1_req,
    output reg         v2_req,
    output reg         v3_req,
    output reg         v4_req,
    output reg         done_led,
    output reg  [2:0]  state_id,
    output reg  [2:0]  step_num,
    output reg  [15:0] cycles_done,
    output reg  [15:0] cycles_rem
);

    localparam [2:0]
        ST_IDLE  = 3'd0,
        ST_P1    = 3'd1,
        ST_TMA   = 3'd2,
        ST_P2    = 3'd3,
        ST_H2O   = 3'd4,
        ST_PAUSE = 3'd5,
        ST_FAULT = 3'd6,
        ST_DONE  = 3'd7;

    reg [2:0]  state;
    reg [2:0]  next_state;
    reg [2:0]  return_state;
    reg [31:0] clk_cnt;
    reg [15:0] ms_cnt;

    wire       tick_1ms;
    wire       in_run_step;

    assign in_run_step = (state == ST_P1) || (state == ST_TMA) ||
                         (state == ST_P2) || (state == ST_H2O);
    assign tick_1ms    = (clk_cnt == (TICKS_1MS - 1));

    // Divisor de tiempo de 1 ms
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_cnt <= 32'd0;
        end else if (state == ST_IDLE || state == ST_FAULT || state == ST_DONE) begin
            clk_cnt <= 32'd0;
        end else if (state == ST_PAUSE) begin
            clk_cnt <= clk_cnt;
        end else if (tick_1ms) begin
            clk_cnt <= 32'd0;
        end else begin
            clk_cnt <= clk_cnt + 32'd1;
        end
    end

    // Registro de estado, temporizador en ms y contador de ciclos
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= ST_IDLE;
            return_state <= ST_P1;
            ms_cnt       <= 16'd0;
            cycles_done  <= 16'd0;
        end else begin
            state <= next_state;

            if (in_run_step && next_state == ST_PAUSE) begin
                return_state <= state;
            end

            if (next_state == ST_IDLE) begin
                ms_cnt      <= 16'd0;
                cycles_done <= 16'd0;
            end else if (next_state == ST_FAULT) begin
                ms_cnt <= 16'd0;
            end else if (state == ST_PAUSE) begin
                ms_cnt <= ms_cnt;
            end else if (state != next_state) begin
                ms_cnt <= 16'd0;
                if (state == ST_H2O && next_state == ST_P1) begin
                    cycles_done <= cycles_done + 16'd1;
                end else if (state == ST_H2O && next_state == ST_DONE) begin
                    cycles_done <= num_cycles;
                end
            end else if (tick_1ms) begin
                ms_cnt <= ms_cnt + 16'd1;
            end
        end
    end

    // Lógica combinacional de transición de estados
    always @(*) begin
        next_state = state;

        if (fault_active) begin
            next_state = ST_FAULT;
        end else begin
            case (state)
                ST_IDLE: begin
                    if (start && (num_cycles > 16'd0))
                        next_state = ST_P1;
                end

                ST_P1: begin
                    if (pause)
                        next_state = ST_PAUSE;
                    else if (ms_cnt >= t_purge1_ms)
                        next_state = ST_TMA;
                end

                ST_TMA: begin
                    if (pause)
                        next_state = ST_PAUSE;
                    else if (ms_cnt >= t_tma_ms)
                        next_state = ST_P2;
                end

                ST_P2: begin
                    if (pause)
                        next_state = ST_PAUSE;
                    else if (ms_cnt >= t_purge2_ms)
                        next_state = ST_H2O;
                end

                ST_H2O: begin
                    if (pause)
                        next_state = ST_PAUSE;
                    else if (ms_cnt >= t_h2o_ms) begin
                        if ((cycles_done + 16'd1) >= num_cycles)
                            next_state = ST_DONE;
                        else
                            next_state = ST_P1;
                    end
                end

                ST_PAUSE: begin
                    if (!pause)
                        next_state = return_state;
                end

                ST_FAULT: begin
                    if (!start)
                        next_state = ST_IDLE;
                end

                ST_DONE: begin
                    if (!start)
                        next_state = ST_IDLE;
                end

                default: next_state = ST_IDLE;
            endcase
        end
    end

    // Salidas solicitadas y telemetría
    always @(*) begin
        v1_req     = 1'b0;
        v2_req     = 1'b0;
        v3_req     = 1'b0;
        v4_req     = 1'b0;
        done_led   = 1'b0;
        state_id   = state;
        step_num   = 3'd0;
        cycles_rem = (num_cycles > cycles_done) ? (num_cycles - cycles_done) : 16'd0;

        case (state)
            ST_P1: begin
                step_num = 3'd1;
                v1_req   = 1'b1;
                v3_req   = 1'b1;
            end
            ST_TMA: begin
                step_num = 3'd2;
                v1_req   = 1'b1;
                v3_req   = 1'b1;
                v4_req   = 1'b1;
            end
            ST_P2: begin
                step_num = 3'd3;
                v1_req   = 1'b1;
                v3_req   = 1'b1;
            end
            ST_H2O: begin
                step_num = 3'd4;
                v1_req   = 1'b1;
                v3_req   = 1'b1;
                v2_req   = 1'b1;
            end
            ST_PAUSE: begin
                step_num = (return_state == ST_P1)  ? 3'd1 :
                           (return_state == ST_TMA) ? 3'd2 :
                           (return_state == ST_P2)  ? 3'd3 :
                           (return_state == ST_H2O) ? 3'd4 : 3'd0;
            end
            ST_DONE: begin
                done_led   = 1'b1;
                cycles_rem = 16'd0;
            end
            default: ;
        endcase
    end

endmodule