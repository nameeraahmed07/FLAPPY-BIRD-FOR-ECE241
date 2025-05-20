module vga_demo(

    CLOCK_50, SW, KEY, VGA_R, VGA_G, VGA_B,

    VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK, LEDR, HEX0, HEX1, HEX2,

  AUD_ADCDAT, AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK,

    FPGA_I2C_SDAT, AUD_XCK, AUD_DACDAT, FPGA_I2C_SCLK

);

    // Pillar Dimensions and Starting Positions

    parameter XDIM1 = 20, YDIM1 = 30;  // Pillar 1 dimensions

    parameter XDIM2 = 20, YDIM2 = 50;  // Pillar 2 dimensions

    parameter XDIM3 = 20, YDIM3 = 50;  // Pillar 3 dimensions

    parameter XDIM4 = 20, YDIM4 = 30;  // Pillar 4 dimensions


    parameter START_X1 = 8'd50, START_Y1 = 7'd0;

    parameter START_X2 = 8'd50, START_Y2 = 7'd70;

    parameter START_X3 = 8'd130, START_Y3 = 7'd0;

    parameter START_X4 = 8'd130, START_Y4 = 7'd90;

 

    input AUD_ADCDAT;

    inout AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK, FPGA_I2C_SDAT;

    output AUD_XCK, AUD_DACDAT, FPGA_I2C_SCLK;

 

  audio audio_inst (

        .CLOCK_50(CLOCK_50),

        .KEY(KEY),

        .AUD_ADCDAT(AUD_ADCDAT),

  .collision_wire(collision_wire),

        .AUD_BCLK(AUD_BCLK),

        .AUD_ADCLRCK(AUD_ADCLRCK),

        .AUD_DACLRCK(AUD_DACLRCK),

        .FPGA_I2C_SDAT(FPGA_I2C_SDAT),

        .AUD_XCK(AUD_XCK),

        .AUD_DACDAT(AUD_DACDAT),

        .FPGA_I2C_SCLK(FPGA_I2C_SCLK)

    );


wire [3:0] ones = score%10;

wire [3:0] tens = (score/10)%10;

wire [3:0] hundreds = (score/100)%10;




 hex_to_7seg one(hundreds, HEX0);
 hex_to_7seg two(tens, HEX1);
 hex_to_7seg three(ones, HEX2);



    localparam GREEN = 3'b010;

    localparam BLACK = 3'b000;

    localparam X_MAX = 160;  // Maximum X-coordinate for wrapping


    input CLOCK_50;

    input [7:0] SW;

    input [3:0] KEY;

    output [7:0] VGA_R;

    output [7:0] VGA_G;

    output [7:0] VGA_B;

    output VGA_HS;

    output VGA_VS;

    output VGA_BLANK_N;

    output VGA_SYNC_N;

    output VGA_CLK;

    output [0:0] LEDR;
	 output [6:0] HEX0, HEX1, HEX2;



    reg [7:0] VGA_X, VGA_Y;

    reg [2:0] VGA_COLOR;

    reg plot;

     

assign LEDR[0] = pass;



    // Pillar position and state variables

    reg [7:0] x_count, y_count;

    reg [23:0] frame_counter;

    reg [7:0] X_pos1, X_pos2, X_pos3, X_pos4;


    // Bird position and FSM state variables

    reg [7:0] X = 20;

    reg [6:0] Y = 60;

    reg [7:0] prev_X = 20;

    reg [6:0] prev_Y = 60;

    reg [23:0] frame_counter1 = 0;

    reg jump_update = 0, frame_update = 0;


    // Object Memory Counters

    wire [2:0] XC, YC;

    wire [2:0] OBJECT_COLOR;


    // State Machine States

    localparam  

        WAIT_FRAME = 4'b0001, ERASE_PILLAR1 = 4'b0010, ERASE_PILLAR2 = 4'b0011,

        ERASE_PILLAR3 = 4'b0100, ERASE_PILLAR4 = 4'b0101, UPDATE_POSITION = 4'b0110,

        PLOT_PILLAR1 = 4'b0111, PLOT_PILLAR2 = 4'b1000, PLOT_PILLAR3 = 4'b1001, 

        PLOT_PILLAR4 = 4'b1010, ERASE_BIRD = 4'b1011, UPDATE_BIRD = 4'b1100, 

        PLOT_BIRD = 4'b1101, RESET_GAME = 4'b1110;


    reg [3:0] state;


    // Initialization

    initial begin

        state = WAIT_FRAME;

        x_count = 0;

        y_count = 0;

        frame_counter = 0;

        X_pos1 = START_X1;

        X_pos2 = START_X2;

        X_pos3 = START_X3;

        X_pos4 = START_X4;

    end


  reg collision;  // Declare collision as a reg



 

