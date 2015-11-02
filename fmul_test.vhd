library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity fmul_test is
end fmul_test;

architecture test of fmul_test is 
  component fmul
    port (
    a : in  std_logic_vector (31 downto 0);
    b : in  std_logic_vector (31 downto 0);
    c : out std_logic_vector (31 downto 0));
  end component;

  signal aa : std_logic_vector(31 downto 0) := (others => '0');
  signal bb : std_logic_vector(31 downto 0) := (others => '0');
  signal cc : std_logic_vector(31 downto 0);

  signal state : std_logic_vector(1 downto 0) := "11";
  signal simclk : std_logic := '0';
begin 
  testee : fmul port map (
    a => aa,
    b => bb,
    c => cc
  );

  tester : process (simclk)
    file input_file  : text open read_mode  is "input.dat";
    file output_file : text open write_mode is "output.dat";
    variable l : LINE;
    variable a_read : std_logic_vector(31 downto 0) := (others => '0');
    variable b_read : std_logic_vector(31 downto 0) := (others => '0');
    variable c_read : std_logic_vector(31 downto 0);
  begin
    if rising_edge(simclk) then
      aa <= a_read;
      bb <= b_read;
      c_read := cc;
      case state is
      when "00" =>
        if endfile(input_file) then
          state <= "11";
        else
          readline(input_file, l);
          read(l, a_read);
          readline(input_file, l);
          read(l, b_read);
          state <= "01";
        end if;
      when "01" =>
        state <= "10";
      when "10" =>
        write(l, cc);
        writeline(output_file, l);
        state <= "11";
      when others =>
        state <= "00";
      end case;
    end if;
  end process;

  clockgen : process
  begin
    simclk <= '0';
    wait for 5 ns;
    simclk <= '1';
    wait for 5 ns;
  end process;
end;