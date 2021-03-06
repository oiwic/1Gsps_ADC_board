----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:40:03 12/09/2016 
-- Design Name: 
-- Module Name:    post_process - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
library UNISIM;
library UNIMACRO;
use UNIMACRO.vcomponents.all;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use UNISIM.vcomponents.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity post_process is
  generic (
    mult_accum_s_width : integer := 32;
    dds_phase_width : integer := 24;
    add_period_cnt : integer :=7 -- dsp:5/fabric:8
    );
  port(
    clk                  : in  std_logic;
    Q_data               : in  std_logic_vector(63 downto 0);
    I_data               : in  std_logic_vector(63 downto 0);
    DDS_phase_shift      : in  std_logic_vector(dds_phase_width downto 0);
    -- pstprc_dps_en        : in std_logic;
    pstprc_en            : in  std_logic;
    Pstprc_num_frs       : in std_logic;
    rst_n                : in  std_logic;
    Pstprc_RAMx_rden_stp : in  std_logic;
    Pstprc_finish        : out std_logic;
    pstprc_Idata         : out std_logic_vector(mult_accum_s_width-1 downto 0);
    pstprc_Qdata         : out std_logic_vector(mult_accum_s_width-1 downto 0);
    Pstprc_add_stp : out std_logic;
    dds_data_start : in std_logic_vector(14 downto 0);
    dds_data_len : in std_logic_vector(14 downto 0);
    cmd_smpl_depth : in std_logic_vector(15 downto 0)
    );
end post_process;

architecture Behavioral of post_process is

  type array_tc_adc_data is array (7 downto 0) of std_logic_vector(7 downto 0);
  signal tc_Q_data : array_tc_adc_data;
  signal tc_I_data : array_tc_adc_data;

    type array_tc_dds_data is array (7 downto 0) of std_logic_vector(11 downto 0);
  signal tc_dds_sin : array_tc_dds_data;
  signal tc_dds_cos : array_tc_dds_data;
  
  type array_data_x_cos is array (7 downto 0) of std_logic_vector(mult_accum_s_width-1 downto 0);
  signal accm_Q_x_cos  : array_data_x_cos;
  signal accm_I_x_cos  : array_data_x_cos;
  signal accm_Q_x_sin  : array_data_x_cos;
  signal accm_I_x_sin  : array_data_x_cos;
  type array_base0_data_x_cos is array (3 downto 0) of std_logic_vector(mult_accum_s_width-1 downto 0);
  signal base0_Q_x_cos : array_base0_data_x_cos;
  signal base0_I_x_cos : array_base0_data_x_cos;
  signal base0_Q_x_sin : array_base0_data_x_cos;
  signal base0_I_x_sin : array_base0_data_x_cos;
  type array_bs0_QxCOS_CO is array (3 downto 0) of std_logic;
  signal bs0_QxCOS_CO  : array_bs0_QxCOS_CO;
  signal bs0_IxCOS_CO  : array_bs0_QxCOS_CO;
  signal bs0_QxSIN_CO  : array_bs0_QxCOS_CO;
  signal bs0_IxSIN_CO  : array_bs0_QxCOS_CO;

  type array_base1_data_x_cos is array (1 downto 0) of std_logic_vector(mult_accum_s_width-1 downto 0);
  signal base1_Q_x_cos : array_base1_data_x_cos;
  signal base1_I_x_cos : array_base1_data_x_cos;
  signal base1_Q_x_sin : array_base1_data_x_cos;
  signal base1_I_x_sin : array_base1_data_x_cos;
  type array_bs1_QxCOS_CO is array (1 downto 0) of std_logic;
  signal bs1_QxCOS_CO  : array_bs1_QxCOS_CO;
  signal bs1_IxCOS_CO  : array_bs1_QxCOS_CO;
  signal bs1_QxSIN_CO  : array_bs1_QxCOS_CO;
  signal bs1_IxSIN_CO  : array_bs1_QxCOS_CO;
  
  -- signal rs_Q_x_sin : std_logic_vector(23 downto 0);
  -- signal rs_Q_x_cos : std_logic_vector(23 downto 0);
  -- signal rs_I_x_sin : std_logic_vector(23 downto 0);
  -- signal rs_I_x_cos : std_logic_vector(23 downto 0);

  -- signal bs0_QxCOS_CO      : std_logic;
  -- signal bs0_QxCOS_CI      : std_logic;
  -- signal bs0_QxSIN_CO      : std_logic;
  -- signal bs0_QxSIN_CI      : std_logic;
  -- signal bs0_IxCOS_CO      : std_logic;
  -- signal bs0_IxCOS_CI      : std_logic;
  -- signal bs0_IxSIN_CO      : std_logic;
  -- signal bs0_IxSIN_CI      : std_logic;
  -- signal bs1_QxCOS_CO      : std_logic;
  -- signal bs1_QxCOS_CI      : std_logic;
  -- signal bs1_QxSIN_CO      : std_logic;
  -- signal bs1_QxSIN_CI      : std_logic;
  -- signal bs1_IxCOS_CO      : std_logic;
  -- signal bs1_IxCOS_CI      : std_logic;
  -- signal bs1_IxSIN_CO      : std_logic;
  -- signal bs1_IxSIN_CI      : std_logic;
  signal rs_QxCOS_CO : std_logic;
  signal rs_QxCOS_CI : std_logic;
  signal rs_IxCOS_CO : std_logic;
  signal rs_IxCOS_CI : std_logic;
  signal rs_QxSIN_CO : std_logic;
  signal rs_QxSIN_CI : std_logic;
  signal rs_IxSIN_CO : std_logic;
  signal rs_IxSIN_CI : std_logic;
  signal rs_q_x_cos  : std_logic_vector(mult_accum_s_width-1 downto 0);
  signal rs_i_x_cos  : std_logic_vector(mult_accum_s_width-1 downto 0);
  signal rs_q_x_sin  : std_logic_vector(mult_accum_s_width-1 downto 0);
  signal rs_i_x_sin  : std_logic_vector(mult_accum_s_width-1 downto 0);
  signal add_rst     : std_logic;
  signal idata_co    : std_logic;
  signal qdata_co    : std_logic;

  signal add_Idata : std_logic_vector(mult_accum_s_width-1 downto 0);
  signal add_Qdata : std_logic_vector(mult_accum_s_width-1 downto 0);

  type array_Q_x_cos is array (7 downto 0) of std_logic_vector(17 downto 0);
  type array_I_x_sin is array (7 downto 0) of std_logic_vector(17 downto 0);
  type array_Q_x_sin is array (7 downto 0) of std_logic_vector(17 downto 0);

  signal IxCOS : std_logic_vector(19 downto 0);
  signal IxSIN : std_logic_vector(19 downto 0);
  signal QxCOS : std_logic_vector(19 downto 0);
  signal QxSIN : std_logic_vector(19 downto 0);
  signal dds_en : std_logic;
  signal dds_sclr          : std_logic;
  signal dds_fifo_rden     : std_logic;
  signal dds_cos           : std_logic_vector(95 downto 0);
  signal dds_sin           : std_logic_vector(95 downto 0);
  -- signal tc_dds_cos        : std_logic_vector(96 downto 0);
  -- signal tc_dds_sin        : std_logic_vector(96 downto 0);
  signal add_clk           : std_logic;
  signal mult_accum_clk    : std_logic;
  signal mult_accum_ce     : std_logic;
  signal mult_accum_sclr   : std_logic;
  signal mult_accum_bypass : std_logic;
  signal mult_accum_ce_d   : std_logic;
  -- signal accm_I_x_cos : std_logic_vector(17 downto 0);
  -- signal accm_Q_x_cos : std_logic_vector(17 downto 0);
  -- signal accm_I_x_sin : std_logic_vector(17 downto 0);
  -- signal accm_Q_x_sin : std_logic_vector(17 downto 0);
  signal add_ce            : std_logic;
  signal adder_en          : std_logic;
  signal adder_en_d        : std_logic;
  signal adder_en_d2       : std_logic;
  signal Adder_en_d3       : std_logic;
  signal add_cnt_en        : std_logic;
  signal add_cnt           : std_logic_vector(7 downto 0);

  -- signal Pstprc_add_stp          : std_logic;
  signal pstprc_ramx_rden_stp_d2 : std_logic;
  signal pstprc_ramx_rden_stp_d  : std_logic;
  signal pstprc_ramx_rden_stp_d3 : std_logic;
  signal pstprc_ramx_rden_stp_d4 : std_logic;

  signal Q_rdy    : std_logic;
  signal Q_rfd    : std_logic;
  signal Q_nd     : std_logic;
  signal I_rfd    : std_logic;
  signal I_rdy    : std_logic;
  signal I_nd     : std_logic;
  signal div_clk  : std_logic;
  signal div_ce   : std_logic;
  signal div_sclr : std_logic;
  signal q_quo    : std_logic_vector(31 downto 0);
  signal I_quo    : std_logic_vector(31 downto 0);

  signal Q_data_d : std_logic_vector(63 downto 0);
  signal I_data_d : std_logic_vector(63 downto 0);
  signal pstprc_en_d : std_logic;
