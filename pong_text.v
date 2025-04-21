`timescale 1ns / 1ps


module pong_text(
    input clk,
    input [1:0] ball,
    input [3:0] one_digit, ten_digit,
    input [9:0] x, y,
    output [3:0] text_on,
    output reg [11:0] text_rgb
    );
    
    // signal declaration

    //..._score: score text, ..._pong: PONG text(middle of the screen), ..._rule: rule text, ..._over: game over text
    wire [3:0] row_addr_score, row_addr_pong, row_addr_rule, row_addr_over;
    reg [6:0] char_addr, char_addr_score, char_addr_pong, char_addr_rule, char_addr_over;
    wire [2:0] bit_addr_score, bit_addr_pong, bit_addr_rule, bit_addr_over;
    wire [10:0] rom_addr;
    reg [3:0] row_addr;
    reg [2:0] bit_addr;
    wire [7:0] ascii_word;
    wire ascii_bit, score_on, PONG_on, rule_on, over_on;
    wire [7:0] rule_rom_addr;

    //instantiate ascii rom
    ascii_rom ascii_unit(.clk(clk), .addr(rom_addr), .data(ascii_word));
   
    //handling PONG

    assign PONG_on = (y[9:7] == 2) && (3 <= x[9:6]) && (x[9:6] <= 6);
    assign row_addr_pong = y[6:3];//16 row
    assign bit_addr_pong = x[5:3];//8 bit

    always @(*)begin

        case(x[8:6])
            3'o3 :    char_addr_pong = 7'h50; // P
            3'o4 :    char_addr_pong = 7'h4F; // O
            3'o5 :    char_addr_pong = 7'h4E; // N
            default : char_addr_pong = 7'h47; // G
        endcase
    end

    //handling score

    assign score_on = (y >= 32) && (y < 64) && (x[9:0] >= 48) && (x[9:0] < 255 + 48);//region of score

    assign row_addr_score = y[4:1];
    assign bit_addr_score = x[3:1];

    always @(*)
    begin
        case(x[9:0] - 10'd32)// starting from 32(x coordinate)
            (10'd16 * 1): char_addr_score = 7'h53;     // S
            (10'd16 * 2): char_addr_score = 7'h43;     // C
            (10'd16 * 3): char_addr_score = 7'h4F;     // O
            (10'd16 * 4): char_addr_score = 7'h52;     // R
            (10'd16 * 5): char_addr_score = 7'h45;     // E
            (10'd16 * 6): char_addr_score = 7'h3A;     // :
            (10'd16 * 7): char_addr_score = {3'b011, ten_digit};    // tens digit
            (10'd16 * 8): char_addr_score = {3'b011, one_digit};    // ones digit
            (10'd16 * 9): char_addr_score = 7'h00;     //
            (10'd16 * 10): char_addr_score = 7'h00;    //
            (10'd16 * 11): char_addr_score = 7'h42;    // B
            (10'd16 * 12): char_addr_score = 7'h41;    // A
            (10'd16 * 13): char_addr_score = 7'h4c;    // L
            (10'd16 * 14): char_addr_score = 7'h4c;    // L
            (10'd16 * 15): char_addr_score = 7'h3A;    // :
            (10'd16 * 16): char_addr_score = {5'b01100, ball};
        endcase
    end
    
    // handling rule(4x16)
    assign rule_on = (x[9:7] == 2) && (y[9:6] == 2);//rule region

    assign row_addr_rule = y[3:0];
    assign bit_addr_rule = x[2:0];
    assign rule_rom_addr = {y[5:4], x[6:3]};

    always @(*)begin
        case(rule_rom_addr)
            // row 1
            6'h00 : char_addr_rule = 7'h52;    // R
            6'h01 : char_addr_rule = 7'h55;    // U
            6'h02 : char_addr_rule = 7'h4c;    // L
            6'h03 : char_addr_rule = 7'h45;    // E
            6'h04 : char_addr_rule = 7'h3A;    // :
            6'h05 : char_addr_rule = 7'h00;    //
            6'h06 : char_addr_rule = 7'h00;    //
            6'h07 : char_addr_rule = 7'h00;    //
            6'h08 : char_addr_rule = 7'h00;    //
            6'h09 : char_addr_rule = 7'h00;    //
            6'h0A : char_addr_rule = 7'h00;    //
            6'h0B : char_addr_rule = 7'h00;    //
            6'h0C : char_addr_rule = 7'h00;    //
            6'h0D : char_addr_rule = 7'h00;    //
            6'h0E : char_addr_rule = 7'h00;    //
            6'h0F : char_addr_rule = 7'h00;    //
            // row 2
            6'h10 : char_addr_rule = 7'h55;    // U
            6'h11 : char_addr_rule = 7'h53;    // S
            6'h12 : char_addr_rule = 7'h45;    // E
            6'h13 : char_addr_rule = 7'h00;    // 
            6'h14 : char_addr_rule = 7'h54;    // T
            6'h15 : char_addr_rule = 7'h57;    // W
            6'h16 : char_addr_rule = 7'h4F;    // O
            6'h17 : char_addr_rule = 7'h00;    //
            6'h18 : char_addr_rule = 7'h42;    // B
            6'h19 : char_addr_rule = 7'h55;    // U
            6'h1A : char_addr_rule = 7'h54;    // T
            6'h1B : char_addr_rule = 7'h54;    // T
            6'h1C : char_addr_rule = 7'h4F;    // O
            6'h1D : char_addr_rule = 7'h4E;    // N
            6'h1E : char_addr_rule = 7'h53;    // S
            6'h1F : char_addr_rule = 7'h00;    //
            // row 3
            6'h20 : char_addr_rule = 7'h54;    // T
            6'h21 : char_addr_rule = 7'h4F;    // O
            6'h22 : char_addr_rule = 7'h00;    // 
            6'h23 : char_addr_rule = 7'h4D;    // M
            6'h24 : char_addr_rule = 7'h4F;    // O
            6'h25 : char_addr_rule = 7'h56;    // V
            6'h26 : char_addr_rule = 7'h45;    // E
            6'h27 : char_addr_rule = 7'h00;    //
            6'h28 : char_addr_rule = 7'h50;    // P
            6'h29 : char_addr_rule = 7'h41;    // A
            6'h2A : char_addr_rule = 7'h44;    // D
            6'h2B : char_addr_rule = 7'h44;    // D
            6'h2C : char_addr_rule = 7'h4C;    // L
            6'h2D : char_addr_rule = 7'h45;    // E
            6'h2E : char_addr_rule = 7'h00;    // 
            6'h2F : char_addr_rule = 7'h00;    //
            // row 4
            6'h30 : char_addr_rule = 7'h55;    // U
            6'h31 : char_addr_rule = 7'h50;    // P
            6'h32 : char_addr_rule = 7'h00;    // 
            6'h33 : char_addr_rule = 7'h41;    // A
            6'h34 : char_addr_rule = 7'h4E;    // N
            6'h35 : char_addr_rule = 7'h44;    // D
            6'h36 : char_addr_rule = 7'h00;    // 
            6'h37 : char_addr_rule = 7'h44;    // D
            6'h38 : char_addr_rule = 7'h4F;    // O
            6'h39 : char_addr_rule = 7'h57;    // W
            6'h3A : char_addr_rule = 7'h4E;    // N
            6'h3B : char_addr_rule = 7'h2E;    // 
            6'h3C : char_addr_rule = 7'h00;    // 
            6'h3D : char_addr_rule = 7'h00;    // 
            6'h3E : char_addr_rule = 7'h00;    // 
            6'h3F : char_addr_rule = 7'h00;    //
        endcase
    end

    // handling game over
    assign row_addr_over = y[5:2];
    // - scale to 32 by 64 text size

    assign over_on = (y[9:6] == 3) && (5 <= x[9:5]) && (x[9:5] <= 13);// game over region

    assign bit_addr_over = x[4:2];

    always @(*)begin

        case(x[8:5])
            4'h5 : char_addr_over = 7'h47;     // G
            4'h6 : char_addr_over = 7'h41;     // A
            4'h7 : char_addr_over = 7'h4D;     // M
            4'h8 : char_addr_over = 7'h45;     // E
            4'h9 : char_addr_over = 7'h00;     //
            4'hA : char_addr_over = 7'h4F;     // O
            4'hB : char_addr_over = 7'h56;     // V
            4'hC : char_addr_over = 7'h45;     // E
            default : char_addr_over = 7'h52;  // R
        endcase
    
    end

    // mux for ascii ROM addresses and rgb
    always @(*) begin
        text_rgb = 12'h111;     // background
        
        if(score_on) begin
            char_addr = char_addr_score;
            row_addr = row_addr_score;
            bit_addr = bit_addr_score;
            if(ascii_bit)
                text_rgb = 12'h0DD;
        end
        
        else if(rule_on) begin
            char_addr = char_addr_rule;
            row_addr = row_addr_rule;
            bit_addr = bit_addr_rule;
            if(ascii_bit)
                text_rgb = 12'h0DD;
        end
        
        else if(PONG_on) begin
            char_addr = char_addr_pong;
            row_addr = row_addr_pong;
            bit_addr = bit_addr_pong;
            if(ascii_bit)
                text_rgb = 12'h055;
        end
            
        else begin // game over
            char_addr = char_addr_over;
            row_addr = row_addr_over;
            bit_addr = bit_addr_over;
            if(ascii_bit)
                text_rgb = 12'h0DD;
        end        
    end

    //combining four signal into a bus 
    assign text_on = {score_on, PONG_on, rule_on, over_on};
    
    // ascii ROM interface
    assign rom_addr = {char_addr, row_addr};
    assign ascii_bit = ascii_word[~bit_addr];
      
endmodule
