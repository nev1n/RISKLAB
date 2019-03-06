library IEEE;
use IEEE.std_logic_1164.all; -- import std_logic types
use IEEE.std_logic_arith.all; -- import add/sub of std_logic_vector
use IEEE.std_logic_unsigned.all;
--use IEEE.numeric_std.all;
use work.RISC_lib.all;


entity jump_unit is
	port (
		
		--need pipeline restructuring
		--decode_jmpflag		: in std_logic_vector(1 downto 0);   
		--decode_jmpaddress	: in data_word;	  
		
		execute_jmpflag		: in std_logic;
		execute_jmpaddress	: in data_word;
				
		jmp_flag			: out std_logic;
		jmpaddress			: out data_word;
		
		flush_fetch			: out std_logic;
		flush_decode		: out std_logic
		);
end entity jump_unit;

architecture behavioral of jump_unit is

begin
	process (execute_jmpflag, execute_jmpaddress)   -- removed decode_jmpflag, decode_jmpaddress, from list
    begin
		
		jmp_flag <= '0';
		jmpaddress <= ZERO;
		flush_fetch <= '0';
		flush_decode <= '0';

		if execute_jmpflag = '1' then
			jmp_flag <= '1';
			jmpaddress <= execute_jmpaddress;
			flush_fetch <= '1';
			flush_decode <= '1';
		
	
		else  -- necessary?
			jmp_flag <= '0';
			jmpaddress <= ZERO;  --!
			flush_fetch <= '0';
			flush_decode <= '0';
		end if;
	
	end process;

end architecture behavioral;	