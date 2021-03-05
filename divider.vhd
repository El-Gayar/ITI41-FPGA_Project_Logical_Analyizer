----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:50:10 01/09/2021 
-- Design Name: 
-- Module Name:    divider - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity divider is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
			  input_mode : in  STD_LOGIC;
           sample_divider : in  STD_LOGIC_VECTOR (23 downto 0);
			  sample_divider_p : in  STD_LOGIC_VECTOR (23 downto 0);
           o_armd : in  STD_LOGIC;
           sample_clk : out  STD_LOGIC);
end divider;

architecture Behavioral of divider is
	signal divider,counter : STD_LOGIC_VECTOR (23 downto 0);
begin
	process(clk)
		begin 
			if (clk'event and clk = '1') then
				if (rst = '1') then
					divider <= (others => '0');
					counter <= (others => '0');
					sample_clk <= '0';
				else
					sample_clk <= '0';
					if (o_armd = '0') then
					if input_mode='0' then
					divider <= sample_divider;
					else 
					divider <= sample_divider_p;
					end if;
					counter <= (others => '0');
					
					else
						if (counter +1< divider)then
							counter <= counter + '1' ;
						elsif(counter+1 = divider) then
							counter <= (others => '0');
							sample_clk <= '1';
						else
							counter <= (others => '0');
						end if;
					end if;
				end if;
			end if;
	end process;
end Behavioral;