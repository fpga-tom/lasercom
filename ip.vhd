library IEEE;
use IEEE.std_logic_1164.all;

entity cnu is
  generic(width: integer:=7);
  port(clk : in std_logic;
       reset : in std_logic;
       din : in std_logic;
       dout : out std_logic;
       sample : in std_logic
       );
end cnu;

architecture behavior of cnu is
signal acc : std_logic :='0';
signal sr : std_logic_vector(width-1 downto 0);
signal z1,z2,zout,sel : std_logic := '0';
signal counter : std_logic_vector(width-1 downto 0) := (width-1 downto 1 =>'0') & '1';
begin
  process(clk,reset)
    begin
    if reset='1' then
        sr <= (others=>'0');
        acc <= '0';
    elsif rising_edge(clk) then

        sr(width-2 downto 0) <= sr(width-1 downto 1);
        sr(width-1) <= din;
        counter(width-1 downto 1) <= counter(width-2 downto 0);
        counter(0) <= counter(width-1);
        if counter(0) = '1' then
          case sel is
            when '0' => zout <= z1;
            when '1' => zout <= z2;
            when others => zout <= '0';
          end case;
        end if;
        
        if sample='1' then
          case sel is
            when '0' => z2 <= acc;
            when '1' => z1 <= acc;
            when others  => zout <= '0';
          end case;
          acc <= '0';
        else
          acc <= acc xor din;
        end if;
        dout <= zout xor sr(0);
    end if;
  end process;
end architecture; 

----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity btos is
  generic(width: integer:=4);
  port(clk : in std_logic;
       reset: in std_logic;
       din: in std_logic;
       dout: out std_logic_vector(width-1 downto 0)
       );
end btos;

architecture behavior of btos is
begin
  process(clk)
    begin
      if reset='1' then
          dout <= (others=>'0');
      elsif rising_edge(clk) then
          case din is
            when '0' => dout <= (width-1 downto 1=>'0') & '1';
            when '1' => dout <= (others=>'1');
            when others => dout <= (others=>'0');
          end case;
      end if;
    end process;
end architecture; 

----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity btos_array is
  generic(width: integer := 14);
  port(clk: in std_logic;
       reset: in std_logic;
       din: in std_logic_vector(width-1 downto 0);
       dout : out std_logic_vector(width*4-1 downto 0)
       );
end btos_array;

architecture structure of btos_array is
component btos is
  generic(width: integer:=4);
  port(clk : in std_logic;
       reset: in std_logic;
       din: in std_logic;
       dout: out std_logic_vector(width-1 downto 0)
       );
end component;
begin
  l1: for i in 0 to width-1 generate
    b1 : btos
      port map(clk=>clk,reset=>reset,din=>din(i),dout=>dout((i+1)*4-1 downto i*4));
  end generate;
end architecture;

----------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity adder is
  generic(width: integer:=4);
  port(clk : in std_logic;
       reset: in std_logic;
       din1: in std_logic_vector(width-1 downto 0);
       din2: in std_logic_vector(width-1 downto 0);
       dout: out std_logic_vector(width-1 downto 0)
       );
end adder;

architecture behavior of adder is
begin
  process(clk,reset)
    begin
      if reset='1' then
          dout <= (others=>'0');
      elsif rising_edge(clk) then
          dout <= din1+din2;
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
       reset : in std_logic;
       din1: in std_logic_vector(width*4-1 downto 0);
       din2: in std_logic_vector(width*4-1 downto 0);
       dout: out std_logic_vector(width*4-1 downto 0)
       );
end adder_array;

architecture structure of adder_array is
component adder is
  generic(width: integer:=4);
  port(clk : in std_logic;
       reset: in std_logic;
       din1: in std_logic_vector(width-1 downto 0);
       din2: in std_logic_vector(width-1 downto 0);
       dout: out std_logic_vector(width-1 downto 0)
       );
