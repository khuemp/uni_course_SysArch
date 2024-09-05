module Decoder(
	input     [31:0] instr,      // Instruktionswort
	input            zero,       // Liefert aktuelle Operation im Datenpfad 0 als Ergebnis?
	output reg       memtoreg,   // Verwende ein geladenes Wort anstatt des ALU-Ergebis als Resultat
	output reg       memwrite,   // Schreibe in den Datenspeicher
	output reg       dobranch,   // Führe einen relativen Sprung aus
	output reg       alusrcbimm, // Verwende den immediate-Wert als zweiten Operanden
	output reg [4:0] destreg,    // Nummer des (möglicherweise) zu schreibenden Zielregisters
	output reg       regwrite,   // Schreibe ein Zielregister
	output reg       dojump,     // Führe einen absoluten Sprung aus
	output reg [2:0] alucontrol,  // ALU-Kontroll-Bits
	output reg       loadhi, loadlo, //Add loadhi, loadlo multiplexer
	output reg		 writehilo, //Add writehilo multiplexer
	output reg 		 jumpregister, //Addd jumpregister multiplexer
	output reg		 jal //Add jal multiplexer
);
	// Extrahiere primären und sekundären Operationcode
	wire [5:0] op = instr[31:26];
	wire [5:0] funct = instr[5:0];
	wire [15:0] immediate = instr[15:0];

	always @*
	begin
		case (op)
			6'b000000: // Rtype Instruktion
				begin
					regwrite = 1;
					destreg = instr[15:11];
					alusrcbimm = 0;
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
					loadhi = 0;
					loadlo = 0;
					writehilo = 0;
					jumpregister = 0;
					jal = 0;
					case (funct)
						6'b100001: alucontrol = 3'b010; // DONE // Addition unsigned
						6'b100011: alucontrol = 3'b110; // DONE // Subtraktion unsigned
						6'b100100: alucontrol = 3'b000; // DONE // and
						6'b100101: alucontrol = 3'b001; // DONE // or
						6'b101011: alucontrol = 3'b111; // DONE // set-less-than unsigned
						//DONE: Implement Move From HI register
						6'b010000: begin
								   alucontrol = 3'bx;
								   loadhi = 1;
						end
						//DONE: Implement Move From LO register
						6'b010010: begin
								   alucontrol = 3'bx;
								   loadlo = 1;
						end
						//DONE: Implement MULTU
						6'b011001: begin
								   regwrite = 0;
								   destreg = 5'bx;
							 	   alucontrol = 3'b011;
								   writehilo = 1;
						end		
						//DONE: Implement Jump Register
						6'b001000: begin
								   regwrite = 0;
								   destreg = 5'bx;
								   alucontrol = 3'bx;
								   dojump = 1;
								   jumpregister = 1;
						end	
						default:   alucontrol = 3'bx;// DONE // undefiniert
					endcase
				end
			6'b100011, // Lade Datenwort aus Speicher
			6'b101011: // Speichere Datenwort
				begin
					regwrite = ~op[3];
					destreg = instr[20:16];
					alusrcbimm = 1;
					dobranch = 0;
					memwrite = op[3];
					memtoreg = 1;
					dojump = 0;
					alucontrol = 3'b010; // DONE // Addition effektive Adresse: Basisregister + Offset
					loadhi = 0;
					loadlo = 0;
					writehilo = 0;
					jumpregister = 0;
					jal = 0;
				end
			6'b000100: // Branch Equal
				begin
					regwrite = 0;
					destreg = 5'bx;
					alusrcbimm = 0;
					dobranch = zero; // Gleichheitstest
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
					alucontrol = 3'b110; // DONE // Subtraktion
					loadhi = 0;
					loadlo = 0;
					writehilo = 0;
					jumpregister = 0;
					jal = 0;
				end
			6'b001001: // Addition immediate unsigned
				begin
					regwrite = 1;
					destreg = instr[20:16];
					alusrcbimm = 1;
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
					alucontrol = 3'b010; // DONE // Addition
					loadhi = 0;
					loadlo = 0;
					writehilo = 0;
					jumpregister = 0;
					jal = 0;
				end
			6'b000010: // Jump immediate
				begin
					regwrite = 0;
					destreg = 5'bx;
					alusrcbimm = 0;
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 1;
					alucontrol = 3'bx; // DONE // Don't care (end of silde deck 12)
					loadhi = 0;
					loadlo = 0;
					writehilo = 0;
					jumpregister = 0;
					jal = 0;
				end
			//DONE: Implement LUI
			6'b001111: // Load Upper Immediate
				begin
					regwrite = 1; // write in register
					destreg = instr[20:16]; // write result in rt
					alusrcbimm = 1; //use immediate as b
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
					alucontrol = 3'b100; //shift left logical 16 bits (fills with 0)
					loadhi = 0;
					loadlo = 0;
					writehilo = 0;
					jumpregister = 0;
					jal = 0;
				end
			//DONE: Implement ORI
			6'b001101: // Or Immediate
				begin
					regwrite = 1; // write in register
					destreg = instr[20:16]; // write result in rt
					alusrcbimm = 1;
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
					alucontrol = 3'b001; // or
					loadhi = 0;
					loadlo = 0;
					writehilo = 0;
					jumpregister = 0;
					jal = 0;
				end
			//DONE: Implement BNE
			6'b000101: // Branch on Not Equal
				begin
					regwrite = 0;
					destreg = 5'bx;
					alusrcbimm = 0;
					dobranch = !zero; // Test for unequality
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
					alucontrol = 3'b110; // Subtraction
					loadhi = 0;
					loadlo = 0;
					writehilo = 0;
					jumpregister = 0;
					jal = 0;
				end
			//DONE: Implement JAL
			6'b000011: //Jump And Link
				begin
					regwrite = 1;
					destreg = 5'b11111;
					alusrcbimm = 0;
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 1;
					alucontrol = 3'bx;
					loadhi = 0;
					loadlo = 0;
					writehilo = 0;
					jumpregister = 0;
					jal = 1;
				end
			default: // Default Fall
				begin
					regwrite = 1'bx;
					destreg = 5'bx;
					alusrcbimm = 1'bx;
					dobranch = 1'bx;
					memwrite = 1'bx;
					memtoreg = 1'bx;
					dojump = 1'bx;
					alucontrol = 3'bx; // DONE
					loadhi = 0;
					loadlo = 0;
					writehilo = 0;
					jumpregister = 0;
					jal = 0;
				end
		endcase
	end
endmodule

