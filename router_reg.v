module register(clk,rst,pktvalid,fifofull,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,din,parity_done,lowpktvalid,err,dout);
    input clk,rst,fifofull,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state;
    input pktvalid;
    input [7:0] din;

    output reg parity_done,lowpktvalid,err;
    output reg [7:0] dout;

    reg [7:0] header_byte, fifofull_state_byte, internal_parity, packet_parity;

    // Header and FIFOfull bytes
    always@(posedge clk) begin
        if(!rst) begin
            header_byte <= 0;
            fifofull_state_byte <= 0;
        end
        else begin
            if (pktvalid && detect_add)
                header_byte <= din;
            else if (ld_state && fifofull)
                fifofull_state_byte <= din;
        end
    end

    // Data Out
    always@(posedge clk) begin
        if(!rst)
            dout <= 0;
        else if(lfd_state)
            dout <= header_byte;
        else if(ld_state && !fifofull)
            dout <= din;
        else if(laf_state)
            dout <= fifofull_state_byte;
    end

    // Low Packet Valid
    always@(posedge clk) begin
        if(!rst)
            lowpktvalid <= 0;
        else if(rst_int_reg)
            lowpktvalid <= 0;
        else if(ld_state && !pktvalid)
            lowpktvalid <= 1;
    end

    // Parity Done
    always@(posedge clk) begin
        if(!rst)
            parity_done <= 0;
        else if(ld_state && !fifofull && !pktvalid)
            parity_done <= 1;
        else if (laf_state && lowpktvalid && !parity_done)
            parity_done <= 0;
        else if (detect_add)
            parity_done <= 0;
    end

    // Internal Parity Calculation
    always@(posedge clk) begin
        if(!rst)
            internal_parity <= 0;
        else if(detect_add) // FIX: Clear parity at new packet
            internal_parity <= 0;
        else if(lfd_state)
            internal_parity <= internal_parity ^ header_byte;
        else if(ld_state && pktvalid && !fifofull) // FIX: Rely on input signal
            internal_parity <= internal_parity ^ din;
    end

    // Packet Parity Latch
    always@(posedge clk) begin
        if(!rst)
            packet_parity <= 0;
        else if((ld_state && !fifofull && !pktvalid)||(laf_state && lowpktvalid && !parity_done))
            packet_parity <= din;
        else if (!pktvalid && rst_int_reg)
            packet_parity <= 0;
        else if(detect_add)
            packet_parity <= 0;
    end

    // Error Flag
    always@(posedge clk) begin
        if (!rst)
            err <= 0;
        else if(parity_done) begin
            if(internal_parity != packet_parity)
                err <= 1;
            else
                err <= 0;
        end
    end
endmodule