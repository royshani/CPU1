library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
---------------------------------------------------------
-- Entity Declaration
---------------------------------------------------------
entity tb is
	constant n : integer := 8;  -- Width of the data bus
	constant k : integer := 3;  -- k = log2(n), determines number of bits needed for indexing
	constant m : integer := 4;  -- m = 2^(k-1), represents half of n
	constant ROWmax : integer := 4; -- Maximum number of rows in memory
end tb;

-------------------------------------------------------------------------------
-- Architecture Declaration
-------------------------------------------------------------------------------
architecture addersub_tb of tb is
	-- Define a memory type that holds 5-bit logic vectors
	type mem is array (0 to ROWmax) of std_logic_vector(4 downto 0);

	-- Define a type for storing 4 different n-bit logic vectors
	type sigvec is array (0 to 3) of std_logic_vector(n-1 downto 0);

	-- Declare signals used in the testbench
	SIGNAL Y, X:  STD_LOGIC_VECTOR (n-1 DOWNTO 0);  -- Input operands for ALU
	SIGNAL ALUFN :  STD_LOGIC_VECTOR (4 DOWNTO 0);  -- Control signal for ALU function
	SIGNAL ALUout:  STD_LOGIC_VECTOR(n-1 downto 0); -- Output result from ALU
	SIGNAL L_opcode : mem := ("01000", "01001", "01010", "01011", "01100"); -- Predefined ALU operation codes
	SIGNAL X_vec : sigvec := ("01000001", "10010110", "01011011", "00110011"); -- Test values for X input
	SIGNAL Y_vec : sigvec := ("10101100", "01010101", "11110110", "00101100"); -- Test values for Y input
	SIGNAL cout : std_logic; -- Carry-out flag from the AdderSub component

begin
	---------------------------------------------------------
	-- Instantiation of AdderSub component
	---------------------------------------------------------
	L1 : AdderSub 
	generic map(n)  -- Mapping the generic parameter 'n' to the entity
	port map (
		Y => Y,         -- Connect signal Y to the AdderSub Y input
		X => X,         -- Connect signal X to the AdderSub X input
		ALUFN => ALUFN(2 downto 0), -- Use the least significant 3 bits of ALUFN for ALU operation selection
		ALUout => ALUout, -- Connect ALUout to the output of the AdderSub
		cout => cout     -- Connect cout to the carry-out output
	);

	---------------------------------------------------------
	-- Process: tb_x_y
	-- This process cycles through different test values for X and Y
	---------------------------------------------------------
	tb_x_y : process
	begin
		X <= (others => '0'); -- Initialize X to all 0s
		Y <= (others => '0'); -- Initialize Y to all 0s
		
		for i in 0 to ROWmax loop  -- Iterate over the row index
			for j in 0 to 3 loop  -- Iterate over different X and Y values
				X <= X_vec(j); -- Assign X with a test value from the X_vec array
				Y <= Y_vec(j); -- Assign Y with a test value from the Y_vec array
				wait for 50 ns; -- Wait for 50 nanoseconds between assignments
			end loop;
		end loop;
		wait; -- Stop execution after all iterations
	end process;	

	---------------------------------------------------------
	-- Process: tb_ALUFN
	-- This process cycles through different ALUFN operation codes
	---------------------------------------------------------
	tb_ALUFN : process
    begin
		ALUFN <= (others => '0'); -- Initialize ALUFN to all 0s
		
		for i in 0 to ROWmax loop  -- Iterate over predefined ALU operation codes
			ALUFN <= L_opcode(i); -- Assign the operation code from L_opcode array
			wait for 200 ns; -- Wait for 200 nanoseconds to simulate execution delay
		end loop;
		
		wait; -- Stop execution after all iterations
    end process;

end architecture addersub_tb;