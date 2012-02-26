-- 14 bit barrel shifter
-- implemented with multipliers
-- see Xilinx XAPP195

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity mul_bs is
  generic(width: integer := 7);
  port (clk : in std_logic;
        rst: in std_logic;
        en : in std_logic;
        din1 : in std_logic_vector(width-1 downto 0);
        din2 : in std_logic_vector(width-1 downto 0);
        din3 : in std_logic_vector(width-1 downto 0);
        dout : out std_logic_vector(width-1 downto 0)
        );
end mul_bs;

architecture behavior of mul_bs is

begin
  process(clk)
    variable p : std_logic_vector(2*width-1 downto 0) := (others=>'0');
    variable p1 : std_logic_vector(2*width-1 downto 0) := (others=>'0');
    variable p3 : std_logic_vector(4*width-1 downto 0) := (others=>'0');
    begin
      if rising_edge(clk) then
        if rst='1' then
            dout <= (others=>'0');
        elsif en='1' then
            p(2*width-1 downto width) := din1;
            p(width-1 downto 0) := din2;
            p1(width-1 downto 0) := din3;
            p3 := p*p1;
            dout <= p3(2*width-1 downto width);
        end if;
      end if;
  end process;
end architecture;


library IEEE;
use IEEE.std_logic_1164.all;

entity mux_bs is
  generic(width: integer);
  port (clk: in std_logic;
           rst: in std_logic;
           en : in std_logic;
           din1: in std_logic_vector(width-1 downto 0);
           din2: in std_logic_vector(width-1 downto 0);
           sel: in std_logic;
           dout : out std_logic_vector(width-1 downto 0)
           );
end mux_bs;

architecture behavior of mux_bs is
begin
  process(clk)
    begin
      if rising_edge(clk) then
        if rst='1' then
            dout <= (others=>'0');
        elsif en='1' then
            case sel is
              when '0' => dout <= din1;
              when '1' => dout <= din2;
              when others => dout <= (others=>'0');
            end case;
        end if;
      end if;
  end process;
end architecture;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity barrel_shifter is
  generic(width : integer := 14);
  port( clk : in std_logic;
        rst: in std_logic;
        en: in std_logic;
        rdy: out std_logic;
        din : in std_logic_vector(width-1 downto 0);
        rot : in std_logic_vector(3 downto 0);
        dout : out std_logic_vector(width-1 downto 0)
        );
end barrel_shifter;

architecture behavior of barrel_shifter is
component mul_bs is
  generic(width: integer);
  port (clk : in std_logic;
        rst: in std_logic;
        en : in std_logic;
        din1 : in std_logic_vector(width-1 downto 0);
        din2 : in std_logic_vector(width-1 downto 0);
        din3 : in std_logic_vector(width-1 downto 0);
        dout : out std_logic_vector(width-1 downto 0)
        );
end component;
component mux_bs is
  generic(width: integer);
  port (clk: in std_logic;
           rst: in std_logic;
           en : in std_logic;
           din1: in std_logic_vector(width-1 downto 0);
           din2: in std_logic_vector(width-1 downto 0);
           sel: in std_logic;
           dout : out std_logic_vector(width-1 downto 0)
           );
