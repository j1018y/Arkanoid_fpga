`timescale 1ns / 1ps


module pong_graph(
    input [9:0] x,
    input [9:0] y,
    input clk,  
    input reset,    
    input video_on,
    input infinite_mode,
    input graph_wait,        // still graphics - newgame, game over states
    input hard_mode,
    input [1:0] btn,        // btn[0] = up, btn[1] = down
    input [1:0] state,
    output graph_on,
    output reg hit, miss,   // ball hit or miss
    output reg [11:0] graph_rgb
    );

    // state declarations for 4 states
    parameter newgame = 2'b00;
    parameter play    = 2'b01;
    parameter newball = 2'b10;
    parameter over    = 2'b11;
    
    // maximum x, y values in display area
    parameter X_MAX = 639;
    parameter Y_MAX = 479;
    
    // create 60Hz refresh tick
    wire refresh_tick;
    assign refresh_tick = ((y == 481) && (x == 0)) ? 1 : 0; // start of vsync(vertical retrace)
    
    
    // WALLS
    // LEFT wall boundaries
    parameter L_WALL_L = 32;    
    parameter L_WALL_R = 39;    // 8 pixels wide
    // TOP wall boundaries
    parameter T_WALL_T = 64;    
    parameter T_WALL_B = 71;    // 8 pixels wide
    // BOTTOM wall boundaries
    parameter B_WALL_T = 472;    
    parameter B_WALL_B = 479;    // 8 pixels wide


    // BLOCKS
    parameter BLOCK_SIZE = 40;
    parameter BLOCK_COLOR_1 = 12'h500;
    parameter BLOCK_COLOR_2 = 12'hC00;
    reg [9:0] block_exist_1 = 10'b1111111111;// assume all of them exist initially
    reg [9:0] block_exist_2 = 10'b1111111111;
    reg [9:0] block_next_exist_1, block_next_exist_2;
    reg [1:0] block_type; // 0 for not exist, 1 for 1, 2 for 2

    // block type
    always @(*) begin
        //left column block
        if(40 <= x && x < 40 + BLOCK_SIZE * 1) begin
            if(72 <= y && y < 72 + BLOCK_SIZE * 1) begin
                if(block_exist_1[0]) block_type = 2'b01;// first type of block
                else block_type = 2'b00;
            end
            else if(72 + BLOCK_SIZE * 1 <= y && y < 72 + BLOCK_SIZE * 2) begin
                if(block_exist_1[1]) block_type = 2'b10;//second type of block
                else block_type = 2'b00;
            end
            else if(72 + BLOCK_SIZE * 2 <= y && y < 72 + BLOCK_SIZE * 3) begin
                if(block_exist_1[2]) block_type = 2'b01;
                else block_type = 2'b00;
            end
            else if(72 + BLOCK_SIZE * 3 <= y && y < 72 + BLOCK_SIZE * 4) begin
                if(block_exist_1[3]) block_type = 2'b10;
                else block_type = 2'b00;
            end
            else if(72 + BLOCK_SIZE * 4 <= y && y < 72 + BLOCK_SIZE * 5) begin
                if(block_exist_1[4]) block_type = 2'b01;
                else block_type = 2'b00;
            end
            else if(72 + BLOCK_SIZE * 5 <= y && y < 72 + BLOCK_SIZE * 6) begin
                if(block_exist_1[5]) block_type = 2'b10;
                else block_type = 2'b00;
            end
            else if(72 + BLOCK_SIZE * 6 <= y && y < 72 + BLOCK_SIZE * 7) begin
                if(block_exist_1[6]) block_type = 2'b01;
                else block_type = 2'b00;
            end
            else if(72 + BLOCK_SIZE * 7 <= y && y < 72 + BLOCK_SIZE * 8) begin
                if(block_exist_1[7]) block_type = 2'b10;
                else block_type = 2'b00;
            end
            else if(72 + BLOCK_SIZE * 8 <= y && y < 72 + BLOCK_SIZE * 9) begin
                if(block_exist_1[8]) block_type = 2'b01;
                else block_type = 2'b00;
            end
            else if(72 + BLOCK_SIZE * 9 <= y && y < 72 + BLOCK_SIZE * 10) begin
                if(block_exist_1[9]) block_type = 2'b10;
                else block_type = 2'b00;
            end
        end
        //right column block
        else if(40 + BLOCK_SIZE <= x && x < 40 + BLOCK_SIZE * 2) begin
            if(72 <= y && y < 72 + BLOCK_SIZE * 1) begin
                if(block_exist_2[0]) block_type = 2'b10;
                else block_type = 2'b00;
            end
            else if(72 + BLOCK_SIZE * 1 <= y && y < 72 + BLOCK_SIZE * 2) begin
                if(block_exist_2[1]) block_type = 2'b01;
                else block_type = 2'b00;
            end
            else if(72 + BLOCK_SIZE * 2 <= y && y < 72 + BLOCK_SIZE * 3) begin
                if(block_exist_2[2]) block_type = 2'b10;
                else block_type = 2'b00;
            end
            else if(72 + BLOCK_SIZE * 3 <= y && y < 72 + BLOCK_SIZE * 4) begin
                if(block_exist_2[3]) block_type = 2'b01;
                else block_type = 2'b00;
            end
            else if(72 + BLOCK_SIZE * 4 <= y && y < 72 + BLOCK_SIZE * 5) begin
                if(block_exist_2[4]) block_type = 2'b10;
                else block_type = 2'b00;
            end
            else if(72 + BLOCK_SIZE * 5 <= y && y < 72 + BLOCK_SIZE * 6) begin
                if(block_exist_2[5]) block_type = 2'b01;
                else block_type = 2'b00;
            end
            else if(72 + BLOCK_SIZE * 6 <= y && y < 72 + BLOCK_SIZE * 7) begin
                if(block_exist_2[6]) block_type = 2'b10;
                else block_type = 2'b00;
            end
            else if(72 + BLOCK_SIZE * 7 <= y && y < 72 + BLOCK_SIZE * 8) begin
                if(block_exist_2[7]) block_type = 2'b01;
                else block_type = 2'b00;
            end
            else if(72 + BLOCK_SIZE * 8 <= y && y < 72 + BLOCK_SIZE * 9) begin
                if(block_exist_2[8]) block_type = 2'b10;
                else block_type = 2'b00;
            end
            else if(72 + BLOCK_SIZE * 9 <= y && y < 72 + BLOCK_SIZE * 10) begin
                if(block_exist_2[9]) block_type = 2'b01;
                else block_type = 2'b00;
            end
        end
    end
    
    
    // PADDLE
    // paddle horizontal boundaries
    parameter X_PAD_L = 600;
    parameter X_PAD_R = 603;        // 4 pixels wide
    // paddle vertical boundary signals
    wire [9:0] y_pad_t, y_pad_b;
    wire [10:0] PAD_HEIGHT = (infinite_mode)?480:72;      // 72 pixels high
    // register to track top boundary and buffer
    reg [9:0] y_pad_reg = (infinite_mode)?72:204;      // Paddle starting position
    reg [9:0] y_pad_next;
    // paddle moving velocity when a button is pressed
    parameter PAD_VELOCITY = 3;     // change to speed up or slow down paddle movement


    // AUTO PADDLE
    parameter AUTO_X_PAD_L = 340;
    parameter AUTO_X_PAD_R = 343;
    wire [9:0] auto_y_pad_t, auto_y_pad_b;
    parameter AUTO_PAD_HEIGHT = 100;
    reg [9:0] auto_y_pad_reg = 204;
    wire [9:0] auto_y_pad_next;
    reg [9:0] auto_pad_delta_reg = 1, auto_pad_delta_next = 1;
    parameter PAD_VELOCITY_POS = 1;
    parameter PAD_VELOCITY_NEG = -1;
    reg[31:0] cnt = 0;
    wire auto_paddle_tick;

    always @(posedge clk) begin
        if(reset) cnt <= 32'd0;
        else if(cnt >= 32'd500000 - 32'd1) cnt <= 32'd0;
        else cnt <= cnt + 32'd1;
    end
    
    assign auto_paddle_tick = (cnt == 32'd0) ? 1'b1 : 1'b0;

    
    // BALL
    // square rom boundaries
    parameter BALL_SIZE = 8;
    // ball horizontal boundary signals(l:keft, r:right)
    wire [9:0] x_ball_l, x_ball_r;
    // ball vertical boundary signals(t:top, b:bottom)
    wire [9:0] y_ball_t, y_ball_b;
    // register to track top left position
    reg [9:0] y_ball_reg, x_ball_reg;
    // signals for register buffer
    wire [9:0] y_ball_next, x_ball_next;
    // registers to track ball speed and buffers
    reg [9:0] x_delta_reg, x_delta_next;
    reg [9:0] y_delta_reg, y_delta_next;
    // positive or negative ball velocity
    reg[3:0] BALL_VELOCITY_POS = hard_mode?2:1;    // ball speed positive pixel direction(down, right)
    reg[3:0] BALL_VELOCITY_NEG = hard_mode?-2:-1;   // ball speed negative pixel direction(up, left)
    // round ball from square image
    wire [2:0] rom_addr, rom_col;   // 3-bit rom address and rom column
    reg [7:0] rom_data;             // data at current rom address
    wire rom_bit;                   // signify when rom data is 1 or 0 for ball rgb control
    
    
    // Register Control
    always @(posedge clk or posedge reset)
        if(reset) begin
            y_pad_reg <= 204;
            auto_y_pad_reg <= 204;
            x_ball_reg <= 0;
            y_ball_reg <= 0;
            x_delta_reg <= BALL_VELOCITY_NEG;
            y_delta_reg <= BALL_VELOCITY_POS;
            auto_pad_delta_reg <= PAD_VELOCITY_POS;
            block_exist_1[9:0] <= 10'b1111111111;
            block_exist_2[9:0] <= 10'b1111111111;
        end
        else begin
            y_pad_reg <= y_pad_next;
            auto_y_pad_reg <= auto_y_pad_next;
            x_ball_reg <= x_ball_next;
            y_ball_reg <= y_ball_next;
            x_delta_reg <= x_delta_next;
            y_delta_reg <= y_delta_next;
            auto_pad_delta_reg <= auto_pad_delta_next;
            block_exist_1 <= block_next_exist_1;
            block_exist_2 <= block_next_exist_2;
        end
    
    
    // ball rom
    always @(*)
        case(rom_addr)
            3'b000 :    rom_data = 8'b00111100; //   ****  
            3'b001 :    rom_data = 8'b01111110; //  ******
            3'b010 :    rom_data = 8'b11111111; // ********
            3'b011 :    rom_data = 8'b11111111; // ********
            3'b100 :    rom_data = 8'b11111111; // ********
            3'b101 :    rom_data = 8'b11111111; // ********
            3'b110 :    rom_data = 8'b01111110; //  ******
            3'b111 :    rom_data = 8'b00111100; //   ****
        endcase
    
    
    // object region detection signal
    wire l_wall_on, t_wall_on, b_wall_on, pad_on, sq_ball_on, ball_on, block_on, auto_pad_on;
    //object color in detail
    wire [11:0] wall_rgb, pad_rgb, ball_rgb, bg_rgb, block_rgb, autopad_rgb;
    
    
    // pixel within wall boundaries
    assign l_wall_on = ((L_WALL_L <= x) && (x <= L_WALL_R)) ? 1 : 0;
    assign t_wall_on = ((T_WALL_T <= y) && (y <= T_WALL_B)) ? 1 : 0;
    assign b_wall_on = ((B_WALL_T <= y) && (y <= B_WALL_B)) ? 1 : 0;

    // pixel within block boundaries
    assign block_on = ((x >= 10'd40 && x < 10'd120) && (y >= 10'd72 && y < 10'd472)) ? 1 : 0;
    
    
    // assign object colors
    assign wall_rgb   = 12'hAAA;    // walls
    assign pad_rgb    = 12'hAAA;    // paddle
    assign ball_rgb   = 12'hFFF;    // ball
    assign bg_rgb     = 12'h111;    // background
    assign block_rgb = (block_type == 2'b00) ? 12'h111 : (block_type == 2'b01) ? BLOCK_COLOR_1 : BLOCK_COLOR_2;
    assign autopad_rgb = 12'hAAA;

    
    
    // paddle 
    assign y_pad_t = y_pad_reg;                             // paddle top position
    assign y_pad_b = y_pad_t + PAD_HEIGHT - 1;              // paddle bottom position
    assign pad_on = (X_PAD_L <= x) && (x <= X_PAD_R) &&     // pixel within paddle boundaries
                    (y_pad_t <= y) && (y <= y_pad_b);
    
    assign auto_y_pad_t = auto_y_pad_reg;
    assign auto_y_pad_b = auto_y_pad_t + AUTO_PAD_HEIGHT - 1;
    assign auto_pad_on = (AUTO_X_PAD_L <= x) && (x <= AUTO_X_PAD_R) &&     // pixel within paddle boundaries
                    (auto_y_pad_t <= y) && (y <= auto_y_pad_b);
                    
    // Paddle Control
    always @(*) begin
        y_pad_next = y_pad_reg;     // no move
        
        if(refresh_tick) begin
            if(btn[1] & (y_pad_b < (B_WALL_T - 1 - PAD_VELOCITY)))
                y_pad_next = y_pad_reg + PAD_VELOCITY;  // move down
            else if(btn[0] & (y_pad_t > (T_WALL_B - 1 - PAD_VELOCITY)))
                y_pad_next = y_pad_reg - PAD_VELOCITY;  // move up

        end
    end
    
    // Auto Paddle Control
    assign auto_y_pad_next = (refresh_tick) ? auto_y_pad_reg + auto_pad_delta_reg : auto_y_pad_reg;

    always @(*) begin
        auto_pad_delta_next = auto_pad_delta_reg;
        if(auto_y_pad_b > B_WALL_T) auto_pad_delta_next = PAD_VELOCITY_NEG;
        else if(auto_y_pad_t < T_WALL_B) auto_pad_delta_next = PAD_VELOCITY_POS;
    end
    
    // rom data square boundaries
    assign x_ball_l = x_ball_reg;
    assign y_ball_t = y_ball_reg;
    assign x_ball_r = x_ball_l + BALL_SIZE - 1;
    assign y_ball_b = y_ball_t + BALL_SIZE - 1;
    // pixel within rom square boundaries
    assign sq_ball_on = (x_ball_l <= x) && (x <= x_ball_r) &&
                        (y_ball_t <= y) && (y <= y_ball_b);
    // map current pixel location to rom addr/col
    assign rom_addr = y[2:0] - y_ball_t[2:0];   // 3-bit address
    assign rom_col = x[2:0] - x_ball_l[2:0];    // 3-bit column index
    assign rom_bit = rom_data[rom_col];         // 1-bit signal rom data by column
    // pixel within round ball
    assign ball_on = sq_ball_on & rom_bit;      // within square boundaries AND rom data bit == 1
 
  
    // new ball position
    assign x_ball_next = (graph_wait) ? X_MAX / 2 :
                         (refresh_tick) ? x_ball_reg + x_delta_reg : x_ball_reg;
    assign y_ball_next = (graph_wait) ? Y_MAX / 2 :
                         (refresh_tick) ? y_ball_reg + y_delta_reg : y_ball_reg;
    
    // change ball direction after collision

    integer i=0;

    always @(*) begin
        hit = 1'b0;
        miss = 1'b0;
        x_delta_next = x_delta_reg;
        y_delta_next = y_delta_reg;
        
        block_next_exist_1 = block_exist_1;
        block_next_exist_2 = block_exist_2;

        if(state == newgame || state == over) begin
            block_next_exist_1 = 10'b1111111111;
            block_next_exist_2 = 10'b1111111111;
        end

        if(graph_wait) begin
            x_delta_next = BALL_VELOCITY_NEG;
            y_delta_next = BALL_VELOCITY_POS;
        end
        
        else if(y_ball_t < T_WALL_B)            // reach top
            y_delta_next = BALL_VELOCITY_POS;   // move down
        
        else if(y_ball_b > (B_WALL_T))         // reach bottom wall
            y_delta_next = BALL_VELOCITY_NEG;   // move up
        
        else if(x_ball_l <= L_WALL_R)           // reach left wall
            x_delta_next = BALL_VELOCITY_POS;   // move right
        
        else if((X_PAD_L <= x_ball_r) && (x_ball_r <= X_PAD_R) &&
                (y_pad_t <= y_ball_b) && (y_ball_t <= y_pad_b)) begin
                    x_delta_next = BALL_VELOCITY_NEG;
                    hit = 1'b1;     
        end

        else if((AUTO_X_PAD_L <= x_ball_r) && (x_ball_r <= AUTO_X_PAD_R) &&
            (auto_y_pad_t <= y_ball_b) && (y_ball_t <= auto_y_pad_b)) begin
                x_delta_next = BALL_VELOCITY_NEG;     
        end

        else if((AUTO_X_PAD_L <= x_ball_l) && (x_ball_l <= AUTO_X_PAD_R) &&
            (auto_y_pad_t <= y_ball_b) && (y_ball_t <= auto_y_pad_b)) begin
                x_delta_next = BALL_VELOCITY_POS;     
        end

        else if(x_ball_r > X_MAX)
            miss = 1'b1;
        
        // collide with blocks (front)
        else if(x_ball_l < 40+BLOCK_SIZE*2 && x_ball_l > 40+BLOCK_SIZE*1 && (x_ball_l+x_ball_r)/2 > 40+BLOCK_SIZE*2) begin
            for(i=0; i<10; i=i+1) begin
                if((72+BLOCK_SIZE*i <= (y_ball_t+y_ball_b)/2 && (y_ball_t+y_ball_b)/2 < 72+BLOCK_SIZE*(i+1)) && block_exist_2[i]) begin
                    x_delta_next = BALL_VELOCITY_POS;
                    block_next_exist_2[i] = 0;//block is destroyed
                    hit = 1'b1;//to increment point
                end
            end
        end
        else if(x_ball_l < 40+BLOCK_SIZE*1 && x_ball_l > 40 && (x_ball_l+x_ball_r)/2 > 40+BLOCK_SIZE*1) begin
            for(i=0; i<10; i=i+1) begin
                if((72+BLOCK_SIZE*i <= (y_ball_t+y_ball_b)/2 && (y_ball_t+y_ball_b)/2 < 72+BLOCK_SIZE*(i+1)) && block_exist_1[i]) begin
                    x_delta_next = BALL_VELOCITY_POS;
                    block_next_exist_1[i] = 0;
                    hit = 1'b1;
                end
            end
        end

        // collide with blocks (back)
        else if(x_ball_r > 40+BLOCK_SIZE*1 && x_ball_r < 40+BLOCK_SIZE*2 && (x_ball_l+x_ball_r)/2 < 40+BLOCK_SIZE*1) begin
            for(i=0; i<10; i=i+1) begin
                if((72+BLOCK_SIZE*i <= (y_ball_t+y_ball_b)/2 && (y_ball_t+y_ball_b)/2 < 72+BLOCK_SIZE*(i+1)) && block_exist_2[i]) begin
                    x_delta_next = BALL_VELOCITY_NEG;
                    block_next_exist_2[i] = 0;
                    hit = 1'b1;
                end
            end
        end
        else if(x_ball_r > 40 && x_ball_r < 40+BLOCK_SIZE*1 && (x_ball_l+x_ball_r)/2 < 40) begin
            for(i=0; i<10; i=i+1) begin
                if((72+BLOCK_SIZE*i <= (y_ball_t+y_ball_b)/2 && (y_ball_t+y_ball_b)/2 < 72+BLOCK_SIZE*(i+1)) && block_exist_1[i]) begin
                    x_delta_next = BALL_VELOCITY_NEG;
                    block_next_exist_1[i] = 0;
                    hit = 1'b1;
                end
            end
        end

        else begin
            for(i=0; i<10; i=i+1) begin
                // collide with blocks (up)
                if(72+BLOCK_SIZE*i < y_ball_b && y_ball_b < 72+BLOCK_SIZE*(i+1)) begin
                    if((40+BLOCK_SIZE*1 <= (x_ball_l+x_ball_r)/2 && (x_ball_l+x_ball_r)/2 < 40+BLOCK_SIZE*2) && block_exist_2[i]) begin
                        y_delta_next = BALL_VELOCITY_NEG;
                        block_next_exist_2[i] = 0;
                        hit = 1'b1;
                    end
                    else if((40 <= (x_ball_l+x_ball_r)/2 && (x_ball_l+x_ball_r)/2 < 40+BLOCK_SIZE*1) && block_exist_1[i]) begin
                        y_delta_next = BALL_VELOCITY_NEG;
                        block_next_exist_1[i] = 0;
                        hit = 1'b1;
                    end
                end
                // collide with blocks (down)
                else if(72+BLOCK_SIZE*i < y_ball_t && y_ball_t < 72+BLOCK_SIZE*(i+1)) begin
                    if((40+BLOCK_SIZE*1 <= (x_ball_l+x_ball_r)/2 && (x_ball_l+x_ball_r)/2 < 40+BLOCK_SIZE*2) && block_exist_2[i]) begin
                        y_delta_next = BALL_VELOCITY_POS;
                        block_next_exist_2[i] = 0;
                        hit = 1'b1;
                    end
                    else if((40 <= (x_ball_l+x_ball_r)/2 && (x_ball_l+x_ball_r)/2 < 40+BLOCK_SIZE*1) && block_exist_1[i]) begin
                        y_delta_next = BALL_VELOCITY_POS;
                        block_next_exist_1[i] = 0;
                        hit = 1'b1;
                    end
                end
            end
        end
    end                    
    
    // output status signal for graphics 
    assign graph_on = l_wall_on | t_wall_on | b_wall_on | pad_on | ball_on | block_on | auto_pad_on;
    
    
    // rgb multiplexing circuit
    always @(*)
        if(~video_on)
            graph_rgb = 12'h000;      // no value, blank
        else
            if(l_wall_on | t_wall_on | b_wall_on)
                graph_rgb = wall_rgb;     // wall color
            else if(pad_on)
                graph_rgb = pad_rgb;      // paddle color
            else if(ball_on)
                graph_rgb = ball_rgb;     // ball color
            else if(block_on)
                graph_rgb = block_rgb;    // block color
            else if(auto_pad_on)
                graph_rgb = autopad_rgb;  // auto paddle color
            else
                graph_rgb = bg_rgb;       // background
       
endmodule
