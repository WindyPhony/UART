module uart_tx#(
  parameter CLK_FREQ = 50_000_000,
  parameter BAUD = 9600
)(
  input logic clk,
  input logic rst_n,
  input logic tx_start,
  input logic [7:0] data_in,
  output logic tx_out,
  output logic tx_busy
);
 //Baud tick generator
 logic baud_tick;
 baud_gen#(
   .CLK_FREQ (CLK_FREQ),
   .BAUD(BAUD)
) baud_inst(
   .clk (clk),
   .rst_n (rst_n),
   .tick (baud_tick)
);
  //FSM states
  typedef enum logic [1:0] {
    IDLE  = 2'b00,
    START = 2'b01,
    DATA  = 2'b10,
    STOP  = 2'b11
  } state_t;

  state_t state, next_state;
  
  //data_path signals
  logic [7:0] shift_reg;
  logic [3:0] bit_cnt;
  
  // state register
  always_ff @(posedge clk or negedge rst_n)begin 
    if (~rst_n)begin 
      state <= IDLE;  
    end else if (baud_tick) begin 
      state <= next_state;
    end
  end

  // next_state logic 

  always_comb begin 

    unique case (state)
    IDLE: next_state = (tx_start) ? START : IDLE;
    START: next_state = DATA;   
    DATA: next_state = (bit_cnt == 4'd7) ? STOP: DATA;
    STOP: next_state = IDLE;
    endcase
  end

  // shift_reg, bit count
  always_ff @(posedge clk or negedge rst_n)begin 
    if(!rst_n)begin 
      shift_reg <= 0;
      bit_cnt <= 0;
    end else if (baud_tick) begin 
      case (state) 
        IDLE: begin 
          if(tx_start) begin 
            shift_reg <= data_in;
            bit_cnt<=0;
          end
        end
        DATA: begin 
            shift_reg <= {1'b0,shift_reg[7:1]};
            bit_cnt <= bit_cnt + 1;
        end
      endcase
    end
  end

  //output
  always_comb begin 
    case (state) 
      IDLE : tx_out = 1;
      START: tx_out = 0;
      DATA : tx_out = shift_reg[0];
      STOP : tx_out = 1;
    endcase
  end

  assign tx_busy = (state != IDLE);

endmodule
