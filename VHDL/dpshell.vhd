--------------------------------------------------------
--Name: Jake M
--Class: Engs31 24X
--File: Datapath Shell
--
--Hooks up the Datapath: Two numbers, and an operator. 
--Hey, that's a calculator! 
--------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


--=============================================================================
--Entity Declaration:
--=============================================================================
entity dpshell is
    Port (
        --timing
        clk	        : in std_logic;
        
        --Input from keyboard
        Button : in STD_LOGIC_VECTOR(3 downto 0);
        
        --Commands from FSM
        add_en      : in std_logic; 
        sub_en      : in std_logic; 
        mult_en     : in std_logic; 
        div_en      : in std_logic;
        exp_en      : in std_logic; 
        modd_en     : in std_logic; 
        
			
       	A_en		: in std_logic; 
        A_overwrite : in std_logic; 
        
        B_en 		: in std_logic; 
        
        clearA 		: in std_logic;
        clearB      : in std_logic; 
        
        sel_disp 	: in std_logic; 
        
        --Display for 7-segment handler
        BCD_display : out std_logic_vector(15 downto 0) 
        
    );
end dpshell;


architecture behavioral_architecture of dpshell is

--=============================================================================
--Sub-Component Declarations:
--=============================================================================

component Operation is
    Port (
		   CLK 	: in  	STD_LOGIC;
           clear    : in std_logic; 
    	   Mult_EN	:  in STD_LOGIC;
           EXP_EN	: in STD_LOGIC;
           Div_EN	: in STD_LOGIC;
           Modd_EN	: in STD_LOGIC;
           Sub_EN	: in STD_LOGIC;
           Add_EN	: in STD_LOGIC;
           A_BCD 	: in  	std_logic_vector (15 downto 0);
           B_BCD 	: in  	std_logic_vector (15 downto 0);
           C_BCD    : out   std_logic_vector (15 downto 0)
           );         
end component;


component Number is
    Port (
			  clk : in  STD_LOGIC;
			  en  : in STD_LOGIC; 
      		  overwrite : in STD_LOGIC; 
      		  
              Button : in STD_LOGIC_VECTOR(3 downto 0);
              Overwrite_Data : in STD_LOGIC_VECTOR(15 downto 0);
              Value : out STD_LOGIC_VECTOR(15 downto 0));         
end component;

--Signals. 
signal A_overwrite_data : std_logic_vector(15 downto 0) := "0000000000000000"; 
signal A_out : std_logic_vector(15 downto 0) := "0000000000000000"; 
signal B_out : std_logic_vector(15 downto 0) := "0000000000000000"; 

begin


--All the components. Two numbers (A, B) and the function logic applied to them Yay! 
    A: Number
        port map (
        clk => clk, 
        en => A_en, 
        overwrite => A_overwrite, 
        Button => Button, 
        Overwrite_Data => A_overwrite_data,
        Value => A_out);
    B: Number
        port map (
        clk => clk, 
        en => B_en, 
        overwrite => clearB, 
        Button => Button, 
        Overwrite_Data => "0000000000000000",
        Value => B_out);
        
    operate_logic: Operation
        port map(
              CLK => clk, 
              clear => clearA, 
      		  
              B_BCD => B_out,
              A_BCD  => A_out,
              C_BCD =>A_overwrite_data,    
              
              Mult_EN => mult_en, 	
              EXP_EN => exp_en, 
              Div_EN => div_en,
              Modd_EN	=> modd_en, 
              Sub_EN	=> sub_en, 
              Add_EN    => add_en
        ); 
	
	--Output either A or B depending on which one the FSM wants. 
    process(A_out, B_out, sel_disp)
    begin 
    	BCD_display <= A_out; 
    	if sel_disp = '1' then 
        	BCD_display <= B_out; 
         end if; 
   end process;
    
end behavioral_architecture;
