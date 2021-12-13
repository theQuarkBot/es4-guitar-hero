library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vga is
  port(
	  pllin : in std_logic;
	  RGBin : in std_logic_vector(5 downto 0);
	  RGB : out std_logic_vector(5 downto 0);
	  HSYNC : out std_logic;
	  VSYNC : out std_logic;
	  pllpinout : out std_logic;
	  rowout : out unsigned(9 downto 0);
	  colout : out unsigned(9 downto 0)
  );
end vga;

architecture synth of vga is

component mypll is
	port(
		ref_clk_i: in std_logic; -- Input clock
		rst_n_i: in std_logic; -- Reset (active low)
		outcore_o: out std_logic; -- Output to pins
		outglobal_o: out std_logic -- Output for clock network
	);
end component;
signal clk : std_logic;
signal a : std_logic := '1';
signal row : unsigned(9 downto 0) := "0000000000";
signal column : unsigned(9 downto 0) := "0000000000";
begin
  clock : mypll port map (ref_clk_i => pllin, rst_n_i => a, outcore_o => pllpinout, outglobal_o => clk);
  process(clk) begin
    if rising_edge(clk) then
	  rowout <= row;
	  colout <= column;
	  
	  if row = "0000000000" then
	    if column < "111101010" then
			VSYNC <= '1';
			column <= column + '1';
			--If it is sync (492)
	      elsif column < "0111101100" then
		    VSYNC <= '0';
			column <= column + '1';
		  elsif column = "1000001101" then
			column <= "0000000000";	
			VSYNC <= '1';
		  else
			VSYNC <= '1';
			column <= column + '1';
		  end if;
		  HSYNC <= '1';
		  row <= row + '1';
		  --visible + frony
	  elsif row < "1010010000" then
		HSYNC <= '1';
		row <= row + '1';
      elsif row < "1011110000" then
		HSYNC <= '0';
		row <= row + '1';
		--If it is 800
	  elsif row = "1100100000" then
		row <= "0000000000";	
		HSYNC <= '1';
      else
	    HSYNC <= '1';
		row <= row + '1';
      end if;
	  
	  if column < "111100000" then
	    if row < "1010000000" then
		  RGB <= RGBin;
		  
		else
		  RGB <= "000000";
		end if;
       else
	     RGB <= "000000";
       end if;
    end if;
  end process;
end;
