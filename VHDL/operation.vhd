--------------------------------------------------------
--Name: Jake M
--Class: Engs31 24X
--File: Operate logic 
--
--Combines the numbers in funny ways: add, subtract, mult., divide, exp., and mod. 
--All except exp. are asynchronous, exp takes ~13 clock cycles to update. 
--
--Assumes the user doesn't press "=" .13 microseconds after entering the last number for exp
--Our calculator works for everyone except the Flash
--------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164 .all;
use IEEE.numeric_std.all;

entity operation is
    Port ( 
           --timing
           CLK 	: in  	STD_LOGIC;
           
           --FSM inputs
           clear    : in std_logic; 
    	   Mult_EN	:  in STD_LOGIC;
           EXP_EN	: in STD_LOGIC;
           Div_EN	: in STD_LOGIC;
           Modd_EN	: in STD_LOGIC;
           Sub_EN	: in STD_LOGIC;
           Add_EN	: in STD_LOGIC;
           
           --Two BCD inputs (A,B) and the BCD output (C)
           A_BCD 	: in  	std_logic_vector (15 downto 0);
           B_BCD 	: in  	std_logic_vector (15 downto 0);
           C_BCD    : out   std_logic_vector (15 downto 0)
			  );
end operation;

architecture Behavioral of operation is

--Each number converted to binary for easy math
signal A_binary : unsigned(15 downto 0) := "0000000000000000"; 
signal B_binary : unsigned(15 downto 0) := "0000000000000000"; 
signal out_binary : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000"; 

--Constantly doing these operations async.. Their results in binary
signal added_binary : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000"; 
signal subbed_binary : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000"; 
signal multed_binary : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000"; 
signal dived_binary : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000"; 
signal modded_binary : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000"; 

--For exponents, each multiplication step is saved. Correct index outputed. Avoids for loops! 
signal exp_count : integer := 0;
type regfile is array(0 to 13) of unsigned(15 downto 0);
signal exp_reg : regfile:= (others=>(others => '0')); 

signal log_dc : unsigned(15 downto 0) := "0000000000000000"; 
signal log_Aghost : unsigned(15 downto 0) := "0000000000000000"; --Initial value of A to be changed by log signal

begin  

--BCD -> binary synchronous conversion for A/B
A_convert : process(A_BCD)
begin 
    A_binary <= ("00" & (unsigned(A_BCD(3 downto 0)) + "1010" * unsigned(A_BCD(7 downto 4)) + "1100100" * unsigned(A_BCD(11 downto 8)) + "1111101000" * unsigned(A_BCD(15 downto 12)))); 
end process; 

B_convert : process(B_BCD)
begin 
    B_binary <= "00" & (unsigned(B_BCD(3 downto 0)) + "1010" * unsigned(B_BCD(7 downto 4)) + "1100100" * unsigned(B_BCD(11 downto 8)) + "1111101000" * unsigned(B_BCD(15 downto 12))); 
end process; 


--These two operations are one liners! Thanks VHDL. 
added_binary  <= STD_LOGIC_VECTOR(A_binary+B_binary);
multed_binary <= std_logic_vector(to_unsigned( to_integer(A_binary) * to_integer(B_binary),16)); 



--Subtraction operation. No negatives, bottoms out at 0. 
subtraction : process(Sub_EN)
begin 
    subbed_binary <= std_logic_vector(A_binary -B_binary ); 

    if A_binary < B_binary then 
        subbed_binary <=  "0000000000000000"; 
    end if; 
end process; 

--Division process. Comment out for testbenches, vivado freaks out about divide by 0 (despite the check).
division : process(Div_EN, Modd_EN) --If Mod is added, and Mod_en here
begin 
   if B_binary = "0000000000000000" then 
        dived_binary <= "0000000000000000";
   else 
        dived_binary <= std_logic_vector(to_unsigned( to_integer(A_binary) / to_integer(B_binary),16)); 
    end if; 

end process; 

--Modd process. Was originally more complicated. 
modding : process(Modd_EN)
begin 
    
    modded_binary <= std_logic_vector(to_unsigned( to_integer(A_binary) - to_integer(unsigned(dived_binary)) * to_integer(B_binary),16));  
   
end process; 

exping : process(clk) --can't be a for loop because vars are updated after processes
begin 
    if rising_edge(clk) then 
        exp_reg(0) <= "0000000000000001"; --x^0 = 1 always
        
        --cycle through each multiplication
        if exp_count = 13 then
           exp_count <= 1; 
        else exp_count <= exp_count +1; 
        end if; 
        
        --update A each 13 cycles
        if exp_count = 0 then 
            exp_reg(1) <= A_binary; 
        else --next multiple in the chain! ex. 64*2 = 128 = 2^6, so (index 5) * 2 = (index 6)
            exp_reg(exp_count) <= to_unsigned( to_integer(exp_reg(exp_count -1)) * to_integer(A_binary),16); 
            
        end if; 
    end if; 
end process; 

--A giant mux to send the requested output out. 
mux_out : process(Mult_EN, Add_EN, Sub_EN, Div_EN, EXP_EN, Modd_EN)
begin 
    out_binary <="0000000000000000"; 
    if Add_EN = '1' then 
        out_binary <= added_binary; 
    elsif Sub_EN = '1' then 
        out_binary <= subbed_binary;
    elsif Mult_EN = '1' then 
        out_binary <= multed_binary ; 
    elsif Div_EN = '1' then 
        out_binary <= dived_binary; 
    elsif EXP_EN  = '1' then
        if B_binary > 12 then
            out_binary <= "0000000000000000"; 
        else  
            out_binary <= STD_LOGIC_VECTOR(exp_reg(to_integer(B_binary))); --Choose the right exp. power. 2^7 is the 7th index of the exp. regfile. 
        end if; 
    elsif Modd_EN = '1' then 
        out_binary <= modded_binary; 
    end if; 
end process; 

--Convert back to BCD for the output. This replaces double dabble 
Decimal_to_BCD : process(out_binary)
begin
	C_BCD <= "0000000000000000";
	if clear = '1' then C_BCD <= "0000000000000000";
    
    else 
		C_BCD(3 downto 0) <= std_logic_vector(to_unsigned(to_integer(unsigned(out_binary)) mod 10, 4));
		C_BCD(7 downto 4) <= std_logic_vector(to_unsigned((to_integer(unsigned(out_binary)) / 10) mod 10, 4));
        C_BCD(11 downto 8) <= std_logic_vector(to_unsigned((to_integer(unsigned(out_binary)) / 100) mod 10, 4));
        C_BCD(15 downto 12) <= std_logic_vector(to_unsigned((to_integer(unsigned(out_binary)) / 1000) mod 10, 4));
    end if; 
end process; 

end Behavioral; 