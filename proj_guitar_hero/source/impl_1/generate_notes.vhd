-- Scrolls the game state and generates new notes to play

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

-- This should do something to generate a new 1 or 0 on top of the string. Needs to be random?
entity generate_notes is
	port (
		col_state : in std_logic_vector(479 downto 0);
		rand 	  : in std_logic_vector(7 downto 0);
		gen		  : out std_logic;
		update    : in std_logic
	);
end generate_notes;

architecture synth of generate_notes is

constant BOX_HEIGHT : integer := 40;

--constant BOX_HEIGHT : unsigned(5 downto 0) := 6d"30";
--constant BOX_WIDTH  : unsigned(5 downto 0) := 6d"30";

signal is_box : std_logic;
signal new_box : std_logic;

begin
	process (update) begin
		if rising_edge(update) then
			is_box <= '1' when (col_state(479) = '1' and col_state(479 - BOX_HEIGHT) = '0') else '0';
			new_box <= '1' when (col_state(479 - (2 * BOX_HEIGHT) + 1) = '1') and (rand(1 downto 0) = "00") else '0';
			gen <= is_box or new_box;
		end if;
	end process;
end;
