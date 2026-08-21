import riscv_pkg::*;

module forward_b (
    input logic [DATA_WIDTH-1:0] read_data2,
    input logic [DATA_WIDTH-1:0] alu_result,
    input logic [DATA_WIDTH-1:0] write_data,
    input logic [1:0] forward_b,
    output logic [DATA_WIDTH-1:0] operand_b_val
);

always_comb begin
    case(forward_b)
        2'b00: begin
            operand_b_val = read_data2;
        end
        2'b01: begin
            operand_b_val = alu_result;
        end
        2'b10: begin
            operand_b_val = write_data;
        end
        default: operand_b_val = read_data2; //default val stop illegal state.
    endcase
end

endmodule