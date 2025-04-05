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
	constant ROWmax : integer := 2; 
end tb;
-------------------------------------------------------------------------------
architecture shifter_tb of tb is
	type mem is array (0 to ROWmax) of std_logic_vector(4 downto 0);
	type sigvec is array (0 to 8) of std_logic_vector(n-1 downto 0);
	SIGNAL Y,X:  STD_LOGIC_VECTOR (n-1 DOWNTO 0);
	SIGNAL ALUFN :  STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL ALUout:  STD_LOGIC_VECTOR(n-1 downto 0); -- ALUout[n-1:0]
	SIGNAL L_opcode : mem := ("10000","10001","10110"); -- last one undefined in task in order to check for ALU vec input 
	-- X values decided to be in increasing order by 3 LSB bits, other bits are random
	SIGNAL X_vec : sigvec := ("00000000","00100001","11111010","01101011","10101100","00001101","00000110","11111111");
	-- Y values decided to be in random but contains bit other then all 0's in order to see the shifter operation
	SIGNAL Y_vec : sigvec := ("11111101","11000001","00010001","10100110","10001001","10100111","01011001","10111011");
	SIGNAL cout : STD_LOGIC;
begin
    L1 : Shifter generic map(n,k)
	port map(Y => Y, X_to_k => X(k-1 downto 0), ALUFN => ALUFN(2 downto 0), ALUout_o => ALUout, cout => cout);
	--------- start of simulation section ----------------------------------------		
			-- based on the tb provided --
        tb_x_y : process -- this section will test the correct operation of the shifter module based on the X & Y inputs
		begin
			X <= (others => '0');
			Y <= (others => '0');
			for j in 0 to 7 loop
				X <= X_vec(j);
				Y <= Y_vec(j);
				wait for 50 ns;
			end loop;
			wait;
		end process;	
		
		tb_ALUFN : process -- this section will test the correct operation of the shifter module based on the ALUFN input
        begin
		  ALUFN <= (others => '0');
		  for s in 0 to 2 loop
			  for i in 0 to ROWmax loop
				ALUFN <= L_opcode(i);
				wait for 150 ns;
			  end loop;
			end loop;
		  wait;
        end process;
  
end architecture shifter_tb;
