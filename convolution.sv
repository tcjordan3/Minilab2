module convolution(
    input  wire        iCLK,
    input  wire        iRST,
    input  wire [10:0] iX_Cont,
    input  wire [10:0] iY_Cont,
    input  wire [11:0] iDATA,
    input  wire        iDVAL,
    output wire [11:0] oRed,
    output wire [11:0] oGreen,
    output wire [11:0] oBlue,
    output wire        oDVAL
);

// Line buffer to store 3 rows of pixels
wire [11:0] row_data [2:0];  // Output from line buffers
line_buffer3 line_buff (
    .clken(iDVAL),
    .clock(iCLK),
    .shiftin(iDATA),
    .taps0x(row_data[2]),  // Oldest row
    .taps1x(row_data[1]),  // Middle row
    .taps2x(row_data[0])   // Newest row
);

// 3x3 window registers to hold neighboring pixels
reg [11:0] window [2:0][2:0];

// Sobel vertical edge detection kernel - Changed to individual parameters
parameter signed [3:0] h00 = -1;
parameter signed [3:0] h01 = -2;
parameter signed [3:0] h02 = -1;
parameter signed [3:0] h10 = 0;
parameter signed [3:0] h11 = 0;
parameter signed [3:0] h12 = 0;
parameter signed [3:0] h20 = 1;
parameter signed [3:0] h21 = 2;
parameter signed [3:0] h22 = 1;

// Registers for pipeline stages
reg [11:0] conv_result;
reg        valid_result;
reg [2:0]  valid_pipeline;

// Shift window contents on each clock
integer i, j;  // Loop variables declared at module level
always @(posedge iCLK or negedge iRST) begin
    if (!iRST) begin
        // Reset window contents
        for (i = 0; i < 3; i = i + 1) begin
            for (j = 0; j < 3; j = j + 1) begin
                window[i][j] <= 12'd0;
            end
        end
        valid_pipeline <= 3'd0;
    end
    else if (iDVAL) begin
        // Shift window left
        for (i = 0; i < 3; i = i + 1) begin
            window[i][0] <= window[i][1];
            window[i][1] <= window[i][2];
        end
        
        // Load new column from line buffers
        window[0][2] <= row_data[0];
        window[1][2] <= row_data[1];
        window[2][2] <= row_data[2];
    end
end

// Convolution calculation
reg signed [15:0] sum;  // Wider to handle multiplication and accumulation
reg signed [15:0] temp_mult [2:0][2:0];  // Temporary multiplication results

always @(posedge iCLK or negedge iRST) begin
    if (!iRST) begin
        sum <= 16'd0;
        conv_result <= 12'd0;
        valid_result <= 1'b0;
    end
    else begin
        valid_pipeline <= {valid_pipeline[1:0], iDVAL};
        
        // Only compute when we have valid data and not at image edges
        if (iDVAL && iX_Cont > 1 && iX_Cont < 1278 && iY_Cont > 1 && iY_Cont < 1022) begin
            // Calculate all multiplications
            temp_mult[0][0] <= window[0][0] * h00;
            temp_mult[0][1] <= window[0][1] * h01;
            temp_mult[0][2] <= window[0][2] * h02;
            temp_mult[1][0] <= window[1][0] * h10;
            temp_mult[1][1] <= window[1][1] * h11;
            temp_mult[1][2] <= window[1][2] * h12;
            temp_mult[2][0] <= window[2][0] * h20;
            temp_mult[2][1] <= window[2][1] * h21;
            temp_mult[2][2] <= window[2][2] * h22;
            
            // Sum all products
            sum <= temp_mult[0][0] + temp_mult[0][1] + temp_mult[0][2] +
                  temp_mult[1][0] + temp_mult[1][1] + temp_mult[1][2] +
                  temp_mult[2][0] + temp_mult[2][1] + temp_mult[2][2];
                  
            // Take absolute value for edge detection
            conv_result <= (sum[15]) ? (-sum[11:0]) : sum[11:0];
            valid_result <= 1'b1;
        end
        else begin
            conv_result <= 12'd0;
            valid_result <= 1'b0;
        end
    end
end

// Output assignments
assign oRed   = conv_result;
assign oGreen = conv_result;
assign oBlue  = conv_result;
assign oDVAL  = valid_result;

endmodule