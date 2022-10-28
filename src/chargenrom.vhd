library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.STD_LOGIC_UNSIGNED.ALL;
use     IEEE.NUMERIC_STD.ALL;
use     STD.TEXTIO.ALL;


entity chargenrom is
port(
      vgaclk    : in std_logic;
      ch        : in std_logic_vector(7 downto 0); -----to video DAC
      xoff      : in std_logic_vector(2 downto 0);
      yoff      : in std_logic_vector(2 downto 0);         
      pixell    : out std_logic
   );
end entity;
-----------------------------------------------------------------------------------------------------
-- Architecture
-----------------------------------------------------------------------------------------------------
architecture rtl of chargenrom is
signal linee           : std_logic_vector(7 downto 0);
type charrom is array (0 to 2047) of bit_vector(5 downto 0);

component ram_char is
   PORT
   (
      address  : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
      clock    : IN STD_LOGIC  := '1';
      data     : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
      wren     : IN STD_LOGIC ;
      q        : OUT STD_LOGIC_VECTOR (5 DOWNTO 0)
   );
END component;
   
   
impure function InitRamFromFile(RamFileName : in string) return charrom is
FILE RamFile         : text is in RamFileName;
variable RamFileLine : line;
variable RAM         : charrom;
begin
      for I in charrom'range loop
         readline(RamFile, RamFileLine);
         read(RamFileLine, RAM(I));
      end loop;
      return RAM;
      end function;

signal RAM : charrom := InitRamFromFile("output.mif");
signal yoffch        : integer;
signal RAM_Addr      : std_logic_vector(10 downto 0);
signal x             : integer;
signal y             : integer;
-----------------------------------------------------------------------------------------------------
-- Begin
-----------------------------------------------------------------------------------------------------
begin
y        <=  to_integer (unsigned( ch))  ; 
yoffch   <= to_integer (unsigned(( yoff)+((ch-x"41") & "000")));
RAM_Addr <= ( yoff)+((ch-x"41") & "000");   
ram_char1 : ram_char
PORT MAP
   (
      address  => RAM_Addr,
      clock    => vgaclk,
      data     => (others => '0'),
      wren     => '0',
      q        => linee(5 DOWNTO 0)
   );
linee(7 downto 6) <= "00"; 
pixell <= linee(7 - (to_integer(unsigned(xoff))));
end rtl;

