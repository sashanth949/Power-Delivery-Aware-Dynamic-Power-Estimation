module booth_mul_seq(
input wire clk,
    input wire rst_n,
    input wire start,

    input wire signed [3:0] x,
    input wire signed [3:0] y,

    output reg signed [7:0] z,
    output reg busy,
    output reg done
);

    reg signed [4:0] acc;
    reg [3:0] multiplier;
    reg E1;

    reg signed [4:0] m;
    reg [2:0] count;

    reg signed [4:0] a_temp;
    reg signed [9:0] combined;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc        <= 5'sd0;
            multiplier <= 4'd0;
            E1         <= 1'b0;
            m          <= 5'sd0;
            count      <= 3'd0;
            z          <= 8'sd0;
            busy       <= 1'b0;
            done       <= 1'b0;
        end
        else begin
            done <= 1'b0;

            // Accept a new multiplication request
            if (start && !busy) begin
                acc        <= 5'sd0;
                multiplier <= y;
                E1         <= 1'b0;
                m          <= {x[3], x};
                count      <= 3'd0;
                busy       <= 1'b1;
            end

            // Perform one Booth iteration per clock
            else if (busy) begin
                a_temp = acc;

                case ({multiplier[0], E1})
                    2'b01: a_temp = acc + m;
                    2'b10: a_temp = acc - m;
                    default: a_temp = acc;
                endcase

                // Arithmetic right shift of A, Q and Q-1
                combined = {a_temp, multiplier, E1};
                combined = combined >>> 1;

                acc        <= combined[9:5];
                multiplier <= combined[4:1];
                E1         <= combined[0];

                if (count == 3'd3) begin
                    // Final signed 8-bit product
                    z    <= {combined[8:5], combined[4:1]};
                    busy <= 1'b0;
                    done <= 1'b1;
                end
                else begin
                    count <= count + 1'b1;
                end
            end
        end
    end
endmodule
