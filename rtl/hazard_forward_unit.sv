import riscv_pkg::*;

module hazard_forward_unit (
    input logic [REG_ADDR_BITS-1:0] id_rs1_addr,
    input logic [REG_ADDR_BITS-1:0] id_rs2_addr,
    input logic [REG_ADDR_BITS-1:0] ex_rd_addr,
    input logic [1:0] ex_wb_sel,
    input logic [REG_ADDR_BITS-1:0] ex_rs1_addr,
    input logic [REG_ADDR_BITS-1:0] ex_rs2_addr,
    input logic [REG_ADDR_BITS-1:0] mem_rd_addr,
    input logic mem_reg_write,
    input logic [REG_ADDR_BITS-1:0] wb_rd_addr,
    input logic wb_reg_write,
    output logic stall,
    output logic [1:0] forward_a,
    output logic [1:0] forward_b
);

    always_comb begin
        //stall logic
        stall = (ex_wb_sel == 2'b01) && (ex_rd_addr != 5'd0) && ((ex_rd_addr == id_rs1_addr) || (ex_rd_addr == id_rs2_addr));
        //forward_a logic
        if (mem_reg_write && (mem_rd_addr != 5'd0) && (mem_rd_addr == ex_rs1_addr)) begin
            forward_a = 2'b01;
        end else if (wb_reg_write && (wb_rd_addr != 5'd0) && (wb_rd_addr == ex_rs1_addr)) begin
            forward_a = 2'b10;
        end else begin
            forward_a = 2'b00;
        end
        //forward b logic
        if (mem_reg_write && (mem_rd_addr != 5'd0) && (mem_rd_addr == ex_rs2_addr)) begin
            forward_b = 2'b01;
        end else if (wb_reg_write && (wb_rd_addr != 5'd0) && (wb_rd_addr == ex_rs2_addr)) begin
            forward_b = 2'b10;
        end else begin
            forward_b = 2'b00;
        end
    end

endmodule