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
   reg [n-1:0] 	  REG [3:0]; // general-purpose registers r0-r3
   reg [3:0]      reg_rdy;

   // internal regs
   reg 		  ignore_reg0_indirect;
   reg [n-1:0] 	  operands[1:0]; // Resolved operands
   reg [n-1:0] 	  result; // ALU / result register

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

//   initial $monitor("time %4d PC %4h IR %8b r0 %4d r1 %4d r2 %4d r3 %4d rd2 %4d // opcode %3b op1 r%1d %8b(%4d) op0 r%1d (%8b)%4d ignore %1b",
//		    $time, PC, IR, REG[0], REG[1], REG[2], REG[3], mem_rd_data2, opcode, reg1, operands[1], operands[1], reg0, operands[0], operands[0], ignore_reg0_indirect);

   // Instruction Fetch
   always@(clk or posedge reset) begin
      if(reset) begin
	 IF_rdy = 0;
	 PC <= 8'h 00;
	 reg_rdy[0] = 1;
	 reg_rdy[1] = 1;
	 reg_rdy[2] = 1;
	 reg_rdy[3] = 1;
      end
      else
	if(!(clk || stall_flag_if)) begin
	   //$display("PC %2h", clk, PC);
	   #1 IR_id[0] = mem_rd_data1;
	   IF_rdy <= 1;
	   PC = PC + 1;
	end
   end

   wire [1:0] stall_flag_if;
   assign stall_flag_if = stall_id;

   // ISB
   reg 	IF_rdy;
   reg 	ID_rdy;
   reg [n-1:0] IR_id[1:0]; // instruction register
   wire [ir_opcode_hi - ir_opcode_lo : 0] opcode_id;
   wire [ir_reg1_hi - ir_reg1_lo:0] 	  reg1_id;
   wire [ir_reg0_hi - ir_reg0_lo:0] 	  reg0_id;
   wire 				  dst_id;
   assign opcode_id = IR_id[1][ir_opcode_hi : ir_opcode_lo];
   assign reg1_id = IR_id[1][ir_reg1_hi : ir_reg1_lo];
   assign reg0_id = IR_id[1][ir_reg0_hi : ir_reg0_lo];
   assign dst_id = IR_id[1][ir_dst];

//   initial $monitor("clk %1b PC %3h IR_id[0] %8b IR_id[1] %8b stall_if %1b stall_id %1b reg_rdy %4b immediate_ex %8b",
//		    clk, PC, IR_id[0], IR_id[1], stall_flag_if, stall_id, reg_rdy[3:0], operands_immediate_ex[0]);

   reg [1:0] 				  stall_id;
   reg 					  id_state;
   reg [n-1:0] 				  operands_immediate_temp;
   reg 					  ignore_next_instr;

   // Instruction Decode
   always@(clk or posedge reset) begin
      if(reset) begin
	 ID_rdy = 0;
	 stall_id <= 0;
	 ignore_next_instr = 0;
      end
      
      if(clk) begin
	 if( IF_rdy && !ignore_next_instr ) begin
	    IF_rdy = 0;
	    IR_id[1] = IR_id[0];
	    #1 ID_rdy = 1;
	 end

	 if(ignore_next_instr)
	   ignore_next_instr = 0;

	 if ( ( reg0_id >= 0 && reg0_id <= 3 && !reg_rdy[reg0_id] ) ||
	      ( reg1_id >= 0 && reg1_id <= 3 && !reg_rdy[reg1_id] ) ) begin
//	    $display("FAIL: r0 %1d r1 %1d rdy0 %1b rdy1 %1b dst %1b", reg0_id, reg1_id, reg_rdy[reg0_id], reg_rdy[reg1_id], dst_id );
	    
	    stall_id = 1;
	 end
	 else begin
//	    $display("PASS: r0 %1d r1 %1d rdy0 %1b rdy1 %1b dst %1b", reg0_id, reg1_id, reg_rdy[reg0_id], reg_rdy[reg1_id], dst_id );
	    
	    stall_id = 0;

	    // Load immediate
	    if (opcode_id == opcode_addi ||
		opcode_id == opcode_subi ||
		opcode_id == opcode_movi ||
		opcode_id == opcode_beq  ||
		opcode_id == opcode_blt) begin

	       #1 operands_immediate_temp = mem_rd_data1;
	       PC = PC + 1;
	    end

	 end
      end
      else if( ID_rdy && !stall_id ) begin
	 if(opcode_id == opcode_add ||
	    opcode_id == opcode_sub ||
	    opcode_id == opcode_mov)
	   ignore_r0_indirect_ex[0] = 0;
	 else
	   ignore_r0_indirect_ex[0] = 1;

	 // Resolve operands
	 if ( reg0_id >= 0 && reg0_id <= 3 )
	   operands_ex[0] = REG[reg0_id];

	 if ( reg1_id >= 0 && reg1_id <= 3 )
	   operands_ex[1] = REG[reg1_id];

	 operands_immediate_ex[0] = operands_immediate_temp;