always @(posedge CLOCK_50) begin

    // Evaluate collision in states where necessary

    collision <= 

        ((X + 8 > X_pos1 && X < X_pos1 + XDIM1 && Y + 8 > START_Y1 && Y < START_Y1 + YDIM1) ||

         (X + 8 > X_pos2 && X < X_pos2 + XDIM2 && Y + 8 > START_Y2 && Y < START_Y2 + YDIM2) ||

         (X + 8 > X_pos3 && X < X_pos3 + XDIM3 && Y + 8 > START_Y3 && Y < START_Y3 + YDIM3) ||

         (X + 8 > X_pos4 && X < X_pos4 + XDIM4 && Y + 8 > START_Y4 && Y < START_Y4 + YDIM4));


end


// Declare the score register

reg [6:0] score;  // Keeps track of the score (number of passes)


// Pass logic and score increment with collision reset

always @(posedge CLOCK_50) begin

    if (collision) begin

        score <= 0;  // Reset score when a collision occurs

    end else if ((X + 8 == X_pos1) || 

                 (X + 8 == X_pos2) || 

                 (X + 8 == X_pos3) || 

                 (X + 8 == X_pos4)) 

    begin

        score <= score + 1; end // Increment score when a pipe is passed
		  
	else 
	
	    score <= score;

end


// Use `score` wherever necessary




 wire pass;