end component;
signal mul_bs_out1, mul_bs_out2 : std_logic_vector(6 downto 0);
type s_t is array(1 downto 0) of std_logic;
signal s1, s2 : s_t :=(others=>'0');
signal r : std_logic_vector(6 downto 0);
type tmp_rdy_t is array(1 downto 0) of std_logic;
signal tmp_rdy: tmp_rdy_t := (others=>'0');
signal din_tmp: std_logic_vector(width-1 downto 0);
begin
  
  process(clk)
    variable overflow : std_logic := '0';

    begin
      if rising_edge(clk) then
        if rst='1' then
            s1 <= (others=>'0');
            s2 <= (others=>'0');
            r <= (others=>'0');
            rdy<='0';
            tmp_rdy<=(others=>'0');
        elsif en='1' then
  --          if rot/="111" then
  --            s1 <='0';
  --            s2 <='0';
  --          else
  --            s1<='1';
  --            s2<='1';
  --          end if;
            overflow := (rot(2) and rot(1) and rot(0)) or rot(3);
            s1(0) <= overflow;
            s2(0) <= overflow;
            s1(s1'left downto 1) <= s1(s1'left-1 downto 0);
            s2(s2'left downto 1) <= s2(s2'left-1 downto 0);
            if overflow='0' then
              case rot(2 downto 0) is
                when "000" => r <= "0000001";
                when "001" => r <= "0000010";
                when "010" => r <= "0000100";
                when "011" => r <= "0001000";
                when "100" => r <= "0010000";
                when "101" => r <= "0100000";
                when "110" => r <= "1000000";
                when others=> r <= "0000001";
              end case;
            else
              case rot(2 downto 0) is
                when "000" => r <= "0000010";
                when "001" => r <= "0000100";
                when "010" => r <= "0001000";
                when "011" => r <= "0010000";
                when "100" => r <= "0100000";
                when "101" => r <= "1000000";
                when others=> r <= "0000001";
              end case;
            end if;
            din_tmp<=din;
            tmp_rdy(0)<='1';
            tmp_rdy(1)<=tmp_rdy(0);
            rdy<=tmp_rdy(1);
        else
            tmp_rdy(0)<='0';
            rdy<=tmp_rdy(1);
        end if;
      end if;
    end process;
  
  m1: mul_bs
    generic map(width=> 7)
    port map(clk=>clk,rst=>rst,en=>tmp_rdy(0),din1=>din_tmp(6 downto 0), din2=>din_tmp(13 downto 7),din3=>r, dout=>mul_bs_out1);
  m2: mul_bs
    generic map(width=> 7)
    port map(clk=>clk,rst=>rst,en=>tmp_rdy(0),din1=>din_tmp(13 downto 7), din2=>din_tmp(6 downto 0),din3=>r, dout=>mul_bs_out2);
  mu1: mux_bs
    generic map(width=> 7)
    port map(clk=>clk,rst=>rst,en=>tmp_rdy(0),din1=>mul_bs_out1, din2=>mul_bs_out2, dout=>dout(6 downto 0), sel=>s1(1));
  mu2: mux_bs
    generic map(width=> 7)
    port map(clk=>clk,rst=>rst,en=>tmp_rdy(0),din1=>mul_bs_out2, din2=>mul_bs_out1, dout=>dout(13 downto 7), sel=>s2(1));
  
end architecture;


----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity barrel_shifter_r is
  generic(width : integer := 14);
  port( clk : in std_logic;
        rst: in std_logic;
        en: in std_logic;
        rdy: out std_logic;
        din : in std_logic_vector(width-1 downto 0);
        rot : in std_logic_vector(3 downto 0);
        dout : out std_logic_vector(width-1 downto 0)
        );
end barrel_shifter_r;

architecture structure of barrel_shifter_r is
component barrel_shifter is
  generic(width : integer := 14);
  port( clk : in std_logic;
        rst: in std_logic;
        en: in std_logic;
        rdy: out std_logic;
        din : in std_logic_vector(width-1 downto 0);
        rot : in std_logic_vector(3 downto 0);
        dout : out std_logic_vector(width-1 downto 0)
        );
end component;
signal din_t, dout_t : std_logic_vector(width-1 downto 0);
begin
  g1:for i in 0 to width-1 generate
    d_i1: din_t(i)<=din(width-1-i);
  end generate;
  g2:for i in 0 to width-1 generate
    d_i2: dout(i)<=dout_t(width-1-i);
  end generate;
  barrel_shifter_i1 : barrel_shifter
    GENERIC MAP(width=>width)
    PORT MAP(
      clk              => clk,
      rst              => rst,
      en               => en,
      rdy              => rdy,
      din              => din_t,
      rot              => rot,
      dout             => dout_t
    );
end architecture;

----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity testbench is
end testbench;

architecture dut of testbench is
signal clk,rst : std_logic := '0';
signal dout : std_logic_vector(13 downto 0);
component barrel_shifter is
  generic(width : integer := 14);
  port( clk : in std_logic;
        rst: in std_logic;
        en : in std_logic;
        rdy : out std_logic;
        din : in std_logic_vector(width-1 downto 0);
        rot : in std_logic_vector(3 downto 0);
        dout : out std_logic_vector(width-1 downto 0)
        );
end component;
begin
  clk <= not clk after 10 ns;
  rst <= '1' after 10 ns, '0' after 40 ns;
  bs1: barrel_shifter
    port map(clk=>clk,rst=>rst,en=>'1',din=>"10000000000001", rot=>"1000", dout=>dout);
end architecture;
