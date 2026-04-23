module router_top(clock,resetn,pkt_valid,read_enb_0,read_enb_1,read_enb_2,data_in,vld_out_0,vld_out_1,vld_out_2,err,busy,data_out_0,data_out_1,data_out_2);
    input clock, resetn, pkt_valid, read_enb_0, read_enb_1, read_enb_2;
    input [7:0] data_in;
    output vld_out_0, vld_out_1, vld_out_2, err, busy;
    output [7:0] data_out_0, data_out_1, data_out_2;
    
    // Internal Wires
    wire [2:0] write_enb;
    wire [7:0] dout;
    wire parity_done, low_pkt_valid, detect_add, ld_state, laf_state, full_state, lfd_state, wr_en_reg, rst_int_reg;
    wire soft_reset_0, soft_reset_1, soft_reset_2, fifo_full;
    wire empty_0, empty_1, empty_2, full_0, full_1, full_2;

    fsm fsm_inst (
        .clk(clock), .rst(resetn), .pktvalid(pkt_valid), .parity_done(parity_done),
        .srst0(soft_reset_0), .srst1(soft_reset_1), .srst2(soft_reset_2),
        .fifofull(fifo_full), .lowpktvalid(low_pkt_valid),
        .fifoe0(empty_0), .fifoe1(empty_1), .fifoe2(empty_2),
        .din(data_in[1:0]), .detect_add(detect_add), .ld_state(ld_state),
        .laf_state(laf_state), .full_state(full_state), .lfd_state(lfd_state),
        .we_en_reg(wr_en_reg), .rst_int_reg(rst_int_reg), .busy(busy)
    );

    sync sync_inst (
        .clk(clock), .rst(resetn), .detect_add(detect_add), .wr_en_reg(wr_en_reg),
        .din(data_in[1:0]), .e0(empty_0), .e1(empty_1), .e2(empty_2),
        .f0(full_0), .f1(full_1), .f2(full_2), .re0(read_enb_0), .re1(read_enb_1),
        .re2(read_enb_2), .we(write_enb), .fifofull(fifo_full),
        .srst0(soft_reset_0), .srst1(soft_reset_1), .srst2(soft_reset_2),
        .vldout0(vld_out_0), .vldout1(vld_out_1), .vldout2(vld_out_2)
    );

    register reg_inst (
        .clk(clock), .rst(resetn), .pktvalid(pkt_valid), .fifofull(fifo_full),
        .rst_int_reg(rst_int_reg), .detect_add(detect_add), .ld_state(ld_state),
        .laf_state(laf_state), .full_state(full_state), .lfd_state(lfd_state),
        .din(data_in), .parity_done(parity_done), .lowpktvalid(low_pkt_valid),
        .err(err), .dout(dout)
    );

    router_fifo f0 (
        .clk(clock), .resetn(resetn), .soft_reset(soft_reset_0), .w_en(write_enb[0]),
        .r_en(read_enb_0), .lfd_state(lfd_state), .d_in(dout),
        .d_out(data_out_0), .empty(empty_0), .full(full_0)
    );
    
    router_fifo f1 (
        .clk(clock), .resetn(resetn), .soft_reset(soft_reset_1), .w_en(write_enb[1]),
        .r_en(read_enb_1), .lfd_state(lfd_state), .d_in(dout),
        .d_out(data_out_1), .empty(empty_1), .full(full_1)
    );
    
    router_fifo f2 (
        .clk(clock), .resetn(resetn), .soft_reset(soft_reset_2), .w_en(write_enb[2]),
        .r_en(read_enb_2), .lfd_state(lfd_state), .d_in(dout),
        .d_out(data_out_2), .empty(empty_2), .full(full_2)
    );
endmodule