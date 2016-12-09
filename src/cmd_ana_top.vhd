----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:34:32 12/08/2016 
-- Design Name: 
-- Module Name:    cmd_ana_top - Behavioral 
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

entity cmd_ana_top is
  port(
    rd_clk               : in  std_logic;
    frm_length           : out std_logic_vector(15 downto 0);
    frm_type             : out std_logic_vector(15 downto 0);
    ram_start            : out std_logic;
    upload_trig_ethernet : out std_logic;
    rst_n                : in  std_logic;
    ram_switch           : out std_logic_vector(2 downto 0);
    TX_dst_MAC_addr      : out std_logic_vector(47 downto 0);
    cmd_smpl_en          : out std_logic;
    cmd_smpl_depth       : out std_logic_vector(15 downto 0);
    ethernet_Rd_en       : out std_logic;
    ethernet_Rd_Addr     : out std_logic_vector(13 downto 0);
    ethernet_frm_valid   : in  std_logic;
    ethernet_rd_data     : in  std_logic_vector(7 downto 0)
    );
end cmd_ana_top;
architecture Behavioral of cmd_ana_top is

  signal frm_valid_d     : std_logic;
  signal rd_en           : std_logic;
  signal rd_addr         : std_logic_vector(13 downto 0);
  signal rd_data         : std_logic_vector(7 downto 0);
  signal cmd_ana_rd_data : std_logic_vector(7 downto 0);
  signal cmd_ana_rd_addr : std_logic_vector(13 downto 0);
  signal cmd_ana_rd_en   : std_logic;

  component command_analysis
    port(
      rd_data              : in  std_logic_vector(7 downto 0);
      rd_clk               : in  std_logic;
      rd_addr              : in  std_logic_vector(13 downto 0);
      rd_en                : in  std_logic;
      rst_n                : in  std_logic;
      frm_length           : out std_logic_vector(15 downto 0);
      frm_type             : out std_logic_vector(15 downto 0);
      ram_start_o            : out std_logic;
      upload_trig_ethernet_o : out std_logic;
      ram_switch           : out std_logic_vector(2 downto 0);
      TX_dst_MAC_addr      : out std_logic_vector(47 downto 0);
      cmd_smpl_en_o          : out std_logic;
      cmd_smpl_depth       : out std_logic_vector(15 downto 0)
      );
  end component;

begin

  cmd_ana_rd_data  <= ethernet_rd_data;
  ethernet_Rd_Addr <= rd_addr;
  ethernet_Rd_en   <= rd_en;            --for up
  cmd_ana_rd_addr  <= rd_addr;          -- for down
  cmd_ana_rd_en    <= rd_en;

  Inst_command_analysis : command_analysis port map(
    rd_data              => cmd_ana_rd_data,
    rd_clk               => rd_clk,
    rd_addr              => cmd_ana_rd_addr,
    rd_en                => cmd_ana_rd_en,
    frm_length           => frm_length,
    frm_type             => frm_type,
    ram_start_o            => ram_start,
    upload_trig_ethernet_o => upload_trig_ethernet,
    rst_n                => rst_n,
    ram_switch           => ram_switch,
    TX_dst_MAC_addr      => TX_dst_MAC_addr,
    cmd_smpl_en_o          => cmd_smpl_en,
    cmd_smpl_depth       => cmd_smpl_depth
    );
  -----------------------------------------------------------------------------
  Rd_en_ps : process (rd_clk, rst_n, ethernet_frm_valid, frm_valid_d) is
  begin  -- process Rd_en_ps
    if rst_n = '0' then                 -- asynchronous reset (active low)
      Rd_en <= '0';
    elsif rd_clk'event and rd_clk = '1' then
      if frm_valid_d = '0' and ethernet_frm_valid = '1' then  -- rising clock edge
        Rd_en <= '1';
      elsif Rd_Addr >= x"42" then
        -- elsif ethernet_Rd_Addr>=x"16" then
        Rd_en <= '0';
      end if;
    end if;
  end process Rd_en_ps;

  Rd_Addr_ps : process (rd_clk, rst_n) is
  begin  -- process Rd_Addr_ps
    if rst_n = '0' then                 -- asynchronous reset (  active low)
      Rd_Addr <= (others => '0');
    elsif rd_clk'event and rd_clk = '1' then  -- rising clock edge
      if Rd_Addr <= x"42" and Rd_en = '1'then
        Rd_Addr <= Rd_Addr + 1;
      elsif Rd_en = '0' or Rd_Addr > x"41" then
        Rd_Addr <= (others => '0');
      end if;
    end if;
  end process Rd_Addr_ps;

  frm_valid_d_ps : process (rd_clk, rst_n) is
  begin  -- process frm_vali_dd
    if rd_clk'event and rd_clk = '1' then  -- rising clock edge
      frm_valid_d <= ethernet_frm_valid;
    end if;
  end process frm_valid_d_ps;
-------------------------------------------------------------------------------
end Behavioral;
