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
		pressing : in std_logic_vector(5 downto 0);
		
		reset : in std_logic;
		start : in std_logic;
		
		--VGA
		RGBout   : out std_logic_vector(5 downto 0);
		rgb   : out std_logic_vector(5 downto 0);
		oscillatorin : in std_logic;
		HSYNCout : out std_logic;
		VSYNCout : out std_logic
		
	);
end top;

architecture synth of top is

constant BOX_HEIGHT : integer := 40;
constant BOX_WIDTH  : integer := 40;

------------------------------------------------------------------------------------------

--port map of clock stuff
component HSOSC is
generic (
	CLKHF_DIV : String := "0b00"); -- Divide 48MHz clock by 2ˆN (0-3)
port(
	CLKHFPU : in std_logic := 'X'; -- Set to 1 to power up
	CLKHFEN : in std_logic := 'X'; -- Set to 1 to enable output
	CLKHF : out std_logic := 'X'); -- Clock output
end component;

------------------------------------------------------------------------------------------

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

------------------------------------------------------------------------------------------

component vga
  port(
	  pllin : in std_logic;
	  RGB : out std_logic_vector(5 downto 0);
	  RGBin : in std_logic_vector(5 downto 0);
	  HSYNC : out std_logic;
	  VSYNC : out std_logic;
	  rowout : out unsigned(9 downto 0);
	  colout : out unsigned(9 downto 0)
  );
end component;

------------------------------------------------------------------------------------------

component generate_notes
	port (
		col_state : in std_logic_vector(479 downto 0);
		rand 	  : in std_logic_vector(7 downto 0);
		gen		  : out std_logic;
		update    : in std_logic
	);
end component;

------------------------------------------------------------------------------------------
--VGA pins

-- Which buttons are being pressed
signal press_green  : std_logic;
signal press_red    : std_logic;
signal press_yellow : std_logic;
signal press_blue   : std_logic;
signal press_orange : std_logic;
signal press_strum  : std_logic;

-- signal to "randomly" generate notes
signal rand : std_logic_vector(63 downto 0) := 64x"100000";

signal clk : std_logic;
signal counter : std_logic_vector(25 downto 0);

-- Game state (arrays to represent where boxes are)
signal col_green   : std_logic_vector(479 downto 0) := 480b"0";
signal col_red     : std_logic_vector(479 downto 0) := 480b"0";
signal col_yellow  : std_logic_vector(479 downto 0) := 480b"0";
signal col_blue   : std_logic_vector(479 downto 0) := 480b"0";
signal col_orange  : std_logic_vector(479 downto 0) := 480b"0";

-- Signals to determine whether a box should be generated for each column
signal gen_g : std_logic := '0';
signal gen_r : std_logic := '0';
signal gen_y : std_logic := '0';
signal gen_b : std_logic := '0';
signal gen_o : std_logic := '0';

-- Output color
--signal rgb_out : std_logic_vector(5 downto 0); TODO: Is this needed?
signal row : unsigned(9 downto 0);
signal col : unsigned(9 downto 0);
signal intergb : std_logic_vector(5 downto 0);

begin
	clock : HSOSC port map('1', '1', clk);
	--vgaout : vga port map(pllin => oscillatorin, RGB => RGBout, HSYNC => HSYNCout, VSYNC => VSYNCout, RGBin => rgbi, rowout => row, colout => col);
	vgaout : vga port map(pllin => oscillatorin, RGB => RGBout, HSYNC => HSYNCout, VSYNC => VSYNCout, RGBin => intergb, rowout => row, colout => col);
	------------------------------------------------------------------------------------------
	-- Given the current game state and a row/column. Give the color of the current pixel
	get_color : draw_game port map(
		row=> row,
		col=> col,
		valid=> '1',    -- TODO: Make sure this is right
		rgb=> intergb,
		col_green=>  col_green,
		col_red=>    col_red,
		col_yellow=> col_yellow,
		col_blue=>   col_blue,
		col_orange=> col_orange
	);
	------------------------------------------------------------------------------------------
	process (clk) begin
		if rising_edge(clk) then
			counter <= counter + 26b"1";
			rand <= (rand(62) xor rand(0)) & rand(63 downto 1);
			
			-- Get button presses
			press_green  <= not pressing(0);
			press_red    <= not pressing(1);
			press_yellow <= not pressing(2);
			press_blue   <= not pressing(3);
			press_orange <= not pressing(4);
			press_strum  <= not pressing(5);
		end if;
	end process;
	
	-- Generate new row when needed
	make_green_note  : generate_notes port map(col_green , rand(7 downto 0), gen_g, counter(20));
	make_red_note    : generate_notes port map(col_red   , rand(7 downto 0), gen_r, counter(20));
	make_yellow_note : generate_notes port map(col_yellow, rand(7 downto 0), gen_y, counter(20));
	make_blue_note   : generate_notes port map(col_blue  , rand(7 downto 0), gen_b, counter(20));
	make_orange_note : generate_notes port map(col_orange, rand(7 downto 0), gen_o, counter(20));
	
	------------------------------------------------------------------------------------------
	-- Shift the notes down one row
	process (counter(20)) begin
		if rising_edge(counter(20)) then
			
		
			col_green  <= gen_g & col_green(479 downto 1);
			col_red    <= gen_r & col_red(479 downto 1);
			col_yellow <= gen_y & col_yellow(479 downto 1);
			col_blue   <= gen_b & col_blue(479 downto 1);
			col_orange <= gen_o & col_orange(479 downto 1);
		end if;
	end process;
	------------------------------------------------------------------------------------------
	
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
