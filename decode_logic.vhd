library IEEE;
use IEEE.std_logic_1164.all; -- import std_logic types
use IEEE.std_logic_arith.all; -- import add/sub of std_logic_vector
use IEEE.std_logic_unsigned.all;
--use IEEE.numeric_std.all;
use work.RISC_lib.all;


entity decode_logic is
	port (
		-- global signals
		clk           : in std_logic;
		reset         : in std_logic; -- active high!
		
		instr		: in instr_word;
		--wr_en		: out std_logic;
		ALU_OP1		: out data_word;
		ALU_OP2		: out data_word;
		ALU_OPC		: out alu_operations
		
	);
end entity decode_logic;

architecture behave of decode_logic is

	signal reg_no  		: reg_array(31 downto 0);
	signal rd,rs1,rs2,rs  	: integer;
	
	alias imm 		: std_logic_vector(9 downto 0) is instr(9 downto 0);		

begin
	rd  <= conv_integer(unsigned(instr(14 downto 10)));
	
	
	process(clk, reset)
	begin
		if (reset = '1') then
			reg_no <= (others => ZERO);
			rs1 <= 0;
			rs2 <= 0;
			
			
		-- stefan says to be safe (latch), and that nothing is hanging and in a latched state
		--for all out signals
		--wr_en <= 0;
		--ALU_OP1 ....
				
		else
			case instr(20 downto 19) is
				when OP_REG => 
					rs1 <= conv_integer(unsigned(instr(9 downto 5)));
					rs2 <= conv_integer(unsigned(instr(4 downto 0)));
					ALU_OP1 <= reg_no(rs1);
					ALU_OP2 <= reg_no(rs2);
					case instr(18 downto 15) is
						when INSTR_ADD => 
							ALU_OPC <=ADD;
						when INSTR_SUB =>
							ALU_OPC <=SUB;
						when INSTR_AND =>
							ALU_OPC <=AAND;
						when INSTR_OR =>
							ALU_OPC <=OOR;
						when INSTR_XOR =>
							ALU_OPC <=XXOR;
						when INSTR_MOV =>
							ALU_OPC <=MOV;
						when INSTR_SLL =>
							ALU_OPC <=SSLL;
						when INSTR_SRL =>
							ALU_OPC <=SSRL;
						when INSTR_SRA =>
							ALU_OPC <=SSRA;
						when INSTR_SEQ =>
							ALU_OPC <=SEQ;
						when INSTR_SNE =>
							ALU_OPC <=SNE;
						when INSTR_SLT =>
							ALU_OPC <=SLT;
						when INSTR_SLE =>
							ALU_OPC <=SLE;
						when INSTR_SGT =>
							ALU_OPC <=SGT;
						when INSTR_SGE =>
							ALU_OPC <=SGE;
						when others =>
					end case;

				when OP_MEM => 
					rs <= conv_integer(unsigned(instr(9 downto 5)));
					case instr(18 downto 15) is
						when INSTR_LD =>
						-- enable read by changing write enable to 0
						--	wr_en <= '0';
						when INSTR_ST =>
						--	wr_en <= '1';
						when others =>
					end case;

				when OP_IMM => 
					case instr(18 downto 15) is
						when INSTR_MVI =>
							ALU_OPC <= MOV;
							ALU_OP1 <= ZERO;
							ALU_OP1(9 downto 0) <= imm;
							ALU_OP2 <= ZERO;
						when INSTR_ADI =>
							ALU_OP1 <= reg_no(rd);
							ALU_OP2 <= ZERO;
							ALU_OP2(9 downto 0) <= imm;
							ALU_OPC <= ADD;
						 when INSTR_SBI =>
							ALU_OP1 <= reg_no(rd);
							ALU_OP2 <= ZERO;
							ALU_OP2(9 downto 0) <= imm;
							ALU_OPC <= SUB;
						when others => 
					end case;
				
				when OP_JMP => 
					case instr(18 downto 15) is
						when INSTR_BEQ =>
					
						when INSTR_BNE =>
						when INSTR_JMP =>
						when INSTR_CLL =>
					
						when others =>
					end case;

				when others =>
			end case;
		end if;
	end process;
				 

end architecture behave;
