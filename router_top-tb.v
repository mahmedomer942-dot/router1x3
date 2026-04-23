module router_top_tb();
    // Parameters for clarity
    parameter CLK_PERIOD = 10;

    reg clock, resetn, pkt_valid, read_enb_0, read_enb_1, read_enb_2;
    reg [7:0] data_in;
    wire vld_out_0, vld_out_1, vld_out_2, err, busy;
    wire [7:0] data_out_0, data_out_1, data_out_2;

    // Instantiation using Named Port Connection (Best Practice)
    router_top DUT (
        .clock(clock), .resetn(resetn), .pkt_valid(pkt_valid),
        .read_enb_0(read_enb_0), .read_enb_1(read_enb_1), .read_enb_2(read_enb_2),
        .data_in(data_in), .vld_out_0(vld_out_0), .vld_out_1(vld_out_1),
        .vld_out_2(vld_out_2), .err(err), .busy(busy),
        .data_out_0(data_out_0), .data_out_1(data_out_1), .data_out_2(data_out_2)
    );

    // Clock Generation
    initial begin
        clock = 1'b1;
        forever #(CLK_PERIOD/2) clock = ~clock;
    end

    // Tasks for modularity
    task initialize();
        begin
            resetn = 1'b1; // Active low reset should be high by default
            pkt_valid = 1'b0;
            {read_enb_0, read_enb_1, read_enb_2, data_in} = 0;
        end
    endtask

    task rst();
        begin
            @(negedge clock);
            resetn = 1'b0;
            @(negedge clock);
            resetn = 1'b1;
        end
    endtask

    task packet_gen(input [1:0] addr, input [5:0] len);
        integer i;
        reg [7:0] payload_data, parity, header;
        begin
            wait (~busy);
            @(negedge clock);
            header = {len, addr};
            data_in = header;
            pkt_valid = 1'b1;
            parity = 8'b0 ^ header;

            for(i = 0; i < len; i = i + 1) begin
                @(negedge clock);
                wait (~busy);
                payload_data = $random % 256;
                data_in = payload_data;
                parity = parity ^ data_in;
            end

            @(negedge clock);
            wait (~busy);
            pkt_valid = 1'b0;
            data_in = parity;
        end
    endtask

    // Main Test Sequence
    initial begin
        initialize();
        rst();
        #20;

        // Test Packet for Address 0
        packet_gen(2'b00, 6'd14);
        
        // Dynamic Read Logic
        @(negedge clock);
        if (vld_out_0) begin
            read_enb_0 = 1'b1;
            wait (~vld_out_0);
            @(negedge clock);
            read_enb_0 = 1'b0;
        end

        #100;
        $display("Simulation Finished Successfully");
        $finish;
    end

    // Performance Monitoring
    initial begin
        $monitor("Time=%0t | Busy=%b | Valid0=%b | DataOut0=%h | Err=%b", 
                 $time, busy, vld_out_0, data_out_0, err);
    end

endmodule