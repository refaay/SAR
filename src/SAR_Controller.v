/*******************************************************************
*
* Module: SAR_Controller.v
* Project: Successive Approximation Register (SAR) ADC Controller
* Author: Ahmed Refaay - refaay@aucegypt.edu
* Description: Full Successive Approximation Register (SAR) ADC Controller Circuit
*
* Change history: 02/17/18 – Created module
*                 02/23/18 – Finished module
*
**********************************************************************/

`include "src/global_numerics.v"

module SAR_Controller(clk, rst, go, cmp, sample, value, valid, result);
    parameter N = 8; // number of bits
    parameter S = 3; // number of sample cycles
    
    input wire [0:0] clk; // global clk
    input wire [0:0] rst; // global reset
    
    input wire [0:0] go; // to start sampling
    input wire [0:0] cmp; // analog op-amp output
    output reg [0:0] sample; // indicates that the conversion is in process
    output reg [N-1:0] value; // register to store the converted bits
    output reg [0:0] valid; // indicates that the conversion is finished
    output reg [N-1:0] result; // result output

    reg [4:0] counter; // 5-bits since the highest count is 16
    reg [3:0] counter2; // 4-bits for sample output control assuming the highest count is 15
    integer k;

    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            value <= {1'b1, {(N-1){1'd0}}};
            result <= {N{1'd0}};
            valid <= 1'd0;
            counter <= 5'd0;
            counter2 <= 4'd0;
            sample <= 1'd0;
        end
        else begin
            if(go) begin // initialize and sample on
                value <= {1'b1, {(N-1){1'd0}}};
                result <= result;
                valid <= 1'b0;
                counter <= 5'd0;
                counter2 <= 4'd1;
                sample <= 1'b1;
            end
            else begin
                if(sample) begin // sample till count
                    counter2 <= counter2 + 4'd1;
                    valid <= 1'b0;
                    value <= {1'b1, {(N-1){1'd0}}};
                    result <= result;
                    counter <= 5'd1;
                    if(counter2 >= S) begin
                        sample <= 1'd0;
                    end
                    else begin
                        sample <= sample;
                    end
                end
                else begin // begin actual conversion
                    counter2 <= 4'd0;
                    sample <= 1'd0;
                    if(counter >= N) begin // end conversion
                        valid <= 1'b1;
                        value <= value;
                        result <= value;
                        counter <= counter;
                    end
                    else begin
                        counter <= counter + 5'd1;
                        valid <= 1'b0;
                        result <= result;
                        for(k=0; k<N; k=k+1) begin // conversion algorithm
                            if(k == N-counter) 
                                value[k] <= cmp;
                            else if(k == N-counter-1) 
                                value[k] <= 1'b1;
                            else 
                                value[k] <= value[k];
                        end
                    end
                end 
            end
        end
    end
endmodule