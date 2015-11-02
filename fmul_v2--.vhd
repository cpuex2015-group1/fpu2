library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fmul is
  Port (
    --clk: in std_logic;
    a : in  std_logic_vector (31 downto 0);
    b : in  std_logic_vector (31 downto 0);
    c : out std_logic_vector (31 downto 0));
end fmul;

architecture struct of fmul is
  signal a_in : std_logic_vector (31 downto 0);
  signal b_in : std_logic_vector (31 downto 0);

  signal c_sign, c_sign1, c_sign2, c_sign3 
    : std_logic;
  signal c_expo
    : std_logic_vector ( 7 downto 0);
  signal c_expo1, c_expo2i, c_expo2s, c_expo3
    : std_logic_vector ( 9 downto 0);

  signal c_frac
    : std_logic_vector (22 downto 0);
  signal c_fracHH
    : std_logic_vector (25 downto 0);
  signal c_fracHL, c_fracLH
    : std_logic_vector (23 downto 0);
  signal c_frac2
    : std_logic_vector (26 downto 0);
  signal c_frac3
    : std_logic_vector (22 downto 0);

  signal a_norm, b_norm : std_logic;
  signal zero, inf, a_nan, b_nan : boolean;
begin
  a_in <= a;
  b_in <= b;

  process (a_in, b_in) is
    --variable
    --  a_expo_0, a_expo_1, a_frac_0, a_zero, a_inf, 
    --  b_expo_0, b_expo_1, b_frac_0, b_zero, b_inf: boolean;
  begin
    --a_expo_0 := a_in(30 downto 23) = "00000000";
    --b_expo_0 := a_in(30 downto 23) = "00000000";
    --a_expo_1 := a_in(30 downto 23) = "11111111";
    --b_expo_1 := a_in(30 downto 23) = "11111111";
    --a_frac_0 := a_in(22 downto  0) = "00000000000000000000000";
    --b_frac_0 := a_in(22 downto  0) = "00000000000000000000000";

    --a_zero := a_expo_0 and a_frac_0;
    --b_zero := b_expo_0 and b_frac_0;
    --a_inf  := a_expo_1 and a_frac_0;
    --b_inf  := b_expo_1 and b_frac_0;

    ----zero <= a_zero or b_zero;
    --inf    <= a_inf or b_inf;
    --a_nan  <= a_expo_1 and (not a_frac_0);
    --b_nan  <= b_expo_1 and (not b_frac_0);
    --a_norm <= '1' when 
    --    ((not a_expo_0) or a_frac_0) else '0';
    --b_norm <= '1' when 
    --    ((not b_expo_0) or b_frac_0) else '0';
    
    c_sign1 <= a_in(31) xor b_in(31);
    c_expo1 <= "0000000000" + a_in(30 downto 23) + b_in(30 downto 23) + 129;
    --c_fracHH <= (a_norm & a_in(22 downto 11)) * (b_norm & b_in(22 downto 11));
    --c_fracHL <= (a_norm & a_in(22 downto 11)) * b_in(10 downto 0);
    --c_fracLH <= a_in(10 downto 0) * (b_norm & b_in(22 downto 11));
    c_fracHH <= ('1' & a_in(22 downto 11)) * ('1' & b_in(22 downto 11));
    c_fracHL <= ('1' & a_in(22 downto 11)) * b_in(10 downto 0);
    c_fracLH <= a_in(10 downto 0) * ('1' & b_in(22 downto 11));
  end process;

  process (c_sign1, c_expo1, c_fracHH, c_fracHL, c_fracLH) is
  begin
    c_sign2 <= c_sign1;
    c_expo2i <= c_expo1 + 1;
    c_expo2s <= c_expo1;
    --c_frac2 <= c_fracHH + c_fracHL(23 downto 11) + c_fracLH(23 downto 11) + 1 + (c_fracLH(10) nand c_fracHL(10));
    --c_frac2 <= c_fracHH + c_fracHL(23 downto 11) + c_fracLH(23 downto 11) + 2 ;

    --c_frac2 <= ((c_fracHH & '0') +  c_fracHL(23 downto 10) + c_fracHL(23 downto 10))
    c_frac2 <= ((c_fracHH & '1') +  c_fracHL(23 downto 10) + c_fracHL(23 downto 10))
  end process;

  process (c_sign2, c_expo2i, c_expo2s, c_frac2) is
    variable c_frac3_tmp : std_logic_vector (26 downto 0);
  begin
    c_sign3 <= c_sign2;
    if (c_frac2(26) = '1') then
      c_expo3 <= c_expo2i;
      c_frac3_tmp <= c_frac2 + (c_frac2(2)+'00');
      c_frac3 <= c_frac3_tmp(25 downto 2);
    else
      c_expo3 <= c_expo2s;
      c_frac3_tmp <= c_frac2 + (c_frac2(1)+'0');
      c_frac3 <= c_frac3_tmp(24 downto 1);
    end if;
  end process;

  process (c_sign3, c_expo3, c_frac3, zero, inf) is
  begin
    if false then
    --elsif a_nan then
    --  c_sign <= a_in(3);
    --  c_expo <= "11111111";
    --  c_frac <= '1' & a_in(21 downto 0);
    --elsif b_nan then
    --  c_sign <= b_in(3);
    --  c_expo <= "11111111";
    --  c_frac <= '1' & b_in(21 downto 0);
    --elsif inf and zero then
    --  c_sign <= c_sign3;
    --  c_expo <= "11111111";
    --  c_frac <= "10000000000000000000000";
    --elsif inf then
    --  c_sign <= c_sign3;
    --  c_expo <= "11111111";
    --  c_frac <= "10000000000000000000000";
    --elsif zero then
    --  c_sign <= c_sign3;
    --  c_expo <= "00000000";
    --  c_frac <= "10000000000000000000000";
    elsif (c_expo3(9) = '1') or (c_expo3(8 downto 0) = "111111111") then
      c_sign <= c_sign3;
      c_expo <= "11111111";
      c_frac <= "00000000000000000000000";
    elsif (c_expo3(8) = '0') or (c_expo3(7 downto 0) = "00000000") then
      -- TODO: denormalized numbers
      c_sign <= c_sign3;
      c_expo <= "00000000";
      c_frac <= "00000000000000000000000";
    else
      c_sign <= c_sign3;
      c_expo <= c_expo3(7 downto 0);
      c_frac <= c_frac3;
    end if;
  end process;

  c <= c_sign & c_expo & c_frac;
end struct;