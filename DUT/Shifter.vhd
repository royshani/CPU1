LIBRARY ieee;  -- Standard VHDL library
USE ieee.std_logic_1164.all;  -- Standard logic types

-- Entity definition for the Shifter block
ENTITY Shifter IS
  GENERIC (
    n : INTEGER := 8;       -- Width of the data vector
    k : INTEGER := 3        -- Number of control bits (log2(n)) for shifting
  );   
  PORT (
    Y : IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);         -- Input data to be shifted
    X_to_k : IN STD_LOGIC_VECTOR (k-1 DOWNTO 0);    -- Binary value indicating how much to shift
    ALUFN : IN STD_LOGIC_VECTOR (2 DOWNTO 0);       -- Operation selector: "000" = shift left, "001" = shift right
    ALUout_o : OUT STD_LOGIC_VECTOR (n-1 DOWNTO 0); -- Output of the shifted result
    cout : OUT STD_LOGIC                            -- Carry-out bit (bit shifted out)
  );
END Shifter;

-- Architecture body of the Shifter block
ARCHITECTURE Shifter_arch OF Shifter IS

  TYPE mat IS ARRAY (k DOWNTO 0) OF STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- Matrix type to hold intermediate stage values
  SIGNAL stage_data : mat;              -- Holds output of each stage of the barrel shifter
  SIGNAL stage_carry : STD_LOGIC_VECTOR(k-1 DOWNTO 0); -- Carry bits from each stage

BEGIN

  -- Initialize the first stage based on shift direction
  init_dir: FOR i IN 0 TO n-1 GENERATE 
    stage_data(0)(i) <= Y(i) WHEN ALUFN = "001" ELSE         -- For right shift: keep order
                         Y(n-1-i) WHEN ALUFN = "000";        -- For left shift: reverse the input
  END GENERATE;

  -- Multi-level conditional shift using binary-controlled barrel shifter
  shifter: FOR level IN 1 TO k GENERATE
    shift_stage: BLOCK
      CONSTANT shift_amt : INTEGER := 2**(level - 1);  -- Amount to shift at this stage
    BEGIN
      stage_data(level) <= (shift_amt - 1 DOWNTO 0 => '0') & stage_data(level - 1)(n-1 DOWNTO shift_amt) WHEN X_to_k(level - 1) = '1' ELSE
                           stage_data(level - 1);  -- If no shift at this stage, keep previous result
    END BLOCK;
  END GENERATE;

  -- Adjust final output based on original shift direction
  fix_dir: FOR i IN 0 TO n-1 GENERATE
    ALUout_o(i) <= stage_data(k)(i) WHEN ALUFN = "001" ELSE           -- For right shift: use directly
                   stage_data(k)(n-1-i) WHEN ALUFN = "000" ELSE       -- For left shift: reverse result
                   '0';                                               -- For invalid ALUFN: return 0
  END GENERATE;

  -- Initialize carry-out from first stage
  stage_carry(0) <= stage_data(0)(0) WHEN X_to_k(0) = '1' ELSE '0';

  -- Propagate carry-out across shift stages
  cout_calc: FOR level IN 1 TO k-1 GENERATE
    cout_stage: BLOCK
      CONSTANT shift_amt : INTEGER := 2**level;
    BEGIN
      stage_carry(level) <= stage_data(level)(shift_amt - 1) WHEN X_to_k(level) = '1' ELSE
                            stage_carry(level - 1); -- If no shift, carry previous stage's carry
    END BLOCK;
  END GENERATE;

  -- Output final carry bit (only valid for left or right shift)
  cout <= stage_carry(k-1) WHEN (ALUFN = "001" OR ALUFN = "000") ELSE '0';

END Shifter_arch;
