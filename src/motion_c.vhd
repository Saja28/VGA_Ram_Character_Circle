library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.STD_LOGIC_SIGNED.ALL;
use     IEEE.NUMERIC_STD.ALL;


entity motion_c is
port(
      vgaclk       : in std_logic;
      x            : in std_logic_vector(9 downto 0);
      y            : in std_logic_vector(9 downto 0);
      xcir         : in std_logic_vector(9 downto 0);
      ycir         : in std_logic_vector(9 downto 0);
      radiuss      : in std_logic_vector(9 downto 0);
      m_circle     : out std_logic
       );
 
end entity;

architecture rtl of motion_c is

signal diff_xcir      : std_logic_vector(9 downto 0);
signal diff_ycir      : std_logic_vector(9 downto 0);
signal pow2_diff_xcir : std_logic_vector(19 downto 0);
signal pow2_diff_ycir : std_logic_vector(19 downto 0);
signal pow2_radiuss   : std_logic_vector(19 downto 0);

signal a1   : std_logic;
signal a2   : std_logic;

begin

process (vgaclk) begin
   if rising_edge(vgaclk) then
      diff_xcir <= x -  xcir;
      diff_ycir <= y - ycir;
      
      pow2_diff_xcir <= diff_xcir * diff_xcir;
      pow2_diff_ycir <= diff_ycir * diff_ycir;
      pow2_radiuss <= radiuss * radiuss;
		
		
		 if (pow2_diff_xcir + pow2_diff_ycir)  > (pow2_radiuss - 130) then
		    a1 <= '1';
		 else
		    a1 <= '0';
		 end if;
		 
		 if (pow2_diff_xcir + pow2_diff_ycir)  < (pow2_radiuss + 130) then
		    a2 <= '1';
		 else
		    a2 <= '0';
		 end if;


      -- if (((pow2_diff_xcir + pow2_diff_ycir)  > (pow2_radiuss - 130)) and ((pow2_diff_xcir + pow2_diff_ycir)  < (pow2_radiuss + 130))) then
			if ( a1 = '1'  and a2 = '1' ) then
            m_circle <= '1';
         else
            m_circle <= '0';
         end if;
   end if;  
   
end process;

end rtl;
