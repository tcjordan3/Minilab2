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

// Clock generation
always begin
    clk = 1'b0;
    #5;
    clk = 1'b1;
    #5;
end

// Test pattern - 6x6 image with a vertical edge:
// 000 000 255 255 000 000
// 000 000 255 255 000 000
// 000 000 255 255 000 000
// 000 000 255 255 000 000
// 000 000 255 255 000 000
// 000 000 255 255 000 000

logic [11:0] test_pattern [0:5][0:5];

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

// Initialize test pattern
initial begin
    // Fill test pattern
    for (int i = 0; i < 6; i++) begin
        for (int j = 0; j < 6; j++) begin
            if (j == 2 || j == 3)
                test_pattern[i][j] = 12'hFFF; // White pixels for edge
            else
                test_pattern[i][j] = 12'h000; // Black pixels
        end
    end

    // Start simulation
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
    for (int y = 0; y < 6; y++) begin
        y_cont = y;
        for (int x = 0; x < 6; x++) begin
            x_cont = x;
            data_in = test_pattern[y][x];
            #10; // Wait one clock cycle
        end
    end
    
    // End simulation
    dval_in = 1'b0;
    #100;
    
    // Check results
    $display("Simulation complete!");
    $display("Edge detection results:");
    for (int y = 1; y < 5; y++) begin
        $write("Row %0d: ", y);
        for (int x = 1; x < 5; x++) begin
            $write("%h ", red_out);
            #10;
        end
        $write("\n");
    end
    
    $stop;
end

// Monitor outputs
always @(posedge clk) begin
    if (dval_out) begin
        $display("Time=%0t Position=(%0d,%0d) Output: R=%h G=%h B=%h", 
                 $time, x_cont, y_cont, red_out, green_out, blue_out);
    end
end

endmodule