//	 $display( "Resolved operands: op1 %d, op0 %d", operands_ex[1], operands_ex[0] );
	 
	 if (opcode_id == opcode_beq  ||
	     opcode_id == opcode_blt) begin
	    if(operands_immediate_ex[0][n-1])
	      operands_immediate_ex[0] = operands_immediate_ex[0] - 2;

//	    $display("execute %8b, offset %8b, jump to %8h op1 %8b, op0 %8b", IR_id[1], operands_immediate_ex[0], PC + operands_immediate_ex[0], operands_ex[1], operands_ex[0]);
	    
	    case(opcode_id)
	      opcode_beq:
		if (operands_ex[1] == operands_ex[0]) begin
		   PC <= PC + operands_immediate_ex[0];
		   ignore_next_instr = 1;
		end
	      opcode_blt:
		if (operands_ex[1] < operands_ex[0]) begin
		   PC <= PC + operands_immediate_ex[0];
		   ignore_next_instr = 1;
		end
	    endcase
	 end

	 // Mark destination register not ready
	 if (ignore_r0_indirect_ex[0] || reg0_id != 0 || dst_id) begin
	    if (opcode_id != opcode_beq && opcode_id != opcode_blt )
	      if (dst_id == 0) reg_rdy[reg0_id] <= 0;
	      else reg_rdy[reg1_id] <= 0;
	 end
	 
	 // Pass on instruction
	 IR_ex[0] <= IR_id[1];

	 ID_rdy = 0;
      end
   end

   // ISB
   reg 	EX_rdy;
   reg [n-1:0] 	  IR_ex[1:0]; // instruction register
   reg 		  ignore_r0_indirect_ex[1:0];
   reg [n-1:0] 	  operands_ex[1:0];
   reg [n-1:0] 	  operands_cur_ex[1:0];
   reg [n-1:0] 	  operands_immediate_ex[1:0];
   wire [ir_opcode_hi - ir_opcode_lo : 0] opcode_ex;
   wire [ir_reg1_hi - ir_reg1_lo:0] 	  reg1_ex;
   wire [ir_reg0_hi - ir_reg0_lo:0] 	  reg0_ex;
   wire 				  dst_ex;
   assign opcode_ex = IR_ex[1][ir_opcode_hi : ir_opcode_lo];
   assign reg1_ex = IR_ex[1][ir_reg1_hi : ir_reg1_lo];
   assign reg0_ex = IR_ex[1][ir_reg0_hi : ir_reg0_lo];
   assign dst_ex = IR_ex[1][ir_dst];

   // Execution, MEM, and WB
   always @(clk or posedge reset) begin
      if ( !reset )
	if ( clk ) begin
	   if (!stall_id) begin
	      ignore_r0_indirect_ex[1] = ignore_r0_indirect_ex[0];
	      IR_ex[1] = IR_ex[0];
	      operands_cur_ex[0] = operands_ex[0];
	      operands_cur_ex[1] = operands_ex[1];
	      operands_immediate_ex[1] = operands_immediate_ex[0];
	      EX_rdy = 1;
	   end
	end
	else if( EX_rdy ) begin
	   mem_wr_en = 0;

	   // MEM read
	   if ( !ignore_r0_indirect_ex[1] && reg0_ex == 0 ) begin
	      // Register indirect
	      operands_cur_ex[0] = mem_rd_data2;
//	      $display("Register redirect result %8b, source %8b", operands_cur_ex[0], mem_rd_data2 );
	   end

	   // Execution
	   case (opcode_ex)
	     opcode_add:
	       result = operands_cur_ex[1] + operands_cur_ex[0];
	     opcode_addi:
	       result = operands_cur_ex[1] + operands_immediate_ex[0];
	     opcode_sub:
	       result = operands_cur_ex[1] - operands_cur_ex[0];
	     opcode_subi:
	       result = operands_cur_ex[1] - operands_immediate_ex[0];
	     opcode_mov:
	       if (dst_ex)
		 result = operands_cur_ex[0];
	       else
		 result = operands_cur_ex[1];
	     opcode_movi:
	       result = operands_immediate_ex[1];
	   endcase
	   
	   // reg/MEM write
	   if (ignore_r0_indirect_ex[1] || reg0_ex != 0 || dst_ex) begin
	      if (opcode_ex != opcode_beq && opcode_ex != opcode_blt ) begin
		 if (dst_ex == 0) begin
		    REG[reg0_ex] <= result;
		    reg_rdy[ reg0_ex ] = 1;

//		    $display( "Instr %8b writing register %d with %d", IR_ex[1], reg0_ex, result );
		 end
		 else begin
		    REG[reg1_ex] <= result;
		    reg_rdy[ reg1_ex ] = 1;
//		    $display( "Instr %8b writing register %d with %d", IR_ex[1], reg1_ex, result );
		 end
	      end
	   end
	   else
	     mem_wr_en = 1;

	   EX_rdy = 0;
	end
      else
	EX_rdy = 0;
   end
endmodule
