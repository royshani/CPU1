LIBRARY ieee;
USE ieee.std_logic_1164.all;
-------------------------------------

entity AdderSub is
	generic (n: INTEGER := 8);
	port (
		X, Y : IN std_logic_vector (n-1 downto 0); 
		ALUFN : IN std_logic_vector (2 downto 0); 
		ALUout : OUT std_logic_vector(n-1 downto 0); 
		cout : OUT std_logic
		);
end AdderSub;

architecture AdderSubArch of AdderSub is
	component FA is
		PORT (xi, yi, cin: IN std_logic;
			      s, cout: OUT std_logic);
	end component;
	SIGNAL reg : std_logic_vector(n-1 DOWNTO 0); 
	SIGNAL X_ctrl, Y_ctrl : std_logic_vector(n-1 DOWNTO 0); 
	SIGNAL cin : std_logic; 
begin

    X_ctrl <= (others => '0') when (ALUFN = "011") else  -- Increment Y by 1 when ALUFN = "011"
              (others => '1') when (ALUFN = "100") else  -- Decrement Y by 1 when ALUFN = "100"
              not X when (ALUFN = "001" or ALUFN = "010") else
              X when ALUFN = "000" else
              (others => '0');
	

	Y_ctrl <= Y when (ALUFN = "000" or ALUFN = "001" or ALUFN = "011" or ALUFN = "100") else
			  (others => '0');
			  
	
	cin <= '1' when (ALUFN = "001" or ALUFN = "010" or ALUFN = "011") else '0';

	MapFirstFA : FA port map (
			xi => X_ctrl(0),
			yi => Y_ctrl(0),
			cin => cin,
			s => ALUout(0),
			cout => reg(0)
	);
	
	MapRestFA : for i in 1 to n-1 generate
		chain : FA port map (
			xi => X_ctrl(i),
			yi => Y_ctrl(i),
			cin => reg(i-1),
			s => ALUout(i),
			cout => reg(i)
		);
	end generate;
	
	cout <= reg(n-1);
end AdderSubArch;

