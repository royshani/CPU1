library IEEE;
use ieee.std_logic_1164.all;

package aux_package is
--------------------------------------------------------
	component top is
	GENERIC (n : INTEGER := 8;
		   k : integer := 3;   -- k=log2(n)
		   m : integer := 4	); -- m=2^(k-1)
	PORT 
	(  
		Y_i,X_i: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
		ALUFN_i : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		ALUout_o: OUT STD_LOGIC_VECTOR(n-1 downto 0);
		Nflag_o,Cflag_o,Zflag_o,Vflag_o: OUT STD_LOGIC 
	); -- Zflag,Cflag,Nflag,Vflag
	end component;
-------------- SYSTEM COMPONENT DECLERATION -------------
---------------------------------------------------------  
	component FA is
		PORT (xi, yi, cin: IN std_logic;
			      s, cout: OUT std_logic);
	end component;
---------------------------------------------------------	
	COMPONENT Logic is -- logic component port decleration
		GENERIC (n : INTEGER);
		PORT (
		Y, X: IN std_logic_vector (n-1 DOWNTO 0); -- Two input vectors
		ALUFN_i : IN std_logic_vector (2 downto 0); -- 3 right-most bits of OPCODE
		ALUout_o : OUT std_logic_vector (n-1 DOWNTO 0)
		);
	END COMPONENT;
---------------------------------------------------------	
	COMPONENT AdderSub IS -- arithmatic unit component port decleration
		GENERIC (n : INTEGER);
		PORT (
		X, Y : IN std_logic_vector (n-1 downto 0); -- Two input vectors
		ALUFN : IN std_logic_vector (2 downto 0); -- 3 right-most bits of OPCODE
		ALUout : OUT std_logic_vector(n-1 downto 0); -- output vector
		cout : OUT std_logic -- carry flag bit
		);
	END COMPONENT;
---------------------------------------------------------	
	COMPONENT Shifter IS -- barrel shifter component port decleration
		GENERIC (n, k : INTEGER);
		PORT (
		Y : IN std_logic_vector (n-1 downto 0); -- Y input vectors
		X_to_k : IN std_logic_vector (k-1 downto 0); -- relevant X input vector
		ALUFN : IN std_logic_vector (2 downto 0); -- 3 right-most bits of OPCODE
		ALUout_o : OUT stD_logic_vector (n-1 downto 0); -- output vector
		cout : OUT std_logic -- carry flag bit
		);
	END COMPONENT;
---------------------------------------------------------	
	
	
	
	
	
	
end package aux_package;

