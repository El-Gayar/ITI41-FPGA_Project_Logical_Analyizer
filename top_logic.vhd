----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:18:06 01/11/2021 
-- Design Name: 
-- Module Name:    top_logic - Behavioral 
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

entity top_logic is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
			  input_mode : in  STD_LOGIC;
           channels : in  STD_LOGIC_VECTOR (7 downto 0);
           uart_rx : in  STD_LOGIC;
           uart_tx : out  STD_LOGIC;
           armed : inout  STD_LOGIC;
           triggered : out  STD_LOGIC;
			 -- data_in : inout STD_LOGIC_VECTOR (7 downto 0);
			 -- trig_value :inout STD_LOGIC_VECTOR (23 downto 0);
			  trig_value_p :in STD_LOGIC_VECTOR (23 downto 0);
			 -- trig_mask :inout STD_LOGIC_VECTOR (23 downto 0);
			  trig_mask_p :in STD_LOGIC_VECTOR (23 downto 0);
			  --sample_count:inout STD_LOGIC_VECTOR (23 downto 0);
			  sample_count_p:in STD_LOGIC_VECTOR (23 downto 0);
			--  data_out_valid: inout STD_LOGIC;
			  --sample_divider: inout STD_LOGIC_VECTOR (23 downto 0);
			  sample_divider_p: in STD_LOGIC_VECTOR (23 downto 0);
			  --sample_clk: inout STD_LOGIC;
			  --captured: inout STD_LOGIC;
			  --transmited_data:inout STD_LOGIC;
			 -- flag: inout STD_LOGIC;
			 --data_in_ready  : inout  STD_LOGIC;
			  --arm_cmd: inout STD_LOGIC;
			  arm_cmd_p: in STD_LOGIC;
			  data_out1 : out STD_LOGIC_VECTOR (7 downto 0)
);
end top_logic;

architecture Behavioral of top_logic is
signal data_in : STD_LOGIC_VECTOR (7 downto 0);
signal data_in_ready : STD_LOGIC;
signal trig_value : STD_LOGIC_VECTOR (23 downto 0);
signal trig_mask: STD_LOGIC_VECTOR (23 downto 0);
signal arm_cmd: STD_LOGIC;
signal sample_count: STD_LOGIC_VECTOR (23 downto 0);
signal sample_divider: STD_LOGIC_VECTOR (23 downto 0);
signal sample_clk: STD_LOGIC;
signal captured: STD_LOGIC;
signal flag: STD_LOGIC;
signal transmited_data: STD_LOGIC;
signal fifo_tready: STD_LOGIC;
signal data_out_valid: STD_LOGIC;
signal data_out : STD_LOGIC_VECTOR (7 downto 0);
signal data_stored : STD_LOGIC_VECTOR (7 downto 0);



begin
data_out1<=data_out; 
storage:entity work.FIFO(FiFo_arch)
	
	port map( Clk          => clk,
			Rst              =>rst ,
		   Data_stored      =>data_stored,
		   Flag		        =>flag,
		   Transmitted_Data =>transmited_data,            
		   Captured         =>captured,
		   Data_out         =>data_out,
		   FiFo_Tready      => fifo_tready,                  
		   Data_out_Valid   =>data_out_valid
			 
		);
		
msg:entity work.Message_Processor(Behavioral)		
port map(  clk => clk,
           rst => rst,
           command_in => data_in,
           command_in_Ready => data_in_ready,
           Trig_Val => trig_value,
           Trig_Mask  => trig_mask,
           Arm_Cmd => arm_cmd,
           Sample_Count => sample_count,
           Sample_Divider => sample_divider
	);
	
	divider:entity work.divider(Behavioral)	
  Port map ( clk =>clk,
           rst => rst,
			  input_mode=>input_mode,
           sample_divider => sample_divider,
			  sample_divider_p => sample_divider_p,
           o_armd =>armed,
           sample_clk => sample_clk);
			  
		
  SUMP_UART_block : entity work.SUMPComms
    --generic map (clock_freq => 1000000, baud_rate => 115200)
    port map (
      clk           => clk,
      rst           => rst,
      rx            => uart_rx,
      tx            => uart_tx,
      tx_command    =>data_out,
      command_ready => data_in_ready,
      data_ready    => data_out_valid,
      data_sent     => transmited_data,
      command       => data_in);
	
	capture_unit : entity work.cap_unit(Behavioral)
	port map (
	chanels => channels,
	clk => clk,
	input_mode=>input_mode,
	fifo_tready => fifo_tready,
	trig_value=> trig_value(7 downto 0),
	trig_mask => trig_mask(7 downto 0),
	i_arm_cmd => arm_cmd,
	sample_count => sample_count,
	trig_value_p=> trig_value_p(7 downto 0),
	trig_mask_p => trig_mask_p(7 downto 0),
	i_arm_cmd_p => arm_cmd_p,
	sample_count_p => sample_count_p,
	data_stored => data_stored,
	data_flag => flag,
	o_armed => armed,
	o_triggered => triggered,
	captured => captured,
	sample_clk => sample_clk,
	reset => rst
);	
		
end Behavioral;


