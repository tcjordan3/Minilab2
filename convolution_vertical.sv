module convolution_vertical(	oRed,
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

input	[10:0]	iX_Cont;
input	[10:0]	iY_Cont;
input	[11:0]	iDATA;
input			iDVAL;
input			iCLK;
input			iRST;
output	[11:0]	oRed;
output	[11:0]	oGreen;
output	[11:0]	oBlue;
output			oDVAL;
wire	[11:0]	mDATA_0;
wire	[11:0]	mDATA_1;
wire	[11:0]	mDATA_2;
reg		[11:0]	mDATAd [2:0][2:0];
reg		[11:0]	mult [2:0][2:0];
reg		[11:0]	mCCD_R;
reg		[12:0]	mCCD_G;
reg		[11:0]	mCCD_B;
reg		[11:0]	mgray;
reg				mDVAL;
reg				mDVAL2;
reg 	[11:0] sum;
reg 	[11:0] out;
reg	[10:0]	oX_Cont;
reg	[10:0]	oY_Cont;
reg [11:0] sobel [2:0][2:0];


RAW2GRAY				u9	(	
							.iCLK(iCLK),
							.iRST(iRST),
							.iDATA(iDATA),
							.iDVAL(iDVAL),
							.oRed(mCCD_R),
							.oGreen(mCCD_G),
							.oBlue(mCCD_B),
							.oDVAL(mDVAL2),
							.iX_Cont(oX_Cont),
							.iY_Cont(oY_Cont)
						   );

line_buffer3 	u0	(	.clken(mDVAL2),
						.clock(iCLK),
						.shiftin(mCCD_R),
						.taps0x(mDATA_2),
						.taps1x(mDATA_1),
                        .taps2x(mDATA_0)	);

assign	oRed	=	out;
assign	oGreen	=	out;
assign	oBlue	=	out;
assign	oDVAL	=	mDVAL;

// Assigning sobel filter values
assign sobel[0][0] = -1; 
assign sobel[0][1] = 0; 
assign sobel[0][2] = 1; 
assign sobel[1][0] = -2; 
assign sobel[1][1] = 0; 
assign sobel[1][2] = 2; 
assign sobel[2][0] = -1; 
assign sobel[2][1] = 0; 
assign sobel[2][2] = 1;
genvar m;
genvar n; 

always@(posedge iCLK or negedge iRST)
begin
	if(!iRST)
	begin
		mDATAd[0][0]<=	mDATA_0;
		mDATAd[1][0]<=	mDATA_1;
        mDATAd[2][0]<=	mDATA_2;
		mDATAd[0][1]<=	0;
		mDATAd[1][1]<=	0;
        mDATAd[2][1]<=	0;
        mDATAd[0][2]<=	0;
		mDATAd[1][2]<=	0;
        mDATAd[2][2]<=	0;
		//sum <= 0;
	end
	else
	begin
		mDATAd[0][1]	<=	mDATAd[0][0];
		mDATAd[1][1]	<=	mDATAd[1][0];
        mDATAd[2][1]	<=	mDATAd[2][0];
        mDATAd[0][2]	<=	mDATAd[0][1];
		mDATAd[1][2]	<=	mDATAd[1][1];
        mDATAd[2][2]	<=	mDATAd[1][2];
		mDVAL		<=	{iY_Cont[0]|iX_Cont[0]}	?	1'b0	:	iDVAL;
	end
end
generate
	for (m = 0;  m < 3; ++m) begin : outside
		for(n = 0; n < 3; ++n) begin : inner
			assign mult[m][n] = (iRST) ? (mDATAd[2-m][2-n] * sobel[m][n]) : 0;
		end
	end
endgenerate

assign sum = mult[0][0] + mult[0][1] + mult[0][2] + mult[1][0] + mult [1][1] + mult[1][2] + mult[2][0] + mult[2][1] + mult[2][2];
// not sure if this works
always @* begin
  if (sum[11] == 1'b1) begin
    out = -sum;
  end
  else begin
    out = sum;
  end
end

endmodule


