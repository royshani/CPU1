library IEEE;
use ieee.std_logic_1164.all;

package aux_package is
--------------------------------------------------------
-- Shift operations unit declaration
--------------------------------------------------------
	COMPONENT Shifter IS
		GENERIC (n, k : INTEGER);
		PORT (
		Y : IN std_logic_vector (n-1 downto 0); -- Operand input for shift operation
		X_to_k : IN std_logic_vector (k-1 downto 0); -- Determines shift amount
		ALUFN : IN std_logic_vector (2 downto 0); -- Function selector for shifting
		ALUout_o : OUT std_logic_vector (n-1 downto 0); -- Shifted output value
		cout : OUT std_logic -- Carry flag output
		);
	END COMPONENT;
--------------------------------------------------------
-- Definition of the arithmetic unit
--------------------------------------------------------
	COMPONENT AdderSub IS
		GENERIC (n : INTEGER);
		PORT (
		X, Y : IN std_logic_vector (n-1 downto 0); -- Input values for arithmetic
		ALUFN : IN std_logic_vector (2 downto 0); -- Selects arithmetic operation
		ALUout : OUT std_logic_vector(n-1 downto 0); -- Computed result
		cout : OUT std_logic -- Carry output flag
		);
	END COMPONENT;
--------------------------------------------------------	
-- Logical operations unit declaration
--------------------------------------------------------	
	COMPONENT Logic is
		GENERIC (n : INTEGER);
		PORT (
		Y, X : IN std_logic_vector (n-1 DOWNTO 0); -- Inputs for logic computation
		ALUFN_i : IN std_logic_vector (2 downto 0); -- Function selection bits
		ALUout_o : OUT std_logic_vector (n-1 DOWNTO 0) -- Logical operation result
		);
	END COMPONENT;
--------------------------------------------------------	
-- Full Adder component declaration
--------------------------------------------------------	
	component FA is
		PORT (xi, yi, cin: IN std_logic;
			      s, cout: OUT std_logic);
	end component;
--------------------------------------------------------
-- Main ALU system component
--------------------------------------------------------
	component top is
	GENERIC (n : INTEGER := 8;
		   k : integer := 3;   -- k represents log2(n)
		   m : integer := 4	); -- m is 2^(k-1)
	PORT 
	(  
		Y_i, X_i : IN STD_LOGIC_VECTOR (n-1 DOWNTO 0); -- ALU inputs
		ALUFN_i : IN STD_LOGIC_VECTOR (4 DOWNTO 0); -- Function selection code
		ALUout_o : OUT STD_LOGIC_VECTOR(n-1 downto 0); -- Output of ALU computation
		Nflag_o, Cflag_o, Zflag_o, Vflag_o : OUT STD_LOGIC -- ALU flags
	);
	end component;
--------------------------------------------------------	

end package aux_package;
