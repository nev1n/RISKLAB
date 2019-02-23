--------------------------------------------------------------------------------
--!@file: RISC_top.vhd
--!@brief: this is the top level of the RISC processor
--! - 5-stage dlx pipeline
--! - 21 bit instruction width
--! - harvard arch
--! - 32 bit data
--! - 32 GP register
--
--!@author: 
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all; -- import std_logic types
use IEEE.std_logic_arith.all; -- import add/sub of std_logic_vector
use IEEE.std_logic_unsigned.all;

use work.RISC_lib.all;


entity RISC_top is
	port (
		-- global signals
		clk           : in std_logic;
		reset         : in std_logic; -- active high!
		
		-- signals from/to instruction ROM
		instr_addr    : out data_word;
		instr         : in instr_word;
		
		-- signals from/to data RAM
		data_addr     : out data_word;
		data_from_mem : in data_word;
		write_en      : out std_logic;
		data_to_mem   : out data_word
	);
end entity RISC_top;



architecture behave of RISC_top is

-- PUT YOUR CODE HERE!!!!
	
	-- record types for the pipeline registers
	-- type for ID pipeline register
	type ID_EX_Reg_Type is record
		alu_opc				: alu_operations;
		alu_op1,alu_op2		: data_word;
		dest_reg_no			: integer;
		dest_reg_wr_flag	: std_logic;
		data_write_flag		: std_logic;
		memInstType_flag	: std_logic;
		store_data_addr		: data_word;
	end record ID_EX_Reg_Type;	
	
	 
	-- type for EX pipeline register
	type EX_MA_Reg_Type is record
		alu_opc				: alu_operations;
		alu_op1,alu_op2		: data_word;
		result				: data_word;
		dest_reg_no			: integer;
		dest_reg_wr_flag	: std_logic;
		data_write_flag		: std_logic;
		memInstType_flag	: std_logic;
		store_data_addr		: data_word;
	end record EX_MA_Reg_Type;
	
	
	
	type MA_WB_Reg_Type is record
		result				: data_word;
		dest_reg_no			: integer;
		dest_reg_wr_flag	: std_logic;
	end record MA_WB_Reg_Type;
	
	--the zero records because (others => '0'); doesnt work , notice the => assignement in the contents and NOT <=
	constant ID_EX_Reg_Type_Default : ID_EX_Reg_Type := (alu_opc => NOP , alu_op1 => ZERO, alu_op2 => ZERO, 
															dest_reg_no => 0, dest_reg_wr_flag => '0', data_write_flag => '0',
															memInstType_flag => '0', store_data_addr => ZERO);
	
	constant EX_MA_Reg_Type_Default : EX_MA_Reg_Type := (alu_opc => NOP, alu_op1 => ZERO, alu_op2 => ZERO, 
															result => ZERO, dest_reg_no => 0, dest_reg_wr_flag => '0', 
															data_write_flag => '0', memInstType_flag => '0', store_data_addr => ZERO);
	
	constant MA_WB_Reg_Type_Default : MA_WB_Reg_Type := (result => ZERO, dest_reg_no => 0, dest_reg_wr_flag => '0');
	
	signal PC			:	data_word;
	
	--signal IR		: instr_word;
	--signal PCce		: std_logic;
	
	signal IF_ID_Reg	: instr_word; -- was instr_word

	--signal MA_WB_Reg	: instr_word;
	
	--signal alu_opc_if	: alu_operations;
	--signal alu_op1_if,alu_op2_if	: instr_word;	
	
	signal id_ex_reg_in	: ID_EX_Reg_Type;
	signal id_ex_reg_out	: ID_EX_Reg_Type;

	
	signal ex_ma_reg_in	: EX_MA_Reg_Type;
	signal ex_ma_reg_out	: EX_MA_Reg_Type;
	
	signal ma_wb_reg_in	: MA_WB_Reg_Type;
	signal ma_wb_reg_out	: MA_WB_Reg_Type;
	
	
	
