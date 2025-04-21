`timescale 1ns / 1ps

module timer(
    input timer_start, timer_tick,
    input reset,
    input clk,
    output timer_up
    );
    //declare reg
    reg [7:0] timer,timer_next;
    
    //sequential block
    always @(posedge reset or posedge clk)begin
        if(reset)timer<=8'b10110100;
        else timer<=timer_next;
    end
    
    //combinational block
    always @(*)begin
        if(timer_start)timer_next=8'b10110100;
        //  (1/60)s per tick, so 180*(1/60) is approximately equal to 3 sec
        else if((timer_tick)&&(timer!=0))timer_next=timer-1;
        else timer_next=timer;//timer==0 or timer_tick==0
    end
            
    // output
    assign timer_up = (timer == 0);
    
endmodule
