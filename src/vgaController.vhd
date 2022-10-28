library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.STD_LOGIC_ARITH.ALL;
use     IEEE.STD_LOGIC_UNSIGNED.ALL;
use     IEEE.NUMERIC_STD.ALL;
use     STD.TEXTIO.ALL;

entity vgaController is
generic (
   -- horizontal back porch
   HBP        : integer := 48  ; 
   HACTIVE    : integer := 640 ;
   HFP        : integer := 16  ;
   HSYN       : integer := 96  ;
   HMAX       : integer := 800;--(HBP + HACTIVE + HFP + HSYN);
   -- vertical back porch
   VBP        : integer := 32 ;
   VACTIVE    : integer := 480;
   VFP        : integer := 11 ;
   VSYN       : integer := 2  ; 
   VMAX       : integer := 525 --(VBP + VACTIVE + VFP + VSYN)
);

port(
      reset     : in std_logic;
      vgaclk    : in std_logic;
      hcnt      : out std_logic_vector( 9 downto 0); -----to video DAC
      vcnt      : out std_logic_vector( 9 downto 0);
      sync_b    : out std_logic;         ----- to monitor & DAC
      blank_b   : out std_logic;         ----- to monitor & DAC
      hsync     : out std_logic;         ------horizontal control signal
      vsync     : out std_logic);        ------vertical   control signal

end entity;

architecture rtl of vgaController is

signal hcnt1             : std_logic_vector(9 downto 0);
signal vcnt1             : std_logic_vector(9 downto 0);
signal HACTIVEHFP_HSYN   : std_logic_vector(9 downto 0);
signal HACTIVE_HFP       : std_logic_vector(9 downto 0);
signal VACTIVE_VFP       : std_logic_vector(9 downto 0);
signal VACTIVEVFP_VSYN   : std_logic_vector(9 downto 0);
begin
-----------------------------------------------------------------------------------
-- vgaController
----------------------------------------------------------------------------------- 
   
   HACTIVEHFP_HSYN <= Std_Logic_Vector(to_unsigned(HACTIVE + HFP + HSYN , 10));
   
   HACTIVE_HFP <= Std_Logic_Vector(to_unsigned(HACTIVE + HFP, 10));
   
   hsync   <=  '1' when ((hcnt1 > HACTIVE_HFP )and  (hcnt1 < HACTIVEHFP_HSYN)) else '0';  
   
   ------------------------------------------------------------------------------------
   --vsync
   ------------------------------------------------------------------------------------
   VACTIVEVFP_VSYN <= Std_Logic_Vector(to_unsigned(VACTIVE + VFP + VSYN , 10));
   
   VACTIVE_VFP <= Std_Logic_Vector(to_unsigned(VACTIVE + VFP, 10));
   
   vsync   <=  '1' when ((vcnt1 > VACTIVE_VFP ) and  (vcnt1 < VACTIVEVFP_VSYN)) else '0';
   
   ------------------------------------------------------------------------------
   --sync_b
   --------------------------------------------------------------------------------
   sync_b  <= '0';
   -----------------------------------------------------------------------------
   --blank_b
   -----------------------------------------------------------------------------
   blank_b <= '1' when ((hcnt1 < HACTIVE) and (vcnt1 < VACTIVE)) else '0';
   
   hcnt <= hcnt1;
   vcnt <= vcnt1;
   
   process (vgaclk)begin
      if (reset = '0') then 
          hcnt1 <= (others => '0');
          vcnt1 <=  (others => '0');
      elsif rising_edge(vgaclk) then
         hcnt1<= hcnt1 + 1;
         if (hcnt1 = HMAX) then
            hcnt1 <=  (others => '0');
            vcnt1<= vcnt1 + 1;
            if (vcnt1 = VMAX) then
               vcnt1 <=  (others => '0');
            end if;
         end if;
      end if;
   end process;      
 end rtl;