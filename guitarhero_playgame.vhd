library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.ALL;
use std.textio.all;

entity playgame is
	port (
		-- Which buttons are being pressewd
		pressing : in std_logic_vector(5 downto 0);
		check : in std_logic;
		
		reset : in std_logic;
		start : in std_logic;
		rgb   : out std_logic_vector(5 downto 0)
	);
end playgame;

signal press_green  : std_logic;
signal press_red    : std_logic;
signal press_yellow : std_logic;
signal press_blue   : std_logic;
signal press_orange : std_logic;
signal strum : std_logic;

signal userInput : std_logic_vector(5 downto 0); 
signal gameInput : std_logic_vector(5 downto 0); -- I guess gameInput would have to Neil's code into account
signal gameOver : std_logic := '0';
signal intialScore : integer := 500;
signal streakCounter : integer := 0;
signal pointCounter : integer := 0; --may or may not be be implemented
signal errorCounter : integer := 0; --may or may not be be implemented


begin 
	process (check) begin
	-- check when the note passes off the screen or when person gives an input
	-- anytime check is on, change the score
	if rising_edge(check) then 
		if(strum = '0' and userInput = gameInput) then 
			initialScore <= initialScore - 50;
			streakCounter <= 0;
		elsif (strum = '1'and userInput /= gameInput) then
			initialScore <= initialScore - 50; 
			streakCounter <= 0;
		elsif strum = '1' and userInput = gameInput then
			initialScore <= initialScore + 50; 
			streakCounter <= streakCounter + 1;
		end if;
		if streakCounter >= 5 then 
			if (strum = '1' and userInput = gameInput) then 
				initialScore <= initialScore + 100;
				streakCounter <= streakCounter + 1;
			end if;
		end if;
	end if;
	end process;
end;
