`timescale 1ns / 1ps


module pong_top(
    input clk,              // 100MHz
    input reset,            // btnR
    input [1:0] btn,
    input infinite_mode,
    input hard_mode,        // btnD, btnU
    output hsync,           // to VGA Connector
    output vsync,           // to VGA Connector
    output [11:0] rgb,      // to DAC, to VGA Connector
    output led,
    output reg [6:0] display,
    output reg [3:0] an
    );
    
    // state declarations for 4 states
    parameter newgame = 2'b00;
    parameter play    = 2'b01;
    parameter newball = 2'b10;
    parameter over    = 2'b11;
           
        
    // signal declaration
    reg [1:0] state_reg, state_next;
    wire screen_x, screen_y;
    wire screen_video_on, screen_tick, graph_on, hit, miss;
    wire [3:0] text_on;
    wire [11:0] graph_rgb, text_rgb;
    reg [11:0] rgb_reg, rgb_next;
    wire [3:0] one_digit, ten_digit;// for example, number 13, one_digit:3,ten_digit:1
    reg graph_wait, score_inc, score_clear, timer_start;
    wire timer_tick, timer_up;
    reg [1:0] ball_reg, ball_next;
    
    
    // Module Instantiations
    //processing vga functions
    vga_controller vga_unit(
        .clk_100MHz(clk),
        .reset(reset),
        .video_on(screen_video_on),
        .hsync(hsync),
        .vsync(vsync),
        .p_tick(screen_tick),
        .x(screen_x),
        .y(screen_y));
    
    //processing text-related functions
    pong_text text_unit(
        .clk(clk),
        .x(screen_x),
        .y(screen_y),
        .one_digit(one_digit),
        .ten_digit(ten_digit),
        .ball(ball_reg),
        .text_on(text_on),
        .text_rgb(text_rgb));
        
    pong_graph graph_unit(
        .clk(clk),
        .reset(reset),
        .btn(btn),
        .graph_wait(graph_wait),
        .video_on(screen_video_on),
        .x(screen_x),
        .y(screen_y),
        .state(state_reg),      // state
        .hit(hit),
        .miss(miss),
        .graph_on(graph_on),
        .graph_rgb(graph_rgb),
        .infinite_mode(infinite_mode),
        .hard_mode(hard_mode));
    
    
    //processing timing related functions
    timer timer_unit(
        .clk(clk),
        .reset(reset),
        .timer_tick(timer_tick),
        .timer_start(timer_start),
        .timer_up(timer_up));
    
    //counting score
    m100_counter counter_unit(
        .clk(clk),
        .reset(reset),
        .score_inc(score_inc),
        .score_clear(score_clear),
        .one_digit(one_digit),
        .ten_digit(ten_digit));
       
    //  when screen is refreshed(60 Hz tick)
    assign timer_tick = (screen_x == 0) && (screen_y == 0);

    // FSM state and registers(sequential circuit)
    always @(posedge clk or posedge reset)
        if(reset) begin
            state_reg <= newgame;
            ball_reg <= 0;
            rgb_reg <= 0;
        end
        else begin
            if(screen_tick)rgb_reg <= rgb_next;//next rgb should be entered to show updated scene
            state_reg <= state_next;
            ball_reg <= ball_next;
        end
    
    // FSM next state logic(combinational circuit)
    always @(*) begin

        //default value for every signal to prevent error

        graph_wait = 1'b1;
        timer_start = 1'b0;
        score_inc = 1'b0;
        score_clear = 1'b0;
        state_next = state_reg;
        ball_next = ball_reg;
        
        case(state_reg)
            newgame: begin
                ball_next = 2'b11;       // three balls
                score_clear = 1'b1;        // clear score
                
                if(btn != 2'b0) begin      // button pressed
                    state_next = play;
                    ball_next = ball_reg - 1;    
                end
            end
            
            play: begin
                graph_wait = 1'b0;   // waiting until the ball was launched
                
                if(hit)score_inc = 1'b1;   // increment score
                
                else if(miss) begin
                    if(ball_reg == 0)state_next = over;//no ball
                    else state_next = newball;
                    
                    timer_start = 1'b1;     // 2 sec timer
                    ball_next = ball_reg - 1;
                
                end
            end
            
            newball: 
            begin
                if(timer_up && (btn != 2'b0))state_next = play;// wait for 2 sec and until button pressed
            end 

            over:   
            begin// wait 2 sec to display game over
                if(timer_up)state_next = newgame;
            end
                
        endcase           
    end
    
    // rgb multiplexing
    always @(*)
        if(~screen_video_on)
            rgb_next = 12'h000; // blank
        
        else
            // colors in graph_text 
            if(graph_on)
                rgb_next = graph_rgb; 

            // colors in pong_text,the rule text will only be displayed in the new game state , "game over" will only be displayed in over state
            else if(text_on[3] || ((state_reg == newgame) && text_on[1]) || ((state_reg == over) && text_on[0]))
                rgb_next = text_rgb;    
                
            else if(text_on[2])
                rgb_next = text_rgb; // colors in pong_text
                
            else
                rgb_next = graph_rgb; // gray background    
    
    // output
    assign rgb = rgb_reg;


    // fpga implementation :for debug and displaying score(7 segment)

    integer cnt = 0;
    reg [6:0] DIGIT [15:0];

    always @(posedge clk) begin
        if(cnt == 400000) cnt <= 0;
        else cnt <= cnt + 1;
    end

    always @(*) begin
        case(cnt)
            0: an = 4'b1110;
            100000: an = 4'b1110;
            200000: an = 4'b1101;
            300000: an = 4'b1101;
        endcase
    end
    always @(*) begin
        case(an)
            4'b1110: display = DIGIT[one_digit];
            4'b1101: display = DIGIT[ten_digit];
            default: display = display;
        endcase
    end
    always @(*) begin
        DIGIT[4'd0] = 7'b100_0000;
        DIGIT[4'd1] = 7'b111_1001;
        DIGIT[4'd2] = 7'b010_0100;
        DIGIT[4'd3] = 7'b011_0000;
        DIGIT[4'd4] = 7'b001_1001;
        DIGIT[4'd5] = 7'b001_0010;
        DIGIT[4'd6] = 7'b000_0010;
        DIGIT[4'd7] = 7'b111_1000;
        DIGIT[4'd8] = 7'b000_0000;
        DIGIT[4'd9] = 7'b001_0000;
        DIGIT[4'd10] = 7'b000_1000;
        DIGIT[4'd11] = 7'b000_0011;
        DIGIT[4'd12] = 7'b100_0110;
        DIGIT[4'd13] = 7'b010_0001;
        DIGIT[4'd14] = 7'b000_0110;
        DIGIT[4'd15] = 7'b000_1110;
    end

    assign led = hit;
    
endmodule


