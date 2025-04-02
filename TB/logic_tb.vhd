library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;

---------------------------------------------------------
-- Testbench entity declaration
---------------------------------------------------------
entity tb is
	constant n : integer := 8;
	constant k : integer := 3;   -- k represents log2(n)
	constant m : integer := 4;   -- m is 2^(k-1)
	constant ROWmax : integer := 7; 
end tb;

---------------------------------------------------------
-- Testbench architecture
---------------------------------------------------------
architecture logic_tb of tb is
	-- Type definition for memory and signal vectors
	type mem is array (0 to ROWmax) of std_logic_vector(4 downto 0);
	type sigvec is array (0 to 3) of std_logic_vector(n-1 downto 0);

	-- Signal declarations
	SIGNAL Y, X : STD_LOGIC_VECTOR (n-1 DOWNTO 0); -- Input signals for the ALU
	SIGNAL ALUFN : STD_LOGIC_VECTOR (4 DOWNTO 0); -- ALU function select bits
	SIGNAL ALUout : STD_LOGIC_VECTOR(n-1 downto 0); -- ALU output signal
	SIGNAL L_opcode : mem := ("11000","11001","11010","11011","11100","11101","11110","11111"); -- Opcode values
	SIGNAL X_vec : sigvec := ("00000000","10100110","11010011","01101000"); -- Test data for X
	SIGNAL Y_vec : sigvec := ("11001100","00000000","01110100","10110100"); -- Test data for Y

begin
	-- Logic component instantiation with parameter 'n' 
	L1 : Logic generic map(n)
		port map(Y => Y, X => X, ALUFN_i => ALUFN(2 downto 0), ALUout_o => ALUout);

	---------------------------------------------------------
	-- Simulation processes
	---------------------------------------------------------
	-- Process for driving the X and Y signals based on the test vectors
	tb_x_y : process
		begin
			X <= (others => '0'); -- Initialize X
			Y <= (others => '0'); -- Initialize Y
			for j in 0 to 3 loop
				X <= X_vec(j); -- Assign the current value from X_vec
				Y <= Y_vec(j); -- Assign the current value from Y_vec
				wait for 400 ns; -- Wait before proceeding to next test vector
			end loop;
			wait; -- Wait indefinitely after the loop
		end process;	

	-- Process for driving the ALUFN signal based on the opcode values
	tb_ALUFN : process
		begin
			ALUFN <= (others => '0'); -- Initialize ALUFN to zero
			for s in 0 to 3 loop
				for i in 0 to ROWmax loop
					ALUFN <= L_opcode(i); -- Set ALUFN to the current opcode
					wait for 50 ns; -- Wait for a short interval
				end loop;
			end loop;
			wait; -- Wait indefinitely after the loop
		end process;
  
end architecture logic_tb;
