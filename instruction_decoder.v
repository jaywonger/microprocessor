module instruction_decoder (
	input clk, sync_reset,
	input [7:0] next_instr,
	
	output reg i_sel, x_sel, y_sel, jmp, jmp_nz,
	output reg [8:0] reg_en,
	output reg [3:0] source_sel, ir_nibble,
	output reg [7:0] ir,
	
	output reg [8:0] from_ID
);

// MIDTERM 2
always @ *
	from_ID <= 8'h00;
	
// Instantiate Instruction Register
always @ (posedge clk)
	ir = next_instr;
	
// Determine IR LS Nibble Output
always @ *
	ir_nibble <= ir[3:0];

// logic for decoding register enables
// for reg enable 0 (x0)
always @ *
	if(sync_reset == 1'b1)
		reg_en[0] = 1'b1;
	else if (ir[7:4] == 4'b0000)	// ir = 0_000_xxxx = load
		reg_en[0] = 1'b1;
	else if (ir[7:3] == 5'b10000)	// ir = 10_000_xxx = mov
		reg_en[0] = 1'b1;
	else 
		reg_en[0] = 1'b0;

// for reg enable 1 (x1)
always @ *
	if(sync_reset == 1'b1)
		reg_en[1] = 1'b1;
	else if (ir[7:4] == 4'b0001)	// ir = 0_001_xxxx = load
		reg_en[1] = 1'b1;
	else if (ir[7:3] == 5'b10001)	// ir = 10_001_xxx = mov
		reg_en[1] = 1'b1;
	else 
		reg_en[1] = 1'b0;
	
// for reg enable 2 (y0)
always @ *	
	if(sync_reset == 1'b1)
		reg_en[2] = 1'b1;
	else if (ir[7:4] == 4'b0010)	// ir = 0_010_xxxx = load
		reg_en[2] = 1'b1;
	else if (ir[7:3] == 5'b10010)	// ir = 10_010_xxx = mov
		reg_en[2] = 1'b1;
	else 
		reg_en[2] = 1'b0;
	
// for reg enable 3 (y1)
always @ *
	if(sync_reset == 1'b1)
		reg_en[3] = 1'b1;
	else if (ir[7:4] == 4'b0011)	// ir = 0_011_xxxx = load
		reg_en[3] = 1'b1;
	else if (ir[7:3] == 5'b10011)	// ir = 10_011_xxx = mov
		reg_en[3] = 1'b1;
	else 
		reg_en[3] = 1'b0;
	
// for reg enable 4 (r)
always @ *
	if(sync_reset == 1'b1)
		reg_en[4] = 1'b1;
	else if(ir[7:5] == 3'b110)
		reg_en[4] = 1'b1;
	else 
		reg_en[4] = 1'b0;
		
// for reg enable 5 (m)
always @ *	
	if(sync_reset == 1'b1)
		reg_en[5] = 1'b1;
	else if (ir[7:4] == 4'b0101)	// ir = 0_101_xxxx = load
		reg_en[5] = 1'b1;
	else if (ir[7:3] == 5'b10101)	// ir = 10_101_xxx = mov
		reg_en[5] = 1'b1;
	else 
		reg_en[5] = 1'b0;
		
// for reg enable 6 (i)
always @ *
	if(sync_reset == 1'b1)
		reg_en[6] = 1'b1;
	else if (ir[7:4] == 4'b0110)	// ir = 0_110_xxxx = load
		reg_en[6] = 1'b1;
	else if (ir[7:3] == 5'b10110)	// ir = 10_110_xxx = mov
		reg_en[6] = 1'b1;
	else if (ir[7:4] == 4'b0111)	// 0_111_xxxx
		reg_en[6] = 1'b1;
	else if (ir[7:3] == 5'b10111)	// 10_111_xxx
		reg_en[6] = 1'b1;
	else if ((ir[7:6] == 2'b10) && (ir[2:0] == 3'b111))	// 10_xxx_111
		reg_en[6] = 1'b1;
	else 	
		reg_en[6] = 1'b0;
	
// for reg enable 7 (dm)
always @ *
	if(sync_reset == 1'b1)
		reg_en[7] = 1'b1;
	else if (ir[7:4] == 4'b0111)	// ir = 0_111_xxxx = load
		reg_en[7] = 1'b1;
	else if (ir[7:3] == 5'b10111)	// ir = 10_111_xxx = mov
		reg_en[7] = 1'b1;
	else 
		reg_en[7] = 1'b0;
		
// for reg enable 8 (o_reg)
always @ *
	if(sync_reset == 1'b1)
		reg_en[8] = 1'b1;
	else if (ir[7:4] == 4'b0100)	// ir = 1_100_xxxx = load
		reg_en[8] = 1'b1;
	else if (ir[7:3] == 5'b10100)	// ir = 10_100_xxx = mov
		reg_en[8] = 1'b1;
	else 
		reg_en[8] = 1'b0;
	
		
// logic for decoding source register
always @ *
	// Source select reverts to 4'd10
	if (sync_reset == 1'b1)
		source_sel <= 4'd10;
	// When loading data, source is pm_data (8)
	else if (ir[7] == 1'b0)
		source_sel <= 4'd8;
	// If src and dst are both 100 during a move operation, r becomes source (4)
	else if (ir[7:0] == 8'b10100100)
		source_sel <= 4'd4;
	// If src and dst are NOT 100, but are both the same value, i_pins is loaded (9)
	else if ((ir[7:6] == 2'b10) && (ir[5:3] == ir[2:0]))
		source_sel <= 4'd9;
	// Otherwise, a move operation includes the desired source (as ir[2:0])
	else if (ir[7:6] == 2'b10)
		source_sel <= { 1'b0, ir[2:0] };
	// Default case
	else
		source_sel <= source_sel;
	
// logic for decoding i,x,y selects
//always @ *
//if (sync_reset == 1'b1)
//	{x_sel, y_sel, i_sel} = 3'b000;
//else if (ir[7] == 1'b0)		// LOAD
//	if (ir[6:4] == 3'b110)	// dst
//		{x_sel, y_sel, i_sel} = 3'bxx0;	// data
//	else if (ir[6:4] == 3'b111)	// dst
//		{x_sel, y_sel, i_sel} = 3'bxx1;	// data
//	else
//		{x_sel, y_sel, i_sel} = 3'bxxx;	// data
//else if (ir[7:6] == 2'b10)	// MOV
//	if (ir[5:3] == 3'b110)	//	dst
//		{x_sel, y_sel, i_sel} = 3'bxx0;
//	else if ((ir[5:3] == 3'b111) | (ir[2:0] == 3'b111))	// dst & src
//		{x_sel, y_sel, i_sel} = 3'bxx1;	// src
//	else
//		{x_sel, y_sel, i_sel} = 3'bxxx;	// src
//else if (ir[7:5] == 3'b110)		// ALU
//	{x_sel, y_sel, i_sel} = {ir[4:3], 1'bx};	// x & y & i
//else
//	{x_sel, y_sel, i_sel} = 3'bxx1;		// x & y & i
	
	
// x_sel
always @ *
	// Should reset to 0
	if (sync_reset == 1'b1)
		x_sel <= 1'b0;
	// If an ALU instruction, x_sel is ir[4]
	else if (ir[7:5] == 3'b110)
		x_sel <= ir[4];
	// Otherwise, x_sel remains 0
	else 
		x_sel <= 1'b0;

// y_sel
always @ *
	// Should reset to 0
	if (sync_reset == 1'b1)
		y_sel <= 1'b0;
	// If an ALU instruction, y_sel is ir[3]
	else if (ir[7:5] == 3'b110)
		y_sel <= ir[3];
	// Otherwise, y_sel remains 0
	else 
		y_sel <= 1'b0;

// i_sel
always @ *
	// Should reset to 0
	if (sync_reset == 1'b1)
		i_sel <= 1'b0;
	// If a load or move instruction is exerted with i as a destination (110), i_sel should be 0
	else if ((ir[7:4] == 4'b0110) || (ir[7:3] == 5'b10110))
		i_sel <= 1'b0;
	// Otherwise, i_sel remains 1
	else 
		i_sel <= 1'b1;
	
	
// logic for decoding instruction type
always @ *
if (sync_reset == 1'b1)
	{jmp, jmp_nz} = 2'b00;
else if (ir[7:4] == 4'hE)	// jump
	{jmp, jmp_nz} = 2'b10;
else if (ir[7:4] == 4'hF)	// conditional jump
	{jmp, jmp_nz} = 2'b01;
else 
	{jmp, jmp_nz} = 2'b00;

endmodule 
	