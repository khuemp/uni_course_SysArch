module MIPScore(
	input clk,
	input reset,
	// Kommunikation Instruktionsspeicher
	output [31:0] pc,
	input  [31:0] instr,
	// Kommunikation Datenspeicher
	output        memwrite,
	output [31:0] aluout, writedata,
	input  [31:0] readdata
);
	wire       memtoreg, alusrcbimm, regwrite, dojump, dobranch, zero, loadhi, loadlo, writehilo, jumpregister, jal;
	wire [4:0] destreg;
	wire [2:0] alucontrol;
	wire [31:0] aluhi, alulo, hiout, loout;
	wire [31:0] pcplus4;

	Decoder decoder(instr, zero, memtoreg, memwrite,
					dobranch, alusrcbimm, destreg,
					regwrite, dojump, alucontrol,
					loadhi, loadlo, writehilo, 
					jumpregister, jal);
	Datapath dp(clk, reset, memtoreg, dobranch,
				alusrcbimm, destreg, regwrite, dojump,
				alucontrol,
				zero, pc, instr,
				aluout, writedata, readdata,
				loadhi, loadlo, writehilo,
				aluhi, alulo, hiout, loout, 
				jumpregister, jal, pcplus4);
endmodule

