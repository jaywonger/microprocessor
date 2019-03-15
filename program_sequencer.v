module program_sequencer ( 
	input clk, sync_reset, jmp, jmp_nz, dont_jmp,
	input [3:0] jmp_addr,
	output reg [7:0] pm_addr
);
reg[7:0] pc;
always @ (posedge clk)
	pc = pm_addr;

always @ *
	if (sync_reset == 1'b1)
		pm_addr = 8'h00;
	else if (jmp == 1'b1)	// jmp is true goto jmp_addr, 4'h0
		pm_addr = {jmp_addr, 4'h0};
	else if ((jmp_nz == 1'b1) && (dont_jmp == 1'b0))	// 
		pm_addr = {jmp_addr, 4'h0};
	else if (pc == 8'hFF)	// program counter is 8'hFF
		pm_addr = 8'h00;
	else
		pm_addr = pc + 1'b1;
	
endmodule
