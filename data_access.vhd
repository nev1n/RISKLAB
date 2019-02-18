library IEEE;
use IEEE.std_logic_1164.all; -- import std_logic types
use IEEE.std_logic_arith.all; -- import add/sub of std_logic_vector
use IEEE.std_logic_unsigned.all;
--use IEEE.numeric_std.all;
use work.RISC_lib.all;


entity data_access is
	port (
		
				
		result        	: in data_word;   -- can be alu result,address for load or data for store (rs1 diverted through here)
		memInstType	  	: in std_logic;	  -- flag to detect if mem type instruction
		
		data_write_en 	: in std_logic;   -- must connect to external write enable flag
		
		in_Rd_value 	: in data_word; -- address for store operation
		
		data_from_mem : in data_word;		
		
		result_out			: out data_word;
		data_addr     		: out data_word;
		data_ld_from_mem	: out data_word;   -- goes back to the reg bank
		write_en			: out std_logic;
		data_to_mem			: out data_word
		
		);
end entity data_access;

architecture behavioral of data_access is

begin  -- architecture behavioral

	
	process (result,memInstType, data_write_en) -- bug when result is same ?
    begin  -- process alu_proc
			
			result_out <= (others => '0');
			data_addr <= (others => '0');
			data_to_mem <= (others => '0');
			data_ld_from_mem <= (others => '0');
			
			if (memInstType = '1' and data_write_en = '0') then  --Load operation
				 data_addr <= result;
				 data_ld_from_mem <= data_from_mem; 
			elsif (memInstType = '1' and data_write_en = '1') then  -- Store operation
				data_addr <= in_Rd_value;
				data_to_mem <= result;
			else -- alu operation
				result_out <= result;  -- alu result might be available one stage early, best to be redirected to prevent race cond.	
			end if;	
			write_en <= data_write_en;
	end process;

end architecture behavioral;		