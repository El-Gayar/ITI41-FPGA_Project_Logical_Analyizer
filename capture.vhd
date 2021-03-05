----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:31:01 01/09/2021 
-- Design Name: 
-- Module Name:    cap_unit - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cap_unit is
    Port ( chanels : in  STD_LOGIC_VECTOR (7 downto 0);
	        input_mode : in  STD_LOGIC;
           fifo_tready : in  STD_LOGIC;
           trig_value : in  STD_LOGIC_VECTOR (7 downto 0);
           trig_mask : in  STD_LOGIC_VECTOR (7 downto 0);
			  trig_value_p : in  STD_LOGIC_VECTOR (7 downto 0);
           trig_mask_p: in  STD_LOGIC_VECTOR (7 downto 0);
           i_arm_cmd : in  STD_LOGIC;
			  i_arm_cmd_p : in  STD_LOGIC;
           sample_count  : in  STD_LOGIC_VECTOR (23 downto 0);
			  sample_count_p  : in  STD_LOGIC_VECTOR (23 downto 0);
           data_stored : out  STD_LOGIC_VECTOR (7 downto 0);
           data_flag : out  STD_LOGIC;
           o_armed : out  STD_LOGIC;
           o_triggered : out  STD_LOGIC;
           captured : out  STD_LOGIC;
           sample_clk : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC);
end cap_unit;

architecture Behavioral of cap_unit is
 TYPE state_t IS (INIT, WAIT_FOR_ARM_CMD, WAIT_FOR_TRIGGER, CAPTURE_DATA);
  SIGNAL state,next_state : state_t := INIT;
  signal trig_mask_in  :STD_LOGIC_VECTOR (7 downto 0);
  signal trig_value_in  :STD_LOGIC_VECTOR (7 downto 0);
  signal data_in  :STD_LOGIC_VECTOR (7 downto 0);
  signal sample_count_in  :STD_LOGIC_VECTOR (23 downto 0);
  signal sample_counter  :natural RANGE 0 TO 16777215:= 0;
  signal armed :  STD_LOGIC:='0';
  signal triggered :  STD_LOGIC:='0';
  signal captured_out   :  STD_LOGIC:='0';
  signal arm_cmd   :  STD_LOGIC:='0';
  signal fifo_tready_in   :  STD_LOGIC:='0';
begin
process  (clk)
begin
if rising_edge(clk) then
	data_flag<='0';
	if reset='1' then
   trig_mask_in <="00000000";
	trig_value_in <="00000000";
	sample_count_in <= (OTHERS => '0');
   state <= INIT;
	else 
	if (input_mode ='0')then
	arm_cmd<=i_arm_cmd;
	else 
	arm_cmd<=i_arm_cmd_p;
	end if ;
	data_stored <=data_in;
	state <= next_state;
	o_armed<=armed;
	o_triggered <=triggered ;
	data_in<=chanels;
	captured<= captured_out;
	fifo_tready_in<=fifo_tready;
		
	   if (armed ='0') then
		if (input_mode ='0')then
		trig_mask_in <=trig_mask;
		trig_value_in <=trig_value;
		sample_count_in <= sample_count;
		else
		trig_mask_in <=trig_mask_p;
		trig_value_in <=trig_value_p;
		sample_count_in <= sample_count_p;
		end if;
		end if;
		if ( state=CAPTURE_DATA ) then
		if (sample_clk='1')then
		data_flag<='1';
		sample_counter<=sample_counter+1;
		end if; 
		else 
		sample_counter<=0;
		end if; 

	end if;
end if ;
end process ;

process  (state,fifo_tready_in,arm_cmd,data_in,trig_mask_in,trig_value_in,sample_counter,sample_count_in)
begin
next_state<=state;
captured_out<='0';
armed<='0';
triggered<='0';
	if state =INIT then
		if (fifo_tready_in='1') then 
		 next_state <=WAIT_FOR_ARM_CMD;
		 end if;
	elsif (state=WAIT_FOR_ARM_CMD) then 
		if (arm_cmd='1') then 
		 next_state <=WAIT_FOR_TRIGGER;
		 end if;
	elsif (state=WAIT_FOR_TRIGGER) then
		armed<='1';
		if ((data_in and trig_mask_in)=(trig_value_in and trig_mask_in)) then 
		 next_state <=CAPTURE_DATA;
		 end if;
	 else
	    armed<='1';
		 triggered<='1';
		if (sample_counter = to_integer( UNSIGNED (sample_count_in))) then 
		next_state <=INIT;
		captured_out<='1';   
		end if;
	 end if;

end process;
end Behavioral;