assign pass = 

    ((X + 8 == X_pos1 && X < X_pos1 + XDIM1) && !(Y + 8 > START_Y1 && Y < START_Y1 + YDIM1)) ||

     (X + 8 == X_pos2 && X < X_pos2 + XDIM2 && !(Y + 8 > START_Y2 && Y < START_Y2 + YDIM2)) ||

     (X + 8 == X_pos3 && X < X_pos3 + XDIM3 && !(Y + 8 > START_Y3 && Y < START_Y3 + YDIM3)) ||

     (X + 8 == X_pos4 && X < X_pos4 + XDIM4 && !(Y + 8 > START_Y4 && Y < START_Y4 + YDIM4));



    // Frame counter for timing updates

    always @(posedge CLOCK_50) begin

      if(collision)begin

          frame_counter1 <= 0;

            frame_update <= 0;end


        if (frame_counter1 == 24'd5000000) begin

            frame_counter1 <= 0;

            frame_update <= 1;

        end else begin

            frame_counter1 <= frame_counter1 + 1;

            frame_update <= 0;

        end

  end

  

  



        


    // Combined FSM

    always @(posedge CLOCK_50) begin

        case (state)


            WAIT_FRAME: begin

                if (frame_counter == 24'd5000000) begin

                    frame_counter <= 0;

                    state <= ERASE_PILLAR1;

                end else begin

                    frame_counter <= frame_counter + 1;

                end

            end


            ERASE_PILLAR1: begin

                VGA_COLOR <= BLACK;

                VGA_X <= X_pos1 + x_count;

                VGA_Y <= START_Y1 + y_count;

                plot <= 1;


                if (x_count < XDIM1 - 1)

                    x_count <= x_count + 1;

                else if (y_count < YDIM1 - 1) begin

                    x_count <= 0;

                    y_count <= y_count + 1;

                end else begin

                    x_count <= 0;

                    y_count <= 0;

                    state <= ERASE_PILLAR2;

                end

            end


            ERASE_PILLAR2: begin

                VGA_COLOR <= BLACK;

                VGA_X <= X_pos2 + x_count;

                VGA_Y <= START_Y2 + y_count;

                plot <= 1;


                if (x_count < XDIM2 - 1)

                    x_count <= x_count + 1;

                else if (y_count < YDIM2 - 1) begin

                    x_count <= 0;

                    y_count <= y_count + 1;

                end else begin

                    x_count <= 0;

                    y_count <= 0;

                    state <= ERASE_PILLAR3;

                end

            end


            ERASE_PILLAR3: begin

                VGA_COLOR <= BLACK;

                VGA_X <= X_pos3 + x_count;

                VGA_Y <= START_Y3 + y_count;

                plot <= 1;


                if (x_count < XDIM3 - 1)

                    x_count <= x_count + 1;

                else if (y_count < YDIM3 - 1) begin

                    x_count <= 0;

                    y_count <= y_count + 1;

                end else begin

                    x_count <= 0;

                    y_count <= 0;

                    state <= ERASE_PILLAR4;

                end

            end


            ERASE_PILLAR4: begin

                VGA_COLOR <= BLACK;

                VGA_X <= X_pos4 + x_count;

                VGA_Y <= START_Y4 + y_count;

                plot <= 1;


                if (x_count < XDIM4 - 1)

                    x_count <= x_count + 1;

                else if (y_count < YDIM4 - 1) begin

                    x_count <= 0;

                    y_count <= y_count + 1;

                end else begin

                    x_count <= 0;

                    y_count <= 0;

                    state <= ERASE_BIRD;

                end

            end


            ERASE_BIRD: begin


                VGA_COLOR <= BLACK;

                VGA_X <= prev_X + XC;

                VGA_Y <= prev_Y + YC;

                plot <= 1;


                if (XC == 3'b111 && YC == 3'b111) begin

                    state <= UPDATE_BIRD;

                end else begin

                    state <= ERASE_BIRD;

                end

            end



            UPDATE_BIRD: begin

                prev_Y <= Y;

                prev_X <= X;


                if (!KEY[1]) begin

                    if (Y > 2)

                        Y <= Y - 2;  // Jump up

                end else if (Y < 117) begin

                    Y <= Y + 1;  // Gravity

                end


                

                if (collision) begin

                    state <= RESET_GAME;

                end else begin

                    state <= PLOT_BIRD;

                end

            end


         



   PLOT_BIRD: begin

                VGA_COLOR <= OBJECT_COLOR;

                VGA_X <= X + XC;

                VGA_Y <= Y + YC;

                plot <= 1;


                if (XC == 3'b111 && YC == 3'b111) begin

                    state <= UPDATE_POSITION;

                end else begin

                    state <= PLOT_BIRD;

                end

            end




           UPDATE_POSITION: begin

    if (X_pos1 > 0) X_pos1 <= X_pos1 - 1; else X_pos1 <= X_MAX - 1;

    if (X_pos2 > 0) X_pos2 <= X_pos2 - 1; else X_pos2 <= X_MAX - 1;

    if (X_pos3 > 0) X_pos3 <= X_pos3 - 1; else X_pos3 <= X_MAX - 1;

    if (X_pos4 > 0) X_pos4 <= X_pos4 - 1; else X_pos4 <= X_MAX - 1;


    // Check for collision after updating positions

    if (collision) begin

        state <= RESET_GAME;  // Transition to reset state if collision detected

    end else begin

        state <= PLOT_PILLAR1;  // Continue if no collision

    end

end



            PLOT_PILLAR1: begin

                VGA_COLOR <= GREEN;

                VGA_X <= X_pos1 + x_count;

                VGA_Y <= START_Y1 + y_count;

                plot <= 1;


                if (x_count < XDIM1 - 1)

                    x_count <= x_count + 1;

                else if (y_count < YDIM1 - 1) begin

                    x_count <= 0;

                    y_count <= y_count + 1;

                end else begin

                    x_count <= 0;

                    y_count <= 0;

                    state <= PLOT_PILLAR2;

                end

            end


            PLOT_PILLAR2: begin

                VGA_COLOR <= GREEN;

                VGA_X <= X_pos2 + x_count;

                VGA_Y <= START_Y2 + y_count;

                plot <= 1;


                if (x_count < XDIM2 - 1)

                    x_count <= x_count + 1;

                else if (y_count < YDIM2 - 1) begin

                    x_count <= 0;

                    y_count <= y_count + 1;

                end else begin

                    x_count <= 0;

                    y_count <= 0;

                    state <= PLOT_PILLAR3;

                end

            end


            PLOT_PILLAR3: begin

                VGA_COLOR <= GREEN;

                VGA_X <= X_pos3 + x_count;

                VGA_Y <= START_Y3 + y_count;

                plot <= 1;


                if (x_count < XDIM3 - 1)

                    x_count <= x_count + 1;

                else if (y_count < YDIM3 - 1) begin

                    x_count <= 0;

                    y_count <= y_count + 1;

                end else begin

                    x_count <= 0;

                    y_count <= 0;

                    state <= PLOT_PILLAR4;

                end

            end


            PLOT_PILLAR4: begin

                VGA_COLOR <= GREEN;

                VGA_X <= X_pos4 + x_count;

                VGA_Y <= START_Y4 + y_count;

                plot <= 1;


                if (x_count < XDIM4 - 1)

                    x_count <= x_count + 1;

                else if (y_count < YDIM4 - 1) begin

                    x_count <= 0;

                    y_count <= y_count + 1;

                end else begin

                    x_count <= 0;

                    y_count <= 0;

                    state <= WAIT_FRAME;

                end

            end


            RESET_GAME: begin

                // Reset all positions and frame counter

                X_pos1 <= START_X1;

                X_pos2 <= START_X2;

                X_pos3 <= START_X3;

                X_pos4 <= START_X4;

                X <= 20;  // Reset bird X position

                Y <= 60;  // Reset bird Y position

                frame_counter <= 0;  // Reset frame counter

                state <= WAIT_FRAME;  // Restart the game loop

            end


        endcase

    end
	 
    // Column and row counters for accessing object memory
    count U3 (CLOCK_50, ~reset, plot, XC);
    defparam U3.n = 3;

    count U4 (CLOCK_50, ~reset, (XC == 3'b111), YC);
    defparam U4.n = 3;

    // Fetch object color from memory
    object_mem U6 ({YC, XC}, CLOCK_50, OBJECT_COLOR);

    // VGA adapter instantiation
    vga_adapter VGA (
        .resetn(1'b1), .clock(CLOCK_50), .colour(VGA_COLOR),
        .x(VGA_X), .y(VGA_Y), .plot(plot),
        .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B),
        .VGA_HS(VGA_HS), .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N), .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_CLK(VGA_CLK)
    );
    defparam VGA.RESOLUTION = "160x120";
    defparam VGA.MONOCHROME = "FALSE";
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    defparam VGA.BACKGROUND_IMAGE = "black.mif";

endmodule

module count (Clock, Resetn, E, Q);
    parameter n = 8;
    input Clock, Resetn, E;
    output reg [n-1:0] Q;

    always @(posedge Clock)
        if (Resetn == 0)
            Q <= 0;
        else if (E)
            Q <= Q + 1;
endmodule





module hex_to_7seg (hex, seg);

input [3:0] hex;

output [6:0] seg;

reg [6:0] seg;


always @(*) begin

    case (hex)

        4'b0000: seg [6:0]= 7'b1000000; // 0

        4'b0001: seg [6:0]= 7'b1111001; // 1

        4'b0010: seg [6:0]= 7'b0100100; // 2

        4'b0011: seg [6:0]= 7'b0110000; // 3

        4'b0100: seg [6:0]= 7'b0011001; // 4

        4'b0101: seg [6:0]= 7'b0010010; // 5

        4'b0110: seg [6:0]= 7'b0000010; // 6

        4'b0111: seg [6:0]= 7'b1111000; // 7

        4'b1000: seg [6:0]= 7'b0000000; // 8

        4'b1001: seg [6:0]= 7'b0010000; // 9

    endcase

end


endmodule 








