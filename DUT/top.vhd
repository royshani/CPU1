LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.aux_package.ALL;

-- Top-level entity declaration for the ALU module
ENTITY top IS
  GENERIC (
    n : INTEGER := 8;  -- Data width
    k : INTEGER := 3;  -- Log2(n), used for shifter
    m : INTEGER := 4   -- Unused in this file, but could be for future extension
  );
  PORT (
    Y_i, X_i       : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);   -- ALU inputs
    ALUFN_i        : IN STD_LOGIC_VECTOR(4 DOWNTO 0);     -- ALU control signal
    ALUout_o       : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);  -- ALU result output
    Nflag_o        : OUT STD_LOGIC;                       -- Negative flag
    Cflag_o        : OUT STD_LOGIC;                       -- Carry-out flag
    Zflag_o        : OUT STD_LOGIC;                       -- Zero result flag
    Vflag_o        : OUT STD_LOGIC                        -- Overflow flag
  );
END top;

-- Architecture of the top module
ARCHITECTURE struct OF top IS

  -- Internal signals for submodules' results and carry outputs
  SIGNAL res_logic, res_arith, res_shift : STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SIGNAL carry_arith, carry_shift        : STD_LOGIC;

  -- Signals for routing inputs to appropriate submodules
  SIGNAL in_arith_X, in_arith_Y          : STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SIGNAL in_shift_X, in_shift_Y          : STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SIGNAL in_logic_X, in_logic_Y          : STD_LOGIC_VECTOR(n-1 DOWNTO 0);

  -- Final ALU result and helper signal for zero flag
  SIGNAL alu_result                      : STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SIGNAL zero_mask                       : STD_LOGIC_VECTOR(n-1 DOWNTO 0);

BEGIN

  -- Instantiate logic unit (bitwise operations)
  logic_unit: Logic
    GENERIC MAP(n)
    PORT MAP (
      Y => in_logic_Y,
      X => in_logic_X,
      ALUFN_i => ALUFN_i(2 DOWNTO 0),  -- Logic operations encoded in lower 3 bits
      ALUout_o => res_logic
    );

  -- Instantiate arithmetic unit (addition and subtraction)
  arith_unit: AdderSub
    GENERIC MAP(n)
    PORT MAP (
      Y => in_arith_Y,
      X => in_arith_X,
      ALUFN => ALUFN_i(2 DOWNTO 0),  -- Arithmetic operations also encoded in lower 3 bits
      ALUout => res_arith,
      cout => carry_arith
    );

  -- Instantiate shifter unit (logical and arithmetic shifts)
  shift_unit: Shifter
    GENERIC MAP(n, k)
    PORT MAP (
      Y => in_shift_Y,
      X_to_k => in_shift_X(k-1 DOWNTO 0),  -- Use only lower k bits for shift amount
      ALUFN => ALUFN_i(2 DOWNTO 0),        -- Shift type selection
      ALUout_o => res_shift,
      cout => carry_shift
    );

  -- Route inputs to arithmetic unit only if ALUFN_i(4:3) = "01"
  in_arith_X  <= X_i WHEN ALUFN_i(4 DOWNTO 3) = "01" ELSE (OTHERS => '0');
  in_arith_Y  <= Y_i WHEN ALUFN_i(4 DOWNTO 3) = "01" ELSE (OTHERS => '0');

  -- Route inputs to shifter unit only if ALUFN_i(4:3) = "10"
  in_shift_X  <= X_i WHEN ALUFN_i(4 DOWNTO 3) = "10" ELSE (OTHERS => '0');
  in_shift_Y  <= Y_i WHEN ALUFN_i(4 DOWNTO 3) = "10" ELSE (OTHERS => '0');

  -- Route inputs to logic unit only if ALUFN_i(4:3) = "11"
  in_logic_X  <= X_i WHEN ALUFN_i(4 DOWNTO 3) = "11" ELSE (OTHERS => '0');
  in_logic_Y  <= Y_i WHEN ALUFN_i(4 DOWNTO 3) = "11" ELSE (OTHERS => '0');

  -- Set carry-out flag depending on active unit
  Cflag_o <= carry_arith WHEN ALUFN_i(4 DOWNTO 3) = "01" ELSE
             carry_shift WHEN ALUFN_i(4 DOWNTO 3) = "10" ELSE
             '0';

  -- Overflow flag logic for arithmetic operations
  Vflag_o <=
    ((NOT Y_i(n-1) AND res_arith(n-1) AND NOT (X_i(n-1) XOR ALUFN_i(0))) OR
     (Y_i(n-1) AND NOT res_arith(n-1) AND (X_i(n-1) XOR ALUFN_i(0))))
    WHEN ALUFN_i(4 DOWNTO 1) = "0100" ELSE
    '0';

  -- Multiplexing result based on high bits of ALUFN
  WITH ALUFN_i(4 DOWNTO 3) SELECT
    alu_result <= res_arith  WHEN "01",  -- Arithmetic
                   res_shift WHEN "10",  -- Shift
                   res_logic WHEN "11",  -- Logic
                   (OTHERS => '0') WHEN OTHERS;  -- Default zero

  -- Set negative flag based on MSB of result
  Nflag_o <= alu_result(n-1);

  -- Set zero flag if result equals zero
  zero_mask <= (OTHERS => '0');
  Zflag_o <= '1' WHEN alu_result = zero_mask ELSE '0';

  -- Output final result
  ALUout_o <= alu_result;

END struct;
