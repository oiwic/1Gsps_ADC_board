----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:24:08 04/19/2018 
-- Design Name: 
-- Module Name:    Oserdese - Behavioral 
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
Library UNISIM;
use IEEE.STD_LOGIC_1164.ALL;
use UNISIM.vcomponents.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Oserdese is
  port(
    rst_n : in std_logic;
    clk : in std_logic;                 --500MHz
    clkdiv : in std_logic;             --250MHz
    D1 : in std_logic;
    D2 : in std_logic;
    D3 : in std_logic;
    D4 : in std_logic;
    OQ : out std_logic
);
end Oserdese;

architecture Behavioral of Oserdese is
  signal OCBEXTEND : std_logic;
  signal OFB : std_logic;
  signal TFB : std_logic;
  signal TQ : std_logic;
  signal CLKPERF : std_logic;
  signal CLKPERFDELAY : std_logic;
  signal WC : std_logic;
  signal ODV : std_logic;
  signal Oserdes_rst : std_logic;
begin
  Oserdes_rst<= not rst_n;
   OSERDESE1_inst : OSERDESE1
   generic map (
      DATA_RATE_OQ => "DDR",       -- "SDR" or "DDR" 
      DATA_RATE_TQ => "DDR",       -- "BUF", "SDR" or "DDR" 
      DATA_WIDTH => 4,             -- Parallel data width (1-8,10)
      DDR3_DATA => 1,              -- Must leave at 1 (MIG-only parameter)
      INIT_OQ => '0',              -- Initial value of OQ output (0/1)
      INIT_TQ => '0',              -- Initial value of TQ output (0/1)
      INTERFACE_TYPE => "DEFAULT", -- Must leave at "DEFAULT" (MIG-only parameter)
      ODELAY_USED => 0,            -- Must leave at 0 (MIG-only parameter)
      SERDES_MODE => "MASTER",     -- "MASTER" or "SLAVE" 
      SRVAL_OQ => '0',             -- OQ output value when SR is used (0/1)
      SRVAL_TQ => '0',             -- TQ output value when SR is used (0/1)
      TRISTATE_WIDTH => 4          -- Parallel to serial 3-state converter width (1 or 4)
   )
   port map (
      -- MIG-only Signals: 1-bit (each) output: Do not use unless generated by MIG
      OCBEXTEND => OCBEXTEND,       -- 1-bit output: Leave unconnected (MIG-only connected signal)
      -- Outputs: 1-bit (each) output: Serial output ports
      OFB => OFB,                   -- 1-bit output: Data feedback output to ISERDESE1
      OQ => OQ,                     -- 1-bit output: Data output (connect to I/O port)
      TFB => TFB,                   -- 1-bit output: 3-state control output
      TQ => TQ,                     -- 1-bit output: 3-state path output
      -- SHIFTOUT1-SHIFTOUT2: 1-bit (each) output: Data width expansion output ports
      SHIFTOUT1 => open,       -- 1-bit output: Connect to SHIFTIN1 of slave or unconnected
      SHIFTOUT2 => open,       -- 1-bit output: Connect to SHIFTIN2 of slave or unconnected
      -- Clocks: 1-bit (each) input: OSERDESE1 clock input ports
      CLK => CLK,                   -- 1-bit input: High-speed clock input
      CLKDIV => CLKDIV,             -- 1-bit input: Divided clock input
      -- Control Signals: 1-bit (each) input: Clock enable and reset input ports
      OCE => '1',                   -- 1-bit input: Active high clock data path enable input
      RST =>  Oserdes_rst,                   -- 1-bit input: Active high reset input
      TCE => '0',                   -- 1-bit input: Active high clock enable input for 3-state
      -- D1 - D6: 1-bit (each) input: Parallel data inputs
      D1 => D1,
      D2 => D2,
      D3 => D3,
      D4 => D4,
      D5 => '0',
      D6 => '0',
      -- MIG-only Signals: 1-bit (each) input: Do not use unless generated by MIG
      CLKPERF => CLKPERF,           -- 1-bit input: Ground input (MIG-only connected signal)
      CLKPERFDELAY => CLKPERFDELAY, -- 1-bit input: Ground input (MIG-only connected signal)
      ODV => ODV,                   -- 1-bit input: Ground input (MIG-only connected signal)
      WC => WC,                     -- 1-bit input: Ground input (MIG-only connected signal)
      -- SHIFTIN1-SHIFTIN2: 1-bit (each) input: Data width expansion input ports
      SHIFTIN1 => '0',         -- 1-bit input: Connect to SHIFTOUT1 of master or GND
      SHIFTIN2 => '0',         -- 1-bit input: Connect to SHIFTOUT2 of master or GND
      -- T1 - T4: 1-bit (each) input: Parallel 3-state inputs
      T1 => '0',
      T2 => '0',
      T3 => '0',
      T4 => '0' 
   );

end Behavioral;
