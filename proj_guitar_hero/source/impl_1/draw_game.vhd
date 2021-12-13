-- draw_game.vhd
-- Outputs a color to draw the game when given the current state of the game and an (x, y) location.
-- This uses 6-bit color (64 colors)

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity draw_game is
    port (
		--clk : in std_logic;
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

constant BOX_HEIGHT : unsigned(9 downto 0) := 10d"40";
constant BOX_WIDTH  : unsigned(9 downto 0) := 10d"40";
constant BOX_RAD    : unsigned(9 downto 0) := 10d"20";

constant BOTTOM_BAR_ROW : unsigned(9 downto 0) := 10d"440";

signal draw_green  : std_logic;
signal draw_red    : std_logic;
signal draw_yellow : std_logic;
signal draw_blue   : std_logic;
signal draw_orange : std_logic;

begin
	-- Indicate a box should be drawn based on current position
	-- Draw a box pixel when            there is a box         and           the (x,y) is in the area the box is             else don't
	draw_green  <= '1' when (col_green (to_integer(row)) = '1' and (10d"64" - BOX_RAD <= col and col <= 10d"64" + BOX_RAD)) else '0';
	draw_red    <= '1' when (col_red   (to_integer(row)) = '1' and (10d"192" - BOX_RAD <= col and col <= 10d"192" + BOX_RAD)) else '0';
	draw_yellow <= '1' when (col_yellow(to_integer(row)) = '1' and (10d"320" - BOX_RAD <= col and col <= 10d"320" + BOX_RAD)) else '0';
	draw_blue   <= '1' when (col_blue  (to_integer(row)) = '1' and (10d"448" - BOX_RAD <= col and col <= 10d"448" + BOX_RAD)) else '0';
	draw_orange <= '1' when (col_orange(to_integer(row)) = '1' and (10d"576" - BOX_RAD <= col and col <= 10d"576" + BOX_RAD)) else '0';
	
	 --Add draw score to beginning
	rgb <= "000000" when valid = '0' else
		   "111111" when row = BOTTOM_BAR_ROW else    -- Draw where user hits
		   "001100" when draw_green else		      -- Draw boxes
		   "110000" when draw_red else
		   "111100" when draw_yellow else
		   "000011" when draw_blue else
		   "110100" when draw_orange else
		   "000000";
end;

