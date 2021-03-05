----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:48:40 01/08/2021 
-- Design Name: 
-- Module Name:    Message_Processor - Behavioral 
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

entity Message_Processor is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           command_in : in  STD_LOGIC_VECTOR (7 downto 0);
           command_in_Ready : in  STD_LOGIC;
           Trig_Val : out  STD_LOGIC_VECTOR (23 downto 0);
           Trig_Mask : out  STD_LOGIC_VECTOR (23 downto 0);
           Arm_Cmd : out  STD_LOGIC;
           Sample_Count : out  STD_LOGIC_VECTOR (23 downto 0);
           Sample_Divider : out  STD_LOGIC_VECTOR (23 downto 0));
end Message_Processor;

architecture Behavioral of Message_Processor is
TYPE states is (INITIAL, CMD_READ, BYTE_1,  BYTE_2,  BYTE_3, CMD_DO);
signal current_state, next_state: states;
signal op_code: STD_LOGIC_VECTOR(7 downto 0);
signal data: STD_LOGIC_VECTOR(23 downto 0);
--signal command_in_int: STD_LOGIC_VECTOR(7 downto 0);
--signal Arm_Cmd_int, command_in_ready_int: STD_LOGIC;
--signal  Trig_Val_int,Trig_Mask_int, Sample_Count_int, Sample_Divider_int:   STD_LOGIC_VECTOR (23 downto 0) ;
signal command_in_int : STD_LOGIC_VECTOR(7 downto 0);
begin
--Arm_Cmd <= Arm_Cmd_int;
--command_in_ready_int<= command_in_ready;
--Trig_Val <= Trig_Val_int;
--Trig_Mask <= Trig_Mask_int;
--Sample_Count<= Sample_Count_int;
--Sample_Divider<=Sample_Divider_int;
command_in_int <= command_in;

--FSM Mealy
-- first process for FSM (clk)
p1: process(clk,rst) IS 
begin
	if rising_edge(clk) THEN

		if rst = '1' THEN 
			 
			 current_state <= INITIAL;
			 if current_state = INITIAl THEN
				Trig_Val <= (others => '0');
				Trig_Mask <= (others => '0');
				Sample_Count <= (others => '0');
				Sample_Divider <= (others => '0');
				Arm_Cmd <= '0';
			end if;
		else
			current_state <= next_state;
			if current_state = INITIAl THEN
			Arm_CMD<= '0';
				if command_in_Ready = '1' THEN 
					op_code <= command_in_int;
				end if;
			end if;
			
			if current_state = BYTE_1 THEN
				if command_in_Ready = '1' THEN 
					data(7 downto 0) <= command_in_int;
				end if;
			end if;
			if current_state = BYTE_2 THEN
				if command_in_Ready = '1' THEN 
					data(15 downto 8) <= command_in_int;
				end if;
			end if;
			if current_state = BYTE_3 THEN
				if command_in_Ready = '1' THEN 
					data(23 downto 16) <= command_in_int;
				end if;
			end if;
			if current_state = CMD_DO THEN
			case op_code IS 
				when x"0B" => 
					Trig_Val <= data;
					
				when x"0C" =>
					Trig_Mask <= data;
					
				when x"0D" =>
					Sample_Divider<= data;
					
				when x"0E" =>
					Sample_Count <= data;
					
				when x"00" =>
					Arm_CMD<= '1';
				when others => 
			end case;
			end if;
	end if;
	end if;
end process p1;

--process 2 for current state and input
p2: process(current_state, command_in_int, command_in_Ready, op_code) IS 
begin
	case current_state IS 
		when INITIAL => 
			
			next_state<=INITIAL;
			if command_in_Ready = '1' THEN 
				--op_code <= command_in;
				next_state<=CMD_READ;
			else
				next_state<=INITIAL;
			end if;
		when CMD_READ => 
			case op_code IS
				when x"0B" | x"0C" |  x"0D" |  x"0E"  => 
					next_state <= BYTE_1;
				when others => 
					next_state <= CMD_DO;
			end case;
				
		when BYTE_1 => 
			if command_in_Ready = '1' THEN 
				--data(7 downto 0) <= command_in;
				next_state <= BYTE_2;
			else 
				next_state <= BYTE_1;
			end if;
		when BYTE_2 => 
			if command_in_Ready = '1' THEN 
				--data(15 downto 8) <= command_in;
				next_state <= BYTE_3;
			else 
				next_state <= BYTE_2;
			end if;
		when BYTE_3 => 
			if command_in_Ready = '1' THEN 
				--data(23 downto 16) <= command_in;
				next_state <= CMD_DO;
			else 
				next_state <= BYTE_3;
			end if;
		when CMD_DO => 
			case op_code IS 
				when x"0B" =>
					--Trig_Val_int <= data;
					next_state <= INITIAL;
				when x"0C" =>
					--Trig_Mask_int <= data;
					next_state <= INITIAL;
				when x"0D" =>
					--Sample_Divider_int <= data;
					next_state <= INITIAL;
				when x"0E" =>
					--Sample_Count_int <= data;
					next_state <= INITIAL;
				when x"00" =>
					--Arm_CMD_int<= '1';
					next_state <= INITIAL;
				when others => 	
					next_state <= INITIAL;
			end case;
				
			
end case;
end process p2;

end Behavioral;

