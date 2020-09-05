module video_controller_tb;

localparam
	TRUE = 1,
	FALSE = 0,
	
	HORZ_TOTAL = 1688,
	VERT_TOTAL = 1066,
	PIXEL_TOTAL = HORZ_TOTAL * VERT_TOTAL;

reg clk = 0;
always #1 clk <= ~clk;

reg reset = TRUE;

wire [14:0] font_address;
wire [15:0] char_row_bitmap;
font font (
	.clk (clk),
	.font_address (font_address),
	.char_row_bitmap (char_row_bitmap)
);

wire rd_request;
wire [22:0] rd_address;
reg rd_available;
reg [31:0] rd_data = 32'b0100_1011_00000000_000000_00_00110101;

localparam WAIT_CYCLES = 'd12;
reg [3:0] wait_cycles;
reg [31:0] value;
always @(posedge clk)
	if (reset) begin
		rd_available <= FALSE;
		wait_cycles <= 'd0;
	end else begin
		if (rd_request) begin
			wait_cycles <= WAIT_CYCLES;
		end

		if (wait_cycles > 'd0) begin
			wait_cycles <= wait_cycles - 'd1;

			if (wait_cycles == 'd1) begin
				rd_available <= TRUE;
				rd_data <= { rd_address[11:4], 14'b0, rd_address[15:6] };
			end else begin
				rd_available <= FALSE;
			end
		end else
			rd_available <= FALSE;
	end

wire hsync;
wire vsync;
wire [2:0] red;
wire [2:0] green;
wire [2:0] blue;
video_controller video_controller(
	.clk (clk),
	.reset (reset),
	.hsync (hsync),
	.vsync (vsync),
	.pixel_red (red),
	.pixel_green (green),
	.pixel_blue (blue),
	.rd_request (rd_request),
	.rd_address (rd_address),
	.rd_available (rd_available),
	.rd_data (rd_data),
	.font_address (font_address),
	.char_row_bitmap (char_row_bitmap)
);

reg [31:0] pixel_count = 'd0;
always @(posedge clk)
	if (~reset) begin
		$display("%0d %0d %0d", red, green, blue);
		pixel_count <= pixel_count + 'd1;
	end

always @(posedge clk)
	// Finish the simulation when an entire frame has been rendered
	if (pixel_count == PIXEL_TOTAL) $finish;

initial begin
	// Generate a PPM file of exactly 1 frame
	$display("P3");
	$display("# Image generated by video_controller_tb");
	$display("%0d %0d", HORZ_TOTAL, VERT_TOTAL);
	$display("7");

	#10 reset <= FALSE;
end

endmodule
