----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:04:37 03/08/2017 
-- Design Name: 
-- Module Name:    Win_RAM_top - Behavioral 
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

entity Pstprc_RAM_Q is
  port(
    Pstprc_ram_wren     : in  std_logic;
    posedge_sample_trig : in  std_logic;
    rst_n               : in  std_logic;
    cmd_smpl_depth      : in  std_logic_vector(15 downto 0);
    ---------------------------------------------------------------------------
    Pstprc_RAMq_clka    : in  std_logic;
    Pstprc_RAMq_clkb    : in  std_logic;
    ---------------------------------------------------------------------------
    Pstprc_RAMq_dina    : in  std_logic_vector(31 downto 0);
    Pstprc_RAMq_doutb   : out std_logic_vector(63 downto 0);
    Pstprc_RAMq_rden : buffer std_logic;
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    ini_pstprc_RAMx_addra           : in  std_logic_vector(12 downto 0);
    ini_pstprc_RAMx_addrb       : in  std_logic_vector(11 downto 0);
    Pstprc_RAMx_rden_ln : in std_logic_vector(11 downto 0);
    Pstprc_RAMq_rden_stp : out std_logic
    );
end Pstprc_RAM_Q;

architecture Behavioral of Pstprc_RAM_Q is

  -----------------------------------------------------------------------------
  
  signal Pstprc_RAMq_addra : std_logic_vector(12 downto 0);
  signal Pstprc_RAMq_addrb : std_logic_vector(11 downto 0);
  signal Pstprc_RAMq_ena   : std_logic;
  signal Pstprc_RAMq_enb   : std_logic;
  signal Pstprc_RAMq_wea   : std_logic_vector(0 downto 0);
  signal Pstprc_RAMq_rstb  : std_logic;
  signal clr_n_ram   : std_logic;
  signal Pstprc_RAMq_full : std_logic;
  signal Pstprc_RAMq_full_o : std_logic;
  signal Pstprc_addra_rdy : std_logic;
  signal Pstprc_addra_rdy_d : std_logic;
  signal Pstprc_addra_rdy_d2 : std_logic;
  signal Pstprc_addra_ok : std_logic;
  signal Pstprc_RAMq_rden_cnt : std_logic_vector(11 downto 0);
  -- signal Pstprc_RAMq_rden : std_logic;
  signal pstprc_RAMq_rden_d : std_logic;
  -- signal ini_pstprc_ramx_addrb : std_logic_vector(11 downto 0);
  -- signal ini_pstprc_ramx_addra : std_logic_vector(12 downto 0);
  signal Pstprc_RAMq_rden_ln : std_logic_vector(11 downto 0);
  -- signal Pstprc_RAMq_rden_stp : std_logic;

  
COMPONENT Post_Process_RAM
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
  );
END COMPONENT;

begin
    
  Inst_Post_Process_RAMQ : Post_Process_RAM
    port map (
      clka  => Pstprc_RAMq_clka,
      ena   => '1',
      wea   => Pstprc_RAMq_wea,
      addra => Pstprc_RAMq_addra,
      dina  => Pstprc_RAMq_dina,
      clkb  => Pstprc_RAMq_clkb,
      enb   => Pstprc_RAMq_rden,
      addrb => Pstprc_RAMq_addrb,
      doutb => Pstprc_RAMq_doutb
      );

  Pstprc_RAMq_wea(0) <= Pstprc_ram_wren and (not Pstprc_RAMq_full);
  clr_n_ram          <= rst_n;
  Pstprc_RAMq_full_o <= Pstprc_RAMq_full;
