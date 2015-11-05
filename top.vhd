library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity top is
  Port ( MCLK1 : in  STD_LOGIC;
         RS_TX : out  STD_LOGIC);
end top;

architecture fpu2 of top is

  signal clk,iclk: std_logic;
  type input_rom is array(0 to 39) of std_logic_vector(31 downto 0);
  type output_rom is array(0 to 19) of std_logic_vector(31 downto 0);

  constant input_data: input_rom :=(
    "11010111000101101000101011001110",
    "11001000011110010011000011010011",
    "11101001011000011011100010100011",
    "01010101110100010010100010010100",
    "01000111000111000011111001010011",
    "01111010001101101011000101110101",
    "01011101011000101000001111100101",
    "11110011110001010101001111000110",
    "10100010101111100000000011111000",
    "00100100010000000001000010101000",
    "00000100001011000100011000110110",
    "00100011001000011001101111001111",
    "00101000000111000001111011101100",
    "00100001001110011111001001011101",
    "11111111101110011000010001100111",
    "10000011010011111000100110010010",
    "10011100110101011111011011001100",
    "10100011001101101010000000011011",
    "01111110010110110111010001100010",
    "01001010111000100110000101000110",
    "10000110110110001100001001001011",
    "01100110011101010110001000001011",
    "01001000100001110101000010110001",
    "11001110110001110000100010111100",
    "00010001110110110111101101010110",
    "10000110101001111010000110011010",
    "00110001001101001110110100110110",
    "11100011111001100100100010101001",
    "00010000011011011000100000011100",
    "01110101001010111111000011101001",
    "00111100111111111110101001000011",
    "11100110111101110001101110111001",
    "01000100010001000011010011100001",
    "01100000000011011001000001111101",
    "10000011001101011000010010000011",
    "10001000000101110101101111111001",
    "01110000000010010000010001111101",
    "11101110010010011000110011111101",
    "01001000110001110111001111010100",
    "10100011110101011010011011010110");

  constant answer_data: output_rom :=(
    "01100000000100101000100110111000",
    "11111111100000000000000000000000",
    "01111111100000000000000000000000",
    "11111111100000000000000000000000",
    "10000111100011101000110100010111",
    "00000000000000000000000000000000",
    "00001001111000101100110001001101",
    "11111111100000000000000000000000",
    "00000000100110001010001101000110",
    "01111111100000000000000000000000",
    "10101101110011111100010011110101",
    "11010111110100100110100010101111",
    "10000000000000000000000000000000",
    "11010101101000101100000001111001",
    "01000110000111111000100101110010",
    "11100100011101110000011010111101",
    "01100100110110001111111110111011",
    "00000000000000000000000000000000",
    "11111111100000000000000000000000",
    "10101101001001100111010101011011");

  signal rom_addr: std_logic_vector(7 downto 0) := (others=>'0');

  signal input1: std_logic_vector(31 downto 0) := (others=>'0');
  signal input2: std_logic_vector(31 downto 0) := (others=>'0');

  signal result: std_logic_vector(31 downto 0);

  signal count: std_logic_vector(1 downto 0) := "00";
  signal errorcount: std_logic_vector(7 downto 0) := "00000000";
  
  signal go : std_logic := '0';
  constant wtime : std_logic_vector(15 downto 0) := x"1B16";
  signal writestate : std_logic_vector(3 downto 0) := "1001";
  signal writecountdown : std_logic_vector(15 downto 0) := (others=>'0');
  signal writebuf : std_logic_vector(7 downto 0);

  component fmul
  Port (
    a  : in  STD_LOGIC_VECTOR (31 downto 0);
    b  : in  STD_LOGIC_VECTOR (31 downto 0);
    c : out STD_LOGIC_VECTOR (31 downto 0));
  end component;

begin
  ib: IBUFG port map (
    i=>MCLK1,
    o=>iclk);
  bg: BUFG port map (
    i=>iclk,
    o=>clk);

  floatmul: fmul port map(
    a => input1,
    b => input2,
    c => result);

  test : process(clk)
  begin
    if rising_edge(clk) then

      if count = "00" then
        if rom_addr = 20 then
          go <= '1';
          count <= "11";
        else
          input1 <= input_data(conv_integer(rom_addr)*2);
          input2 <= input_data(conv_integer(rom_addr)*2 + 1);
          count <= count + 1;
        end if;
      elsif count = "01" then
        if answer_data(conv_integer(rom_addr)) /= result then
          errorcount <= errorcount + 1;
        end if;
        rom_addr <= rom_addr + 1;
        count <= "00";
      elsif count < "11"  then
        count <= count + 1;
      end if;


      if writestate = "1001" then
        if go = '1' then
          RS_TX <= '0';
          writebuf <= errorcount;
          writestate <= "0000";
          writecountdown <= wtime;
        else
          RS_TX <= '1';
        end if;
      elsif writestate = "1000" then
        if writecountdown = 0 then
          RS_TX <= '1';
          writestate <= "1001";
          go <= '0';
        else
          writecountdown <= writecountdown - 1;
        end if;
      else
        if writecountdown = 0 then
          RS_TX <= writebuf(0);
          writebuf <= '1' & writebuf(7 downto 1);
          writecountdown <= wtime;
          writestate <= writestate + 1;
        else
          writecountdown <= writecountdown - 1;
        end if;
      end if;

    end if;
  end process;

end fpu2;
