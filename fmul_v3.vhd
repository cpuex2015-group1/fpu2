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
    variable
      a_expo_0, a_expo_1, a_frac_0, a_zero, a_inf, 
      b_expo_0, b_expo_1, b_frac_0, b_zero, b_inf: boolean;
  begin
    a_expo_0 := a_in(30 downto 23) = "00000000";
    b_expo_0 := a_in(30 downto 23) = "00000000";
    a_expo_1 := a_in(30 downto 23) = "11111111";
    b_expo_1 := a_in(30 downto 23) = "11111111";
    a_frac_0 := a_in(22 downto  0) = "00000000000000000000000";
    b_frac_0 := a_in(22 downto  0) = "00000000000000000000000";

    a_zero := a_expo_0 and a_frac_0;
    b_zero := b_expo_0 and b_frac_0;
    a_inf  := a_expo_1 and a_frac_0;

    zero <= a_zero or b_zero;
    inf  <= a_inf or b_inf;

    a_nan  <= a_expo_1 and (not a_frac_0);
    b_nan  <= b_expo_1 and (not b_frac_0);

    a_norm <= '1' when 
        ((not a_expo_0) or a_frac_0) else '0';
    b_norm <= '1' when 
        ((not b_expo_0) or b_frac_0) else '0';
    
    c_sign1 <= a_in(31) xor b_in(31);
    c_expo1 <= "0000000000" + a_in(30 downto 23) + b_in(30 downto 23) + 129;
    c_fracHH <= (a_norm & a_in(22 downto 11)) * (b_norm & b_in(22 downto 11));
    c_fracHL <= (a_norm & a_in(22 downto 11)) * b_in(10 downto 0);
    c_fracLH <= a_in(10 downto 0) * (b_norm & b_in(22 downto 11));
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
    if (a_nan || b_nan) then
      if (c_frac2(26) = '1') then
        c_expo3 <= c_expo2 + 2;
        c_frac3_tmp := c_frac3 + (c_frac2(2)+'00');
        c_frac3 <= c_frac3_tmp(25 downto 3);
      elsif (c_frac2(25) = '1') then
        c_expo3 <= c_expo2 + 1;
        c_frac3_tmp := c_frac3 + (c_frac2(1)+'0');
        c_frac3 <= c_frac3_tmp(24 downto 2);
      elsif (c_frac2(24) = '1') then
        c_expo3 <= c_expo2;
        c_frac3_tmp := c_frac3 +  c_frac2(0);
        c_frac3 <= c_frac3_tmp(23 downto 1);
      elsif (c_frac2(23) = '1') then
        c_expo3 <= c_expo2 - 1;
        c_frac3 <= c_frac3_tmp(22 downto 0);
      elsif (c_frac2(23) = '1') then
        c_expo3 <= c_expo2 - 1;
        c_frac3 <= c_frac3_tmp(21 downto 0) & "0";
      elsif (c_frac2(22) = '1') then
        c_expo3 <= c_expo2 - 2;
        c_frac3 <= c_frac3_tmp(20 downto 0) & "00";
      elsif (c_frac2(21) = '1') then
        c_expo3 <= c_expo2 - 3;
        c_frac3 <= c_frac3_tmp(19 downto 0) & "000";
      elsif (c_frac2(20) = '1') then
        c_expo3 <= c_expo2 - 4;
        c_frac3 <= c_frac3_tmp(18 downto 0) & "0000";
      elsif (c_frac2(19) = '1') then
        c_expo3 <= c_expo2 - 5;
        c_frac3 <= c_frac3_tmp(17 downto 0) & "00000";
      elsif (c_frac2(18) = '1') then
        c_expo3 <= c_expo2 - 6;
        c_frac3 <= c_frac3_tmp(16 downto 0) & "000000";
      elsif (c_frac2(17) = '1') then
        c_expo3 <= c_expo2 - 7;
        c_frac3 <= c_frac3_tmp(15 downto 0) & "0000000";
      elsif (c_frac2(16) = '1') then
        c_expo3 <= c_expo2 - 8;
        c_frac3 <= c_frac3_tmp(14 downto 0) & "00000000";
      elsif (c_frac2(15) = '1') then
        c_expo3 <= c_expo2 - 9;
        c_frac3 <= c_frac3_tmp(13 downto 0) & "000000000";
      elsif (c_frac2(14) = '1') then
        c_expo3 <= c_expo2 - 10;
        c_frac3 <= c_frac3_tmp(12 downto 0) & "0000000000";
      elsif (c_frac2(13) = '1') then
        c_expo3 <= c_expo2 - 11;
        c_frac3 <= c_frac3_tmp(11 downto 0) & "00000000000";
      elsif (c_frac2(12) = '1') then
        c_expo3 <= c_expo2 - 12;
        c_frac3 <= c_frac3_tmp(10 downto 0) & "000000000000";
      elsif (c_frac2(11) = '1') then
        c_expo3 <= c_expo2 - 13;
        c_frac3 <= c_frac3_tmp( 9 downto 0) & "0000000000000";
      elsif (c_frac2(10) = '1') then
        c_expo3 <= c_expo2 - 14;
        c_frac3 <= c_frac3_tmp( 8 downto 0) & "00000000000000";
      elsif (c_frac2( 9) = '1') then
        c_expo3 <= c_expo2 - 15;
        c_frac3 <= c_frac3_tmp( 7 downto 0) & "000000000000000";
      elsif (c_frac2( 8) = '1') then
        c_expo3 <= c_expo2 - 16;
        c_frac3 <= c_frac3_tmp( 6 downto 0) & "0000000000000000";
      elsif (c_frac2( 7) = '1') then
        c_expo3 <= c_expo2 - 17;
        c_frac3 <= c_frac3_tmp( 5 downto 0) & "00000000000000000";
      elsif (c_frac2( 6) = '1') then
        c_expo3 <= c_expo2 - 18;
        c_frac3 <= c_frac3_tmp( 4 downto 0) & "000000000000000000";
      elsif (c_frac2( 5) = '1') then
        c_expo3 <= c_expo2 - 19;
        c_frac3 <= c_frac3_tmp( 3 downto 0) & "0000000000000000000";
      elsif (c_frac2( 4) = '1') then
        c_expo3 <= c_expo2 - 20;
        c_frac3 <= c_frac3_tmp( 2 downto 0) & "00000000000000000000";
      elsif (c_frac2( 3) = '1') then
        c_expo3 <= c_expo2 - 21;
        c_frac3 <= c_frac3_tmp( 1 downto 0) & "000000000000000000000";
      elsif (c_frac2( 2) = '1') then
        c_expo3 <= c_expo2 - 22;
        c_frac3 <= c_frac3_tmp( 0 downto 0) & "0000000000000000000000";
      elsif (c_frac( 1) = '1')
        c_expo3 <= c_expo2 - 23;
        c_frac3 <= "00000000000000000000000";
      elsif (c_frac( 0) = '1')
        c_expo3 <= c_expo2 - 24;
        c_frac3 <= "00000000000000000000000";
      else -- zero
        c_expo3 <= c_expo2 - 25;
        c_frac3 <= "00000000000000000000000";
      end if;
    else
      if (c_frac2(26) = '1') then
        c_expo3 <= c_expo2i;
        c_frac3_tmp := c_frac2 + (c_frac2(2)+'00');
        c_frac3 <= c_frac3_tmp(25 downto 3);
      else
        c_expo3 <= c_expo2s;
        c_frac3_tmp := c_frac2 + (c_frac2(1)+'0');
        c_frac3 <= c_frac3_tmp(24 downto 2);
      end if;
    end if;
  end process;

  process (c_sign3, c_expo3, c_frac3, zero, inf) is
  begin
    if false then
    elsif b_nan then
      c_sign <= b_in(31);
      c_expo <= "11111111";
      c_frac <= "00000000000000000000000";
    elsif a_nan then
      c_sign <= a_in(31);
      c_expo <= "11111111";
      c_frac <= "00000000000000000000000";
    elsif inf and zero then
      c_sign <= '1';
      c_expo <= "11111111";
      c_frac <= "00000000000000000000000";
    elsif inf or (c_expo3(9) = '1') or (c_expo3(8 downto 0) = "111111111") then
      c_sign <= c_sign3;
      c_expo <= "11111111";
      c_frac <= "00000000000000000000000";
    elsif zero or (c_expo3(8) = '0') or (c_expo3(7 downto 0) = "00000000") then
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