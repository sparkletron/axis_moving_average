//******************************************************************************
/// @FILE    axis_moving_average.v
/// @AUTHOR  JAY CONVERTINO
/// @DATE    2023.02.01
/// @BRIEF   AXIS moving average for unsigned numbers.
///
/// @LICENSE MIT
///  Copyright 2023 Jay Convertino
///
///  Permission is hereby granted, free of charge, to any person obtaining a copy
///  of this software and associated documentation files (the "Software"), to 
///  deal in the Software without restriction, including without limitation the
///  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
///  sell copies of the Software, and to permit persons to whom the Software is 
///  furnished to do so, subject to the following conditions:
///
///  The above copyright notice and this permission notice shall be included in 
///  all copies or substantial portions of the Software.
///
///  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
///  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
///  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
///  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
///  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
///  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
///  IN THE SOFTWARE.
//******************************************************************************

`timescale 1ns/100ps

module axis_moving_average 
 #(
    parameter BUS_WIDTH = 1,
    parameter WEIGHT    = 1
  )
  (
    input                     aclk,
    input                     arstn,
    // m axis
    output [8*BUS_WIDTH-1:0]  m_axis_tdata,
    output                    m_axis_tvalid,
    input                     m_axis_tready,
    // s axis
    input  [8*BUS_WIDTH-1:0]  s_axis_tdata,
    input                     s_axis_tvalid,
    output                    s_axis_tready
  );
  
  `include "util_helper_math.vh"
  
  //calculate the power of the weight
  localparam c_WEIGHT_POWER = clogb2(WEIGHT);
  //buffer size based on max bytes
  localparam c_BUF_SIZE     = cmax(c_WEIGHT_POWER, 8*BUS_WIDTH) * 2;
  
  integer index = 0;
  
  reg [8*BUS_WIDTH-1:0] r_buffer_data[(2**c_WEIGHT_POWER)-1:0];
  
  reg [c_BUF_SIZE-1:0] r_accumulator;
  
  //trim and shift data to get amount this is the divide out.
  assign m_axis_tdata = r_accumulator[(8*BUS_WIDTH+c_WEIGHT_POWER-1):c_WEIGHT_POWER];
  //single clock edge valid
  assign m_axis_tvalid = s_axis_tvalid;
  //we are ready if the destination is ready
  assign s_axis_tready = m_axis_tready;
  
  always @(posedge aclk) begin
    if(arstn == 1'b0) begin
      r_accumulator <= 0;
      
      //0 out buffer
      for(index = 0; index < 2**c_WEIGHT_POWER; index++) begin
        r_buffer_data[index] <= 0;
      end
      
//       $display("SIZE: %d %d %d", (2**c_WEIGHT_POWER), c_WEIGHT_POWER, c_BUF_SIZE);
    end else begin
      if(s_axis_tvalid == 1'b1) begin
      
        //add data
        r_accumulator <= r_accumulator + s_axis_tdata - r_buffer_data[2**c_WEIGHT_POWER-1];
        
        //push input data to 0th array element
        r_buffer_data[0] <= s_axis_tdata;
        
        //push data to next element in buffer
        for(index = 0; index < ((2**c_WEIGHT_POWER)-1); index++) begin
          r_buffer_data[index+1] <= r_buffer_data[index];
        end
      end
    end
  end
endmodule
