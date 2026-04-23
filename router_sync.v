module sync(clk,rst,detect_add,wr_en_reg,din,e0,e1,e2,f0,f1,f2,re0,re1,re2,we,fifofull,srst0,srst1,srst2,vldout0,vldout1,vldout2);
    input clk,rst,detect_add,wr_en_reg,e0,e1,e2,f0,f1,f2,re0,re1,re2;
    input [1:0] din;

    output reg [2:0] we;
    output reg fifofull,srst0,srst1,srst2;
    output vldout0,vldout1,vldout2;
    
    reg [1:0] temp_reg;
    reg [4:0] timer_0, timer_1, timer_2;

    // Internal address logic
    always @(posedge clk) begin
        if(!rst)
            temp_reg <= 0;
        else if(detect_add)
            temp_reg <= din;
    end

    // Write Enable Logic
    always @(*) begin
        we = 3'b000;
        if (wr_en_reg) begin
            case(temp_reg)
                2'b00 : we = 3'b001;
                2'b01 : we = 3'b010;
                2'b10 : we = 3'b100;
                default: we = 3'b000;
            endcase
        end
    end

    // FIFO Full Logic
    always@(*) begin
        case(temp_reg)
            2'b00 : fifofull = f0;
            2'b01 : fifofull = f1;
            2'b10 : fifofull = f2;
            default: fifofull = 1'b0;
        endcase
    end

    // Soft Reset 0
    always @(posedge clk) begin
        if(!rst) begin
            timer_0 <= 0;
            srst0 <= 0;
        end
        else if(vldout0) begin
            if((~re0) && (timer_0 == 29)) begin
                srst0 <= 1'b1;
                timer_0 <= 5'b0;
            end
            else begin
                srst0 <= 1'b0;
                timer_0 <= timer_0 + 1'b1;
            end
        end
        else begin
            srst0 <= 1'b0;
            timer_0 <= 5'b0;
        end
    end

    // Soft Reset 1
    always @(posedge clk) begin
        if(!rst) begin
            timer_1 <= 0;
            srst1 <= 0;
        end
        else if(vldout1) begin
            if((~re1) && (timer_1 == 29)) begin
                srst1 <= 1'b1;
                timer_1 <= 5'b0;
            end
            else begin
                srst1 <= 1'b0;
                timer_1 <= timer_1 + 1'b1;
            end
        end
        else begin
            srst1 <= 1'b0;
            timer_1 <= 5'b0;
        end
    end

    // Soft Reset 2
    always @(posedge clk) begin
        if(!rst) begin
            timer_2 <= 0;
            srst2 <= 0;
        end
        else if(vldout2) begin
            if((~re2) && (timer_2 == 29)) begin
                srst2 <= 1'b1;
                timer_2 <= 5'b0;
            end
            else begin
                srst2 <= 1'b0;
                timer_2 <= timer_2 + 1'b1;
            end
        end
        else begin
            srst2 <= 1'b0;
            timer_2 <= 5'b0;
        end
    end
 
    assign vldout0 = ~e0;
    assign vldout1 = ~e1;
    assign vldout2 = ~e2;
endmodule