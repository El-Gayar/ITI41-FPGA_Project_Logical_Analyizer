----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:13:30 01/12/2021 
-- Design Name: 
-- Module Name:    test - Behavioral 
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test is
    Port ( uart_tx_command : in  STD_LOGIC_VECTOR (7 downto 0);
           data_ready : in  STD_LOGIC;
           uart_rx_data : out  STD_LOGIC_VECTOR (7 downto 0);
           clk : in  STD_LOGIC;
           rst : in  STD_LOGIC);
end test;

architecture Behavioral of test is
signal logic_rx :  STD_LOGIC;
signal logic_tx :  STD_LOGIC;
signal channels: STD_LOGIC_VECTOR (7 downto 0);
signal armed : STD_LOGIC;
signal triggered : STD_LOGIC;
signal data_sent : STD_LOGIC;
signal data_in : STD_LOGIC_VECTOR (7 downto 0);
signal data_in_ready : STD_LOGIC;
signal data_out_valid: STD_LOGIC;
--signal data_in : STD_LOGIC_VECTOR (7 downto 0);
--signal data_in_ready : STD_LOGIC;
signal trig_value : STD_LOGIC_VECTOR (23 downto 0);
signal trig_mask: STD_LOGIC_VECTOR (23 downto 0);
signal sample_clk: STD_LOGIC;
signal captured: STD_LOGIC;
signal flag: STD_LOGIC;
signal sample_count: STD_LOGIC_VECTOR (23 downto 0);
signal sample_divider: STD_LOGIC_VECTOR (23 downto 0);
signal transmited_data: STD_LOGIC;
begin
 SUMP_UART_block : entity work.SUMPComms
   -- generic map (clock_freq => 1000000, baud_rate => 115200)
    port map (
      clk           => clk,
      rst           => rst,
      rx            => logic_tx,
      tx            => logic_rx ,
		data_sent     => data_sent,
      tx_command    =>uart_tx_command ,
      data_ready    => data_ready ,
		
      command       => uart_rx_data);

 logic:entity work.top_logic
    Port map ( clk => clk,
           rst => rst,
           channels => channels,
           uart_rx =>  logic_rx,
           uart_tx =>  logic_tx,
           armed =>   armed,
			  data_in=> data_in,
			  data_in_ready=>data_in_ready,
			  
			  trig_value =>trig_value,
			  trig_mask =>trig_mask,
			  captured=>captured,
			  flag=>flag,
			  sample_count=>sample_count,
			  sample_clk=>sample_clk,
			  sample_divider=>sample_divider,
			  transmited_data=>transmited_data,
           triggered =>  triggered);


end Behavioral;