end component;
begin
  da1 : for i in 0 to width-1 generate
    d1: adder
      port map(clk=>clk,reset=>reset,din1=>din1((i+1)*4-1 downto i*4),din2=>din2((i+1)*4-1 downto i*4),dout=>dout((i+1)*4-1 downto i*4));
  end generate;
end architecture;

----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity diff is
  generic(width: integer:=4);
  port(clk : in std_logic;
       reset: in std_logic;
       din1: in std_logic_vector(width-1 downto 0);
       din2: in std_logic_vector(width-1 downto 0);
       dout: out std_logic_vector(width-1 downto 0)
       );
end diff;

architecture behavior of diff is
begin
  process(clk,reset)
    begin
      if reset='1' then
          dout <= (others=>'0');
      elsif rising_edge(clk) then
          dout <= din1-din2;
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
       reset : in std_logic;
       din1: in std_logic_vector(width*4-1 downto 0);
       din2: in std_logic_vector(width*4-1 downto 0);
       dout: out std_logic_vector(width*4-1 downto 0)
       );
end diff_array;

architecture structure of diff_array is
component diff is
  generic(width: integer:=4);
  port(clk : in std_logic;
       reset: in std_logic;
       din1: in std_logic_vector(width-1 downto 0);
       din2: in std_logic_vector(width-1 downto 0);
       dout: out std_logic_vector(width-1 downto 0)
       );
end component;
begin
  da1 : for i in 0 to width-1 generate
    d1: diff
      port map(clk=>clk,reset=>reset,din1=>din1((i+1)*4-1 downto i*4),din2=>din2((i+1)*4-1 downto i*4),dout=>dout((i+1)*4-1 downto i*4));
  end generate;
end architecture;

----------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity pc is
  generic(width: integer:=10);
  port(clk : in std_logic;
       reset : in std_logic;
       dout : out std_logic_vector(width-1 downto 0)
       );
end pc;

architecture behavior of pc is
signal counter: std_logic_vector(width-1 downto 0);
begin
  process(clk,reset)
    begin
      if reset='1' then
          counter <= (others=>'0');
          dout  <= (others=>'0');
      elsif rising_edge(clk) then
          counter <= counter + '1';
          dout <= counter;
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
       reset: in std_logic;
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
signal memory : memory_tt;
begin
  process(clk,reset)
    begin
      if reset='1' then
          data <= (others=>'0');
          busy <= '0';
      elsif rising_edge(clk) then
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
       reset: in std_logic;
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
signal memory : memory_tt;
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
  process(clk,reset)
    begin
      if reset='1' then
          data <= (others=>'0');
--          busy <= '0';
      elsif rising_edge(clk) then
          if req='1' and rdwr='1' then
              data <= memory(to_integer(unsigned(addr)));
--              busy <= '0';
          elsif req1='1' and rdwr1='1' then
              memory(to_integer(unsigned(addr))) <= data;
--              busy1 <= '0';
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
       reset : in std_logic;
       codeword: in std_logic;
       b : in std_logic_vector(width-1 downto 0);
       lq : in std_logic_vector(width-1 downto 0);
       dout : out std_logic
       );
end entity;

architecture behavior of vnu is

begin
  process(clk,reset)
    variable ncodeword : std_logic :='0';
    variable lqt : std_logic_vector(width-1 downto 0) := (others=>'0');
    begin
      if reset='1' then
          dout <= '0';
      elsif rising_edge(clk) then
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
    end process;
end architecture; 

----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity serdes is
  generic(width: integer := 18);
  port(clk : in std_logic;
       reset : in std_logic;
       din : in std_logic;
       dout : out std_logic_vector(width-1 downto 0);
       valid : out std_logic
       );
end entity;

