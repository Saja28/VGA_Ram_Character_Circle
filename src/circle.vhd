library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity circle is

port(
       vgaclk      : in std_logic;
       x           : in std_logic_vector(9 downto 0);
       y           : in std_logic_vector(9 downto 0);
       xcenter     : in std_logic_vector(9 downto 0);
       ycenter     : in std_logic_vector(9 downto 0);
       radius      : in std_logic_vector(9 downto 0);
       incircle    : out std_logic
       );
 
end entity;

architecture rtl of circle is

signal diff_x : std_logic_vector(9 downto 0);
signal diff_y : std_logic_vector(9 downto 0);

signal pow2_diff_x : std_logic_vector(19 downto 0);
signal pow2_diff_y : std_logic_vector(19 downto 0);
signal pow2_radius : std_logic_vector(19 downto 0);

begin

process (vgaclk) begin
   if rising_edge(vgaclk) then
      diff_x <= x -  xcenter;
      diff_y <= y - ycenter;
      
      pow2_diff_x <= diff_x * diff_x;
      pow2_diff_y <= diff_y * diff_y;
      pow2_radius <= radius * radius;

         if (pow2_diff_x + pow2_diff_y) < pow2_radius then
            incircle <= '1';
         else 
            incircle <= '0';
         end if;
   end if;     
end process;

end rtl;

