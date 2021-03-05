----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:04:49 01/09/2021 
-- Design Name: 
-- Module Name:    FIFO - Behavioral 
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

--Input and outputs
entity FIFO is
	
	port ( Clk ,Rst : in std_logic ;
		   Data_stored : in std_logic_vector (7 downto 0);
		   Flag		: in std_logic;
		   Transmitted_Data : in std_logic;               --when 0 UART is busy  
		   Captured  : in std_logic;
		   Data_out :out std_logic_vector ( 7 downto 0);
		   FiFo_Tready : out std_logic ;                  --when 0 = Full when 1 = kml Capturing
		   Data_out_Valid : inout std_logic;
			Read_Count,Write_Count : out integer 
		   
		); 
		
end entity;

Architecture FiFo_arch of FIFO is
Type states is (Idle,Read_S,Write_S);
Type depth is array ( 0 to 255) of std_logic_vector ( 7 downto 0);    --FIFO Depth
signal First_p : natural range 0 to 255 := 0;
signal End_p : natural range 0 to 255 := 0;
signal FIFO_Data : depth;
signal Current_state,Next_State : States;
signal Read_C ,Write_C : integer:=0 ;


Begin
	Read_Count <= Read_C;
	Write_Count <= Write_C;
	
	p1: process (Clk) is
		begin
		if rising_edge (Clk) THEN
		Data_out_Valid <='0';
			if Rst='1' THEN
				
				Current_state <= idle;
			else
			 Current_state <= Next_State;
			 if (current_state=Read_s) then
			 if (End_p /= First_p) and (Transmitted_Data ='1' and data_out_valid='0')Then
						
						Data_out <= FIFO_Data(End_p);
						End_p <= End_p +1;
						Read_C <= Read_C +1;
						Data_out_Valid <='1';
						
						
			end if;
			 end if;
			 if (current_state=Write_s) then
			 if ((First_p < 255) and Captured ='0' )  Then  --mknsh fe flag
						if flag = '1' THEN
						FIFO_Data(First_p) <= Data_stored;
						First_p <= First_p +1 ;
						Write_C <= Write_C +1;
						
						end if;
						end if;
						end if;
			if (current_state=idle) then
						First_p <=1;
						End_p <=1;
			end if ;
			end if ;
		end if;
		end process p1;
		
	p2: process (Flag,Captured,Transmitted_Data,Current_state,First_p,End_p)
		begin
		FiFo_Tready <= '0';
		next_state<= current_state;
			case Current_state is
--				when reset => 
--					Data_out <=	x"00";
--					FiFo_Tready <= '1';
--					Data_out_Valid <= '0';
--					First_p <= 0;
--					End_p <= 0;
--					next_state <= idle;
				when Idle =>
				  
					FiFo_Tready <= '1';
					
					
					if Flag='1' THEN
					Next_State <= Write_S;
					else
					Next_State <= Idle;
					end if;
				when Write_S=>
					if ((First_p < 255) and Captured ='0' )  Then  --mknsh fe flag
						if flag = '1' THEN
--						FIFO_Data(First_p) <= Data_stored;
--						First_p <= First_p +1 ;
--						Write_C <= Write_C +1;
--						--FiFo_Tready <= '1';
						Next_State <= Write_S;
						end if;
					else 
					
					Next_State <= Read_S;
					
					end if;
				when Read_S =>
--					if (End_p /= First_p) and Transmitted_Data ='1' Then
--						
--						Data_out <= FIFO_Data(End_p);
--						End_p <= End_p +1;
--						Read_C <= Read_C +1;
--						Data_out_Valid <='1';
--						FiFo_Tready <= '0';
					--	Next_State<=Read_S;
--					
--					if Transmitted_Data ='0' THEN
--						Next_State <= Wait_S;
--					end if;
						
					if (End_p = First_p) THEN
						Next_State <= Idle;
					end if;
--				when Wait_S =>
--					If Transmitted_Data='1' Then
--						
--						Next_State <=Read_S;
--					else
--						
--						Next_State <=Wait_S;
--					
--					end if;
			end case;
		end process p2;

end architecture FiFo_arch;