-------------------------------------------------------------------------------
	COMPONENT DDS_top
	PORT(
		dds_clk : IN std_logic;
		dds_sclr : IN std_logic;
		dds_en : IN std_logic;
		dds_phase_shift : IN std_logic_vector(dds_phase_width downto 0);
                Pstprc_num_frs : in std_logic;
		cos_out : OUT std_logic_vector(95 downto 0);
		sin_out : OUT std_logic_vector(95 downto 0);
                dds_data_start : in std_logic_vector(14 downto 0);
                dds_data_len : in std_logic_vector(14 downto 0);
                cmd_smpl_depth : in std_logic_vector(15 downto 0)
		);
	END COMPONENT;

  component multi_accum_top
    port(
      mult_accum_clk    : in  std_logic;
      mult_accum_ce     : in  std_logic;
      mult_accum_sclr   : in  std_logic;
      mult_accum_bypass : in  std_logic;
      Q_data            : in  std_logic_vector(7 downto 0);
      I_data            : in  std_logic_vector(7 downto 0);
      dds_sin           : in  std_logic_vector(11 downto 0);
      dds_cos           : in  std_logic_vector(11 downto 0);
      accm_I_x_cos      : out std_logic_vector(mult_accum_s_width-1 downto 0);
      accm_I_x_sin      : out std_logic_vector(mult_accum_s_width-1 downto 0);
      accm_Q_x_cos      : out std_logic_vector(mult_accum_s_width-1 downto 0);
      accm_Q_x_sin      : out std_logic_vector(mult_accum_s_width-1 downto 0)
      );
  end component;

  -- component divider
  --   port (
  --     clk        : in  std_logic;
  --     ce         : in  std_logic;
  --     sclr       : in  std_logic;
  --     nd         : in  std_logic;       --New Data (ND). Used to signal to the core that new operands
  --                                       --are present on the input to the core.
  --     rdy        : out std_logic;
  --     rfd        : out std_logic;
  --     dividend   : in  std_logic_vector(31 downto 0);
  --     divisor    : in  std_logic_vector(11 downto 0);
  --     quotient   : out std_logic_vector(31 downto 0);
  --     fractional : out std_logic_vector(7 downto 0));
  -- end component;
