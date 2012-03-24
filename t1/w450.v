module w450(mem_wr_data, mem_wr_addr, mem_wr_en, mem_rd_data1, mem_rd_addr1,
	    mem_rd_data2, mem_rd_addr2, reset, clk);
   parameter n=8;
   output [n-1:0] mem_wr_data;
   output [n-1:0] mem_wr_addr;
   output 	  mem_wr_en;
   input [n-1:0]  mem_rd_data1;
   output [n-1:0] mem_rd_addr1;
   input [n-1:0]  mem_rd_data2;
   output [n-1:0] mem_rd_addr2;
   input 	  reset;
   input 	  clk;

   reg 		  mem_wr_en;

   parameter [2:0]
     st_if  = 3'b000,
     st_id  = 3'b001;
   // you'll need more states than this...

   parameter [3:0]
     opcode_add = 3'b000,
     opcode_addi = 3'b001,
     opcode_sub = 3'b010,
     opcode_subi = 3'b011,
     opcode_mov = 3'b100,
     opcode_movi = 3'b101,
     opcode_beq = 3'b110,
     opcode_blt = 3'b111;
   
   reg [2:0] 	  state;

   // processor regs
   reg [n-1:0] 	  PC; // program counter
   reg [n-1:0] 	  IR; // instruction register
   reg [n-1:0] 	  REG [3:0]; // general-purpose registers r0-r3

   // internal regs
   reg 		  ignore_reg0_indirect;
   reg [n-1:0] 	  operands[1:0]; // Resolved operands
   reg [n-1:0] 	  result; // ALU / Lresult register

   assign mem_rd_addr1 = PC; // read port 1 is for instructions
   assign mem_rd_addr2 = REG[0]; // read port 2 is for r0 indirect
   assign mem_wr_data = result;
   assign mem_wr_addr = REG[0];

   // useful for indexing in IR - modify as needed...
   parameter ir_opcode_hi = 7;
   parameter ir_opcode_lo = 5;
   parameter ir_reg1_hi = 4;
   parameter ir_reg1_lo = 3;
   parameter ir_reg0_hi = 2;
   parameter ir_reg0_lo = 1;
   parameter ir_dst = 0;

   wire [ir_opcode_hi - ir_opcode_lo : 0] 	  opcode;
   wire [ir_reg1_hi - ir_reg1_lo:0] 		  reg1;
   wire [ir_reg0_hi - ir_reg0_lo:0] 		  reg0;
   wire 					  dst;

   assign opcode = IR[ir_opcode_hi : ir_opcode_lo];
   assign reg1 = IR[ir_reg1_hi : ir_reg1_lo];
   assign reg0 = IR[ir_reg0_hi : ir_reg0_lo];
   assign dst = IR[ir_dst];

//   initial $monitor("time %4d PC %4h IR %8b r0 %4d r1 %4d r2 %4d r3 %4d rd2 %4d // opcode %3b op1 r%1d %8b(%4d) op0 r%1d (%8b)%4d ignore %1b",
//		    $time, PC, IR, REG[0], REG[1], REG[2], REG[3], mem_rd_data2, opcode, reg1, operands[1], operands[1], reg0, operands[0], operands[0], ignore_reg0_indirect);

   always@(posedge clk or posedge reset) begin // stages
      mem_wr_en = 0;
      
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
	     // Pre-configure
	     if(opcode == opcode_add ||
		opcode == opcode_sub ||
		opcode == opcode_mov)
	       ignore_reg0_indirect = 0;
	     else
	       ignore_reg0_indirect = 1;
	     
	     // Resolve operands
	     // Register indirect
	     if ( ignore_reg0_indirect || reg0 != 0 ) begin
	       if ( reg0 >= 0 && reg0 <= 3 ) operands[0] = REG[reg0];
	     end
	     else 
	       operands[0] = mem_rd_data2;

	     // Sync the rest of the program to ensure operands
	     operands[1] = REG[reg1];

	     // Execution

	     // Load immediate
	     if (opcode == opcode_addi ||
		 opcode == opcode_subi ||
		 opcode == opcode_movi) begin
		#21 operands[0] = mem_rd_data1;
		PC = PC + 1;
	     end

	     if (opcode == opcode_beq  ||
		 opcode == opcode_blt) begin
		#21 result = mem_rd_data1;
		PC = PC + 1;
	     end

	     if (opcode == opcode_add ||
		 opcode == opcode_addi)
	       result = operands[1] + operands[0];

	     if (opcode == opcode_sub ||
		 opcode == opcode_subi)
	       result = operands[1] - operands[0];

	     if (opcode == opcode_movi)
	       result = operands[0];

	     if (opcode == opcode_mov)
	       if (dst)
		 result = operands[0];
	       else
		 result = operands[1];

	     if ((opcode == opcode_beq ||
		  opcode == opcode_blt) &&
		 result[n - 1])
	       result = result - 2;
		
	     case(opcode)
	       opcode_beq:
		 if (REG[reg1] == REG[reg0])
		   PC <= PC + result;
	       opcode_blt:
		 if (REG[reg1] < REG[reg0])
		   PC <= PC + result;
	     endcase

	     // Write back
	     if (ignore_reg0_indirect || reg0 != 0 || dst) begin
		if (opcode != opcode_beq && opcode != opcode_blt )
		  if (dst == 0) REG[reg0] <= result;
		  else REG[reg1] <= result;
	     end
	     else
		mem_wr_en = 1;
	     
	     state <= st_if;
	  end

	  default: state <= st_if;
	endcase
   end
endmodule
