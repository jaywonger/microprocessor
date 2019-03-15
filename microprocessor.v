module microprocessor(
	input clk, reset, 
	input[3:0] i_pins,
	output[3:0] o_reg,
	output[7:0] pm_address, pm_data,
	output[7:0] ir, from_ID,
	output[7:0] pc, from_PS,
	output [7:0] from_CU,
	output [3:0] x0, x1, y0, y1, r, m, i,
	output zero_flag
);

wire [3:0] LS_nibble_ir, source_select, data_bus, dm;
wire [8:0] reg_enables;
reg sync_reset;
wire jmp, jmp_nz, i_mux_select, y_reg_select, x_reg_select;

always @ (posedge clk)
sync_reset = reset;


program_memory pm1(.clock(~clk), 
				 .q(pm_data), 
				 .address(pm_address)
				 );
program_sequencer ps1(.clk(clk),
						    .sync_reset(sync_reset), 
						    .pm_addr(pm_address), 
						    .jmp(jmp), 
						    .jmp_nz(jmp_nz), 
						    .jmp_addr(LS_nibble_ir), 
						    .dont_jmp(zero_flag),
							 .pc(pc),
							 .from_PS(from_PS)
						   );
instruction_decoder id1(.clk(clk),
					  .sync_reset(sync_reset),
					  .jmp(jmp), 
					  .jmp_nz(jmp_nz), 
					  .next_instr(pm_data),
					  .ir(ir),
					  .ir_nibble(LS_nibble_ir), 
					  .i_sel(i_mux_select), 
					  .y_sel(y_reg_select), 
					  .x_sel(x_reg_select), 
					  .source_sel(source_select), 
					  .reg_en(reg_enables),
					  .from_ID(from_ID)
					  );
computational_unit cu1( .clk(clk),
					.sync_reset(sync_reset),
					.r_eq_0(zero_flag),
					.i_pins(i_pins),
					.i(i),
					.data_bus(data_bus),
					.dm(dm),
					.o_reg(o_reg),
					.reg_en({reg_enables[8], reg_enables[6:0]}),
					.source_sel(source_select),
					.x_sel(x_reg_select),
					.y_sel(y_reg_select),
					.i_sel(i_mux_select),
					.nibble_ir(LS_nibble_ir),
					.x0(x0),
					.x1(x1),
					.y0(y0),
					.y1(y1),
					.r(r),
					.m(m),
					.from_CU(from_CU)
					);
data_memory dm1(.clock(~clk), 
				.address(i), 
				.data(data_bus), 
				.q(dm), 
				.wren(reg_enables[7])
				);

endmodule
