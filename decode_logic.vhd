library IEEE;
use IEEE.std_logic_1164.all; -- import std_logic types
use IEEE.std_logic_arith.all; -- import add/sub of std_logic_vector
use IEEE.std_logic_unsigned.all;
use work.RISC_lib.all;


entity decode_logic is
	port (
		-- global signals
		clk				: in std_logic;
		reset			: in std_logic; -- active high!
		instr			: in instr_word;
			
		WB_Rd			: in integer;
		WB_result		: in data_word;
		wb_reg_wr_en	: in std_logic;
		
		PC				: in data_word;
		--data_in			: in data_word; 	-- for getting value from data_ld _mem into register, ie for instr load
		
		ALU_OP1			: out data_word;
		ALU_OP2			: out data_word;
		ALU_OPC			: out alu_operations;
		
		ID_rd_no		: out integer;			-- alu register write stuff
		ID_reg_wr_en	: out std_logic;		-- same as above
		data_wr_en		: out std_logic;		-- wr enable for data access	
				
		memInst_flag	: out std_logic;		-- to detect memtype for data access
		out_Rd_value	: out data_word;			-- for store operation, content of rd
		
		decode_jmpflag		: out std_logic;
		decode_jmpaddress	: out data_word;
	
		rs_1			: out integer;
		rs_2			: out integer
	);
end entity decode_logic;

architecture behave of decode_logic is

	signal reg_no  						: reg_array(31 downto 0);
	signal rd,rs1,rs2,rs 				: integer := 0; -- initialize to zero for decode logic to not be hanging. NOT synthesizable
	signal reg_wr_en					: std_logic;
	alias imm							: std_logic_vector(9 downto 0) is instr(9 downto 0);		

	
begin
	
	rd  <= conv_integer(unsigned(instr(14 downto 10)));
	rs1 <= conv_integer(unsigned(instr(9 downto 5)));
	--data_addr <= (others => '0');

	--register set 0 to 31
	process(clk, reset)
	begin
		
		if (reset = '1') then
				reg_no <= (others => ZERO);
				
		elsif rising_edge (clk) then
			if (wb_reg_wr_en = '1') then
				reg_no(WB_Rd) <= WB_result;
			end if;	
		end if;
	end process;
	
	-- decode logic
	process(instr, rd, rs1 )  -- rd was not in the sensitivity list in the beginning!
	begin
			
			-- stefan says to be safe (latch), and that nothing is hanging and in a latched state
			--for all out signals
			
			reg_wr_en 			<= '0'; -- whether to touch the register bank for write
			data_wr_en 			<= '0';
			memInst_flag 		<= '0';
			decode_jmpflag 		<= '0';
			decode_jmpaddress 	<= ZERO;
			
			case instr(20 downto 19) is
				when OP_REG => 
					
					rs2 <= conv_integer(unsigned(instr(4 downto 0)));
					ALU_OP1 <= reg_no(rs1);
					ALU_OP2 <= reg_no(rs2);
					reg_wr_en <= '1'; -- was at the end
					
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
							reg_wr_en <= '0'; -- for nop
					end case;
					
				when OP_MEM => 
					
					ALU_OPC <= MOV;
					ALU_OP1 <= reg_no(rs1);
					ALU_OP2 <= ZERO;
					memInst_flag <= '1';
					
					case instr(18 downto 15) is
						when INSTR_LD =>
						-- enable read by changing write enable to 0
						--	wr_en <= '0';
							reg_wr_en <= '1'; -- write into regbank
							data_wr_en <= '0';
							--ALU_OPC <= MOV; -- st* bypass rs1 as result for wb
							
						when INSTR_ST =>
							reg_wr_en <= '0'; -- needed?!
							data_wr_en <= '1';
							out_Rd_value <= reg_no(rd);
							
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
					reg_wr_en <= '1';
					
				when OP_JMP => 
					
					case instr(18 downto 15) is
						when INSTR_BEQ =>
							ALU_OPC <= BEQ;
							ALU_OP1 <= reg_no(rd);
							ALU_OP2 <= reg_no(rs1);
						when INSTR_BNE =>
							ALU_OPC <= BNE;
							ALU_OP1 <= reg_no(rd);
							ALU_OP2 <= reg_no(rs1);
						when INSTR_JMP =>
							ALU_OPC <= NOP;
							decode_jmpflag <= '1';
							decode_jmpaddress <= reg_no(rd);
						when INSTR_CLL =>
							ALU_OPC <= OOR;
							ALU_OP1	<= PC;
							ALU_OP2 <= ZERO;
							reg_wr_en <= '1';
							decode_jmpflag <= '1';
							decode_jmpaddress <= reg_no(rd);
						when others =>
					end case;

				when others => 
			end case;
			
			ID_rd_no <= rd;
			ID_reg_wr_en <= reg_wr_en;	
			
			rs_1 <= rs1;
			rs_2 <= rs2;
	end process;
	
end architecture behave;