begin

	

-- PUT YOUR CODE HERE!!!!

-- jmpflag and jump address not created
	
	PC_IF:
	
	process(clk, reset) is
	begin
		if reset = '1' then
			PC <= (others => '0');
		elsif rising_edge(clk) then
			if Jmp_Flag = '1' then
				PC <= Jmpaddress;
			else	
				PC <= PC + WORDSIZE;
			end if;
			instr_addr <= PC;
		end if;
	end process;
		
	
	IF_ID: 
	
	process(clk, reset) is
	begin
		if reset = '1' then
			IF_ID_Reg <= (others => '0');
		elsif rising_edge(clk) then
			IF_ID_Reg <= instr;  -- IR replaced as aditional clk cycle introduced
		end if;
	end process;

	
	ID:
	
	entity work.decode_logic port map(clk, reset, IF_ID_Reg,
										ma_wb_reg_out.dest_reg_no, ma_wb_reg_out.result, ma_wb_reg_out.dest_reg_wr_flag,
										id_ex_reg_in.alu_op1, id_ex_reg_in.alu_op2, id_ex_reg_in.alu_opc,
										id_ex_reg_in.dest_reg_no, id_ex_reg_in.dest_reg_wr_flag, id_ex_reg_in.data_write_flag,
										id_ex_reg_in.memInstType_flag, id_ex_reg_in.store_data_addr);
	
	
	ID_EX: 
	process(clk, reset) is
	begin
		if reset = '1' then
			id_ex_reg_out <= ID_EX_Reg_Type_Default; -- because its an effin record
		elsif rising_edge(clk) then
			id_ex_reg_out <= id_ex_reg_in;
		end if;
	end process;
		
	
	EX:
	
	entity work.alu port map (id_ex_reg_out.alu_opc, id_ex_reg_out.alu_op1,id_ex_reg_out.alu_op2, 
								ex_ma_reg_in.result );
								
	ex_ma_reg_in.dest_reg_no		<= id_ex_reg_out.dest_reg_no;
	ex_ma_reg_in.dest_reg_wr_flag	<= id_ex_reg_out.dest_reg_wr_flag;
	ex_ma_reg_in.data_write_flag	<= id_ex_reg_out.data_write_flag;
	ex_ma_reg_in.memInstType_flag	<= id_ex_reg_out.memInstType_flag;
	ex_ma_reg_in.store_data_addr	<= id_ex_reg_out.store_data_addr;
	
	
	EX_MA: 
	
	process(clk, reset) is
	begin
		if reset = '1' then
			--ex_ma_reg_out <= (others => '0');
			ex_ma_reg_out <= EX_MA_Reg_Type_Default; 
		elsif rising_edge(clk) then
			ex_ma_reg_out <= ex_ma_reg_in ;
		end if;
	end process;		
	
	--ma_wb_reg_in.result <= ex_ma_reg_out.result; -- just forwarding result from stage 3 into 4
		
	MA:
	
	entity work.data_access port map (ex_ma_reg_out.result, ex_ma_reg_out.memInstType_flag, ex_ma_reg_out.data_write_flag,
										ex_ma_reg_out.store_data_addr, data_from_mem, ma_wb_reg_in.result, data_addr,
										write_en, data_to_mem);
										
	ma_wb_reg_in.dest_reg_no		<= ex_ma_reg_out.dest_reg_no;
	ma_wb_reg_in.dest_reg_wr_flag	<= ex_ma_reg_out.dest_reg_wr_flag;
	
	
	
	MA_WB: 
	
	process(clk, reset) is
	begin
		if reset = '1' then
		--	ma_wb_reg_out <= (others => '0'); //not possible because this is of type record
			ma_wb_reg_out <= MA_WB_Reg_Type_Default;
		elsif rising_edge(clk) then
			ma_wb_reg_out <= ma_wb_reg_in;	
		end if;
	end process;

end architecture behave;
