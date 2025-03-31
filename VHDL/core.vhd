--=============================================================================
--ENGS 31/ CoSc 56
--Lab 5 Shell
--Ben Dobbins
--Eric Hansen
--=============================================================================

--=============================================================================
--Library Declarations:
--=============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

--=============================================================================
--Entity Declaration:
--=============================================================================
entity core is
    Port (
              clk : in  STD_LOGIC;
              button_pressed : in  STD_LOGIC;
              operator_pressed : in std_logic_vector (3 downto 0); 
              Button : in std_logic_vector(3 downto 0);
              A_switch : in std_logic; 
              BCD_display 		: out  std_logic_vector (15 downto 0)	-- anodes        
    );
end core;

--=============================================================================
--Architecture Type:
--=============================================================================
architecture behavioral_architecture of core is

    --=============================================================================
    --Sub-Component Declarations:
    --=============================================================================
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --System Clock Generation:
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component  FSM is
    Port (
		--timing:
			clk_port 		: in std_logic;
		--control inputs:
			button_pressed : in std_logic ; 
			operator_pressed : in std_logic_vector(3 downto 0); 
						
			advanced_switch : in std_logic; 
			 
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
end component;

component dpshell is
    Port (
        clk	        : in std_logic;
        Button : in STD_LOGIC_VECTOR(3 downto 0);
       
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
        
        BCD_display : out std_logic_vector(15 downto 0) 
        
    );
end component;

    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --Input Conditioning:
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++





signal Aen_line : std_logic ;  
signal Aoverwrite_line : std_logic ; 
signal Ben_line : std_logic ; 
signal clearA_line : std_logic; 
signal clearB_line : std_logic; 
signal seldisp_line : std_logic ;

signal add_en_line : std_logic; 
signal mult_en_line : std_logic; 
signal div_en_line : std_logic; 
signal sub_en_line : std_logic; 
signal exp_en_line : std_logic; 
signal modd_en_line : std_logic; 

begin
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --Wire the system clock generator into the shell with a port map:
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --Wire the input conditioning block into the shell with a port map:
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --Wiring the port map in twice generates two separate instances of one component
    State_Machine: FSM 
        port map (
            clk_port 		=> clk, 
			button_pressed => button_pressed,
			operator_pressed => operator_pressed,
			
			advanced_switch => A_switch, 
			add_en  => add_en_line, 
            sub_en  => sub_en_line, 
            mult_en  => mult_en_line, 
            div_en  => div_en_line, 
            exp_en => exp_en_line,     
            modd_en   => modd_en_line,  

			A_en		=> Aen_line, 
            A_overwrite => Aoverwrite_line,
            
            B_en 		=> Ben_line,
            
            clearA 		=>clearA_line,
            clearB      => clearB_line, 
            
            sel_disp 	=> seldisp_line);
            
            
    Datapath :  dpshell
    port map (
        clk	      => clk, 
        Button => Button, 
        
        add_en  => add_en_line, 
        sub_en  => sub_en_line, 
        mult_en  => mult_en_line, 
        div_en  => div_en_line,
        exp_en => exp_en_line,
        modd_en => modd_en_line, 
       
       	A_en		=> Aen_line, 
        A_overwrite => Aoverwrite_line,
        
        B_en => Ben_line, 
        
        clearA 		=> clearA_line,
        clearB      => clearB_line, 
        
        sel_disp 	=>  seldisp_line,
        BCD_display=> BCD_display);
        
 
              
end behavioral_architecture;
