`timescale 1ns / 1ps


module m100_counter(
    input clk,
    input score_inc, score_clear,
    input reset,
    output [3:0] one_digit, ten_digit
    );
    
    // signal declaration
    reg [3:0] one_digit, ten_digit, one_digit_next, ten_digit_next;
    wire  op_score_inc;
    integer  i=0;

    // to make score_inc value read only once each time it is raised to 1
    onepulse op(score_inc, clk, op_score_inc);
    
    // register control
    always @(posedge clk or posedge reset)
        if(reset) begin
            ten_digit <= 0;
            one_digit <= 0;
        end
        else begin
            ten_digit <= ten_digit_next;
            one_digit <= one_digit_next;
        end
    
    // next state logic
    always @(*) begin
        one_digit_next = one_digit;
        ten_digit_next = ten_digit;
        // if score_c
        if(score_clear) begin
            one_digit_next <= 0;
            ten_digit_next <= 0;
        end
        //if one_pulse score increment signal equals to one, increment the score by 1
        else if(op_score_inc)
        begin
            if(one_digit == 9) begin

                one_digit_next = 0;
                
                if(ten_digit == 9)ten_digit_next = 0;
                else ten_digit_next = ten_digit + 1;

            end
            else    // one_digit != 9
                one_digit_next = one_digit + 1;
        end
    end
    
endmodule



module onepulse(debounced, clk, one_pulse);
input debounced, clk;
output reg one_pulse;
reg debounced_delay;

always @(posedge clk) begin
    one_pulse <= debounced & (!debounced_delay);
    debounced_delay <= debounced;
end
endmodule