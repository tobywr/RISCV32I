import riscv_pkg::*;

module writeback_mux (
    input logic [1:0] wb_sel,
    input logic [DATA_WIDTH-1:0] alu_result,
    input logic [DATA_WIDTH-1:0] mem_read_data,
    input logic [ADDR_WIDTH-1:0] pc_plus_4,
    output logic [DATA_WIDTH-1:0] write_data
);

    always_comb begin
        case (wb_sel)
            2'b00: write_data = alu_result;
            2'b01: write_data = mem_read_data;
            2'b10: write_data = pc_plus_4;
            default: write_data = alu_result;
        endcase
    end 

endmodule