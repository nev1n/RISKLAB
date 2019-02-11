library IEEE;
use IEEE.std_logic_1164.all; -- import std_logic types
use IEEE.std_logic_arith.all; -- import add/sub of std_logic_vector
use IEEE.std_logic_unsigned.all;
--use IEEE.numeric_std.all;
use work.RISC_lib.all;


entity data_access is
	port (
		-- global signals
		clk           : in std_logic;
		reset         : in std_logic; -- active high!
		
		instr		: in instr_word;
		
		wr_en		: out std_logic;
		ALU_OP1		: out data_word;
		ALU_OP2		: out data_word;
		ALU_OPC		: out alu_operations
		
		-- signals from/to instruction ROM
		instr_addr    : out data_word;
		instr         : in instr_word;
		
		-- signals from/to data RAM
		data_addr     : out data_word;
		data_from_mem : in data_word;
		write_en      : out std_logic;
		data_to_mem   : out data_word
		
	);