// file: SAR_Controller_tb.v
// author: @refaay
// Testbench for SAR_Controller

`timescale 1ns/1ns

module SAR_Controller_tb;

	//Inputs
	reg [0: 0] clk;
	reg [0: 0] rst;
	reg [0: 0] go;
	reg [0: 0] cmp;


	//Outputs
	wire  [0:0] sample;
	wire [7: 0] value;
	wire [0: 0] valid;
	wire  [8-1:0] result;


    //For Testbench
    wire [7:0] analog = 8'd167;
    wire err;
    
    assign err =  (result != analog) & valid; // self-checking
    
	//Instantiation of Unit Under Test
	SAR_Controller uut (
		.clk(clk),
		.rst(rst),
		.go(go),
		.cmp(cmp),
		.sample(sample),
		.value(value),
		.valid(valid),
		.result(result)
	);

    always #2 clk = !clk;
    
	initial begin
	//Inputs initialization
		clk = 1'b0;
		rst = 1'b0;
		go = 1'b0;

		#12;
		rst = 1'b1;
		go = 1'b1;
		
		#4;
		go = 1'b0;
		
        #400;
        go = 1'b1;

		#4;
		go = 1'b0;
	end

    always @(negedge clk) begin // OP-AMP
        cmp <= (analog>value);
    end

endmodule