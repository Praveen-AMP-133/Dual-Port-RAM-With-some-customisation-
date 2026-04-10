module dual_port_ram #( //With some customisation
    parameter DEPTH = 8,
    parameter WIDTH = 8,
    parameter ALMOST_FULL_THRESH  = DEPTH-1,
    parameter ALMOST_EMPTY_THRESH = 1
)(
    //--------------------Input ports ----------------
    input clk_a,                         //Write clock                       
    input [$clog2(DEPTH)-1:0] addr_a,   // Write address

    input clk_b,                         //Read clock                
    input [$clog2(DEPTH)-1:0] addr_b,   // Read address

    input wr_en_a,                      //Write Enable                
    input rd_en_b,                      //Read Enable                
    input  [WIDTH-1:0] din,             //Input data    

    //---------------------output ports --------------------------
    output reg [WIDTH-1:0] dout,        //Output data    

    // Status flags
    output full,                        //RAM full checker
    output empty,                       //RAM empty checker
    output almost_full,                 //RAM threshold full 
    output almost_empty                 //RAM threshold empty
);

  // Memory
  reg [WIDTH-1:0] mem [0:DEPTH-1];       //Main RAM memory

  // Track valid entries
  reg valid [0:DEPTH-1];                 //Address Valid checker

  // Counter
  reg [$clog2(DEPTH):0] count = 0;       //Counter

  integer i;                             //Integer

  // Initialize valid bits (optional, for simulation)
  initial begin
    for (i = 0; i < DEPTH; i = i + 1)
      valid[i] = 0;
  end

  // Write Logic
  always @(posedge clk_a) begin  
    if (wr_en_a) begin
      mem[addr_a] <= din;

      // If writing to an empty location → increment count
      if (!valid[addr_a]) begin
        valid[addr_a] <= 1;
        count <= count + 1;
      end
    end
  end

  // Read Logic
  always @(posedge clk_b) begin
    if (rd_en_b) begin 
      dout <= mem[addr_b];

      // If reading a valid location → decrement count
      if (valid[addr_b]) begin
        valid[addr_b] <= 0;
        count <= count - 1;
      end
    end
  end

  // Status Flags
  assign full         = (count == DEPTH);
  assign empty        = (count == 0);
  assign almost_full  = (count >= ALMOST_FULL_THRESH);
  assign almost_empty = (count <= ALMOST_EMPTY_THRESH);

endmodule
