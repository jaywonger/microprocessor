module computational_unit(
	input clk, sync_reset,
	input [3:0] nibble_ir,
	input i_sel, x_sel, y_sel,
	input [3:0] source_sel,
	input [8:0] reg_en,
	input [3:0] i_pins,
	input [3:0] dm,
	output reg [3:0] data_bus,
	output reg [3:0] o_reg,
	output reg r_eq_0,
	output reg i
);

// Data bus sources
// i_pins and dm are external inputs, i is an output
wire [3:0] pm_data;
reg[3:0] m, r, y1, y0, x1, x0;

// ALU core input registers
reg[3:0] x,y;

// PM data immediate from instruction (ir_nibble). Not always valid data
assign pm_data = nibble_ir[3:0];

wire [2:0] alu_func;
wire reset_output;
reg[3:0] alu_out;
reg alu_out_eq_0;
wire[7:0] MULRES = x*y;

// need assign because of wires
// alu function to ir_nibble
assign alu_func = nibble_ir[2:0];
assign reset_output = sync_reset;

// ALU Logic
always @ *
if (reset_output)
	alu_out <= 4'h00;
else
	case(alu_func)
		3'd0: if(y_sel) 
					alu_out <= r;
				else
					alu_out <= -x;
		3'd1: alu_out <= x-y;
		3'd2: alu_out <= x+y;
		3'd3: alu_out <= MULRES[7:4];
		3'd4: alu_out <= MULRES[3:0];
		3'd5: alu_out <= x^y;
		3'd6: alu_out <= x&y;
		3'd7: if(y_sel)
					alu_out <= r;
				else
					alu_out <= ~x;
	endcase 

// ALU Eq 0 Logic
always @ *
	if (alu_out == 4'd0)
		alu_out_eq_0 <= 1'b1;
	else
		alu_out_eq_0 <= 1'b0;
		
// Data Bus
always @ *
	case (source_sel)
		4'h0: data_bus <= x0;
		4'h1: data_bus <= x1;
		4'h2: data_bus <= y0;
		4'h3: data_bus <= y1;
		4'h4: data_bus <= r;
		4'h5: data_bus <= m;
		4'h6: data_bus <= i;
		4'h7: data_bus <= dm;
		4'h8: data_bus <= pm_data;
		4'h9: data_bus <= i_pins;
		4'hA: data_bus <= 4'h0;
		4'hB: data_bus <= 4'h0;
		4'hC: data_bus <= 4'h0;
		4'hD: data_bus <= 4'h0;
		4'hE: data_bus <= 4'h0;
		4'hF: data_bus <= 4'h0;
	endcase 

// REGISTERS
// X Registers
always @ (posedge clk)
	if (reg_en[0])
		x0 = data_bus;
	else
		x0 = x0;
		
always @ (posedge clk)
	if (reg_en[1])
		x1 = data_bus;
	else
		x1 = x1;

// Y Registers	
always @ (posedge clk)
	if (reg_en[2])
		y0 = data_bus;
	else
		y0 = y0;
		
always @ (posedge clk)
	if (reg_en[3])
		y1 = data_bus;
	else
		y1 = y1;	

// Result Register
always @ (posedge clk)
	if (reg_en[4])
		r = alu_out;
	else
		r = r;
		
always @ (posedge clk)
	if (reg_en[4])
		r_eq_0 = alu_out_eq_0;
	else
		r_eq_0 = r_eq_0;

// M Register	
always @ (posedge clk)
	if (reg_en[5])
		m = data_bus;
	else
		m = m;

// I Register
always @ (posedge clk)
	if (reg_en[6])
		if (i_sel)
			i = m+i;
		else
			i = data_bus;
	else
		i = i;

// O Regiser		
always @ (posedge clk)
	if (reg_en[8])
		o_reg = data_bus;
	else
		o_reg = o_reg;
		
endmodule
