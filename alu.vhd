--src: https://github.com/inforichland/freezing-spice/blob/master/src/alu.vhd 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.RISC_lib.all;

entity alu is
    port (alu_opc		: in  alu_operations;
          alu_op1		: in  data_word;
          alu_op2		: in  data_word;
          result		: out data_word);
end entity alu;

architecture behavioral of alu is

begin  -- architecture behavioral

    -- purpose: arithmetic and logic
    -- type   : combinational
    -- inputs : alu_opc, alu_op1, alu_op2
    -- outputs: result
    alu_proc : process (alu_opc, alu_op1, alu_op2) is
         variable so1, so2 : signed(31 downto 0);
        variable uo1, uo2 : unsigned(31 downto 0);
    begin  -- process alu_proc
        
		so1 := signed(alu_op1);
        so2 := signed(alu_op2);
        uo1 := unsigned(alu_op1);
        uo2 := unsigned(alu_op2);
        result <= (others => '0'); -- NOP implementation ignored because of this
		
        case (alu_opc) is
            when ADD => result <= std_logic_vector(uo1 + uo2);
            when SUB => result <= std_logic_vector(uo1 - uo2);
            when AAND => result <= alu_op1 and alu_op2;
            when OOR  => result <= alu_op1 or alu_op2;
            when XXOR => result <= alu_op1 xor alu_op2;
			
			when MOV  => 
				result <= alu_op1;
			
			when SSLL => result <= std_logic_vector(shift_left(uo1, to_integer(uo2(4 downto 0))));
			when SSRL => result <= std_logic_vector(shift_right(uo1, to_integer(uo2(4 downto 0))));
			when SSRA => result <= std_logic_vector(shift_right(so1, to_integer(uo2(4 downto 0))));
			when SEQ  => 
				if uo1 = uo2 then
                    result <= (0 => '1', others => '0');
				end if;
			when SNE  =>
				if uo1 /= uo2 then
						result <= (0 => '1', others => '0');
				end if;		
			when SLT =>
                if uo1 < uo2 then
                    result <= "00000000000000000000000000000001";
				end if;
			when SLE =>
				if uo1 <= uo2 then
						result <= (0 => '1', others => '0');
				end if;		
			when SGT =>
				if uo1 > uo2 then
						result <= (0 => '1', others => '0');
				end if;
			when SGE => 
				if uo1 >= uo2 then
						result <= (0 => '1', others => '0');	
				end if;
            when others  => 
        end case;
    end process alu_proc;

end architecture behavioral;