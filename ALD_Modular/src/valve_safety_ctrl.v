//-----------------------------------------------------------------------------
//
// Title       : \valve_safety_ctrl\ 
// Design      : ALD_Modular
// Author      : a210200969@unison.mx
// Company     : UNISON
//
//-----------------------------------------------------------------------------
//
// File        : c:/My_Designs/ALD_Modular/ALD_Modular/src/valve_safety_ctrl.v
// Generated   : Sun Nov 22 15:12:21 2026
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1ns/1ps

module valve_safety_ctrl (
    input  wire v1_req,
    input  wire v2_req,       // Agua
    input  wire v3_req,
    input  wire v4_req,       // TMA
    input  wire fault_active,
    output reg  v1_out,
    output reg  v2_out,
    output reg  v3_out,
    output reg  v4_out,
    output reg  interlock_err
);

    always @(*) begin
        v1_out        = 1'b0;
        v2_out        = 1'b0;
        v3_out        = 1'b0;
        v4_out        = 1'b0;
        interlock_err = 1'b0;

        if (v2_req && v4_req) begin
            // Condición inválida: V2 y V4 activas simultáneamente
            interlock_err = 1'b1;
        end else if (!fault_active) begin
            v1_out = v1_req;
            v2_out = v2_req;
            v3_out = v3_req;
            v4_out = v4_req;
        end
    end

endmodule