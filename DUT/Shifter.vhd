LIBRARY ieee;
USE ieee.std_logic_1164.all;
--------------------------------------------
-- Create a barrel shifter. The barrel shifter itself only shifts right. For a left shift we first reverse the vector, shift, the reverse it back.
-- The elements which are shifted out are replaced by zeroes.
-------- Define the Logic block entity -----
ENTITY Shifter IS
  GENERIC (n : INTEGER := 8;
			k : INTEGER := 3 -- k=log2(n) -- *overridden by generic map from top.vhd
		  );   
	PORT (
		Y : IN STD_LOGIC_VECTOR (n-1 DOWNTO 0); -- Y input vector
		X_to_k : IN STD_LOGIC_VECTOR (k-1 DOWNTO 0); -- relevant X input vector - Tells us how much to shift
		ALUFN : IN STD_LOGIC_VECTOR (2 DOWNTO 0); -- 3 right-most bits of OPCODE
		ALUout_o : OUT STD_LOGIC_VECTOR (n-1 DOWNTO 0); -- output vector
		cout : OUT STD_LOGIC -- carry flag bit vector
		);
	END Shifter;
-------- Define the logic block architecture -----
ARCHITECTURE Shifter_arch OF Shifter IS
	TYPE mat IS ARRAY (k DOWNTO 0) OF STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- 1Dx1D Matrix
	SIGNAL shift_levels : mat; -- Each pass through a level of the barrel shifter will be mapped to the relevant row
	SIGNAL cout_levels : STD_LOGIC_VECTOR(k-1 DOWNTO 0);
BEGIN
	-- Choose direction based on ALUFN
	-- It is inserted into the 0th shift level
	init_dir: FOR i IN 0 TO n-1 GENERATE 
		shift_levels(0)(i) <=  Y(i) WHEN ALUFN = "001" ELSE -- Shift right
							Y(n-1-i) WHEN ALUFN = "000"; -- Shift left
	END GENERATE;
	-- Barrel Shifter logic. Shifts the vector to the right, chaining zeroes to the left.
	shifter: FOR level in 1 to k GENERATE
		-- Each level shifts by 2^(level-1), and the decision to shift in each level is decided by X_to_k bits.
		-- If we do shift, we connect the left side of the vector we are shifting, to the right side of the shifted vector. We chain the correct amount of zeroes to the left.
		-- If we don't shift we connect to the last level's vector.
		shift_levels(level) <= (2**(level-1) - 1 DOWNTO 0 => '0') & shift_levels(level-1)(n-1 DOWNTO 2**(level-1)) WHEN X_to_k(level-1) = '1' ELSE
														  shift_levels(level-1);
	END GENERATE;
	-- Fix the finished product in terms of direction, and 
	fix_dir: FOR i IN 0 TO n-1 GENERATE
		ALUout_o(i) <= shift_levels(k)(i) WHEN ALUFN = "001" ELSE
						shift_levels(k)(n-1-i) WHEN ALUFN = "000" ELSE
						'0'; -- if opcode invalid we return zeroes
					
	END GENERATE;
	-- Calculate cout: we have all the levels of shifts in the shift_levels matrix
	-- for each level, if we made a shift it might be the last one and we store the cout
	-- if we don't shift at that level, pass the cout from the level before
	cout_levels(0) <= shift_levels(0)(0) WHEN X_to_k(0) = '1' ELSE '0'; -- cout from the first level shift
	cout_calc: FOR level in 1 to k-1 GENERATE
				cout_levels(level) <= shift_levels(level)(2**(level) - 1) WHEN X_to_k(level) = '1' ELSE
										cout_levels(level-1);
	END GENERATE;
	
	cout <= cout_levels(k-1) WHEN (ALUFN = "001" OR ALUFN = "000") ELSE '0'; -- Use calculated carry out only if OPCODE is legal.
	


END Shifter_arch;
