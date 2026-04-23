module router_fifo(clk, resetn, soft_reset, w_en, r_en, lfd_state, d_in, d_out, empty, full);
    input clk, resetn, soft_reset, w_en, r_en, lfd_state;
    input [7:0] d_in;
    output reg [7:0] d_out;
    output empty, full;
    
    reg [4:0] w_ptr, r_ptr; // 5-bit pointers for 16-depth FIFO
    reg [5:0] count;
    reg [8:0] mem[15:0];    // 9-bit width to store lfd_state as MSB
    integer i;

    // Write Logic
    always@(posedge clk) begin
        if(!resetn) begin
            for(i=0; i<16; i=i+1) mem[i] <= 0;
        end
        else if(soft_reset) begin
            for(i=0; i<16; i=i+1) mem[i] <= 0;
        end
        else if(w_en && !full) begin
            // FIX: Use 4-bit addressing for memory [3:0]
            mem[w_ptr[3:0]] <= {lfd_state, d_in}; 
        end
    end

    // Read Logic
    always@(posedge clk) begin
        if(!resetn)
            d_out <= 8'h00;
        else if(soft_reset)
            d_out <= 8'h00; // FIX: Avoid High-Z in internal logic
        else if(r_en && !empty)
            d_out <= mem[r_ptr[3:0]][7:0]; // Read only data bits
    end

    // Pointer Management
    always@(posedge clk) begin
        if(!resetn || soft_reset) begin
            w_ptr <= 5'b0;
            r_ptr <= 5'b0;
        end
        else begin
            if(w_en && !full) w_ptr <= w_ptr + 1'b1;
            if(r_en && !empty) r_ptr <= r_ptr + 1'b1;
        end
    end

    // Counter Logic for payload
    always@(posedge clk) begin
        if(!resetn || soft_reset)
            count <= 0;
        else if(r_en && !empty) begin
            // FIX: Check bit 8 (lfd_state)
            if(mem[r_ptr[3:0]][8] == 1'b1) 
                count <= mem[r_ptr[3:0]][7:2] + 1'b1;
            else if(count != 6'd0)
                count <= count - 1'b1;
        end
    end

    // FIX: Standard VLSI Full/Empty Logic for cyclic FIFO
    assign empty = (r_ptr == w_ptr);
    assign full  = (w_ptr == {~r_ptr[4], r_ptr[3:0]});
endmodule