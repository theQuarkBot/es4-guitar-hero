-- draw_game.vhd
-- Outputs a color to draw the game when given the current state of the game and an (x, y) location.
-- This uses 6-bit color (64 colors)

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity draw_game is
    port (
		clk : in std_logic;
        row : in unsigned(9 downto 0);
        col : in unsigned(9 downto 0);
		valid : in std_logic;
        rgb : out std_logic_vector(5 downto 0);
		
		-- Game state (arrays to represent where boxes are)
		col_green   : in std_logic_vector(479 downto 0);
		col_red     : in std_logic_vector(479 downto 0);
		col_yellow  : in std_logic_vector(479 downto 0);
		col_blue    : in std_logic_vector(479 downto 0);
		col_orange  : in std_logic_vector(479 downto 0)
    );
end draw_game;
architecture synth of draw_game is


signal draw_green  : std_logic;
signal draw_red    : std_logic;
signal draw_yellow : std_logic;
signal draw_blue   : std_logic;
signal draw_orange : std_logic;

begin

	draw_green  <= col_green(to_integer(col));
	draw_red    <= col_red(to_integer(col));
	draw_yellow <= col_yellow(to_integer(col));
	draw_blue   <= col_blue(to_integer(col));
	draw_orange <= col_orange(to_integer(col));

	
end;