COMPONENT adder
  PORT (
    a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    clk : IN STD_LOGIC;
    add : IN STD_LOGIC;
    c_in : IN STD_LOGIC;
    ce : IN STD_LOGIC;
    sclr : IN STD_LOGIC;
    s : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;
-------------------------------------------------------------------------------
begin


  Inst_DDS : DDS_top port map(
    dds_clk         => clk,
    dds_sclr        => dds_sclr,
    dds_en =>dds_en,
  Pstprc_num_frs =>Pstprc_num_frs,
    -- pstprc_dps_en => pstprc_dps_en,
    dds_phase_shift => dds_phase_shift,
    cos_out         => dds_cos,
    sin_out         => dds_sin,
    dds_data_start => dds_data_start,
    dds_data_len => dds_data_len,
    cmd_smpl_depth =>cmd_smpl_depth
    );

  multi_accum_inst : for i in 0 to 7 generate
  begin

    -- tc_dds_cos(i)   <= not(dds_cos(8*i+11))&dds_cos(8*i+10 downto 8*i);
    -- tc_dds_sin(i)   <= not(dds_sin(8*i+11))&dds_sin(8*i+10 downto 8*i);
    tc_dds_cos(i)<= dds_cos(12*i+11 downto 12*i);
    tc_dds_sin(i)<= dds_sin(12*i+11 downto 12*i);
    tc_I_data(i) <= not(I_data_d(8*i+7))& I_data_d(8*i+6 downto 8*i);
    tc_Q_data(i) <= not(Q_data_d(8*i+7))& Q_data_d(8*i+6 downto 8*i);

    Inst_multi_accum_top : multi_accum_top port map(
      mult_accum_clk    => mult_accum_clk,
      mult_accum_ce     => mult_accum_ce,
      mult_accum_sclr   => mult_accum_sclr,
      mult_accum_bypass => mult_accum_bypass,
      -- Q_data            => Q_data(8*i+7 downto 8*i),
      -- I_data            => I_data(8*i+7 downto 8*i),
      Q_data            => tc_Q_data(i),
      I_data            => tc_I_data(i), --two's complement
      -- dds_sin           => dds_sin,
      -- dds_cos           => dds_cos,
      dds_sin           => tc_dds_sin(i),
      dds_cos           => tc_dds_cos(i),  --two's comlement
      accm_Q_x_cos      => accm_Q_x_cos(i),
      accm_I_x_sin      => accm_I_x_sin(i),
      accm_I_x_cos      => accm_I_x_cos(i),
      accm_Q_x_sin      => accm_Q_x_sin(i)
      );
  end generate multi_accum_inst;

  -- pstprc_divQ_inst : divider
  --   port map (
  --     clk        => div_clk,
  --     ce         => div_ce,
  --     sclr       => div_sclr,
  --     nd         => Q_nd,
  --     rdy        => Q_rdy,
  --     rfd        => Q_rfd,
  --     dividend   => add_Qdata,
  --     divisor    => Pstprc_RAMx_rden_ln&"000",
  --     quotient   => Q_quo,
  --     fractional => Q_fra);

  --   pstprc_divI_inst : divider
  --   port map (
  --     clk        => div_clk,
  --     ce         => div_ce,
  --     sclr       => div_sclr,
  --     nd         => I_nd,
  --     rdy        => I_rdy,
  --     rfd        => I_rfd,
  --     dividend   => add_Idata,
  --     divisor    => Pstprc_RAMx_rden_ln&"000",
  --     quotient   => I_quo,
  --     fractional => I_fra);

-------------------------------------------------------------------------------
  ADD_QxCOS_bs0_inst : for i in 0 to 3 generate  --QxCOS
  begin
    -- ADDSUB_MACRO_QxCOS_inst : ADDSUB_MACRO
    --   generic map (
    --     DEVICE  => "VIRTEX6",  -- Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6" 
    --     LATENCY => 1,                   -- Desired clock cycle latency, 0-2
    --     WIDTH   => mult_accum_s_width)  -- Input / Output bus width, 1-48
    --   port map (
    --     CARRYOUT => bs0_QxCOS_CO(i),    -- 1-bit carry-out output signal
    --     RESULT   => base0_Q_x_cos(i),  -- Add/sub result output, width defined by WIDTH generic
    --     A        => accm_Q_x_cos(2*i),  -- Input A bus, width defined by WIDTH generic
    --     ADD_SUB  => '1',  -- 1-bit add/sub input, high selects add, low selects subtract
    --     B        => accm_Q_x_cos(2*i+1),  -- Input B bus, width defined by WIDTH generic
    --     CARRYIN  => '0',                -- 1-bit carry-in input
    --     CE       => ADD_CE,             -- 1-bit clock enable input
    --     CLK      => ADD_CLK,            -- 1-bit clock input
    --     RST      => ADD_RST             -- 1-bit active high synchronous reset
    --     );

  ADDSUB_MACRO_QxCOS_inst : adder
  PORT MAP (
    a => accm_Q_x_cos(2*i),
    b => accm_Q_x_cos(2*i+1),
    clk => ADD_CLK,
    add => '1',
    c_in => '0',
    ce => ADD_CE,
    sclr => ADD_RST,
    s =>  base0_Q_x_cos(i)
    );
    
  end generate ADD_QxCOS_bs0_inst;

  ADD_QxCOS_bs1_inst : for j in 0 to 1 generate
  begin
    -- ADDSUB_MACRO_QxCOS_inst : ADDSUB_MACRO
    --   generic map (
    --     DEVICE  => "VIRTEX6",  -- Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6" 
    --     LATENCY => 1,                   -- Desired clock cycle latency, 0-2
    --     WIDTH   => mult_accum_s_width)  -- Input / Output bus width, 1-48
    --   port map (
    --     CARRYOUT => bs1_QxCOS_CO(j),    -- 1-bit carry-out output signal
    --     RESULT   => base1_Q_x_cos(j),  -- Add/sub result output, width defined by WIDTH generic
    --     A        => base0_Q_x_cos(2*j),  -- Input A bus, width defined by WIDTH generic
    --     ADD_SUB  => '1',  -- 1-bit add/sub input, high selects add, low selects subtract
    --     B        => base0_Q_x_cos(2*j+1),  -- Input B bus, width defined by WIDTH generic
    --     CARRYIN  => '0',                -- 1-bit carry-in input
    --     CE       => ADD_CE,             -- 1-bit clock enable input
    --     CLK      => ADD_CLK,            -- 1-bit clock input
    --     RST      => ADD_RST             -- 1-bit active high synchronous reset
    --     );

  ADDSUB_MACRO_QxCOS_inst : adder
  PORT MAP (
    a => base0_Q_x_cos(2*j),
    b => base0_Q_x_cos(2*j+1),
    clk => ADD_CLK,
    add => '1',
    c_in => '0',
    ce => ADD_CE,
    sclr => ADD_RST,
    s => base1_Q_x_cos(j)
    );
  
  end generate ADD_QxCOS_bs1_inst;

  -- ADDSUB_QxCOS_RS_inst : ADDSUB_MACRO
  --   generic map (
  --     DEVICE  => "VIRTEX6",  -- Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6" 
  --     LATENCY => 1,                     -- Desired clock cycle latency, 0-2
  --     WIDTH   => mult_accum_s_width)    -- Input / Output bus width, 1-48
  --   port map (
  --     CARRYOUT => rs_QxCOS_CO,          -- 1-bit carry-out output signal
  --     RESULT   => rs_Q_x_cos,  -- Add/sub result output, width defined by WIDTH generic
  --     A        => base1_Q_x_cos(0),  -- Input A bus, width defined by WIDTH generic
  --     ADD_SUB  => '1',  -- 1-bit add/sub input, high selects add, low selects subtract
  --     B        => base1_Q_x_cos(1),  -- Input B bus, width defined by WIDTH generic
  --     CARRYIN  => '0',                  -- 1-bit carry-in input
  --     CE       => ADD_CE,               -- 1-bit clock enable input
  --     CLK      => ADD_CLK,              -- 1-bit clock input
  --     RST      => ADD_RST               -- 1-bit active high synchronous reset
  --     );
  ADDSUB_QxCOS_RS_inst : adder
  PORT MAP (
    a => base1_Q_x_cos(0),
    b => base1_Q_x_cos(1),
    clk => ADD_CLK,
    add => '1',
    c_in => '0',
    ce => ADD_CE,
    sclr => ADD_RST,
    s =>rs_Q_x_cos
    );
  ------------------------------------------------------------------------------
  ADD_QxSIN_bs0_inst : for i in 0 to 3 generate  --QxSIN
  begin
    -- ADDSUB_MACRO_QxSIN_inst : ADDSUB_MACRO
    --   generic map (
    --     DEVICE  => "VIRTEX6",  -- Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6" 
    --     LATENCY => 1,                   -- Desired clock cycle latency, 0-2
    --     WIDTH   => mult_accum_s_width)  -- Input / Output bus width, 1-48
    --   port map (
    --     CARRYOUT => bs0_QxSIN_CO(i),    -- 1-bit carry-out output signal
    --     RESULT   => base0_Q_x_sin(i),  -- Add/sub result output, width defined by WIDTH generic
    --     A        => accm_Q_x_sin(2*i),  -- Input A bus, width defined by WIDTH generic
    --     ADD_SUB  => '1',  -- 1-bit add/sub input, high selects add, low selects subtract
    --     B        => accm_Q_x_sin(2*i+1),  -- Input B bus, width defined by WIDTH generic
    --     CARRYIN  => '0',                -- 1-bit carry-in input
    --     CE       => ADD_CE,             -- 1-bit clock enable input
    --     CLK      => ADD_CLK,            -- 1-bit clock input
    --     RST      => ADD_RST             -- 1-bit active high synchronous reset
    --     );
    
  ADDSUB_MACRO_QxSIN_inst : adder
  PORT MAP (
    a => accm_Q_x_sin(2*i),
    b => accm_Q_x_sin(2*i+1),
    clk => ADD_CLK,
    add => '1',
    c_in => '0',
    ce => ADD_CE,
    sclr => ADD_RST,
    s =>base0_Q_x_sin(i)
    );
  
  end generate ADD_QxSIN_bs0_inst;

  ADD_QxSIN_bs1_inst : for j in 0 to 1 generate
  begin
    -- ADDSUB_MACRO_inst : ADDSUB_MACRO
    --   generic map (
    --     DEVICE  => "VIRTEX6",  -- Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6" 
    --     LATENCY => 1,                   -- Desired clock cycle latency, 0-2
    --     WIDTH   => mult_accum_s_width)  -- Input / Output bus width, 1-48
    --   port map (
    --     CARRYOUT => bs1_QxSIN_CO(j),    -- 1-bit carry-out output signal
    --     RESULT   => base1_Q_x_SIN(j),  -- Add/sub result output, width defined by WIDTH generic
    --     A        => base0_Q_x_sin(j),  -- Input A bus, width defined by WIDTH generic
    --     ADD_SUB  => '1',  -- 1-bit add/sub input, high selects add, low selects subtract
    --     B        => base0_Q_x_sin(2*j+1),  -- Input B bus, width defined by WIDTH generic
    --     CARRYIN  => '0',                -- 1-bit carry-in input
    --     CE       => ADD_CE,             -- 1-bit clock enable input
    --     CLK      => ADD_CLK,            -- 1-bit clock input
    --     RST      => ADD_RST             -- 1-bit active high synchronous reset
    --     );
    ADDSUB_MACRO_QxSIN_inst : adder
  PORT MAP (
    a => base0_Q_x_sin(j),
    b => base0_Q_x_sin(2*j+1),
    clk => ADD_CLK,
    add => '1',
    c_in => '0',
    ce => ADD_CE,
    sclr => ADD_RST,
    s =>base1_Q_x_SIN(j)
    );
  
  end generate ADD_QxSIN_bs1_inst;

  -- ADDSUB_MACRO_inst : ADDSUB_MACRO
  --   generic map (
  --     DEVICE  => "VIRTEX6",  -- Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6" 
  --     LATENCY => 1,                     -- Desired clock cycle latency, 0-2
  --     WIDTH   => mult_accum_s_width)    -- Input / Output bus width, 1-48
  --   port map (
  --     CARRYOUT => rs_QxSIN_CO,          -- 1-bit carry-out output signal
  --     RESULT   => rs_Q_x_sin,  -- Add/sub result output, width defined by WIDTH generic
  --     A        => base1_Q_x_sin(0),  -- Input A bus, width defined by WIDTH generic
  --     ADD_SUB  => '1',  -- 1-bit add/sub input, high selects add, low selects subtract
  --     B        => base1_Q_x_sin(1),  -- Input B bus, width defined by WIDTH generic
  --     CARRYIN  => '0',                  -- 1-bit carry-in input
  --     CE       => ADD_CE,               -- 1-bit clock enable input
  --     CLK      => ADD_CLK,              -- 1-bit clock input
  --     RST      => ADD_RST               -- 1-bit active high synchronous reset
  --     );

  ADDSUB_MACRO_QxSIN_inst : adder
  PORT MAP (
    a => base1_Q_x_sin(0),
    b => base1_Q_x_sin(1),
    clk => ADD_CLK,
    add => '1',
    c_in => '0',
    ce => ADD_CE,
    sclr => ADD_RST,
    s =>rs_Q_x_sin
    );
  -----------------------------------------------------------------------------
  
  ADD_IxCOS_bs0_inst : for i in 0 to 3 generate  --IxCOS
  begin
    -- ADDSUB_MACRO_inst : ADDSUB_MACRO
    --   generic map (
    --     DEVICE  => "VIRTEX6",  -- Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6" 
    --     LATENCY => 1,                   -- Desired clock cycle latency, 0-2
    --     WIDTH   => mult_accum_s_width)  -- Input / Output bus width, 1-48
    --   port map (
    --     CARRYOUT => bs0_IxCOS_CO(i),    -- 1-bit carry-out output signal
    --     RESULT   => base0_I_x_cos(i),  -- Add/sub result output, width defined by WIDTH generic
    --     A        => accm_I_x_cos(2*i),  -- Input A bus, width defined by WIDTH generic
    --     ADD_SUB  => '1',  -- 1-bit add/sub input, high selects add, low selects subtract
    --     B        => accm_I_x_cos(2*i+1),  -- Input B bus, width defined by WIDTH generic
    --     CARRYIN  => '0',                -- 1-bit carry-in input
    --     CE       => ADD_CE,             -- 1-bit clock enable input
    --     CLK      => ADD_CLK,            -- 1-bit clock input
    --     RST      => ADD_RST             -- 1-bit active high synchronous reset
    --     );
  ADDSUB_MACRO_inst : adder
  PORT MAP (
    a => accm_I_x_cos(2*i),
    b => accm_I_x_cos(2*i+1),
    clk => ADD_CLK,
    add => '1',
    c_in => '0',
    ce => ADD_CE,
    sclr => ADD_RST,
    s =>base0_I_x_cos(i)
    );
  end generate ADD_IxCOS_bs0_inst;

  ADD_IxCOS_bs1_inst : for j in 0 to 1 generate
  begin
    -- ADDSUB_MACRO_inst : ADDSUB_MACRO
    --   generic map (
    --     DEVICE  => "VIRTEX6",  -- Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6" 
    --     LATENCY => 1,                   -- Desired clock cycle latency, 0-2
    --     WIDTH   => mult_accum_s_width)  -- Input / Output bus width, 1-48
    --   port map (
    --     CARRYOUT => bs1_IxCOS_CO(j),    -- 1-bit carry-out output signal
    --     RESULT   => base1_I_x_cos(j),  -- Add/sub result output, width defined by WIDTH generic
    --     A        => base0_I_x_cos(2*j),  -- Input A bus, width defined by WIDTH generic
    --     ADD_SUB  => '1',  -- 1-bit add/sub input, high selects add, low selects subtract
    --     B        => base0_I_x_cos(2*j+1),  -- Input B bus, width defined by WIDTH generic
    --     CARRYIN  => '0',                -- 1-bit carry-in input
    --     CE       => ADD_CE,             -- 1-bit clock enable input
    --     CLK      => ADD_CLK,            -- 1-bit clock input
    --     RST      => ADD_RST             -- 1-bit active high synchronous reset
    --     );

  ADDSUB_MACRO_inst : adder
  PORT MAP (
    a => base0_I_x_cos(2*j),
    b => base0_I_x_cos(2*j+1),
    clk => ADD_CLK,
    add => '1',
    c_in => '0',
    ce => ADD_CE,
    sclr => ADD_RST,
    s =>base1_I_x_cos(j)
    );
    
  end generate ADD_IxCOS_bs1_inst;

  -- ADDSUB_IxCOS_RS_inst : ADDSUB_MACRO
  --   generic map (
  --     DEVICE  => "VIRTEX6",  -- Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6" 
  --     LATENCY => 1,                     -- Desired clock cycle latency, 0-2
  --     WIDTH   => mult_accum_s_width)    -- Input / Output bus width, 1-48
  --   port map (
  --     CARRYOUT => rs_IxCOS_CO,          -- 1-bit carry-out output signal
  --     RESULT   => rs_I_x_cos,  -- Add/sub result output, width defined by WIDTH generic
  --     A        => base1_I_x_cos(0),  -- Input A bus, width defined by WIDTH generic
  --     ADD_SUB  => '1',  -- 1-bit add/sub input, high selects add, low selects subtract
  --     B        => base1_I_x_cos(1),  -- Input B bus, width defined by WIDTH generic
  --     CARRYIN  => '0',                  -- 1-bit carry-in input
  --     CE       => ADD_CE,               -- 1-bit clock enable input
  --     CLK      => ADD_CLK,              -- 1-bit clock input
  --     RST      => ADD_RST               -- 1-bit active high synchronous reset
  --     );
  ADDSUB_IxCOS_RS_inst : adder
  PORT MAP (
    a => base1_I_x_cos(0),
    b => base1_I_x_cos(1),
    clk => ADD_CLK,
    add => '1',
    c_in => '0',
    ce => ADD_CE,
    sclr => ADD_RST,
    s =>rs_I_x_cos
    );
    
  -----------------------------------------------------------------------------
  ADD_IxSIN_bs0_inst : for i in 0 to 3 generate  --IxSIN
  begin
    -- ADDSUB_MACRO_inst : ADDSUB_MACRO
    --   generic map (
    --     DEVICE  => "VIRTEX6",  -- Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6" 
    --     LATENCY => 1,                   -- Desired clock cycle latency, 0-2
    --     WIDTH   => mult_accum_s_width)  -- Input / Output bus width, 1-48
    --   port map (
    --     CARRYOUT => bs0_IxSIN_CO(i),    -- 1-bit carry-out output signal
    --     RESULT   => base0_I_x_sin(i),  -- Add/sub result output, width defined by WIDTH generic
    --     A        => accm_I_x_sin(2*i),  -- Input A bus, width defined by WIDTH generic
    --     ADD_SUB  => '1',  -- 1-bit add/sub input, high selects add, low selects subtract
    --     B        => accm_I_x_sin(2*i+1),  -- Input B bus, width defined by WIDTH generic
    --     CARRYIN  => '0',                -- 1-bit carry-in input
    --     CE       => ADD_CE,             -- 1-bit clock enable input
    --     CLK      => ADD_CLK,            -- 1-bit clock input
    --     RST      => ADD_RST             -- 1-bit active high synchronous reset
    --     );

  ADDSUB_MACRO_inst : adder
  PORT MAP (
    a => accm_I_x_sin(2*i),
    b => accm_I_x_sin(2*i+1),
    clk => ADD_CLK,
    add => '1',
    c_in => '0',
    ce => ADD_CE,
    sclr => ADD_RST,
    s => base0_I_x_sin(i)
    );
      
  end generate ADD_IxSIN_bs0_inst;

  ADD_IxSIN_bs1_inst : for j in 0 to 1 generate
  begin
    -- ADDSUB_MACRO_inst : ADDSUB_MACRO
    --   generic map (
    --     DEVICE  => "VIRTEX6",  -- Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6" 
    --     LATENCY => 1,                   -- Desired clock cycle latency, 0-2
    --     WIDTH   => mult_accum_s_width)  -- Input / Output bus width, 1-48
    --   port map (
    --     CARRYOUT => bs1_IxSIN_CO(j),    -- 1-bit carry-out output signal
    --     RESULT   => base1_I_x_sin(j),  -- Add/sub result output, width defined by WIDTH generic
    --     A        => base0_I_x_sin(2*j),  -- Input A bus, width defined by WIDTH generic
    --     ADD_SUB  => '1',  -- 1-bit add/sub input, high selects add, low selects subtract
    --     B        => base0_I_x_sin(2*j+1),  -- Input B bus, width defined by WIDTH generic
    --     CARRYIN  => '0',                -- 1-bit carry-in input
    --     CE       => ADD_CE,             -- 1-bit clock enable input
    --     CLK      => ADD_CLK,            -- 1-bit clock input
    --     RST      => ADD_RST             -- 1-bit active high synchronous reset
    --     );

  ADDSUB_MACRO_inst : adder
  PORT MAP (
    a => base0_I_x_sin(2*j),
    b => base0_I_x_sin(2*j+1),
    clk => ADD_CLK,
    add => '1',
    c_in => '0',
    ce => ADD_CE,
    sclr => ADD_RST,
    s => base1_I_x_sin(j)
    );
      
  end generate ADD_IxSIN_bs1_inst;

  -- ADDSUB_IxSIN_RS_inst : ADDSUB_MACRO
  --   generic map (
  --     DEVICE  => "VIRTEX6",  -- Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6" 
  --     LATENCY => 1,                     -- Desired clock cycle latency, 0-2
  --     WIDTH   => mult_accum_s_width)    -- Input / Output bus width, 1-48
  --   port map (
  --     CARRYOUT => rs_IxSIN_CO,          -- 1-bit carry-out output signal
  --     RESULT   => rs_I_x_SIN,  -- Add/sub result output, width defined by WIDTH generic
  --     A        => base1_I_x_SIN(0),  -- Input A bus, width defined by WIDTH generic
  --     ADD_SUB  => '1',  -- 1-bit add/sub input, high selects add, low selects subtract
  --     B        => base1_I_x_SIN(1),  -- Input B bus, width defined by WIDTH generic
  --     CARRYIN  => '0',                  -- 1-bit carry-in input
  --     CE       => ADD_CE,               -- 1-bit clock enable input
  --     CLK      => ADD_CLK,              -- 1-bit clock input
  --     RST      => ADD_RST               -- 1-bit active high synchronous reset
  --     );
  
  ADDSUB_IxSIN_RS_inst : adder
  PORT MAP (
    a => base1_I_x_SIN(0),
    b => base1_I_x_SIN(1),
    clk => ADD_CLK,
    add => '1',
    c_in => '0',
    ce => ADD_CE,
    sclr => ADD_RST,
    s => rs_I_x_SIN
    );
-------------------------------------------------------------------------------
  -- ADDSUB_Idata_inst : ADDSUB_MACRO
  --   generic map (
  --     DEVICE  => "VIRTEX6",  -- Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6" 
  --     LATENCY => 1,                     -- Desired clock cycle latency, 0-2
  --     WIDTH   => mult_accum_s_width)    -- Input / Output bus width, 1-48
  --   port map (
  --     CARRYOUT => Idata_CO,             -- 1-bit carry-out output signal
  --     RESULT   => add_Idata,  -- Add/sub result output, width defined by WIDTH generic
  --     A        => rs_I_x_cos,  -- Input A bus, width defined by WIDTH generic
  --     ADD_SUB  => '1',  -- 1-bit add/sub input, high selects add, low selects subtract
  --     B        => rs_Q_x_sin,  -- Input B bus, width defined by WIDTH generic
  --     CARRYIN  => '0',                  -- 1-bit carry-in input
  --     CE       => ADD_CE,               -- 1-bit clock enable input
  --     CLK      => ADD_CLK,              -- 1-bit clock input
  --     RST      => ADD_RST               -- 1-bit active high synchronous reset
  --     );
  ADDSUB_Idata_inst : adder
  PORT MAP (
    a => rs_I_x_cos,
    b => rs_Q_x_sin,
    clk => ADD_CLK,
    add => '1',
    c_in => '0',
    ce => ADD_CE,
    sclr => ADD_RST,
    s => add_Idata                      -- at least two clk latency due to the
                                        -- fabric choice
                                        
    );
  
  -- ADDSUB_Qdata_inst : ADDSUB_MACRO
  --   generic map (
  --     DEVICE  => "VIRTEX6",  -- Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6" 
  --     LATENCY => 1,                     -- Desired clock cycle latency, 0-2
  --     WIDTH   => mult_accum_s_width)    -- Input / Output bus width, 1-48
  --   port map (
  --     CARRYOUT => Qdata_CO,             -- 1-bit carry-out output signal
  --     RESULT   => add_Qdata,  -- Add/sub result output, width defined by WIDTH generic
  --     A        => rs_Q_x_cos,  -- Input A bus, width defined by WIDTH generic
  --     ADD_SUB  => '0',  -- 1-bit add/sub input, high selects add, low selects subtract
  --     B        => rs_I_x_sin,  -- Input B bus, width defined by WIDTH generic
  --     CARRYIN  => '0',                  -- 1-bit carry-in input
  --     CE       => ADD_CE,               -- 1-bit clock enable input
  --     CLK      => ADD_CLK,              -- 1-bit clock input
  --     RST      => ADD_RST               -- 1-bit active high synchronous reset
  --     );
  ADDSUB_Qdata_inst : adder
  PORT MAP (
    a => rs_Q_x_cos,
    b => rs_I_x_sin,
    clk => ADD_CLK,
    add => '0',
    c_in => '0',
    ce => ADD_CE,
    sclr => ADD_RST,
    s => add_Qdata
    );
-------------------------------------------------------------------------------
  -- pstprc_ramx_rden_stp_d_ps : process (clk, rst_n) is
  -- begin  -- process pstprc_ramx_rden_stp_d    
  --   if clk'event and clk = '1' then     -- rising clock edge
  --     pstprc_ramx_rden_stp_d  <= pstprc_ramx_rden_stp;
  --     pstprc_ramx_rden_stp_d2 <= pstprc_ramx_rden_stp_d;
  --     pstprc_ramx_rden_stp_d3 <= pstprc_ramx_rden_stp_d2;
  --     pstprc_ramx_rden_stp_d4 <= pstprc_ramx_rden_stp_d3;
  --   end if;
  -- end process pstprc_ramx_rden_stp_d_ps;

Q_data_d_ts: process (clk, rst_n) is
  begin  -- process Q_data_d_ts
    if rst_n = '0' then                 -- asynchronous reset (active low)
      Q_data_d<=(others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      Q_data_d<=Q_data;
    end if;
  end process Q_data_d_ts;

  I_data_d_ts: process (clk, rst_n) is
  begin  -- process i_data_d_ts
    if rst_n = '0' then                 -- asynchronous reset (active low)
      I_data_d<=(others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      I_data_d<=I_data;
    end if;
  end process I_data_d_ts;

  
  Pstprc_add_stp_ps : process (clk, rst_n) is
  begin  -- process Pstprc_add_stp_ps
    if rst_n = '0' then                 -- asynchronous reset (active low)
      Pstprc_add_stp <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if add_cnt = add_period_cnt then
        Pstprc_add_stp <= '1';
      else
        Pstprc_add_stp <= '0';
      end if;
    end if;
  end process Pstprc_add_stp_ps;

  Pstprc_finish_ps : process (clk, rst_n) is  --generate pstprc_finish signal
                                              --by the add_cnt
  begin  -- process Pstprc_add_stp_ps
    if rst_n = '0' then                 -- asynchronous reset (active low)
      Pstprc_finish <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if add_cnt = add_period_cnt+1 then 
        Pstprc_finish <= '1';
      else
        Pstprc_finish <= '0';
      end if;
    end if;
  end process Pstprc_finish_ps;

  mult_accum_sclr_ps : process (clk, rst_n) is
  begin  -- process mult_accum_sclr_ps
    if rst_n = '0' then                 -- asynchronous reset (active low)
      mult_accum_sclr <= '1';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if add_cnt = add_period_cnt then
        mult_accum_sclr <= '1';
      else
        mult_accum_sclr <= '0';
      end if;
    end if;
  end process mult_accum_sclr_ps;

  Adder_en_ps : process (clk, rst_n) is
  begin  -- process Adder_en_ps
    if rst_n = '0' then                 -- asynchronous reset (active low)
      Adder_en <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      Adder_en <= Pstprc_en_d;
    end if;
  end process Adder_en_ps;

  Adder_en_d_ps : process (clk, rst_n) is
  begin  -- process Pstprc_en_d_ps
    if rst_n = '0' then                 -- asynchronous reset (active low)
      Adder_en_d  <= '0';
      Adder_en_d2 <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      Adder_en_d      <= Adder_en;
      Adder_en_d2     <= Adder_en_d;
      Adder_en_d3     <= Adder_en_d2;
      mult_accum_ce_d <= mult_accum_ce;
    end if;
  end process Adder_en_d_ps;

  Pstprc_en_d_ps: process (clk, rst_n) is
  begin  -- process Pstprc_en_d_ps
    if rst_n = '0' then                 -- asynchronous reset (active low)
      Pstprc_en_d<='0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      Pstprc_en_d<=Pstprc_en;
    end if;
  end process Pstprc_en_d_ps;

  div_ce_ps : process (clk, rst_n) is
  begin  -- process div_ce_ps
    if rst_n = '0' then                 -- asynchronous reset (active low)
      div_ce <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      div_ce <= Add_ce;
    end if;
  end process div_ce_ps;

  add_cnt_en_ps : process (clk, rst_n) is
  begin  -- process add_cnt_ps
    if rst_n = '0' then                 -- asynchronous reset (active low)
      add_ce <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if mult_accum_ce = '0' and mult_accum_ce_d = '1' then
--mark, 3 clk latency. relating to ram_rden_d or combination logic will save 1 clk latency
        add_ce <= '1';
      elsif add_cnt = add_period_cnt then        --dsp:x"04";fabric:x"08"
        add_ce <= '0';
      end if;
    end if;
  end process add_cnt_en_ps;

  add_cnt_ps : process (clk, rst_n) is
  begin  -- process add_cnt_ps
    if rst_n = '0' then                 -- asynchronous reset (active low)
      add_cnt <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if add_ce = '1' then
        add_cnt <= add_cnt+1;
      elsif add_ce = '0' then
        add_cnt <= (others => '0');
      end if;
    end if;
  end process add_cnt_ps;

-----------------------------------------------------------------------------
  mult_accum_clk    <= clk;
  mult_accum_ce     <= pstprc_en_d and adder_en_d;  --delay 2 clk after ram_rden
                                                  --and low at 1 clk after ram_rden
  mult_accum_bypass <= '0';


  dds_sclr <= not rst_n;
  dds_en  <= pstprc_en_d;

  ADD_clk <= clk;
  ADD_RST <= not rst_n;
-- ADD_CE <= Adder_en_d3;

  div_clk  <= clk;
  div_ce   <= div_ce;
  div_sclr <= not rst_n;

-- Pstprc_finish<=Q_rdy; -- use divide module
  pstprc_Qdata <= add_Qdata;
  pstprc_Idata <= add_Idata;
end Behavioral;

