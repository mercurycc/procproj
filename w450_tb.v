module w450_tb;
	parameter n=8;
	wire[n-1:0] mem_wr_data, mem_wr_addr;
	wire mem_wr_en;
	wire[n-1:0] mem_rd_data1, mem_rd_addr1;
	wire[n-1:0] mem_rd_data2, mem_rd_addr2;
	reg reset, clk;

	mem mem_0(mem_wr_data, mem_wr_addr, mem_wr_en,
		mem_rd_data1, mem_rd_addr1,
		mem_rd_data2, mem_rd_addr2,
		~clk);

	w450 w450_0(mem_wr_data, mem_wr_addr, mem_wr_en,
		mem_rd_data1, mem_rd_addr1,
		mem_rd_data2, mem_rd_addr2,
		reset, clk);

	initial begin
		clk = 0;
		reset = 1;
		#30 reset=0;
		wait((mem_wr_addr==8'hff) && (mem_wr_data==8'h01))
			$finish;
	end

	always begin
		#10 clk = ~clk;
	end
endmodule
