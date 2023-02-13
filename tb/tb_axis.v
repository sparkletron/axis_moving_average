//******************************************************************************
/// @file    tb_top_axis.v
/// @author  JAY CONVERTINO
/// @date    2022.10.24
/// @brief   Generic AXIS test bench top with verification.
/// @details This generic top and mod axis test bench is created for a FIFO.
///          It will have to be altered for other devices that alter the input
///          for some sort of output.
//******************************************************************************

`timescale 1 ns/10 ps

module tb_axis;
  //parameter or local param bus, user and dest width? and files as well? 
  
  localparam BUS_WIDTH  = 2;
  localparam USER_WIDTH = 1;
  localparam DEST_WIDTH = 1;
  
  localparam CLK_PERIOD = 500;
  localparam RST_PERIOD = 1000;
  
  wire                      tb_dut_valid;
  wire                      tb_dut_ready;
  wire [(BUS_WIDTH*8)-1:0]  tb_dut_data;
  wire [BUS_WIDTH-1:0]      tb_dut_keep;
  wire                      tb_dut_last;
  wire [USER_WIDTH-1:0]     tb_dut_user;
  wire [DEST_WIDTH-1:0]     tb_dut_dest;
  
  wire                      tb_stim_clk;
  wire                      tb_stim_rstn;
  wire                      tb_stim_valid;
  wire [(BUS_WIDTH*8)-1:0]  tb_stim_data;
  wire [BUS_WIDTH-1:0]      tb_stim_keep;
  wire                      tb_stim_last;
  wire [USER_WIDTH-1:0]     tb_stim_user;
  wire [DEST_WIDTH-1:0]     tb_stim_dest;
  
  reg         tb_cnt_clk  = 0;
  reg         tb_cnt_rstn = 0;
  wire [8:0]  tb_cnt_data;
  
  // fst dump command
  initial begin
    $dumpfile ("tb_axis.fst");
    $dumpvars (0, tb_axis);
    #1;
  end
  
  clk_stimulus #(
    .CLOCKS(1), // # of clocks
    .CLOCK_BASE(1000000), // clock time base mhz
    .CLOCK_INC(1000), // clock time diff mhz
    .RESETS(1), // # of resets
    .RESET_BASE(2000), // time to stay in reset
    .RESET_INC(100) // time diff for other resets
  ) clk_stim (
    //clk out ... maybe a vector of clks with diff speeds.
    .clkv(tb_stim_clk),
    //rstn out ... maybe a vector of rsts with different off times
    .rstnv(tb_stim_rstn),
    .rstv()
  );
  
  slave_axis_stimulus #(
    .BUS_WIDTH(BUS_WIDTH),
    .USER_WIDTH(USER_WIDTH),
    .DEST_WIDTH(DEST_WIDTH),
    .FILE("in.bin")
  ) slave_axis_stim (
    // output to slave
    .m_axis_aclk(tb_stim_clk),
    .m_axis_arstn(tb_stim_rstn),
    .m_axis_tvalid(tb_stim_valid),
    .m_axis_tready(tb_stim_ready),
    .m_axis_tdata(tb_stim_data),
    .m_axis_tkeep(tb_stim_keep),
    .m_axis_tlast(tb_stim_last),
    .m_axis_tuser(tb_stim_user),
    .m_axis_tdest(tb_stim_dest)
  );
  
  axis_moving_average #(
    .BUS_WIDTH(BUS_WIDTH),
    .WEIGHT(8)
  ) dut (
    .aclk(tb_stim_clk),
    .arstn(tb_stim_rstn),
    // m axis
    .m_axis_tdata(tb_dut_data),
    .m_axis_tvalid(tb_dut_valid),
    .m_axis_tready(tb_dut_ready),
    // s axis
    .s_axis_tdata(tb_stim_data),
    .s_axis_tvalid(tb_stim_valid),
    .s_axis_tready(tb_stim_ready)
  );
  
  master_axis_stimulus #(
    .BUS_WIDTH(BUS_WIDTH),
    .USER_WIDTH(USER_WIDTH),
    .DEST_WIDTH(DEST_WIDTH),
    .FILE("out.bin")
  ) master_axis_stim (
    // write
    .s_axis_aclk(tb_stim_clk),
    .s_axis_arstn(tb_dut_rstn),
    .s_axis_tvalid(tb_dut_valid),
    .s_axis_tready(tb_dut_ready),
    .s_axis_tdata(tb_dut_data),
    .s_axis_tkeep(tb_dut_keep),
    .s_axis_tlast(tb_dut_last),
    .s_axis_tuser(tb_dut_user),
    .s_axis_tdest(tb_dut_dest)
  );
  
endmodule

