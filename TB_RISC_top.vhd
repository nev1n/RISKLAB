--------------------------------------------------------------------------------
--!@file: TB_RISC_top.vhd
--!@brief: this is the testbench for the RISC processor
--!@author: Tobias Koal/ Christian Gleichner
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_arith.all; 
use IEEE.std_logic_unsigned.all;
use work.RISC_lib.all;
use IEEE.std_logic_textio.all;
library STD;
use std.textio.all;


entity TB_RISC_top is 
end entity TB_RISC_top;

architecture TB_RISC_top_behave of TB_RISC_top is
	-- set the path to your memory file directory here!
	constant MEM_DIR   : string := "mem/";
	-- program memory file is specified here!
	constant MEM_PROG_FILE : string := "prog.mem";
	-- data memory file is specified here!
	constant MEM_DATA_FILE : string := "data.mem";
	
	-- address range exceeds range of type integer,
	-- therefore RAM/ROM is set to a maximum of 2^16
	constant MAX_ROM_COUNT : natural := 2**16;
	constant MAX_RAM_COUNT : natural := 2**16;
	
	constant PERIOD             : time := 100 ns;
	constant RESET_DELAY        : time := 200 ns;
	constant SIMULATION_TIME    : time := 80000 ns;
	
	--! your top level MUST have the same interface as the example here!
	component RISC_top is
		port (      
			clk           : in std_logic;
			reset         : in std_logic;	-- active high!
			instr_addr    : out data_word;
			instr         : in instr_word;
			data_addr     : out data_word;
			data_from_mem : in data_word;
			write_en      : out std_logic;	-- active high!
			data_to_mem   : out data_word
		);
	end component;
	
	type ROM is array (0 to MAX_ROM_COUNT-1) of instr_word;
  	type RAM is array (0 to MAX_ROM_COUNT-1) of data_word;
	signal memory_rom: ROM;
	signal memory_ram: RAM;
	
	signal clk           : std_logic;
	signal reset         : std_logic;
	signal instr_addr    : data_word;
	signal instr         : instr_word;
	signal data_addr     : data_word;
	signal data_to_mem   : data_word;
	signal data_from_mem : data_word;
	signal write_en      : std_logic;
	
	
begin
	-- generate clock signal
	clk_process: process
	begin
		loop
			clk <= '0';
			wait for PERIOD/2;
			clk <= '1';
			wait for PERIOD/2;
			
			assert instr_addr >= 0 and instr_addr < MAX_ROM_COUNT 
			report "ADDRESS ERROR! Instruction address exceeds address range of program memory."
			severity error; --failure
			
			assert data_addr >= 0 and data_addr < MAX_RAM_COUNT 
			report "ADDRESS ERROR! Data address exceeds address range of data memory."
			severity error; --failure
			
			assert now < SIMULATION_TIME
			report "End of Simulation!"
			severity failure; -- throw failure to break simulation
		end loop;
	end process;

	reset <= '1', '0' after RESET_DELAY;

	-- instantiate your top level here!
	tb_component : RISC_top
		port map (
			clk           => clk,
			reset         => reset,
			instr_addr    => instr_addr,
			instr         => instr,
			data_addr     => data_addr,
			data_from_mem => data_from_mem,
			write_en      => write_en,
			data_to_mem	  => data_to_mem
		);
	
	-- simulates data memory
  	data_mem : process(reset, data_addr, data_to_mem, write_en)
		file ram_init_file : text open read_mode is MEM_DIR & MEM_DATA_FILE;
		variable line_in   : line;
   		variable value_in  : data_word;
   		variable good      : boolean;
   		variable address   : integer := 0;
   		variable memory    : RAM := (others => data_word'(others=>'0'));
	begin
        --initialize memory with file content
		if reset = '1' then
			data_from_mem <= memory(0); 
			address := 0;
			loop
				if endfile(ram_init_file) then 
					exit; 
				else
					readline(ram_init_file,line_in);
					read(line_in, value_in, good);
					memory(address) := value_in;
					address := address + 1;
				end if;
			end loop;
		-- normal data memory behaviour
		elsif data_addr >= 0 and data_addr < MAX_RAM_COUNT then
			-- asynchronous write
			if write_en = '1' then
				memory(CONV_INTEGER(data_addr)) := data_to_mem;
			-- asynchronous read
			else
				data_from_mem <= memory(CONV_INTEGER(data_addr));
			end if;
		end if;
		memory_ram <= memory;
	end process;
	
	-- simulates program memory
	prog_mem : process(reset, instr_addr)
		file ram_init_file : text open read_mode is MEM_DIR & MEM_PROG_FILE;
	    variable line_in   : line; -- Line buffers
		variable value_in  : instr_word;
		variable good      : boolean;
		variable address   : integer := 0;
		variable memory    : ROM := (others => instr_word'(others=>'0'));
	begin
        --initialize memory with file content
		if reset = '1' then
			instr <= memory(0); 
			address := 0;
			loop
				if endfile(ram_init_file) then 
					exit; 
				else
					readline(ram_init_file,line_in);
					read(line_in, value_in, good);
					memory(address) := value_in;
					address := address + 1;
				end if;
			end loop;
		-- normal memory behaviour (read)
		elsif instr_addr >= 0 and instr_addr < MAX_ROM_COUNT then
			instr <= memory(CONV_INTEGER(instr_addr));
		end if;
		memory_rom <= memory;
	end process;
	
end TB_RISC_top_behave;
