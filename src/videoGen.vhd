library IEEE;
use     IEEE.STD_LOGIC_1164.ALL;
use     IEEE.STD_LOGIC_ARITH.ALL;
use     IEEE.STD_LOGIC_SIGNED.ALL;
use     IEEE.NUMERIC_STD.ALL;
use     STD.TEXTIO.ALL;

entity videoGen is
generic(
       N         : integer := 7;
       STEPS     : integer := 23;
       RD        : integer := 200
       );
port(
      vgaclk     : in  std_logic;
      reset      : in  std_logic;
       x         : in  std_logic_vector( 9 downto 0); ---to video DAC
       y         : in  std_logic_vector( 9 downto 0);
       r         : out std_logic_vector( 7 downto 0);         
       g         : out std_logic_vector( 7 downto 0);         
       b         : out std_logic_vector( 7 downto 0)
       );        
               
end entity;

architecture rtl of videoGen is
------------------------------------------------------------
-- chargenrom
------------------------------------------------------------
component chargenrom is
port(
       vgaclk    : in std_logic;
       ch        : in std_logic_vector(7 downto 0); ---to video DAC
       xoff      : in std_logic_vector(2 downto 0);
       yoff      : in std_logic_vector(2 downto 0);         
       pixell    : out std_logic);         
 
end component;
------------------------------------------------------------
-- circle
------------------------------------------------------------
component circle is
port(
       vgaclk      : in std_logic;
       x           : in std_logic_vector(9 downto 0);
       y           : in std_logic_vector(9 downto 0);
       xcenter     : in std_logic_vector(9 downto 0);
       ycenter     : in std_logic_vector(9 downto 0);
       radius      : in std_logic_vector(9 downto 0);
       incircle    : out std_logic
       );
 
end component;
------------------------------------------------------------
--motion_c
------------------------------------------------------------
component motion_c is

port(
       vgaclk       : in std_logic;
       x            : in std_logic_vector(9 downto 0);
       y            : in std_logic_vector(9 downto 0);
       xcir         : in std_logic_vector(9 downto 0);
       ycir         : in std_logic_vector(9 downto 0);
       radiuss      : in std_logic_vector(9 downto 0);
       m_circle     : out std_logic
       );
 
end component;

    
signal pixell           : std_logic;
signal inrect           : std_logic;
signal inrect1          : std_logic;
signal leftt            : std_logic_vector(9  downto 0):="00" & x"78"; 
signal top              : std_logic_vector(9  downto 0):= "00" & x"96";
signal rightt           : std_logic_vector(9  downto 0):= "00" & x"C8";         
signal bot              : std_logic_vector(9  downto 0):= "00" & x"E6"; 
   
signal xcenter          : std_logic_vector(9  downto 0);--:= "01" & x"A9";
signal ycenter          : std_logic_vector(9  downto 0);--:= "00" & x"F5";
signal radius           : std_logic_vector(9  downto 0);--:= "10" & x"25";
   
signal xcir             : std_logic_vector(9  downto 0):= "01" & x"A9";
signal ycir             : std_logic_vector(9  downto 0):= "00" & x"F5";
signal radiuss          : std_logic_vector(9  downto 0);--:= "00" & x"50";
   
signal diff_xcir        : std_logic_vector(9  downto 0);
signal diff_ycir        : std_logic_vector(9  downto 0);
signal pow2_diff_xcir   : std_logic_vector(19 downto 0);
signal pow2_diff_ycir   : std_logic_vector(19 downto 0);
signal pow2_radiuss     : std_logic_vector(19 downto 0);
signal m_circle         : std_logic_vector(4*N downto 0);
signal xcenter_2        : std_logic_vector(9 downto 0);
signal ycenter_2        : std_logic_vector(9 downto 0);
   
signal refresh          : std_logic;

signal yycir            : std_logic_vector(19  downto 0);
signal xxcir            : std_logic_vector(19  downto 0);
signal rcir             : std_logic_vector(19 downto 0);

signal cntr             : std_logic_vector( 27 downto 0);
signal color_reg        : std_logic_vector(  5 downto 0):="000001" ;
signal two_sec_pulse    : std_logic;
signal two_sec_pulseQ   : std_logic;
signal sec_pulse        : std_logic;

constant COLOR_ON      : std_logic_vector(7 downto 0) := (others=>'1'); 
constant COLOR_OFF     : std_logic_vector(7 downto 0) := (others=>'0');
constant ROW_HEIGHT    : integer := 480; -- number of visible rows
constant COLUMN_WIDTH  : integer := 640 -1 ;


begin

------------------------------------------------------------
-- chargenrom
------------------------------------------------------------
 chargenrom1:chargenrom
port map(
       vgaclk    => vgaclk,
       ch        => y(3 downto 0) + x"41",
       xoff      => x(2 downto 0),
       yoff      => y(2 downto 0),         
       pixell    => pixell  
      );     
 
