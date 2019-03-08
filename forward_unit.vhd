library IEEE;
use IEEE.std_logic_1164.all; -- import std_logic types
use IEEE.std_logic_arith.all; -- import add/sub of std_logic_vector
use IEEE.std_logic_unsigned.all;

use work.RISC_lib.all;

entity forward_unit is
	port ( 
			decode_rs1			: in integer;
			decode_rs2			: in integer;
			decode_alu_op1			: in data_word;
			decode_alu_op2			: in data_word;
			
			id_ex_reg_wr		: in std_logic;
			id_ex_reg_no		: in integer;
			alu_result			: in data_word;
			
			ex_mem_reg_wr		: in std_logic;
			ex_mem_reg_no		: in integer;
			ex_mem_result		: in data_word;
			
			mem_wb_reg_wr		: in std_logic;
			mem_wb_reg_no		: in integer;
			mem_wb_result		: in data_word;
			
			
		
		alu_op1	: out data_word;
		alu_op2	: out  data_word
		);
end forward_unit;

architecture behavioral of forward_unit is
begin
	process (decode_rs1, decode_rs2, decode_alu_op1, decode_alu_op2,
				id_ex_reg_wr, id_ex_reg_no, alu_result,
				ex_mem_reg_wr, ex_mem_reg_no, ex_mem_result, 
				mem_wb_reg_wr, mem_wb_reg_no, mem_wb_result )
	begin
		if ((id_ex_reg_wr = '1') and (id_ex_reg_no = decode_rs1)) then
			alu_op1 <= alu_result;
		elsif ((ex_mem_reg_wr = '1') and (ex_mem_reg_no = decode_rs1)) then
			alu_op1 <= ex_mem_result;
		elsif ((mem_wb_reg_wr = '1') and (mem_wb_reg_no = decode_rs1)) then
			alu_op1 <= mem_wb_result;
		else
			alu_op1 <= decode_alu_op1;
		end if;
		
		if ((id_ex_reg_wr = '1') and (id_ex_reg_no = decode_rs2)) then
			alu_op2 <= alu_result;
		elsif ((ex_mem_reg_wr = '1') and (ex_mem_reg_no = decode_rs2)) then
			alu_op2 <= ex_mem_result;
		elsif ((mem_wb_reg_wr = '1') and (mem_wb_reg_no = decode_rs2)) then
			alu_op2 <= mem_wb_result;
		else
			alu_op2 <= decode_alu_op2;
		end if;
	end process;
end architecture behavioral;