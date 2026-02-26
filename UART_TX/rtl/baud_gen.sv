module baud_gen#(
  parameter CLK_FREQ = 50_000_000,
  parameter BAUD = 9600
)(
  input logic clk,
  input logic rst_n,
  output logic tick
);
  localparam int DIVISOR  = CLK_FREQ / BAUD;
  
  logic [$clog2(DIVISOR)-1 : 0] counter;

  always_ff @(posedge clk or negedge rst_n) begin 
    if(~rst_n) begin 
      counter <= 0;
      tick <= 0;
    end else begin 
      if(counter == DIVISOR -1)begin
        counter <= 0;
        tick <= 1;
      end else begin 
        counter <= counter +1;
        tick <= 0;
      end
    end
  end

endmodule