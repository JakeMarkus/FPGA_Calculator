-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity dpshell_tb is
end dpshell_tb;

architecture testbench of dpshell_tb is

component dpshell is
    Port (
        clk	        : in std_logic;
        Button : in STD_LOGIC_VECTOR(3 downto 0);
       
       	A_en		: in std_logic; 
        A_overwrite : in std_logic; 
        
        B_en 		: in std_logic; 
        
        clear 		: in std_logic;
        
        sel_disp 	: in std_logic; 
        BCD_display : out std_logic_vector(15 downto 0) 
        
    );
end component;  

signal clk	        : std_logic := '0';
signal Button : STD_LOGIC_VECTOR(3 downto 0) := "0000";

signal A_en		: std_logic := '0'; 
signal A_overwrite : std_logic :=  '0'; 

signal B_en 		: std_logic := '0'; 

signal clear 		: std_logic := '0';

signal sel_disp 	: std_logic := '0'; 
signal BCD_display : std_logic_vector(15 downto 0) := "0000000000000000"; 


begin

uut : dpshell PORT MAP(
		clk  => CLK,
		A_en => A_en,
       	B_en => B_en,
        A_overwrite => A_overwrite,
        Button => Button,
        clear => clear,
        sel_disp => sel_disp,
        BCD_display => BCD_display);
    
    
clk_proc : process
BEGIN

  CLK <= '0';
  wait for 5ns;   

  CLK <= '1';
  wait for 5ns;

END PROCESS clk_proc;

stim_proc : process
begin
	wait for 55 ns; 
    A_en <= '1'; 
    Button <= "0011"; 
    wait for 10 ns; 
    Button <= "0100";
    wait for 10 ns; 
    Button <= "1001"; 
    wait for 10 ns; 
    A_en <= '0'; 
    wait for 10 ns; 
    B_en <= '1'; 
    Button <= "0111"; 
    sel_disp <= '1';
    wait for 10 ns; 
    Button <= "0001"; 
    wait for 10 ns; 
    B_en <= '0'; 
    wait for 10 ns; 
    A_overwrite <= '1'; 
    sel_disp <= '0';
    wait for 10 ns; 
    A_overwrite <= '0'; 
    wait; 
end process stim_proc;
end testbench;