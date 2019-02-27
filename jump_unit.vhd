library IEEE;
use IEEE.std_logic_1164.all; -- import std_logic types
use IEEE.std_logic_arith.all; -- import add/sub of std_logic_vector
use IEEE.std_logic_unsigned.all;
--use IEEE.numeric_std.all;
use work.RISC_lib.all;


entity jump_unit is
	port (
		
		decode_jmpflag		: in std_logic;   
		decode_jmpaddress	: in data_word;	  
		
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
	process (decode_jmpflag, decode_jmpaddress, execute_jmpflag, execute_jmpaddress)
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
		
		elsif decode_jmpflag = '1' then -- separate ifs?, if execute flag goes high then that branch must be taken.following jmp irrelevant
			jmp_flag <= '1';
			jmpaddress <= decode_jmpaddress;
			flush_fetch <= '1';
		
		else  -- necessary?
			jmp_flag <= '0';
			jmpaddress <= ZERO;
			flush_fetch <= '0';
			flush_decode <= '0';
		end if;
	
	end process;

end architecture behavioral;	