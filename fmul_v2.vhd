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
  begin
    c_sign1 <= a_in(31) xor b_in(31);
    c_expo1 <= "0000000000" + a_in(30 downto 23) + b_in(30 downto 23) + 129;
    c_fracHH <= ('1' & a_in(22 downto 11)) * ('1' & b_in(22 downto 11));
    c_fracHL <= ('1' & a_in(22 downto 11)) * b_in(10 downto 0);
    c_fracLH <= a_in(10 downto 0) * ('1' & b_in(22 downto 11));
  end process;

  process (c_sign1, c_expo1, c_fracHH, c_fracHL, c_fracLH) is
  begin
    c_sign2 <= c_sign1;
    c_expo2i <= c_expo1 + 1;
    c_expo2s <= c_expo1;
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
    if (c_expo3(9) = '1') or (c_expo3(8 downto 0) = "111111111") then
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