process (vgaclk)begin
   if rising_edge(vgaclk) then
      if x= 639 and y = 479 then
         refresh <='1';
      else
         refresh <='0';
      end if;
      
      if refresh = '1' then
         if xcenter >639 then
            ycir <=  ycir;
            xcir <=  xcir;
         else
           xcir <=  xcir + 2  ;
         end if;
      end if;  
      
end if;
end process;

------------------------------------------------------------
--circle
------------------------------------------------------------   

 circle1 : circle
port map(
       vgaclk    => vgaclk,
       x         => x,
       y         => y,
       xcenter   => xcenter,
       ycenter   => ycenter,
       radius    =>"00" & x"28",
       incircle  => inrect
       );
       
       
------------------------------------------------------------
-- x_motion_c
------------------------------------------------------------
   motion_c0 : motion_c -- Main
   port map(
          vgaclk       => vgaclk,
          x            => x,
          y            => y,
          xcir         => xcir,
          ycir         => ycir,
          radiuss      => std_logic_vector(to_unsigned(RD, 10)),
          m_circle     => m_circle(0)
          );

gen: for i in 1 to N generate

   motion_c1to7: motion_c -- Right (1 to 7)
   port map(
          vgaclk       => vgaclk,
          x            => x,
          y            => y,
          xcir         => xcir + std_logic_vector(to_unsigned(STEPS*i , 10)),
          ycir         => ycir,
          radiuss      => std_logic_vector(to_unsigned(RD - STEPS*i, 10)),
          m_circle     => m_circle(i)
          );

   motion_c8to14: motion_c -- Left (8 to 14)
   port map(
          vgaclk       => vgaclk,
          x            => x,
          y            => y,
          xcir         => xcir - std_logic_vector(to_unsigned(STEPS*i , 10)),
          ycir         => ycir,
          radiuss      => std_logic_vector(to_unsigned(RD - STEPS*i, 10)),
          m_circle     => m_circle(i+N)
          );
                  
   motion_c15to21: motion_c -- Down (15 to 21)
   port map(
          vgaclk       => vgaclk,
          x            => x,
          y            => y,
          xcir         => xcir ,
          ycir         => ycir + std_logic_vector(to_unsigned(STEPS*i , 10)),
          radiuss      => std_logic_vector(to_unsigned(RD - STEPS*i, 10)),
          m_circle     => m_circle(i+2*N)
          );
   
   motion_c22to28: motion_c -- Up (22 to 28)
   port map(
          vgaclk       => vgaclk,
          x            => x,
          y            => y,
          xcir         => xcir ,
          ycir         => ycir - std_logic_vector(to_unsigned(STEPS*i , 10)),
          radiuss      => std_logic_vector(to_unsigned(RD - STEPS*i, 10)),
          m_circle     => m_circle(i+3*N)
          );      
          
end generate;

------------------------------------------------------------
-- Counter second pulse 
------------------------------------------------------------
process (vgaclk)begin
   if rising_edge(vgaclk) then
      if ( cntr = x"17D7840") then  
         cntr      <= (others =>'0');
         sec_pulse <= '1';            
      else
         cntr      <=  cntr +'1'  ;
         sec_pulse <= '0';
      end if;
   end if;  
end process;

process (vgaclk)begin
   if rising_edge(vgaclk) then
      two_sec_pulseQ <= two_sec_pulse;
      if ( sec_pulse = '1' ) then
         two_sec_pulse <= not two_sec_pulse;            
      end if;
   end if;  
end process;


process (vgaclk)begin
   if rising_edge(vgaclk) then
     -- if ( two_sec_pulse = '1' and two_sec_pulseQ = '0' ) then
     if sec_pulse='1' then
         color_reg <= (color_reg(4 downto 0) & color_reg(5) );            
      end if;
   end if;  
end process;
     
------------------------------------------------------------
--
------------------------------------------------------------  
process (vgaclk)begin
   
   if rising_edge(vgaclk) then
      r <= (others=>'0');
      g <= (others=>'0');
      b <= (others=>'0');
--      if y(3)='1' then 
--         r <= "0000000" & pixell;
--         b <= (others=>'0');
--         g <= (others=>'0');
--      else
--         r <=(others=>'0');
--         b <= "0000000" & pixell;
--         g <= "0000000" & pixell;
--      end if;
--   
--      if inrect = '1'  then 
--         g <= "11111111";
--         r <= "11111111";
--      end if;
            
      if  m_circle /= std_logic_vector(to_unsigned(0 , 4*N+1)) then
         if color_reg(0) = '1' then
            g <= "11111111";
         elsif color_reg(1) = '1' then
            g <= "11111111";
            r <= "11111111";
         elsif color_reg(2) = '1' then
            b <= "11111111";
            r <= "11111111";
         elsif color_reg(3) = '1' then
            b <= "11111111";
            g <= "11111111";
         elsif color_reg(4) = '1' then
            r <= "11111111";
            g <= "11111111";
            b <= "11111111";         
         else
            r <= "11111111";
         end if;        
      end if;     
   end if;
 end process;
end rtl;