-------------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  Pstprc_RAMq_addra_ps : process (Pstprc_RAMq_clka, clr_n_ram, posedge_sample_trig) is
  begin  -- process addra_ps
    if clr_n_ram = '0' then             -- asynchronous reset (active low)
      Pstprc_RAMq_addra <= (others => '0');
    elsif Pstprc_RAMq_clka'event and Pstprc_RAMq_clka = '1' then  -- rising clock edge
      if posedge_sample_trig = '1' then
        Pstprc_RAMq_addra <= (others => '0');
      elsif Pstprc_ram_wren = '1' then
        if Pstprc_RAMq_addra < cmd_smpl_depth(14 downto 2)then  --cmd_smpl_depth/4
          Pstprc_RAMq_addra <= Pstprc_RAMq_addra+1;
        end if;
      end if;
    end if;
  end process Pstprc_RAMq_addra_ps;

  Pstprc_RAMq_full_ps : process (Pstprc_RAMq_clka, clr_n_ram, posedge_sample_trig) is
  begin  -- process addra_ps
    if clr_n_ram = '0' then             -- asynchronous reset (active low)
      Pstprc_RAMq_full <= '0';
    elsif Pstprc_RAMq_clka'event and Pstprc_RAMq_clka = '1' then  -- rising clock edge
      if posedge_sample_trig = '1' then
        Pstprc_RAMq_full <= '0';
      elsif Pstprc_ram_wren = '1' then
        if Pstprc_RAMq_addra < cmd_smpl_depth(14 downto 2)then  --cmd_smpl_depth/4
          Pstprc_RAMq_full <= '0';
        elsif Pstprc_RAMq_addra >= cmd_smpl_depth(14 downto 2) then
          Pstprc_RAMq_full <= '1';
        end if;
      end if;
    end if;
  end process Pstprc_RAMq_full_ps;

  -- purpose:  to generate addra ready flag
  -- type   : sequential
  -- inputs : Pstprc_RAMq_clka, clr_n_ram
  -- outputs: 
  Pstprc_addra_rdy_ps : process (Pstprc_RAMq_clka, clr_n_ram) is
  begin  -- process Pstprc_Addra_rdy_ps
    if clr_n_ram = '0' then             -- asynchronous reset (active low)
      Pstprc_addra_rdy <= '0';
    elsif Pstprc_RAMq_clka'event and Pstprc_RAMq_clka = '1' then  -- the front side of the
                                        -- ram ,dont cross the
                                        -- clock domain
      if Pstprc_RAMq_addra = ini_pstprc_RAMx_addra then  --ini_pstprc_RAMq_addrb=demoWinstart/4
        Pstprc_addra_rdy <= '1';
      else
        Pstprc_addra_rdy <= '0';
      end if;
    end if;
  end process Pstprc_addra_rdy_ps;
  
  Pstprc_addra_ok <= Pstprc_addra_rdy_d or Pstprc_addra_rdy_d2;  --extend one clk
                                        --period for 125MHz

  -- purpose:  to generate RAMq_rden
  -- type   : sequential
  -- inputs : Pstprc_RAMq_clkb, clr_n_ram
  -- outputs: 
  Pstprc_RAMq_rden_ps : process (Pstprc_RAMq_clkb, clr_n_ram) is
  begin  -- process Pstprc_RAMq_rden_ps
    if clr_n_ram = '0' then             -- asynchronous reset (active low)
      Pstprc_RAMq_rden <= '0';
    elsif Pstprc_RAMq_clkb'event and Pstprc_RAMq_clkb = '1' then  -- rising clock edge
      if Pstprc_RAMq_rden_cnt = Pstprc_RAMx_rden_ln then  --width of the
                                                             --doutb is 64 bit
        Pstprc_RAMq_rden <= '0';
      elsif Pstprc_addra_ok = '1' then
        Pstprc_RAMq_rden <= '1';
      end if;
    end if;
  end process Pstprc_RAMq_rden_ps;

  Pstprc_RAMq_rden_cnt_ps : process (Pstprc_RAMq_clkb, clr_n_ram) is
  begin  -- process Pstprc_RAMq_rden_cnt_ps
    if clr_n_ram = '0' then             -- asynchronous reset (active low)
      Pstprc_RAMq_rden_cnt <= (others => '0');
    elsif Pstprc_RAMq_clkb'event and Pstprc_RAMq_clkb = '1' then  -- rising clock edge
      if Pstprc_RAMq_rden = '0' then
        Pstprc_RAMq_rden_cnt <= (others => '0');
      elsif Pstprc_RAMq_rden = '1' then
        Pstprc_RAMq_rden_cnt <= Pstprc_RAMq_rden_cnt+1;
      end if;
    end if;
  end process Pstprc_RAMq_rden_cnt_ps;

  Pstprc_RAMq_rden_stp_ps : process (Pstprc_RAMq_clkb, clr_n_ram) is
  begin  -- process Pstprc_RAMq_rden_stp_ps
    if clr_n_ram = '0' then             -- asynchronous reset (active low)
      Pstprc_RAMq_rden_stp <= '0';
    elsif Pstprc_RAMq_clkb'event and Pstprc_RAMq_clkb = '1' then  -- rising clock edge
--             if Pstprc_RAMq_rden = '0' and Pstprc_RAMq_rden_d = '1' then
-- --falling edge
      if Pstprc_RAMq_rden_cnt = Pstprc_RAMx_rden_ln then                    --have a try
        Pstprc_RAMq_rden_stp <= '1';
      else
        Pstprc_RAMq_rden_stp <= '0';
      end if;
    end if;
  end process Pstprc_RAMq_rden_stp_ps;

  Pstprc_RAMq_addrb_ps : process (Pstprc_RAMq_clkb, clr_n_ram) is
  begin  -- process Pstprc_RAMq_addrb_ps
    if clr_n_ram = '0' then             -- asynchronous reset (active low)
      Pstprc_RAMq_addrb <= ini_pstprc_RAMx_addrb;
      -- Pstprc_RAMq_addrb <=(others => '0');
    elsif Pstprc_RAMq_clkb'event and Pstprc_RAMq_clkb = '1' then  -- rising clock edge
      if Pstprc_RAMq_rden = '1' then
        Pstprc_RAMq_addrb <= Pstprc_RAMq_addrb+1;
      else
        Pstprc_RAMq_addrb <= ini_pstprc_RAMx_addrb;
      end if;
    end if;
  end process Pstprc_RAMq_addrb_ps;
  -----------------------------------------------------------------------------
  Pstprc_Addra_rdy_d_ps : process (Pstprc_RAMq_clka, clr_n_ram) is
  begin  -- process Pstprc_Addra_rdy_d
    if Pstprc_RAMq_clka'event and Pstprc_RAMq_clka = '1' then  -- rising clock edge
      Pstprc_addra_rdy_d  <= Pstprc_addra_rdy;
      Pstprc_addra_rdy_d2 <= Pstprc_addra_rdy_d;
    end if;
  end process Pstprc_Addra_rdy_d_ps;



  pstprc_RAMq_rden_d_ps : process (Pstprc_RAMq_clkb, clr_n_ram) is
  begin  -- process pstprc_addr_rden_d_ps
    if Pstprc_RAMq_clkb'event and Pstprc_RAMq_clkb = '1' then  -- rising clock edge
      Pstprc_RAMq_rden_d <= Pstprc_RAMq_rden;
    end if;
  end process pstprc_RAMq_rden_d_ps;



end Behavioral;
