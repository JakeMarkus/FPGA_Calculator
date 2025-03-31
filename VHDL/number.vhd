--------------------------------------------------------
--Name: Jake M
--Class: Engs31 24X
--File: Number storage for calculator project
--
--Stores a 4 digit BCD number where each digit can be individually written to
--or all digits can be reset at architecture
--Outputs 4 digit BCD 
--------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164 .all;
use IEEE.numeric_std.all;

entity Number is
    Port (  
              --timing 
			  clk : in  STD_LOGIC;
			  
			  --Keyboard inputs 
			  Button : in STD_LOGIC_VECTOR(3 downto 0);
              
              --FSM commands 
			  en  : in STD_LOGIC; 
      		  overwrite : in STD_LOGIC; 
      		  
              Overwrite_Data : in STD_LOGIC_VECTOR(15 downto 0);
              
              --Output value (4 digit BCD)
              Value : out STD_LOGIC_VECTOR(15 downto 0));         
end Number;

architecture Behavioral of Number is

--4x4 Storage regfile
type regfile is array(0 to 3) of std_logic_vector(3 downto 0);
signal reg : regfile:= (others => (others => '0'));
begin 

--Synchronous flip-flop logic
sync : process(clk)
begin 
	if rising_edge(clk) then
	   
    	for i in 0 to 3 loop --for each digit, load button press if FSM says so via sel_digit and en
            if overwrite = '1' then --Overwrite all of them at once
            	reg(i) <= Overwrite_Data(i*4+3 downto i*4); 
            end if; 
  		end loop;
        
        --If enabled, take in the current digit and shift the rest. How calculator inputs work! 
        if en = '1' then
        	reg(1) <= reg(0); 
            reg(2) <= reg(1); 
            reg(3) <= reg(2);
            reg(0) <= Button;
        end if; 
            
    end if; 
end process; 

Value <= reg(3) & reg(2) & reg(1) & reg(0); --Output BCD

end Behavioral;


