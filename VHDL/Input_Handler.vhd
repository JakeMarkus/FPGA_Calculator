--------------------------------------------------------
--Name: Jake M
--Class: Engs31 24X
--File: Keyboard Input Handler
--
--Interacts with Digilent's PmodKYPD keyboard, and filters between number and operation presses
--------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

--takes in clk and row responses (which role is held down at col output)
--puts out col to keyboard, and three things to rest of logic: 
--button pressed is a monopulsed signal for every new button press (0-9)
--Smoothed_Button is the always the last numeric button architecture (0-9)
--operator pressed is a monopulsed operator (A,B,C,D,E,F)
entity Input_Handler is
    Port (
              clk : in  STD_LOGIC;
              Row : in  STD_LOGIC_VECTOR (3 downto 0);
			  button_pressed : out STD_LOGIC; 
			  operator_pressed : out std_logic_vector(3 downto 0); 
			  Col : out  STD_LOGIC_VECTOR (3 downto 0);
              Smoothed_Button : out  STD_LOGIC_VECTOR (3 downto 0));
end Input_Handler;

architecture Behavioral of Input_Handler is

signal divider : integer := 0; --Goes from 0-400020 to make slower output so keyboard can handle it. 100 MHz is crazy fast! 
signal last_button : std_logic_vector(4 downto 0) := "00000"; 
signal curr_button : std_logic_vector(4 downto 0) := "00000"; 
signal flopper : std_logic := '0'; --flopper changes between two button presses of the same number, so we know there's been a new input
signal held : std_logic_vector(3 downto 0) := "0000"; --Held keeps track of which cols have currently held down buttons. Needed to update flopper

begin
	process(clk)
		begin 
		if rising_edge(clk) then
			
			--Change which column we're reading every 1ms. Low is logical true! 
			if divider = 100000 then 
			    held <= "1111";
				Col<= "0111";
		    elsif divider = 200000 then	
				Col<= "1011";
			elsif divider = 300000 then 
				Col<= "1101";
		    elsif divider = 400000 then 			
				Col<= "1110";
			end if; 
			
			--If a row comes back with a button press, record that in curr_button
			if divider = 100010 then	
				if Row = "0111" then
					curr_button <= flopper & "0001";	--1
				elsif Row = "1011" then
					curr_button <= flopper & "0100"; --4
				elsif Row = "1101" then
					curr_button <= flopper & "0111"; --7
				elsif Row = "1110" then
					curr_button <= flopper & "0000"; --0
			    else held(0) <= '0'; 
				end if;
			elsif divider = 200010 then	
				if Row = "0111" then		
					curr_button <= flopper & "0010"; --2
				elsif Row = "1011" then
					curr_button <= flopper & "0101"; --5
				elsif Row = "1101" then
					curr_button <= flopper & "1000"; --8
				elsif Row = "1110" then
					curr_button <= flopper & "1111"; --F
				else held(1) <= '0';
				end if;
			elsif divider = 300010 then 
				if Row = "0111" then
					curr_button <= flopper & "0011"; --3	
				elsif Row = "1011" then
					curr_button <= flopper & "0110"; --6
				elsif Row = "1101" then
					curr_button <= flopper & "1001"; --9
				elsif Row = "1110" then
					curr_button <= flopper & "1110"; --E
				else held(2) <= '0';
				end if;
			elsif divider = 400010 then 
				if Row = "0111" then
					curr_button <= flopper & "1010"; --A
				elsif Row = "1011" then
					curr_button <= flopper & "1011"; --B
				elsif Row = "1101" then
					curr_button <= flopper & "1100"; --C
				elsif Row = "1110" then
					curr_button <= flopper & "1101"; --D
				else held(3) <= '0';
				end if;
			end if;
			
			--Reset divider ever 4-ish ms
		    if divider = 400020 then 
		      divider <= 0; 
		      --flip flopper if nothing is held down, so if 5 is pressed/released and than press again, the new 5 =/= old 5. This triggers an output! 
		      if held = "0000" then flopper <= not curr_button(4); end if; 
		    else divider <= divider + 1; 
		    end if;
		    
		    --If a new button is pressed, check if operator or number and do corresponding output
		    if not (curr_button = last_button) then 
		      
		      if unsigned(curr_button(3 downto 0)) > 9 then
		          operator_pressed <= curr_button (3 downto 0); 
		      else button_pressed <= '1';  
		      end if; 
		      last_button <= curr_button;
		    else 
		      button_pressed <= '0';
		      operator_pressed <= "0000"; 
		    end if; 
		    
		    
		end if; 
	end process;
	--Output smoothed button without flopper.
	Smoothed_Button <= curr_button(3 downto 0); 
end Behavioral;
