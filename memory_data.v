module data(
    input clk,
    input mem_write,
    input mem_read,
    input [31:0]addr,
    input [31:0]write_data,
    output [31:0]read_data
);
reg [31:0]memory[63:0];
always @(posedge clk) begin
    if(mem_write) begin
      memory[addr[7:2]]<=write_data;
    end
end
assign read_data=(mem_read)?memory[addr[7:2]]:32'd0;

endmodule