architecture behavior of serdes is
signal data : std_logic_vector(width-1 downto 0);
signal counter : std_logic_vector(4 downto 0);
type stav1_t is (RST,FILL);
type stav2_t is (RST,FILLING,DATA_VALID);
signal stav1 : stav1_t;
signal stav2 : stav2_t;
begin
  process(clk,reset)
    begin
      if reset='1' then
        stav1 <= RST;
      elsif rising_edge(clk) then
        case stav1 is
          when RST => stav1 <= FILL;
          when FILL => stav1 <= FILL;
        end case;
      end if;
    end process;
    
-- TODO: prerobit    process(stav1'transaction)
    process(stav1)
      procedure Reset is
      begin
        data <= (others=>'0');
        
      end;
      
      procedure Fill is
      begin
        data(0) <= din;
        data(width-1 downto 1) <= data(width-2 downto 0);
      end;
      
      begin
        case stav1 is
          when RST => Reset;
          when FILL => Fill;
        end case;
      end process;
      
    process(clk,reset)
      begin
        if reset='1' then
          stav2 <= RST;
        elsif rising_edge(clk) then
          case stav2 is
            when RST => stav2 <= FILLING;
            when FILLING => 
              if counter=(width-1 downto 0=>'0') then
                stav2 <= DATA_VALID;
              end if;
            when DATA_VALID => stav2 <= FILLING;
          end case;
        end if;
      end process;
    
-- TODO: prerobit    process(stav2'transaction)
    process(stav2)
      procedure CounterInit is
      begin
        counter <= std_logic_vector(to_unsigned(width,5));
      end;
            
      procedure CounterDec is
      begin
        counter <= counter - '1';
      end;
      
      procedure ValidDeassert is
      begin
        valid <= '0';
      end;
      
      procedure ValidAssert is
      begin
        valid <= '1';
        dout <= data;
      end;
      
      procedure Reset is
      begin
        dout <= (others=>'0');
        ValidDeassert;
        CounterInit;
      end;
      
      begin
        case stav2 is
          when RST => Reset;
          when FILLING => ValidDeassert; CounterDec;
          when DATA_VALID => ValidAssert; CounterInit;
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
       reset : in std_logic;
       cw : in std_logic_vector(width-1 downto 0);
       bin : in std_logic_vector(width*4-1 downto 0);
       qin : in std_logic_vector(width*4-1 downto 0);
       dout : out std_logic_vector(width-1 downto 0)
       );
end cmpu;

architecture behavior of cmpu is
signal qi_tmp : std_logic_vector(width*4-1 downto 0);
begin
  q : for i in 0 to width-1 generate
    process(clk,reset)
      begin
        if reset='1' then
          qi_tmp((i+1)*4-1 downto i*4)<=(others=>'0');
        elsif rising_edge(clk) then
           if cw(i)='0' then
              qi_tmp((i+1)*4-1 downto i*4)<=-qin((i+1)*4-1 downto i*4);
           else
              qi_tmp((i+1)*4-1 downto i*4)<=qin((i+1)*4-1 downto i*4);
          end if;
        end if;
      end process;
  end generate;
  
  q1 : for i in 0 to width-1 generate
    process(clk,reset)
      begin
        if reset='1' then
          dout(i)<='0';
        elsif rising_edge(clk) then
          if qi_tmp((i+1)*4-1 downto i*4)>=bin((i+1)*4-1 downto i*4) then
            dout(i)<=not cw(i);
          else
            dout(i)<=cw(i);
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
  generic(width: integer := 4; max: integer:= 14);
  port(clk: in std_logic;
       reset: in std_logic;
       enable : in std_logic;
       overflow : out std_logic
       );
end counter;

architecture behavior of counter is
signal val : std_logic_vector(width-1 downto 0);
begin
  process(clk,reset)
    begin
      if reset='1' then
        val<=(others=>'0');
        overflow<='0';
      elsif rising_edge(clk) and enable='1' then
        val<=val+'1';
        if val=std_logic_vector(to_unsigned(max,width)) then
          overflow<='1';
          val<=(others=>'0');
        end if;
      end if;
    end process;
end behavior;