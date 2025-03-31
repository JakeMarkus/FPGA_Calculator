--------------------------------------------------------
--Name: Jake M
--Class: Engs31 24X
--File: Calculator State Machine
--
--Handles all of the calculator states, stores the operator, and which number register to show
--Tells the datapath what operation to do
--------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;

--=============================================================================
--Entity Declaration:
--=============================================================================
entity FSM is
    Port (
		--timing:
			clk_port 		: in std_logic;
		--control inputs:
			button_pressed : in std_logic ; 
			operator_pressed : in std_logic_vector(3 downto 0); 
						
			advanced_switch : in std_logic; 
			
		--Datapath commands 
			add_en      : out std_logic; 
			sub_en      : out std_logic; 
			mult_en     : out std_logic; 
			div_en      : out std_logic; 
			exp_en      : out std_logic; 
            modd_en     : out std_logic; 
			
			A_en		: out std_logic; 
            A_overwrite : out std_logic; 
            
            B_en 		: out std_logic; 
            
            clearA 		: out std_logic;
            clearB      : out std_logic; 
            
            sel_disp 	: out std_logic);
end FSM;


architecture behavioral_architecture of FSM is
--=============================================================================
--Signal Declarations: 
--=============================================================================

type state_type is (Idle, enA, WFB, enB, doOP, clearall, B_clearer);
signal current_state, next_state : state_type;

signal operator_mode : std_logic_vector(3 downto 0) := "0000"; --A is add or exp (depending on advanced_mode), B is subtract, C is mult., D is divide or Mod
signal B_clear_primed : std_logic := '0'; --Stores if clear has been pressed once in B so that two clears in a row clears all (incl. A)

signal advanced_mode : std_logic := '0'; --Switches operators so we can add extra

begin


stateUpdate: process(clk_port)  
    begin
    	if rising_edge(clk_port) then 
    	
    	    current_state <= next_state;
    	    
    	    if current_state = Idle then
    	       advanced_mode <= advanced_switch; --Only update mode at before operator pressed
    	    end if; 
    	    
        	if current_state = doOP or current_state = Idle or current_state = enB  then 
        	   B_clear_primed <= '0'; --reset double tap
        	end if; 
        	
        	if current_state = Idle and operator_pressed = "1010" then 
        	    operator_mode <= "1010"; -- A for Add and AExponent
        	elsif current_state = Idle and operator_pressed = "1011" then 
        	    operator_mode <= "1011"; --B for Bubtract and b-log
        	elsif current_state = Idle and operator_pressed = "1100" then 
        	    operator_mode <= "1100"; --C for Cmultiply
        	elsif current_state = Idle and operator_pressed = "1101" then 
        	    operator_mode <= "1101"; --D for Divide and dMod
        	elsif current_state = WFB and operator_pressed = "1111" then 
        	    B_clear_primed <= '1'; --prime double tap
        	end if; 
        	

        end if; 
		--complete the update process
end process stateUpdate;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Next State Logic (asynchronous):
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NextStateLogic: process(current_state, button_pressed, operator_pressed)
	begin

	next_state <= current_state;
        case current_state is 
        	when Idle =>
            	if button_pressed = '1' then 
            	   next_state <= enA; --take in digit
            	elsif (operator_pressed = "1010") or (operator_pressed = "1011") or (operator_pressed = "1100") or (operator_pressed = "1101") then 
            	   next_state <= B_clearer; --clear B before taking second number in
            	elsif operator_pressed = "1111" then 
            	   next_state <= clearall;   
            	elsif operator_pressed = "1110" then 
            	   next_state <= doOp; --Do last operation again
            	end if;
            	
            when enA => next_state <= Idle;  
            
            when WFB => 
                if button_pressed  = '1' then 
                    next_state <= enB; 
                elsif operator_pressed = "1110" then 
                    if (operator_mode = "1010") or (operator_mode = "1011") or (operator_mode = "1100") or (operator_mode = "1101") then 
                        next_state <= doOP; -- do a valid operation on '=' press
                    end if;
                elsif operator_pressed = "1111" then 
                    if B_clear_primed = '1' then --double tap clears all
                        next_state <= clearall; 
                    else next_state <= B_clearer; --single tap only clears B
                    end if;  
                end if; 
                
            when clearall => next_state <= Idle; 
            
            when B_clearer => next_state <= WFB; --go back to B after B clear
             
            when enB => next_state <= WFB; 
                    
            when  doOP=> 
            	   next_state <= Idle;
            	   
            when others => 
                next_state <= Idle; 
        end case; 
end process NextStateLogic; 

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Output Logic (asynchronous):
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
OutputLogic: process(current_state)
begin
        --most signals will be low 99% of the time
        A_en <= '0'; 
        B_en  <= '0'; 
       
        add_en <= '0';     
        sub_en <= '0'; 
        mult_en <= '0'; 
        div_en  <= '0'; 
        exp_en <= '0'; 
        modd_en <= '0';            
        
        A_overwrite <= '0'; 
        clearA <= '0'; 
        clearB <= '0';
        sel_disp <= '0'; 
        
        case current_state is 
        
            when enA => 
                A_en <='1'; 
                
            when enB => 
                B_en  <= '1'; 
                sel_disp <= '1'; 
                
            when WFB => 
                sel_disp <= '1'; 
                
            when doOp => 
                A_overwrite <= '1'; 
                if advanced_mode = '0' then 
                    
                    --Send monopulsed commands for Add-Divide 
                    if operator_mode = "1010"
                        then add_en <= '1'; 
                    elsif operator_mode = "1011"
                        then sub_en <= '1'; 
                    elsif operator_mode = "1100"
                        then mult_en <= '1'; 
                    elsif operator_mode = "1101"
                        then div_en <= '1'; 
                    end if; 
                else  --Send monopulsed commands for Exp and Mod
                    if operator_mode = "1010"
                        then  exp_en <= '1'; 
                    elsif operator_mode = "1101"
                        then modd_en <= '1'; 
                    end if; 
                
                end if; 
                    
            when clearall =>
                clearA <= '1'; 
                clearB <= '1'; 
                A_overwrite <= '1'; 
                
            when B_clearer => 
                clearB <= '1'; 
                
            when Idle => 
                null;   
            
            
        end case;


end process OutputLogic;
				
end behavioral_architecture;