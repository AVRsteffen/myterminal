module myterminal (
	// Clock and reset
	input wire i_clk24,
	input wire reset_n,

	// Serial port
	input wire o_UART_RX,
	output wire o_UART_TX,
	output wire o_UART_CTS,

	// VGA output
	output wire [7:0] o_LCD_R,
	output wire [7:0] o_LCD_G,
	output wire [7:0] o_LCD_B,	
	output wire o_LCD_CLK,	
	output wire o_LCD_DEN,
	output wire o_LCD_HSYNC,
	output wire o_LCD_VSYNC
);

`include "constant.v"

assign o_UART_TX = 'b1;

wire w_clk25;
wire w_clk60;
assign o_LCD_CLK = w_clk25;


clock clock (
	.refclk (i_clk24),
	.reset (~reset_n),	
	.clk0_out (w_clk60),
	.clk1_out (w_clk25)
);


wire [7:0] in_byte;
wire in_byte_available;
serial_in #(
	.CLK_FREQUENCY_HZ (25_000_000),
	.SERIAL_BPS (115_200)
) serial_in (
	.clk (w_clk25),
	.reset (~reset_n),
	.rx (o_UART_RX),
	.data (in_byte),
	.oe (in_byte_available)
);

wire [14:0] font_address;
wire [15:0] char_row_bitmap;
font font (
	.clk (w_clk25),
	.font_address (font_address),
	.char_row_bitmap (char_row_bitmap)
);

wire [7:0] unicode;
wire unicode_available;
simple_fifo #(
	.DATA_WIDTH (8)
) simple_fifo (
	.clk (w_clk25),
	.reset (~reset_n),

	.in_data (in_byte),
	.in_data_available (in_byte_available),

	.receiver_ready (~o_UART_CTS),
	.out_data_available (unicode_available),
	.out_data (unicode)
);

wire [22:0] wr_address;
wire [31:0] wr_data;
wire [3:0] wr_mask;
wire wr_request;
wire wr_done;
wire [8:0] wr_burst_length;
wire [3:0] register_index;
wire [22:0] register_value;
terminal_stream terminal_stream (
	.clk (w_clk25),
	.reset (~reset_n),
	.ready_n (o_UART_CTS),
	.unicode (unicode),
	.unicode_available (unicode_available),
	.wr_address (wr_address),
	.wr_request (wr_request),
	.wr_data (wr_data),
	.wr_mask (wr_mask),
	.wr_done (wr_done),
	.wr_burst_length (wr_burst_length),
	.register_index (register_index),
	.register_value (register_value)
);

wire rd_request;
wire [22:0] rd_address;
wire [31:0] rd_data;
wire rd_available;
wire [8:0] rd_burst_length;
ram #(
	.CLK_FREQUENCY_HZ (25_000_000)
) ram (
	.clk (w_clk25),
	.rst_n (reset_n),

	// Read signals
	.rd_request (rd_request),
	.rd_address (rd_address),
	.rd_available (rd_available),
	.rd_data (rd_data),
	.rd_burst_length (rd_burst_length),

	// Write signals
	.wr_request (wr_request),
	.wr_mask (wr_mask),
	.wr_done (wr_done),
	.wr_address (wr_address),
	.wr_data (wr_data),
	.wr_burst_length (wr_burst_length)
);


wire [2:0] w_lcd_R;
wire [2:0] w_lcd_G;
wire [2:0] w_lcd_B;

video_controller video_controller (
	.clk (w_clk25),
	.reset (~reset_n),

	.hsync (o_LCD_HSYNC),
	.vsync (o_LCD_VSYNC),	
	.data_en (o_LCD_DEN),
	.pixel_red (w_lcd_R),
	.pixel_green (w_lcd_G),
	.pixel_blue (w_lcd_B),

	.rd_request (rd_request),
	.rd_address (rd_address),
	.rd_available (rd_available),
	.rd_data (rd_data),
	.rd_burst_length (rd_burst_length),

	.font_address (font_address),
	.char_row_bitmap (char_row_bitmap),

	.register_index (register_index),
	.register_value (register_value)
);

assign o_LCD_R = {w_lcd_R[2],w_lcd_R[1],w_lcd_R[0],w_lcd_R[2],w_lcd_R[1],w_lcd_R[0],w_lcd_R[1],w_lcd_R[0] };
assign o_LCD_G = {w_lcd_G[2],w_lcd_G[1],w_lcd_G[0],w_lcd_G[2],w_lcd_G[1],w_lcd_G[0],w_lcd_G[1],w_lcd_G[0] };
assign o_LCD_B = {w_lcd_B[2],w_lcd_B[1],w_lcd_B[0],w_lcd_B[2],w_lcd_B[1],w_lcd_B[0],w_lcd_B[1],w_lcd_B[0] };

endmodule
