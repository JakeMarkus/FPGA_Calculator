-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity core_tb is
end core_tb;

architecture testbench of core_tb is

component core is
    Port (
              clk : in  STD_LOGIC;
              button_pressed : in  STD_LOGIC;
              operator_pressed : in std_logic_vector (3 downto 0); 
              Button : in std_logic_vector(3 downto 0);
              A_switch : in std_logic; 
              BCD_display 		: out  std_logic_vector (15 downto 0)	-- anodes        
    );
end component;


signal clk : STD_LOGIC := '0'; --10 MHz clock
signal button_pressed :  STD_LOGIC := '0'; 
signal operator_pressed :  std_logic_vector(3 downto 0) := "0000"; 
signal Button :  STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
signal BCD_display :   STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal A_switch : STD_LOGIC := '0'; 




begin

uut : Core PORT MAP(
		clk  => CLK,
		button_pressed => button_pressed,
		operator_pressed => operator_pressed, 
        Button => Button,
        BCD_display => BCD_display,
        A_switch  => A_switch); 
    
    
clk_proc : process
BEGIN

  CLK <= '0';
  wait for 5ns;   

  CLK <= '1';
  wait for 5ns;

END PROCESS clk_proc;

stim_proc : process
begin
	wait for 500 ns; 
	Button <= "1001";
	button_pressed  <= '1'; 
	wait for 10 ns; 
    button_pressed  <= '0'; 
    wait for 50 ns; 
    Button <= "0110";
	button_pressed  <= '1'; 
	wait for 10 ns; 
    button_pressed  <= '0';	
    wait for 50 ns; 
    operator_pressed <= "1100"; 
    wait for 10 ns; 
    operator_pressed <= "0000"; 
    wait for 10 ns; 
    Button <= "1000"; 
    button_pressed <= '1';
    wait for 10 ns;  
    button_pressed <= '0'; 
    wait for 50 ns; 
    operator_pressed <= "1110"; 
    wait for 10 ns;
    operator_pressed <= "0000"; 
    wait;
end process stim_proc;
end testbench;