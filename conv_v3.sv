module conv_v3(	oRed,
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
genvar m;
genvar n; 
// I feel like we have to do something like this? But since output is a pixel row by row but this will give 3 pixels from row 0 then three pixels from row 1 we have to figure out how to buffer that?
generate
	for (m = 0;  m < 3; ++m) begin : outside
		for(n = 0; n < 3; ++n) begin : inner
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
		end
	end
endgenerate


endmodule


