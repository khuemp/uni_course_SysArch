module Datapath(
	input         clk, reset,
	input         memtoreg,
	input         dobranch,
	input         alusrcbimm,
	input  [4:0]  destreg,
	input         regwrite,
	input         jump,
	input  [2:0]  alucontrol,
	output        zero,
	output [31:0] pc,
	input  [31:0] instr,
	output [31:0] aluout,
	output [31:0] writedata,
	input  [31:0] readdata,
	input		  loadhi, loadlo, //Add loadhi, loadlo multiplexer
	input		  writehilo, //Add writehilo multiplexer
	output [31:0] aluhi, alulo, //Add output of HI and LO for ALU
	output [31:0] hiout, loout, //Add output for register LO
	input 		  jumpregister, //Add jumpregister multiplexer
	input		  jal, //Add jal multiplexer
	output [31:0] pcplus4 //Add output pcplus4
);
	wire [31:0] pc;
	wire [31:0] signimm;
	wire [31:0] srca, srcb, srcbimm;
	reg  [31:0] result;
	reg  [31:0] hiin, loin; //Add input for register HI(can be changed so we need reg instead of input)

	// Fetch: Reiche PC an Instruktionsspeicher weiter und update PC
	ProgramCounter pcenv(clk, reset, dobranch, signimm, jump, instr[25:0], pc, jumpregister, srca, jal, pcplus4); //use scra instead of istr[25:21]

	// Execute:
	// (a) Wähle Operanden aus
	SignExtension se(instr[15:0], signimm);
	assign srcbimm = alusrcbimm ? signimm : srcb;
	// (b) Führe Berechnung in der ALU durch
	ArithmeticLogicUnit alu(srca, srcbimm, alucontrol, aluout, zero, aluhi, alulo);
	//choose hiout/loout or aluhi/alulo tobe new hiin/loin
	always @* begin
		if(writehilo) begin
			hiin = aluhi;
			loin = alulo;
		end else begin
			hiin = hiout;
			loin = loout;
		end
	end
	HI hi(hiin, hiout);
	LO lo(loin, loout);
	// (c) Wähle richtiges Ergebnis aus
	always @* begin
		if (memtoreg) begin
			result = readdata;
		end else begin
			if (loadhi) begin
				result = hiout;
			end else begin
				if (loadlo) begin
					result = loout;
				end else begin
					if (jal) begin
						result = pcplus4;
					end else begin
						result = aluout;
					end
				end
			end
		end
	end

	// Memory: Datenwort das zur (möglichen) Speicherung an den Datenspeicher übertragen wird
	assign writedata = srcb;

	// Write-Back: Stelle Operanden bereit und schreibe das jeweilige Resultat zurück
	RegisterFile gpr(clk, regwrite, instr[25:21], instr[20:16],
				   destreg, result, srca, srcb, jal);
endmodule

module ProgramCounter(
	input         clk,
	input         reset,
	input         dobranch,
	input  [31:0] branchoffset,
	input         dojump,
	input  [25:0] jumptarget,
	output [31:0] progcounter,
	input		  jumpregister, //Add input jumpregister
	input  [31:0] addresstojump, //Add input registertojump
	input 		  jal, //Add input jal
	output [31:0] pcplus4 //Add output pcplus4
);
	reg  [31:0] pc;
	wire [31:0] incpc, branchpc, nextpc;
	reg  [31:0] nextpcreg; //Add register nextpc to use if else

	// Inkrementiere Befehlszähler um 4 (word-aligned)
	Adder pcinc(.a(pc), .b(32'b100), .cin(1'b0), .y(incpc));
	assign pcplus4 = (jal) ? incpc : pcplus4;
	// Berechne mögliches (PC-relatives) Sprungziel
	Adder pcbranch(.a(incpc), .b({branchoffset[29:0], 2'b00}), .cin(1'b0), .y(branchpc));
	// Wähle den nächsten Wert des Befehlszählers aus
	always @* begin
		if (dojump) begin
			if (jumpregister) begin
				nextpcreg = addresstojump;
			end else begin
				nextpcreg = {incpc[31:28], jumptarget, 2'b00};
			end
		end else begin
			if (dobranch) begin
				nextpcreg = branchpc;
			end else begin
				nextpcreg = incpc;
			end
		end
	end
	assign nextpc = nextpcreg;

	// Der Befehlszähler ist ein Speicherbaustein
	always @(posedge clk)
	begin
		if (reset) begin // Initialisierung mit Adresse 0x00400000
			pc <= 'h00400000;
		end else begin
			pc <= nextpc;
		end
	end

	// Ausgabe
	assign progcounter = pc;

endmodule

module RegisterFile(
	input         clk,
	input         we3,
	input  [4:0]  ra1, ra2, wa3,
	input  [31:0] wd3,
	output [31:0] rd1, rd2,
	input 		  jal //Add jal input
);
	reg [31:0] registers[31:0];
	reg [31:0] rd1reg, rd2reg;

	always @(posedge clk)
		if (we3) begin
			registers[wa3] <= wd3;
		end

	always @* begin
		if(!jal) begin
			if(ra1 != 0) begin
				rd1reg = registers[ra1];
			end else begin
				rd1reg = 0;
			end
			if (ra2 != 0) begin
				rd2reg = registers[ra2];
			end else begin
				rd2reg = 0;
			end
		end
	end
	assign rd1 = rd1reg;
	assign rd2 = rd2reg;
endmodule

module Adder(
	input  [31:0] a, b,
	input         cin,
	output [31:0] y,
	output        cout
);
	assign {cout, y} = a + b + cin;
endmodule

module SignExtension(
	input  [15:0] a,
	output [31:0] y
);
	assign y = {{16{a[15]}}, a};
endmodule

module ArithmeticLogicUnit(
	input  [31:0] a, b,
	input  [2:0]  alucontrol,
	output [31:0] result,
	output        zero,
	output reg [31:0] aluhi, //add output HI, LO of ALU
	output reg [31:0] alulo 
);

	// DONE Implementierung der ALU

	reg [31:0] res;
	reg [63:0] mul;

	always @* begin

		case (alucontrol)

			3'b000: res = a&b;
			3'b001: res = a|b;
			3'b010: res = a + b;
			3'b110: res = a - b;
			3'b111:
					if (a<b) begin
						res = 32'b1;
					end else begin
						res = 32'b0;
					end
			//DONE: Implement shift left logical 16 bits (fills with 0) (for LUI)
			3'b100: res = b<<16;
			//DONE: Implement multiplication, give out result for HI and LO
			3'b011: begin
					mul = a*b;
					aluhi = mul[63:32];
					alulo = mul[31:0];
			end
			default: res = a + b; 

		endcase

	end
	
	assign result = res;
	assign zero = (res == 32'b0) ? (1'b1) : (1'b0);

endmodule

module HI(
	input		[31:0] 	hiin,
	output 		[31:0] 	hiout
);
	assign hiout = hiin;
endmodule

module LO(
	input		[31:0]	loin,
	output 		[31:0] 	loout
);
	assign loout = loin;
endmodule