module sync_tb();

reg clk, rst, detect_add, wr_en_reg, e0, e1, e2, f0, f1, f2, re0, re1, re2;
reg [1:0] din;

wire [2:0] we;
wire fifofull, srst0, srst1, srst2, vldout0, vldout1, vldout2;

// Named Instantiation
sync DUT (
    .clk(clk), .rst(rst), .detect_add(detect_add), .wr_en_reg(wr_en_reg),
    .din(din), .e0(e0), .e1(e1), .e2(e2), .f0(f0), .f1(f1), .f2(f2),
    .re0(re0), .re1(re1), .re2(re2), .we(we), .fifofull(fifofull),
    .srst0(srst0), .srst1(srst1), .srst2(srst2), .vldout0(vldout0),
    .vldout1(vldout1), .vldout2(vldout2)
);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

task initialize;
begin
    rst = 0;
    detect_add = 0;
    wr_en_reg = 0;
    {re0, re1, re2, e0, e1, e2, f0, f1, f2} = 9'b0;
    din = 2'b0;
end
endtask

task reset;
begin
    @(negedge clk) rst = 1'b0;
    @(negedge clk) rst = 1'b1;
end
endtask

task delay();
begin
    #10; // Can also be synchronized with @(negedge clk) for better practice
end
endtask

task data(input [1:0] i);
begin
    @(negedge clk) din = i;
end
endtask

initial begin
    initialize();
    reset();
    delay();

    // Changed from decimal 01 to binary 2'b01 to avoid radix confusion
    data(2'b01); 

    @(negedge clk);
    detect_add = 1'b1;
    wr_en_reg = 1'b1;
    e1 = 1'b0;
    re1 = 1'b0;
    
    #350;
    @(negedge clk) re1 = 1'b1;
    delay();
    @(negedge clk) e1 = 1'b1;
    delay();
    @(negedge clk) f1 = 1'b1;

    delay(); delay();

    data(2'b10); // Changed 10 to 2'b10

    @(negedge clk);
    detect_add = 1'b1;
    wr_en_reg = 1'b1;
    e2 = 1'b0;
    re2 = 1'b0;
    
    #350;
    @(negedge clk) re2 = 1'b1;
    delay();
    @(negedge clk) e2 = 1'b1;
    delay();
    @(negedge clk) f2 = 1'b1;

    #50;
    $display("Synchronizer Simulation Completed.");
    $finish;
end

initial begin
    $monitor ("Time=%0t | data_in=%b | write_enable=%b | fifofull=%b", 
              $time, din, we, fifofull);
end

endmodule