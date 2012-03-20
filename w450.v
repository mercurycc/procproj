module w450(mem_wr_data, mem_wr_addr, mem_wr_en, mem_rd_data1, mem_rd_addr1,
	mem_rd_data2, mem_rd_addr2, reset, clk);
	parameter n=8;
	output [n-1:0] mem_wr_data;
	output [n-1:0] mem_wr_addr;
	output mem_wr_en;
	input [n-1:0] mem_rd_data1;
	output [n-1:0] mem_rd_addr1;
	input [n-1:0] mem_rd_data2;
	output [n-1:0] mem_rd_addr2;
	input reset;
	input clk;

	parameter [2:0]
		st_if  = 3'b000,
		st_id  = 3'b001;
		// you'll need more states than this...

	reg[2:0] state;

	// processor regs
	reg[n-1:0] PC; // program counter
	reg[n-1:0] IR; // instruction register
	reg[n-1:0] REG [3:0]; // general-purpose registers r0-r3

	assign mem_rd_addr1 = PC; // read port 1 is for instructions

	// useful for indexing in IR - modify as needed...
	parameter ir_opcode_hi = 7;
	parameter ir_opcode_lo = 5;
	parameter ir_reg1_hi = 4;
	parameter ir_reg1_lo = 3;
	parameter ir_reg0_hi = 2;
	parameter ir_reg0_lo = 1;
	parameter ir_dst = 0;

	always@(posedge clk or posedge reset) begin // stages
		if(reset) begin
			state <= st_if;
			PC <= 8'h 00;
		end
		else
		case(state)
			st_if: begin
				IR <= mem_rd_data1;
				PC <= PC + 1;
				state <= st_id;
			end

			st_id: begin
				//...
				state <= st_if; // you'll need to change this...
			end

			// add a case for each state that you define...

			default: state <= st_if;
		endcase
	end
endmodule
