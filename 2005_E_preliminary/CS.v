`timescale 1ns/10ps
/*
 * IC Contest Computational System (CS)
*/
module CS(Y, X, reset, clk);

input       clk, reset; 
input       [7:0] X;
output reg  [9:0] Y;

reg      [7:0] data [8:0]; // 9x8-bit register file
reg      [11:0] sum;           // 9-bit accumulator
reg      [7:0] X_appr; 
integer i;

always @(posedge clk) begin
   data[0] <= X;
   if (reset) begin
      sum <= X;
      for (i = 1; i <= 8; i = i + 1)
         data[i] <= 0;
   end else begin
      sum <= sum - data[8] + X;
      for (i = 0; i < 9; i = i + 1)
         data[i+1] <= data[i];
   end
end

always @(*) begin
   X_appr = 0;
   if (X_appr <= data[0] && data[0] <= (sum/9))
      X_appr = data[0];
   if (X_appr <= data[1] && data[1] <= (sum/9))
      X_appr = data[1];
   if (X_appr <= data[2] && data[2] <= (sum/9))
      X_appr = data[2];
   if (X_appr <= data[3] && data[3] <= (sum/9))
      X_appr = data[3];
   if (X_appr <= data[4] && data[4] <= (sum/9))
      X_appr = data[4];
   if (X_appr <= data[5] && data[5] <= (sum/9))
      X_appr = data[5];
   if (X_appr <= data[6] && data[6] <= (sum/9))
      X_appr = data[6];
   if (X_appr <= data[7] && data[7] <= (sum/9))
      X_appr = data[7];
   if (X_appr <= data[8] && data[8] <= (sum/9))
      X_appr = data[8];
end

always @(negedge clk) begin
   Y <= (sum + (X_appr << 3) + X_appr) >> 8;
end
 
endmodule
