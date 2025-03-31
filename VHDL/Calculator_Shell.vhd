--------------------------------------------------------
--Name: Jake M
--Class: Engs31 24X
--File: Top Shell for Calculator Project
--
--Connects all the blocks of our design: input handler, State Machine, Datapath, and the output handler
--------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

--top level entity
entity calc_shell is
    Port (
              clk : in  STD_LOGIC;
              Row : in  STD_LOGIC_VECTOR (3 downto 0);
              A_switch : in std_logic; 
			  Col : out  STD_LOGIC_VECTOR (3 downto 0);
              seg_ext_port 	: out  std_logic_vector(0 to 6);		-- segments (a...g)
              dp_ext_port 		: out  std_logic;								-- decimal point
              an_ext_port 		: out  std_logic_vector (3 downto 0);	-- anodes
              A_light_port        : out std_logic;   
              B_light_port        : out std_logic        
                
    );
end calc_shell;


architecture behavioral_architecture of calc_shell is

--=============================================================================
--Declare all four components
--=============================================================================
--State machine declaration
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

--Datapath declaration

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

--Datapath declaration
component Input_Handler is
    Port (
			  clk : in  STD_LOGIC;
			  button_pressed : out STD_LOGIC; 
			  operator_pressed : out std_logic_vector (3 downto 0); 
              Row : in  STD_LOGIC_VECTOR (3 downto 0);
			  Col : out  STD_LOGIC_VECTOR (3 downto 0);
              Smoothed_Button : out  STD_LOGIC_VECTOR (3 downto 0));
              
end component;

--display declaration
component  mux7seg is
    Port ( clk_port 	: in  std_logic;						-- runs on a fast (1 MHz or so) clock
         y3_port 		: in  std_logic_vector (3 downto 0);	-- digits
         y2_port 		: in  std_logic_vector (3 downto 0);	-- digits
         y1_port 		: in  std_logic_vector (3 downto 0);	-- digits
         y0_port 		: in  std_logic_vector (3 downto 0);	-- digits
         dp_set_port 	: in  std_logic_vector(3 downto 0);     -- decimal points
         seg_port 	: out  std_logic_vector(0 to 6);		-- segments (a...g)
         dp_port 		: out  std_logic;						-- decimal point
         an_port 		: out  std_logic_vector (3 downto 0) );	-- anodes
end component ;


--=============================================================================
--Declare all intermediate signals
--=============================================================================
signal BCD_outline : std_logic_vector(15 downto 0);
signal SButton_line : std_logic_vector(3 downto 0);
signal bp_line : std_logic ; 
signal operpressed_line : std_logic_vector(3 downto 0); 
signal button_pressed : std_logic := '0';

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
--=============================================================================
--Wire it all up; Consult diagram! 
--=============================================================================
    display: mux7seg
        port map (
        clk_port => clk,
        y3_port => BCD_outline(15 downto 12),	
        y2_port => BCD_outline(11 downto 8),	
        y1_port => BCD_outline(7 downto 4),	
        y0_port => 	BCD_outline(3 downto 0), 
        dp_set_port => "000" & seldisp_line,
        seg_port => seg_ext_port ,
        dp_port  => dp_ext_port ,	
        an_port => an_ext_port 	);
    Handler: Input_Handler 
        port map (
          clk => clk,  
          button_pressed => bp_line, 
          operator_pressed => operpressed_line, 
          Row => Row,
          Col => Col,
          Smoothed_Button => SButton_line );
    State_Machine: FSM 
        port map (
            clk_port 		=> clk, 
			button_pressed => bp_line,
			operator_pressed => operpressed_line,
			
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
        Button => SButton_line, 
        
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
        BCD_display=> BCD_outline);
        
 
         A_light_port <= not seldisp_line;  
         B_light_port <= seldisp_line;     
end behavioral_architecture;
