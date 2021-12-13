library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.ALL;
use std.textio.all;
 
entity game_score is
    port (
        -- Which buttons are being pressewd
        pressing : in std_logic_vector(5 downto 0);
		curr_color : in std_logic_vector(5 downto 0);
        clk : in std_logic;
        progress : out integer
		-- TODO: Game over out
    );
end game_score;

architecture synth of game_score is

signal hitNote : std_logic := '0'; 
signal gameOver : std_logic := '0';
signal initialScore : integer := 50;
signal streakCounter : integer := 0;
--signal pointCounter : integer := 0; --may or may not be be implemented
--signal errorCounter : integer := 0; --may or may not be be implemented

begin 
	-- Increase score if holding a note and strumming
	process (pressing(5)) begin
		if rising_edge(pressing(5)) then
			--if (hitNote = '1') then
				--if (streakCounter >=5) then
					--initialScore <= initialScore + 15; 
				--else
					--initialScore <= initialScore + 5; 
				--end if;
				--streakCounter <= streakCounter + 1;
			--else--if initialScore >= 5 then
				--initialScore <= initialScore - 5; 
				--streakCounter <= 0;
			--end if;
			
			initialScore <= initialScore + 1;
		end if;
	end process;

	--set value for progress bar
	--process (initialScore) begin
		
		--assert progress <= 0 report to_string(initialScore);
	--end process;

    process (clk) begin
	
    -- check when the note passes off the screen or when person gives an input
    -- anytime check is on, change the score
    if rising_edge(clk) then 
		-- hit_note if for any color, pressing bit equals curr_data bit
		hitNote <= (pressing(0) and curr_color(0)) or (pressing(1) and curr_color(1)) or 
					(pressing(2) and curr_color(2)) or (pressing(3) and curr_color(3)) or 
					(pressing(4) and curr_color(4)); 
    end if;
	
    --if (initialScore <= 0 or 500 <= initialScore) then 
        --gameOver <= '1';
    --end if;
	progress <= initialScore;
	
    end process;
end;