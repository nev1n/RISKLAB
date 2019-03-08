--------------------------------------------------------------------------------
--!@file: RISC_lib.vhd
--!@brief: this is the library file of the RISC processor
--! new types and constants are defined here
--
--!@author: Tobias Koal/ Christian Gleichner
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all; -- import std_logic types
use IEEE.std_logic_arith.all; -- import add/sub of std_logic_vector
use IEEE.std_logic_unsigned.all;


package RISC_lib is
	
	constant DATAWIDTH   : natural := 32;
	constant INSTRWIDTH  : natural := 21;
	constant ADDRWIDTH   : natural := 5;
	constant NUMOFREG    : natural := 32; --2**ADDRWIDTH
	
	-- Data word 
	subtype data_word is std_logic_vector(DATAWIDTH-1 downto 0);
	
	-- Instruction word
	subtype instr_word is std_logic_vector(INSTRWIDTH-1 downto 0);
	
	-- Zero vector for initialisation
	constant ZERO  : DATA_WORD := (others => '0');
	
	-- Word size
	constant WORDSIZE	: DATA_WORD := (0 => '1', others => '0');
	
	-- Register file
	type reg_array is array(natural range <>) of data_word;
	
	-- ALU operations
	type alu_operations is (NOP,ADD,SUB,AAND,OOR,XXOR,MOV,SSLL,SSRL,SSRA,SEQ,SNE,SLT,SLE,SGT,SGE,BNE,BEQ,JMP,CALL);
	
	constant OP_REG : std_logic_vector(1 downto 0) := "00";
	constant OP_MEM : std_logic_vector(1 downto 0) := "01";
	constant OP_IMM : std_logic_vector(1 downto 0) := "10";
	constant OP_JMP : std_logic_vector(1 downto 0) := "11";
	
	-- Register-Register Instructions
	constant INSTR_ADD : std_logic_vector(3 downto 0) := X"1";
	constant INSTR_SUB : std_logic_vector(3 downto 0) := X"2";
	constant INSTR_AND : std_logic_vector(3 downto 0) := X"3";
	constant INSTR_OR  : std_logic_vector(3 downto 0) := X"4";
	constant INSTR_XOR : std_logic_vector(3 downto 0) := X"5";
	constant INSTR_MOV : std_logic_vector(3 downto 0) := X"6";
	constant INSTR_SLL : std_logic_vector(3 downto 0) := X"7";
	constant INSTR_SRL : std_logic_vector(3 downto 0) := X"8";
	constant INSTR_SRA : std_logic_vector(3 downto 0) := X"9";
	constant INSTR_SEQ : std_logic_vector(3 downto 0) := X"A";
	constant INSTR_SNE : std_logic_vector(3 downto 0) := X"B";
	constant INSTR_SLT : std_logic_vector(3 downto 0) := X"C";
	constant INSTR_SLE : std_logic_vector(3 downto 0) := X"D";
	constant INSTR_SGT : std_logic_vector(3 downto 0) := X"E";
	constant INSTR_SGE : std_logic_vector(3 downto 0) := X"F";
	-- Memory Access Instructions
	constant INSTR_LD  : std_logic_vector(3 downto 0) := X"0";
	constant INSTR_ST  : std_logic_vector(3 downto 0) := X"1";
	-- Immediate Instructions                                 
	constant INSTR_MVI : std_logic_vector(3 downto 0) := X"0";
	constant INSTR_ADI : std_logic_vector(3 downto 0) := X"1";
	constant INSTR_SBI : std_logic_vector(3 downto 0) := X"2";
	-- Jump/Branch Instructions                               
	constant INSTR_BEQ : std_logic_vector(3 downto 0) := X"0";
	constant INSTR_BNE : std_logic_vector(3 downto 0) := X"1";
	constant INSTR_JMP : std_logic_vector(3 downto 0) := X"2";
	constant INSTR_CLL : std_logic_vector(3 downto 0) := X"3";

	
end package RISC_lib;


package body RISC_lib is
	
end package body;
