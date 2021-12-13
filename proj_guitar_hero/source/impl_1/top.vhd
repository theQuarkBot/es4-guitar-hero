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
		rand 	  : in std_logic;
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
signal rand1 : std_logic;
signal rand2 : std_logic;
signal rand3 : std_logic;
signal rand4 : std_logic;
signal rand5 : std_logic;

signal clk : std_logic;
signal counter : std_logic_vector(25 downto 0);
signal update : std_logic;

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

signal cur_note : integer := 0;
signal to_next_note : integer := 0;
signal num_pixels : integer := 0;

signal counterzz  : unsigned(479 downto 0) := 480d"0";

-- Output color
--signal rgb_out : std_logic_vector(5 downto 0); TODO: Is this needed?
signal row : unsigned(9 downto 0);
signal col : unsigned(9 downto 0);
signal intergb : std_logic_vector(5 downto 0);

--memory vars
signal data : std_logic_vector(49 downto 0);
signal addr : std_logic_vector(2 downto 0);
signal addrcounter : unsigned(2 downto 0);
signal addrcountlogic : std_logic_vector(2 downto 0);

begin
	addrcountlogic <= std_logic_vector(addrcounter);
	
	clock : HSOSC port map('1', '1', clk);
	update <= counter(19);
	
	--vgaout : vga port map(pllin => oscillatorin, RGB => RGBout, HSYNC => HSYNCout, VSYNC => VSYNCout, RGBin => rgbi, rowout => row, colout => col);
	vgaout : vga port map(pllin => oscillatorin, RGB => RGBout, HSYNC => HSYNCout, VSYNC => VSYNCout, RGBin => intergb, rowout => row, colout => col);
	------------------------------------------------------------------------------------------
	
	-- Given the current game state and a row/column. Give the color of the current pixel
	get_color : draw_game port map(
		row=> col,
		col=> row,
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
			
			-- Get button presses
			press_green  <= not pressing(0);
			press_red    <= not pressing(1);
			press_yellow <= not pressing(2);
			press_blue   <= not pressing(3);
			press_orange <= not pressing(4);
			press_strum  <= not pressing(5);
		end if;
	end process;
	
	-- Generate new data
	process(clk) is
	begin
		if rising_edge(clk) then
			case addr is
				when "000" => data <= "10100001011110011001011011111101001001000101000001"; -- Assumes 2-bit address and 16-bit data
				when "001" => data <= "10110101110001111010010001011011101110101010000111"; -- You can make these any size you want
				when "010" => data <= "01000111110000111101000100100011011000011011011010";
				when "011" => data <= "10001011101011100000101001110000100000100110001100";
				when "100" => data <= "10101000000101000101011101000010011110111101111000";
				when others => data <= 50b"0"; -- Don't forget the "others" case!
			end case;
		end if;
	end process;

	process (update) begin
		if rising_edge(update) then
			--num_pixels <= num_pixels + 1;
			--if (to_next_note >= 80) then
				--to_next_note <= 0;
				--cur_note <= cur_note + 1;
			--else
				--to_next_note <= to_next_note + 1;
			--end if;
			
			col_green  <= col_green(478 downto 0)  & gen_g;
			col_red    <= col_red(478 downto 0)    & gen_r;
			col_yellow <= col_yellow(478 downto 0) & gen_y;
			col_blue   <= col_blue(478 downto 0)   & gen_b;
			col_orange <= col_orange(478 downto 0) & gen_o;
		end if;
	end process;

	--process (num_pixels) begin
		--if rising_edge(num_pixels) then
			
		--end if;
	--end process;

	--process (to_next_note) begin
		--if to_next_note < 5 then
			--addr <= std_logic_vector(to_unsigned(to_next_note, 3));
		--end if;
	--end process;
	
	--addr <= "000";
	rand1 <= '1';
	rand2 <= '1';
	rand3 <= '1';
	rand4 <= '1';
	rand5 <= '1';
	
	--process (data) begin
		--if (to_next_note = 1) then
			--rand1 <= data(cur_note);
		--elsif (to_next_note = 2) then
			--rand2 <= data(cur_note);
		--elsif (to_next_note = 3) then
			--rand3 <= data(cur_note);
		--elsif (to_next_note = 4) then
			--rand4 <= data(cur_note);
		--elsif (to_next_note = 5) then
			--rand5 <= data(cur_note);
		--end if;
	--end process;

	-- Generate new row when needed
	make_green_note  : generate_notes port map(col_green , rand1, gen_g, update);
	make_red_note    : generate_notes port map(col_red   , rand2, gen_r, update);
	make_yellow_note : generate_notes port map(col_yellow, rand3, gen_y, update);
	make_blue_note   : generate_notes port map(col_blue  , rand4, gen_b, update);
	make_orange_note : generate_notes port map(col_orange, rand5, gen_o, update);
	
	
	
	------------------------------------------------------------------------------------------
	-- Shift the notes down one row
	--process (update) begin
		--if rising_edge(update) then
			
			--counterzz <= counterzz + '1';
			--if (addrcountlogic = "000") then
				--addr <= "000";
				--col_green  <= col_green(478 downto 0)  & data(to_integer(counterzz));
				--addrcounter <= addrcounter + '1';
			--elsif (addrcountlogic = "001") then
				--addr <= "001";
				--col_red    <= col_red(478 downto 0)    & data(to_integer(counterzz));
				--addrcounter <= addrcounter + '1';
			--elsif (addrcountlogic = "010") then
				--addr <= "010";
				--col_yellow <= col_yellow(478 downto 0) & data(to_integer(counterzz));
				--addrcounter <= addrcounter + '1';
			--elsif (addrcountlogic = "011") then
				--addr <= "011";
				--col_blue   <= col_blue(478 downto 0)   & data(to_integer(counterzz));
				--addrcounter <= addrcounter + '1';
			--elsif (addrcountlogic = "100") then
				--addr <= "100";
				--col_orange <= col_orange(478 downto 0) & data(to_integer(counterzz));
				--addrcounter <= addrcounter + '1';
			--elsif (addrcountlogic = "101") then
				--addrcounter <= "000";
			--end if;
			
		--end if;
	--end process;

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
