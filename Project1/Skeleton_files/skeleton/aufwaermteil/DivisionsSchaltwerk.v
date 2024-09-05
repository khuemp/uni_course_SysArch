module Division(
	input         clock,
	input         start,
	input  [31:0] a,
	input  [31:0] b,
	output [31:0] q,
	output [31:0] r
);

	// DONE Implementierung
	reg [31:0] R;
	reg [31:0] B;
	reg [31:0] AandQ;

	reg [5:0] counter;

	always @(posedge clock) begin

		if (start) begin //if start == 1 reset A, B, R, Q and counter
			AandQ <= a;
			B <= b;
			R <= 32'd0;
			counter <= 6'd0;
		end else begin
			
			if (counter < 32) begin

				counter = counter + 1'd1;

				if (R + R + AandQ[31] < B) begin
					R <= R + R + AandQ[31];
					AandQ <= AandQ << 1; //remove A[31] and add Q[31] = 0
				end else begin
					R <= R + R + AandQ[31] - B;
					AandQ <= (AandQ << 1) + 1'd1;
				end

			end

		end

	end

	assign q = AandQ; //after loop AandQ will completely become Q
	assign r = R;

endmodule

