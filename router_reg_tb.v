module register_tb();

reg clk, rst, pktvalid, fifofull, rst_int_reg, detect_add, ld_state, laf_state, full_state, lfd_state;
reg [7:0] din;

wire parity_done, lowpktvalid, err;
wire [7:0] dout;
integer i;

// Named Instantiation
register DUT (
    .clk(clk), .rst(rst), .pktvalid(pktvalid), .fifofull(fifofull),
    .rst_int_reg(rst_int_reg), .detect_add(detect_add), .ld_state(ld_state),
    .laf_state(laf_state), .full_state(full_state), .lfd_state(lfd_state),
    .din(din), .parity_done(parity_done), .lowpktvalid(lowpktvalid),
    .err(err), .dout(dout)
);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

task reset;
begin
    @(negedge clk) rst = 1'b0;
    @(negedge clk) rst = 1'b1;
end
endtask

task packet1();
    reg [7:0] header, payload_data, parity;
    reg [5:0] payload_len;
begin
    @(negedge clk);
    payload_len = 14;
    parity = 0;
    detect_add = 1;
    pktvalid = 1;
    header = {payload_len, 2'b10};
    din = header;
    parity = parity ^ din;
    
    @(negedge clk);
    detect_add = 0;
    lfd_state = 1;
    
    for (i=0; i<payload_len; i=i+1) begin
        @(negedge clk);
        lfd_state = 0;
        ld_state = 1;
        payload_data = {$random}%256;
        din = payload_data;
        parity = parity ^ din;
    end
    
    @(negedge clk);
    pktvalid = 0;
    din = parity;
    
    @(negedge clk);
    ld_state = 0;
end
endtask

initial begin
    // Added initialize logic properly
    {pktvalid, fifofull, rst_int_reg, detect_add, ld_state, laf_state, full_state, lfd_state} = 0;
    din = 8'b0;
    reset();
    
    #20;
    packet1();
    
    #20;
    @(negedge clk) rst_int_reg = 1;
    #20;
    @(negedge clk) rst_int_reg = 0;
    
    #50;
    $display("Register Simulation Completed.");
    $finish;
end

initial begin
    $monitor ("Time=%0t | clk=%b | reset=%b | din=%h | dout=%h | parity_done=%b | err=%b", 
              $time, clk, rst, din, dout, parity_done, err);
end

endmodule