/**
	TEST COMMAND: vsim work.minilab2_tb -L C:/intelFPGA_lite/23.1std/questa_fse/intel/verilog/altera_mf -voptargs="+acc"
**/

// CODED BY US

// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

module minilab2_tb();

// Testbench signals
logic        clk;
logic        rst_n;
logic [10:0] x_cont;
logic [10:0] y_cont;
logic [11:0] data_in;
logic        dval_in;
logic [11:0] red_out;
logic [11:0] green_out;
logic [11:0] blue_out;
logic        dval_out;

// Parameters for image dimensions
localparam IMG_WIDTH = 640;
localparam IMG_HEIGHT = 480;

// Clock generation
always begin
    clk = 1'b0;
    #5;
    clk = 1'b1;
    #5;
end

// Test pattern memory - we'll create a simple pattern with vertical edges
logic [11:0] test_pattern [];
initial begin
    // Allocate memory for the test pattern
    test_pattern = new[IMG_WIDTH * IMG_HEIGHT];
    
    // Create a pattern with vertical edges every 80 pixels
    for (int y = 0; y < IMG_HEIGHT; y++) begin
        for (int x = 0; x < IMG_WIDTH; x++) begin
            if (x % 80 == 0 || x % 80 == 1)  // Create vertical edges
                test_pattern[y * IMG_WIDTH + x] = 12'hFFF;  // White
            else
                test_pattern[y * IMG_WIDTH + x] = 12'h000;  // Black
        end
    end
end

// DUT instantiation
convolution_vertical DUT (
    .iCLK(clk),
    .iRST(rst_n),
    .iX_Cont(x_cont),
    .iY_Cont(y_cont),
    .iDATA(data_in),
    .iDVAL(dval_in),
    .oRed(red_out),
    .oGreen(green_out),
    .oBlue(blue_out),
    .oDVAL(dval_out)
);

// Test sequence
initial begin
    // Initialize signals
    rst_n = 1'b0;
    x_cont = 0;
    y_cont = 0;
    data_in = 0;
    dval_in = 0;
    
    // Reset sequence
    #20;
    rst_n = 1'b1;
    #20;

    // Feed test pattern
    dval_in = 1'b1;
    
    // Process each pixel
    for (int y = 0; y < IMG_HEIGHT; y++) begin
        y_cont = y;
        for (int x = 0; x < IMG_WIDTH; x++) begin
            x_cont = x;
            data_in = test_pattern[y * IMG_WIDTH + x];
            #10; // Wait one clock cycle
        end
    end
    
    // End simulation
    dval_in = 1'b0;
    #100;
    
    // Output verification - sample a few key points
    $display("Simulation complete!");
    $display("Checking key points in the image...");
    
    // Check edges at specific locations
    for (int y = 1; y < IMG_HEIGHT-1; y += IMG_HEIGHT/10) begin
        for (int x = 1; x < IMG_WIDTH-1; x += IMG_WIDTH/10) begin
            $display("Position (%0d,%0d): Edge value = %h", x, y, red_out);
            #10;
        end
    end
    
    $stop;
end

// Monitor outputs - only display every 1000th pixel to avoid excessive output
int pixel_counter;
always @(posedge clk) begin
    if (dval_out) begin
        pixel_counter++;
        if (pixel_counter % 1000 == 0) begin
            $display("Time=%0t Position=(%0d,%0d) Output: R=%h G=%h B=%h", 
                     $time, x_cont, y_cont, red_out, green_out, blue_out);
        end
    end
end

endmodule