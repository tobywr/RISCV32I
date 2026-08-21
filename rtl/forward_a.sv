import riscv_pkg::*;

module forward_a (
    input logic [DATA_WIDTH-1:0] read_data1,
    input logic [DATA_WIDTH-1:0] alu_result,
    input logic [DATA_WIDTH-1:0] write_data,
    input logic [1:0] forward_a,
    output logic [DATA_WIDTH-1:0] operand_a_val
);

always_comb begin
    case(forward_a)
        2'b00: begin
            operand_a_val = read_data1;
        end
        2'b01: begin
            operand_a_val = alu_result;
        end
        2'b10: begin
            operand_a_val = write_data;
        end
        default: operand_a_val = read_data1; //default val stop illegal state.
    endcase
end

endmodule