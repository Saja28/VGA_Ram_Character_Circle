library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.STD_LOGIC_ARITH.ALL;


entity VGA_S is
port(
       clk50_in  : in std_logic;      --system clock i/p
       reset     : in std_logic;
      
       r         : out std_logic;     ---vector( 7 downto 0); -----to video DAC
       g         : out std_logic;     ---vector( 7 downto 0);
       b         : out std_logic;     ---vector( 7 downto 0);
       hsync     : out std_logic;     --horizontal control signal
       vsync     : out std_logic);   --vertical   control signal

end entity;

architecture rtl of VGA_S is
----------------------------------------------------
--
--------------------------------------------------------------
component vgaController is
port(
       reset     : in std_logic;
       vgaclk    : in std_logic;
       hcnt      : out std_logic_vector( 9 downto 0); ---to video DAC
       vcnt      : out std_logic_vector( 9 downto 0);
       sync_b    : out std_logic;              --- to monitor & DAC
       blank_b   : out std_logic;              --- to monitor & DAC
       hsync     : out std_logic;              ----horizontal control signal
       vsync     : out std_logic
       );       
end component;
-----------------------------------------------------------------
--videoGen
----------------------------------------------------------------

component videoGen is
port(
      vgaclk     : in  std_logic;
      reset     : in std_logic;
       x         : in  std_logic_vector( 9 downto 0); ---to video DAC
       y         : in  std_logic_vector( 9 downto 0);
      
       r         : out std_logic_vector( 7 downto 0);         
       g         : out std_logic_vector( 7 downto 0);         
       b         : out std_logic_vector( 7 downto 0)
       );        
               
end component;
--------------------------------------------------------
--signals
---------------------------------------------------------------------------
signal hcnt       : std_logic_vector( 9 downto 0);
signal Vcnt       : std_logic_vector( 9 downto 0);
signal x          : std_logic_vector( 9 downto 0);
signal y          : std_logic_vector( 9 downto 0);
signal vgaclk     : std_logic;


begin   
    
   process (clk50_in)begin
      if clk50_in'event and clk50_in='1' then
         if (vgaclk = '0') then              
            vgaclk <= '1';
         else
            vgaclk <= '0';
         end if;
      end if;
   end process;
   
   
--------------------------------------------------------------
--vgaController
---------------------------------------------------------------- 
  vgaController1:vgaController
port map(
       reset     => reset,
       vgaclk    => vgaclk,
       hcnt      => x,
       vcnt      => y,
       sync_b    => open,
       blank_b   => open,
       hsync     => hsync,
       vsync     => vsync
       );
--------------------------------------------------------------
--videoGen
---------------------------------------------------------------- 

   videoGen1: videoGen 
port map(
      vgaclk         =>vgaclk,
      reset         =>reset,
       x             => x,
       y             => y,
       r(0)          => r,
       r(7 downto 1) => open,     
       g(7 downto 1) => open,     
       b(7 downto 1) => open,     
       g(0)          => g,         
       b(0)          => b
       );        
               
   end rtl;