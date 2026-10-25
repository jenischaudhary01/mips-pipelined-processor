module mem_inst (
    input  wire [31:0] pc,
    output wire [31:0] instruction
);

    reg [31:0] mem [0:63];

    initial begin
        $readmemh("instruction.hex", mem);
    end

    assign instruction = mem[pc[7:2]];

endmodule