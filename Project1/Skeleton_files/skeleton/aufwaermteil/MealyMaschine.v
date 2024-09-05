module MealyPattern(
	input        clock,
	input        i,
	output [1:0] o
);

// DONE Implementierung

	parameter s0 = 2'b00; //4 states are required
	parameter s1 = 2'b01;
	parameter s01 = 2'b10;
	parameter s10 = 2'b11;

	reg [1:0] currentState;
	reg [1:0] nextState;

	reg [1:0] out;

	initial begin 
		begin
			if (i) begin //find initial state
				nextState = s1;
			end else begin
				nextState = s0;
			end

			out = 2'b00; //set initial output
		end
	end

	always @(negedge clock) begin //for negedge detect 101 and 010
		
		currentState = nextState;

		case (currentState)

			s1: if (i) begin
				out = 2'b00;
				nextState = s1;
			end else begin
				out = 2'b00;
				nextState = s10;
			end

			s10: if (i) begin
				out = 2'b10;
				nextState = s01;
			end else begin
				out = 2'b00;
				nextState = s0;
			end

			s0: if (i) begin
				out = 2'b00;
				nextState = s01;
			end else begin
				out = 2'b00;
				nextState = s0;
			end

			s01: if (i) begin
				out = 2'b00;
				nextState = s1;
			end else begin
				out = 2'b01;
				nextState = s10;
			end
		endcase
	end

	always @(posedge clock) begin // output 00 if posedge
		out = 2'b00;
	end

	assign o = out;

endmodule

module MealyPatternTestbench();

	// DONE Input Stimuli

	//inputs
	reg i;
	reg clock;

	//output
	wire [1:0] o;

	MealyPattern machine(.clock(clock), .i(i), .o(o));

	// DONE Überprüfe Ausgaben

	initial begin //set input
		i = 0;
		#10
		i = 1;
		#10
		i = 1;
		#10
		i = 0;
		#10
		i = 1;
		#10
		i = 0;
		#10
		i = 1;
		#10
		i = 0;
		#10
		i = 1;
		#10
		i = 1;
	end

	initial begin //set clock
		clock = 0;
	end
	always
		#5
		clock = !clock;

	initial begin //set time 100
		#100 $finish;
	end

	initial begin //create waveform file
		$dumpfile("MealyMaschine.vcd");
		$dumpvars;
	end



endmodule

