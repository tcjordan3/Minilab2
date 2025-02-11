// CODED BY US

module convolution_horizontal(
	oRed,
	oGreen,
	oBlue,
	oDVAL,
	iX_Cont,
	iY_Cont,
	iDATA,
	iDVAL,
	iCLK,
	iRST
);

input		[10:0]	iX_Cont;
input		[10:0]	iY_Cont;
input		[11:0]	iDATA;
input			iDVAL;
input			iCLK;
input			iRST;
output		[11:0]	oRed;
output		[11:0]	oGreen;
output		[11:0]	oBlue;
output			oDVAL;
wire		[11:0]	mDATA_0;
wire		[11:0]	mDATA_1;
wire		[11:0]	mDATA_2;
reg		[11:0]	mDATAd [2:0][2:0];
reg		[11:0]	mult [2:0][2:0];
reg		[11:0]	mCCD_R;
reg		[11:0]	mCCD_G;
reg		[11:0]	mCCD_B;
reg			mDVAL;
reg			mDVAL2;
reg 		[11:0] sum;
reg 		[11:0] out;
reg 		[11:0] sobel [2:0][2:0];


RAW2GRAY u9	(	
	.iCLK(iCLK),
	.iRST(iRST),
	.iDATA(iDATA),
	.iDVAL(iDVAL),
	.oRed(mCCD_R),
	.oGreen(mCCD_G),
	.oBlue(mCCD_B),
	.oDVAL(mDVAL2),
	.iX_Cont(iX_Cont),
	.iY_Cont(iY_Cont)
		);

/**
other_linebuffer3 	u0	(	
	.clken(mDVAL2),
	.clock(iCLK),
	.shiftin(mCCD_R),
	.shiftout(),
	.taps0x(mDATA_0),
	.taps1x(mDATA_1),
        .taps2x(mDATA_2)	
			);
**/

Line_Buffer2 	u0	(	.clken(mDVAL2),
						.clock(iCLK),
						.shiftin(mCCD_R),
						.taps0x(mDATA_0),
						.taps1x(mDATA_1)	);

Line_Buffer1 	u1	(	.clken(mDVAL2),
						.clock(iCLK),
						.shiftin(mCCD_R),
						.taps0x(),
						.taps1x(mDATA_2)	);

assign	oRed	= out;
assign	oGreen	= out;
assign	oBlue	= out;
assign  oDVAL = mDVAL;

// negation + edge logic
assign out = ((iX_Cont > 9) && (iX_Cont < 1270) && (iY_Cont > 9) && (iY_Cont < 1270)) ? (sum[11] ? (~sum + 1) : sum) : 12'b0;

// Assigning sobel filter values
assign sobel[0][0] = -1; 
assign sobel[0][1] = -2; 
assign sobel[0][2] = -1; 
assign sobel[1][0] = 0; 
assign sobel[1][1] = 0; 
assign sobel[1][2] = 0; 
assign sobel[2][0] = 1; 
assign sobel[2][1] = 2; 
assign sobel[2][2] = 1;

always@(posedge iCLK or negedge iRST)
begin
	if(!iRST) begin
	  mDATAd[0][0]<= 0;
	  mDATAd[1][0]<= 0;
          mDATAd[2][0]<= 0;
	  mDATAd[0][1]<= 0;
	  mDATAd[1][1]<= 0;
          mDATAd[2][1]<= 0;
          mDATAd[0][2]<= 0;
	  mDATAd[1][2]<= 0;
          mDATAd[2][2]<= 0;
	  //sum <= 0;
	end else begin
	  mDATAd[0][0] <= mDATA_0;
	  mDATAd[1][0] <= mDATA_1;
          mDATAd[2][0] <= mDATA_2;
	  mDATAd[0][1] <= mDATAd[0][0];
	  mDATAd[1][1] <= mDATAd[1][0];
          mDATAd[2][1] <= mDATAd[2][0];
          mDATAd[0][2] <= mDATAd[0][1];
	  mDATAd[1][2] <= mDATAd[1][1];
          mDATAd[2][2] <= mDATAd[2][1];
	  mDVAL	       <= {iY_Cont[0]|iX_Cont[0]} ? 1'b0 : iDVAL;
	end
end

always_ff @(posedge iCLK or negedge iRST) begin
    if (!iRST) begin
        sum <= 0;
    end else begin
        sum <= mDATAd[0][0] * sobel[0][0] + mDATAd[0][1] * sobel[0][1] + mDATAd[0][2] * sobel[0][2] +
               mDATAd[1][0] * sobel[1][0] + mDATAd[1][1] * sobel[1][1] + mDATAd[1][2] * sobel[1][2] +
               mDATAd[2][0] * sobel[2][0] + mDATAd[2][1] * sobel[2][1] + mDATAd[2][2] * sobel[2][2];
    end
end

//assign sum = mult[0][0] + mult[0][1] + mult[0][2] + mult[1][0] + mult [1][1] + mult[1][2] + mult[2][0] + mult[2][1] + mult[2][2];
// not sure if this works

endmodule
