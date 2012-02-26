library IEEE;
use IEEE.std_logic_1164.all;

entity cnu is
  generic(width: integer:=7);
  port(clk : in std_logic;
       rst : in std_logic;
       en : in std_logic;
       din : in std_logic;
       dout : out std_logic;
       sample : in std_logic
       );
end cnu;

architecture behavior of cnu is
signal acc : std_logic :='0';
signal sr : std_logic_vector(8 downto 0);
signal sel : std_logic := '0';
signal z1,z2,zout : std_logic;
signal counter : std_logic_vector(7 downto 0) := (7 downto 1 =>'0') & '1';
begin
  process(clk)

    begin
      if rising_edge(clk) then
        if rst='1' then
            sr <= (others=>'0');
            acc <= '0';
            dout <= '0';
            sel<='0';
            counter<=(counter'left downto 1 =>'0') & '1';
            z1<='0';
            z2<='0';
            zout<='0';
        elsif en='1' then    
            sr(sr'left-1 downto 0) <= sr(sr'left downto 1);
            sr(sr'left) <= din;
            counter(counter'left downto 1) <= counter(counter'left-1 downto 0);
            if sample='1' then
              case sel is
                when '0' => z2 <= acc;
                when '1' => z1 <= acc;
                when others  => zout <= '0';
              end case;
              acc <= din;
              sel <= not sel;
              counter(0)<='1';
            else
              acc <= acc xor din;
              counter(0)<='0';
            end if;
            if counter(counter'left) = '1' then
              case sel is
                when '0' => zout <= z1;
                when '1' => zout <= z2;
                when others => zout <= '0';
              end case;
            end if;
      
            dout <= zout xor sr(0);
        end if;
      end if;
  end process;
end architecture;

----------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity cnu_array is
  generic(width: integer:= 14);
  port (clk: in std_logic;
        rst: in std_logic;
        en : in std_logic;
        rdy: out std_logic;
        sample: in std_logic;
        din: in std_logic_vector(width-1 downto 0);
        dout: out std_logic_vector(width-1 downto 0)
        );
end cnu_array;

architecture behavior of cnu_array is
component cnu is
  generic(width: integer:=7);
  port(clk : in std_logic;
       rst : in std_logic;
       en : in std_logic;
       din : in std_logic;
       dout : out std_logic;
       sample : in std_logic
       );
end component;
signal tmp_rdy: std_logic_vector(8 downto 0);
begin
  process(clk)
    begin
      if rising_edge(clk) then
        if rst='1' then
          rdy<='0';
          tmp_rdy<=(others=>'0');
        else 
          if en='1' then
            tmp_rdy(0)<='1';
          else
            tmp_rdy(0)<='0';
          end if;
          tmp_rdy(tmp_rdy'left downto 1)<=tmp_rdy(tmp_rdy'left-1 downto 0);
          rdy<=tmp_rdy(tmp_rdy'left);
        end if;

      end if;
    end process;
    
  g1: for i in width-1 downto 0 generate
    cnu1: cnu
      port map(clk=>clk,rst=>rst,en=>en,din=>din(i),dout=>dout(i),sample=>sample);
  end generate;
end architecture;

----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity btos is
  generic(width: integer:=4);
  port(clk : in std_logic;
       rst: in std_logic;
       en : in std_logic;
       din: in std_logic;
       dout: out std_logic_vector(width-1 downto 0)
       );
end btos;

architecture behavior of btos is
begin
  process(clk)
    begin
      if rising_edge(clk) then
        if rst='1' then
            dout <= (others=>'0');
        elsif en='1' then
            case din is
              when '0' => dout <= (width-1 downto 1=>'0') & '1';
              when '1' => dout <= (others=>'1');
              when others => dout <= (others=>'0');
            end case;
        end if;
      end if;
    end process;
end architecture; 

----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity btos_array is
  generic(width: integer := 14);
  port(clk: in std_logic;
       rst: in std_logic;
       en: in std_logic;
       rdy: out std_logic;
       din: in std_logic_vector(width-1 downto 0);
       dout : out std_logic_vector(width*4-1 downto 0)
       );
end btos_array;

architecture structure of btos_array is
component btos is
  generic(width: integer:=4);
  port(clk : in std_logic;
       rst: in std_logic;
       en: in std_logic;
       din: in std_logic;
       dout: out std_logic_vector(width-1 downto 0)
       );
end component;
begin
  process(clk)
    begin
      if rising_edge(clk) then
        if rst='1' then
          rdy<='0';
        else 
          if en='1' then
            rdy<='1';
          else
            rdy<='0';
          end if;
        end if;
      end if;
    end process;
    
  l1: for i in width-1 downto 0 generate
    b1 : btos
      port map(clk=>clk,rst=>rst,en=>en,din=>din(i),dout=>dout((i+1)*4-1 downto i*4));
  end generate;
end architecture;

----------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity adder is
  generic(width: integer:=4);
  port(clk : in std_logic;
       rst: in std_logic;
       en: in std_logic;
       din1: in std_logic_vector(width-1 downto 0);
       din2: in std_logic_vector(width-1 downto 0);
       dout: out std_logic_vector(width-1 downto 0)
       );
end adder;

architecture behavior of adder is
begin
  process(clk)
    begin
      if rising_edge(clk) then
        if rst='1' then
            dout <= (others=>'0');
        elsif en='1' then
            dout <= din1+din2;
        end if;
      end if;
    end process;
end architecture;

----------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity adder_array is
  generic(width: integer := 14);
  port(clk : in std_logic;
       rst : in std_logic;
       en : in std_logic;
       rdy: out std_logic;
       din1: in std_logic_vector(width*4-1 downto 0);
       din2: in std_logic_vector(width*4-1 downto 0);
       dout: out std_logic_vector(width*4-1 downto 0)
       );
end adder_array;

architecture structure of adder_array is
component adder is
  generic(width: integer:=4);
  port(clk : in std_logic;
       rst: in std_logic;
       en: in std_logic;
       din1: in std_logic_vector(width-1 downto 0);
       din2: in std_logic_vector(width-1 downto 0);
       dout: out std_logic_vector(width-1 downto 0)
       );
end component;
begin
  process(clk)
    begin
      if rising_edge(clk) then
        if rst='1' then
          rdy<='0';
        else
          if en='1' then
            rdy<='1';
          else
            rdy<='0';
          end if;
        end if;
      end if;
    end process;
    
  da1 : for i in 0 to width-1 generate
    d1: adder
      port map(clk=>clk,rst=>rst,en=>en,din1=>din1((i+1)*4-1 downto i*4),din2=>din2((i+1)*4-1 downto i*4),dout=>dout((i+1)*4-1 downto i*4));
  end generate;
end architecture;

----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity diff is
  generic(width: integer:=4);
  port(clk : in std_logic;
       rst: in std_logic;
       en: in std_logic;
       din1: in std_logic_vector(width-1 downto 0);
       din2: in std_logic_vector(width-1 downto 0);
       dout: out std_logic_vector(width-1 downto 0)
       );
end diff;

architecture behavior of diff is
begin
  process(clk)
    begin
      if rising_edge(clk) then
        if rst='1' then
            dout <= (others=>'0');
        elsif en='1' then
            dout <= din1-din2;
        end if;
      end if;
    end process;
end architecture; 


----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity diff_array is
  generic(width: integer := 14);
  port(clk : in std_logic;
       rst : in std_logic;
       en: in std_logic;
       rdy: out std_logic;
       din1: in std_logic_vector(width*4-1 downto 0);
       din2: in std_logic_vector(width*4-1 downto 0);
       dout: out std_logic_vector(width*4-1 downto 0)
       );
end diff_array;

architecture structure of diff_array is
component diff is
  generic(width: integer:=4);
  port(clk : in std_logic;
       rst: in std_logic;
       en: in std_logic;
       din1: in std_logic_vector(width-1 downto 0);
       din2: in std_logic_vector(width-1 downto 0);
       dout: out std_logic_vector(width-1 downto 0)
       );
end component;
begin
  process(clk)
    begin
      if rising_edge(clk) then
        if rst='1' then
          rdy<='0';
        else
          if en='1' then
            rdy<='1';
          else
            rdy<='0';
          end if;
        end if;
      end if;
    end process;
    
  da1 : for i in 0 to width-1 generate
    d1: diff
      port map(clk=>clk,rst=>rst,en=>en,din1=>din1((i+1)*4-1 downto i*4),din2=>din2((i+1)*4-1 downto i*4),dout=>dout((i+1)*4-1 downto i*4));
  end generate;
end architecture;

----------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity pc is
  generic(width: integer:=10; max: integer:=23);
  port(clk : in std_logic;
       rst : in std_logic;
       en : in std_logic;
       dout : out std_logic_vector(width-1 downto 0)
       );
end pc;

architecture behavior of pc is

begin
  process(clk)
    variable counter: std_logic_vector(width-1 downto 0):=(others=>'0');
    begin
      if rising_edge(clk) then
        if rst='1' then
            counter := (others=>'0');
            dout  <= (others=>'0');
        elsif en='1' then
          if counter=std_logic_vector(to_unsigned(max,width)) then
            counter:=(others=>'0');
          else
            counter := counter + '1';
          end if;
          dout <= counter;
        end if;
      end if;
    end process;
end architecture;

----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ram is
  generic(word_length: integer := 14;
          addr_width: integer := 13);
  port(clk : in std_logic;
       rst: in std_logic;
       data: inout std_logic_vector(word_length-1 downto 0);
       addr: in std_logic_vector(addr_width-1 downto 0);
       rdwr: in std_logic;
       req: in std_logic;
       busy : out std_logic
       );
end ram;

architecture behavior of ram is
type memory_t is array(natural range<>) of std_logic_vector(word_length-1 downto 0);
subtype memory_tt is memory_t(0 to 2**addr_width);
signal memory : memory_tt := (others=>(others=>'0'));
begin
  process(clk)
    begin
      if rising_edge(clk) then
        if rst='1' then
            data <= (others=>'Z');
            busy <= '0';
        else
            if req='1' then
              if rdwr='1' then
                data <= memory(to_integer(unsigned(addr)));
                busy <= '0';
              else
                memory(to_integer(unsigned(addr))) <= data;
                busy <= '0';
              end if;
            end if;
        end if;
      end if;
    end process;
end architecture;

----------------------------------------------------------------------
-- tato ram moze sucasne citat a zapisovat
-- nemoze sucasne citat alebo sucasne zapisovat
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity dpram is
  generic(word_length: integer := 14;
          addr_width: integer := 13);
  port(clk : in std_logic;
       rst: in std_logic;
       data: inout std_logic_vector(word_length-1 downto 0);
       addr: in std_logic_vector(addr_width-1 downto 0);
       rdwr: in std_logic;
       req: in std_logic;
       busy : out std_logic;
       data1: inout std_logic_vector(word_length-1 downto 0);
       addr1: in std_logic_vector(addr_width-1 downto 0);
       rdwr1: in std_logic;
       req1: in std_logic;
       busy1 : out std_logic
       );
end dpram;

architecture behavior of dpram is
type memory_t is array(natural range<>) of std_logic_vector(word_length-1 downto 0);
subtype memory_tt is memory_t(0 to 2**addr_width);
signal memory : memory_tt :=(others=>(others=>'0'));
begin
  -- write process
  busy <= '0';
  busy1 <= '0';
  process(clk)
    begin
      if rising_edge(clk) then
        if req='1' and rdwr='0' then
              memory(to_integer(unsigned(addr))) <= data;
--              busy <= '0';
        elsif req1='1' and rdwr1='0' then
              memory(to_integer(unsigned(addr1))) <= data1;
--              busy1 <= '0';
        end if;
      end if;
    end process;
    
  -- read process
  process(clk)
    begin
      if rising_edge(clk) then
        if rst='1' then
            data <= (others=>'Z');
  --          busy <= '0';
        else
            if req='1' and rdwr='1' then
                data <= memory(to_integer(unsigned(addr)));
  --              busy <= '0';
            elsif req1='1' and rdwr1='1' then
                memory(to_integer(unsigned(addr))) <= data;
  --              busy1 <= '0';
            end if;
        end if;
      end if;
    end process;
end architecture;

----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity vnu is
  generic(width: integer:= 4);
  port(clk : in std_logic;
       rst : in std_logic;
       codeword: in std_logic;
       b : in std_logic_vector(width-1 downto 0);
       lq : in std_logic_vector(width-1 downto 0);
       dout : out std_logic
       );
end entity;

architecture behavior of vnu is

begin
  process(clk)
    variable ncodeword : std_logic :='0';
    variable lqt : std_logic_vector(width-1 downto 0) := (others=>'0');
    begin
      if rising_edge(clk) then
        if rst='1' then
            dout <= '0';
        else
            ncodeword := not codeword;
              
            if ncodeword='1' then
              lqt := -lq;
            else
              lqt := lq;
            end if;
            if lqt >= b then
              dout <= ncodeword;
            else
              dout <= codeword;
            end if;
        end if;
      end if;
    end process;
end architecture; 

----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity serdes is
  generic(width: integer := 14);
  port(clk : in std_logic;
       rst : in std_logic;
       din : in std_logic;
       dout : out std_logic_vector(width-1 downto 0);
       valid : out std_logic
       );
end entity;

architecture behavior of serdes is
signal data             : std_logic_vector(width-1 downto 0);
signal cnt              : std_logic_vector(4 downto 0);
signal cnt_en, cnt_rst,
       fill_en          : std_logic;
type stav1_t is (RES,FILL);
type stav2_t is (RES,FILLING,VALID_ASSERT,DATA_VALID);
signal stav1            : stav1_t;
signal stav2            : stav2_t;
begin
  process(clk)
    begin
     if rising_edge(clk) then
       if cnt_rst='1' then
          cnt <= std_logic_vector(to_unsigned(width-1,5));
       elsif cnt_en='1' then
          cnt <= cnt - '1';
       end if;
     end if;
    end process;
        
  process(clk)
    begin
      if rising_edge(clk) then
        if rst='1' then
          stav1 <= RES;
        else
          case stav1 is
            when RES => stav1 <= FILL;
            when FILL => stav1 <= FILL;
          end case;
        end if;
      end if;
    end process;
  
  process(clk,fill_en)
    begin
      if rising_edge(clk) then
        if rst='1' then
          data<=(others=>'0');
        elsif fill_en='1' then
          data(0) <= din;
          data(width-1 downto 1) <= data(width-2 downto 0);
        end if;
      end if;
  end process;
    
  process(stav1)

      procedure Reset is
      begin
        fill_en <= '0';
      end;
      
      procedure Fill is
      begin
        fill_en<='1';
        cnt_en<='1';
      end;
      
   begin
        case stav1 is
          when RES => Reset;
          when FILL => Fill;
        end case;
  end process;
      
    process(clk)
      begin
        if rising_edge(clk) then
          if rst='1' then
            stav2 <= RES;
          else
            case stav2 is
              when RES => stav2 <= FILLING;
              when FILLING => 
                if cnt=(width-1 downto 1=>'0')&'1' then
                  stav2 <= VALID_ASSERT;
                end if;
              when VALID_ASSERT => stav2 <= DATA_VALID;
              when DATA_VALID => stav2 <= FILLING;
            end case;
          end if;
        end if;
      end process;
    
    process(stav2)
      
      procedure ValidDeassert is
      begin
        valid <= '0';
      end;
      
      procedure ValidAssert is
      begin
        valid <= '1';
      end;
      
      procedure Reset is
      begin
        dout <= (others=>'0');
        ValidDeassert;
        cnt_rst<='1';
      end;
      
      begin
        case stav2 is
          when RES => Reset;
          when FILLING => cnt_rst<='0';
          when VALID_ASSERT => ValidAssert; cnt_rst<='1';
          when DATA_VALID => dout<=data; ValidDeassert;cnt_rst<='0';
        end case;
      end process;
end architecture;

----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity cmpu is
  generic(width : integer := 14);
  port(clk : in std_logic;
       rst : in std_logic;
       en: in std_logic;
       rdy: out std_logic;
       cw : in std_logic_vector(width-1 downto 0);
       bin : in std_logic_vector(width*4-1 downto 0);
       qin : in std_logic_vector(width*4-1 downto 0);
       dout : out std_logic_vector(width-1 downto 0)
       );
end cmpu;

architecture behavior of cmpu is
signal qi_tmp : std_logic_vector(width*4-1 downto 0);
signal rdy_tmp : std_logic:='0';
begin
  q : for i in 0 to width-1 generate
    process(clk)
      begin
        if rising_edge(clk) then
          if rst='1' then
            qi_tmp((i+1)*4-1 downto i*4)<=(others=>'0');
            rdy_tmp<='0';
          elsif en='1' then
             if cw(i)='0' then
                qi_tmp((i+1)*4-1 downto i*4)<=-qin((i+1)*4-1 downto i*4);
             else
                qi_tmp((i+1)*4-1 downto i*4)<=qin((i+1)*4-1 downto i*4);
            end if;
            rdy_tmp<='1';
          end if;
        end if;
      end process;
  end generate;
  
  q1 : for i in 0 to width-1 generate
    process(clk)
      begin
        if rising_edge(clk) then
          if rst='1' then
            dout(i)<='0';
            rdy<='0';
          elsif en='1' and rdy_tmp='1' then
            if qi_tmp((i+1)*4-1 downto i*4)>=bin((i+1)*4-1 downto i*4) then
              dout(i)<=not cw(i);
            else
              dout(i)<=cw(i);
            end if;
            rdy<=rdy_tmp;
          end if;
        end if;
    end process;
  end generate;
end architecture;

----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity counter is
  generic(width: integer := 4; max: integer:= 14; dao: boolean:=false);
  port(clk: in std_logic;
       rst: in std_logic;
       enable : in std_logic;
       overflow : out std_logic
       );
end counter;

architecture behavior of counter is
signal val : std_logic_vector(width-1 downto 0);
begin
  process(clk)
    begin
      if rising_edge(clk) then
        if rst='1' then
          val<=(others=>'0');
          overflow<='0';
        elsif enable='1' then
          val<=val+'1';
          if val=std_logic_vector(to_unsigned(max-1,width)) then
            overflow<='1';
          end if;
          if val=std_logic_vector(to_unsigned(max,width)) then
            val<=(others=>'0');
            if dao=true then
              overflow<='0';
            end if;
          end if;
        end if;
      end if;
    end process;
end behavior;

----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity vcnt is
  generic(width : integer := 3);
  port (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(width-1 downto 0);
    zf  : OUT STD_LOGIC;
    samp: OUT STD_LOGIC
    );
end entity;

architecture behavior of vcnt is
signal cnt: std_logic_vector(width-1 downto 0);


begin
  process(clk)

    begin
      if rising_edge(clk) then
        if rst='1' then
          zf<='0';
          cnt<=(cnt'left downto 2=>'0') & "11";
        elsif ena='1' then
          zf<=cnt(1) and cnt(0) and not cnt(2);
          cnt<=cnt-'1';
          if cnt=(cnt'left downto 1=>'0') & '1' then
            cnt<=din;
            samp<='1';
          else
            samp<='0';
          end if;
        end if;
      end if;
    end process;
end architecture;