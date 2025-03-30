LIBRARY ieee;
USE ieee.std_logic_1164.all;
--------------------------------------------
-------- Define the Logic block entity -----
ENTITY Logic IS
    GENERIC (n : INTEGER := 8);
	PORT (
		Y, X: IN std_logic_vector (n-1 DOWNTO 0);
		ALUFN_i : IN std_logic_vector (2 downto 0);
		ALUout_o : OUT std_logic_vector (n-1 DOWNTO 0)
		);
END Logic;
-------- Define the logic block architecture -----
ARCHITECTURE logic_arch OF Logic IS
BEGIN
	WITH ALUFN_i SELECT -- choose action based on the OPCODE
		ALUout_o <= not Y when "000" ,
					Y or X when "001" ,
					Y and X when "010" ,
					Y xor X when "011" ,
					Y nor X when "100" ,
					Y nand X when "101" ,
					Y xnor X when "111" ,
					(others => '0') when others; -- In case of unkown opcode we output 0 vector
END logic_arch;