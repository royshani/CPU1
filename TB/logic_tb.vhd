library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
---------------------------------------------------------
entity tb is
	constant n : integer := 8;
	constant k : integer := 3;   -- k=log2(n)
	constant m : integer := 4;   -- m=2^(k-1)
	constant ROWmax : integer := 7; 
end tb;
-------------------------------------------------------------------------------
architecture logic_tb of tb is
	type mem is array (0 to ROWmax) of std_logic_vector(4 downto 0);
	type sigvec is array (0 to 3) of std_logic_vector(n-1 downto 0);
	SIGNAL Y,X:  STD_LOGIC_VECTOR (n-1 DOWNTO 0);
	SIGNAL ALUFN :  STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL ALUout:  STD_LOGIC_VECTOR(n-1 downto 0); -- ALUout[n-1:0]
	SIGNAL L_opcode : mem := ("11000","11001","11010","11011","11100","11101","11110","11111");
	SIGNAL X_vec : sigvec := ("00000000","10100110","11010011","01101000");
	SIGNAL Y_vec : sigvec := ("11001100","00000000","01110100","10110100");
begin
    L1 : Logic generic map(n)
	port map(Y => Y, X => X, ALUFN_i => ALUFN(2 downto 0), ALUout_o => ALUout);
	--------- start of simulation section ----------------------------------------	
		-- based on the tb provided --	
        tb_x_y : process
		begin
			X <= (others => '0');
			Y <= (others => '0');
			for j in 0 to 3 loop
				X <= X_vec(j);
				Y <= Y_vec(j);
				wait for 400 ns;
			end loop;
			wait;
		end process;	
		
		tb_ALUFN : process
        begin
		  ALUFN <= (others => '0');
		  for s in 0 to 3 loop
			  for i in 0 to ROWmax loop
				ALUFN <= L_opcode(i);
				wait for 50 ns;
			  end loop;
			end loop;
		  wait;
        end process;
  
end architecture logic_tb;
