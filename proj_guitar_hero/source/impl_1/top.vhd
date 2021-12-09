-- This is a possible starter template for making the program.
-- I figure it will work as long as each subcomponent works
-- By no means is this completely planned. Lots of stuff still needs to be done.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity top is
	port (
		-- Which buttons are being pressewd
		pressing : in std_logic_vector(4 downto 0);
		
		reset : in std_logic;
		start : in std_logic;
		rgb   : out std_logic_vector(5 downto 0)
	);
end top;

architecture synth of top is

--port map of clock stuff
component HSOSC is
generic (
	CLKHF_DIV : String := "0b00"); -- Divide 48MHz clock by 2ˆN (0-3)
port(
	CLKHFPU : in std_logic := 'X'; -- Set to 1 to power up
	CLKHFEN : in std_logic := 'X'; -- Set to 1 to enable output
	CLKHF : out std_logic := 'X'); -- Clock output
end component;

-- Get the RGB value for the current pixel
component draw_game
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
end component;

-- Which buttons are being pressed
signal press_green  : std_logic;
signal press_red    : std_logic;
signal press_yellow : std_logic;
signal press_blue   : std_logic;
signal press_orange : std_logic;




--COMPONENT FOR VGA DISPLAY
-------------------------------
-------------------------------
-------------------------------

constant BOX_HEIGHT : unsigned(5 downto 0) := 6d"30";
constant BOX_WIDTH  : unsigned(5 downto 0) := 6d"30";

signal clk : std_logic;
signal counter : std_logic_vector(25 downto 0);

-- Game state (arrays to represent where boxes are)
signal col_green   : std_logic_vector(479 downto 0) := 480b"0";
signal col_red     : std_logic_vector(479 downto 0) := 480b"0";
signal col_yellow  : std_logic_vector(479 downto 0) := 480b"0";
signal col_blue    : std_logic_vector(479 downto 0) := 480b"0";
signal col_orange  : std_logic_vector(479 downto 0) := 480b"0";

signal gen_g : std_logic := '0';
signal gen_r : std_logic := '0';
signal gen_y : std_logic := '0';
signal gen_b : std_logic := '0';
signal gen_o : std_logic := '0';


-- Output color
--signal rgb_out : std_logic_vector(5 downto 0); TODO: Is this needed?
signal row : unsigned(9 downto 0);
signal col : unsigned(9 downto 0);

begin
	clock : HSOSC port map('1', '1', clk);
	
	-- Given the current game state and a row/column. Give the color of the current pixel
	get_color : draw_game port map(
		row=> row,
		col=> col,
		valid=> '1',    -- TODO: Make sure this is right
		rgb=> rgb,
		col_green=>  col_green,
		col_red=>    col_red,
		col_yellow=> col_yellow,
		col_blue=>   col_blue,
		col_orange=> col_orange
	);
	
	process (clk) begin
		if rising_edge(clk) then
			counter <= counter + 26b"1";
			
			-- Get button presses
			press_green  <= pressing(0);
			press_red    <= pressing(1);
			press_yellow <= pressing(2);
			press_blue   <= pressing(3);
			press_orange <= pressing(4);
		end if;
	end process;
	
	
	
	
	process (counter(20)) begin
		if rising_edge(counter(20)) then
			col_green  <= gen_g & col_green(479 downto 1);
			col_red    <= gen_r & col_red(479 downto 1);
			col_yellow <= gen_y & col_yellow(479 downto 1);
			col_blue   <= gen_b & col_blue(479 downto 1);
			col_orange <= gen_o & col_orange(479 downto 1);
		
		
		
		end if;
	
	
	
	
	end process;
	
	-- TODO: logic to determine which buttons are being pressed

	-- TODO: logic to determine whether a box should be drawn in each column
	
	-- TODO: logic to draw on VGA
	-- TODO: determine constants to define how screen should be drawn

	-- TODO: make game logic
		-- Check user input and determine new score (how to do this)
	
		-- Generate new line of boxes, shifting all old ones down one
			-- If there is a 1 in the line below, check how big that box is, and give 1 or 0 depending on size\
			-- If there is a 0: Check that there has been a sufficient delay for another box to be drawn;
				-- If so, run random number generator to determine whether a new box should be placed
end;
