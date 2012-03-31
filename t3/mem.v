module mem(wr_data, wr_addr, wr_en, rd_data1, rd_addr1, rd_data2, rd_addr2,
	clk);
	parameter n=8;
	input[n-1:0] wr_data, wr_addr;
	input wr_en;
	output[n-1:0] rd_data1;
	input[n-1:0] rd_addr1;
	output[n-1:0] rd_data2;
	input[n-1:0] rd_addr2;
	input clk;

	reg[n-1:0] data [0:255];

	reg[n-1:0] data1;
	reg[n-1:0] data2;
	assign rd_data1 = data1;
	assign rd_data2 = data2;

	initial $readmemb("programs/addArray.data", data);
	initial $monitor("time %4d: mem[128] %3d", $time, data[128]);

	always @(clk) begin
		data1 <= data[rd_addr1];
		data2 <= data[rd_addr2];
		if(wr_en) data[wr_addr] <= wr_data;
	end

endmodule
