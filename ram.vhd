library IEEE;
use IEEE.std_logic_1164.all;


entity lq_ram is
  port(clk : in std_logic;
       rst: in std_logic;
       ena : IN STD_LOGIC;
       addra : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
       dina : IN STD_LOGIC_VECTOR(55 DOWNTO 0);
       clkb : IN STD_LOGIC;
       enb : IN STD_LOGIC;
       addrb : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
       doutb : OUT STD_LOGIC_VECTOR(55 DOWNTO 0)
       );
end lq_ram;


architecture structure of lq_ram is
COMPONENT blk_mem_gen_v6_1
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(55 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(55 DOWNTO 0)
  );
END COMPONENT;
begin

ram_i1 : blk_mem_gen_v6_1
  PORT MAP (
    clka => clk,
    ena => ena,
    wea => (0=>'1'),
    addra => addra,
    dina => dina,
    clkb => clkb,
    enb => enb,
    addrb => addrb,
    doutb => doutb
  );

end architecture;

----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


entity ri_ram is
  port(
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(13 DOWNTO 0)
    );
end ri_ram;

architecture structure of ri_ram is
COMPONENT blk_mem_gen_v6_2
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(13 DOWNTO 0)
  );
END COMPONENT;

begin
  ram_i1 : blk_mem_gen_v6_2
  PORT MAP (
    clka => clk,
    ena => ena,
    wea => (0=>'1'),
    addra => addra,
    dina => dina,
    clkb => clk,
    enb => enb,
    addrb => addrb,
    doutb => doutb
  );

end architecture;

----------------------------------------------------------------------



library IEEE;
use IEEE.std_logic_1164.all;


entity cw_ram is
    PORT (
    clk : IN STD_LOGIC;
    rst : in std_logic;
    ena : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(13 DOWNTO 0)
  );
end entity;

architecture structure of cw_ram is
COMPONENT blk_mem_gen_v6_3
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(13 DOWNTO 0)
  );
END COMPONENT;
begin
  ram_i1 : blk_mem_gen_v6_3
  PORT MAP (
    clka => clk,
    ena => ena,
    wea => (0=>'1'),
    addra => addra,
    dina => dina,
    clkb => clk,
    enb => enb,
    addrb => addrb,
    doutb => doutb
  );

end architecture;

----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity mmu is 
  PORT(
    clk: in std_logic;
    ena: in std_logic;
    addr: in std_logic_vector(6 downto 0);
    dout: out std_logic_vector(4 downto 0)
  );
end entity;

architecture structure of mmu is
COMPONENT blk_mem_gen_v6_4
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
  );
END COMPONENT;
begin
  mmu_mem_i1 : blk_mem_gen_v6_4
  PORT MAP (
    clka => clk,
    ena => ena,
    addra => addr,
    douta => dout
  );

end architecture;

----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity b_rom is 
  PORT(
    clk: in std_logic;
    ena: in std_logic;
    addr: in std_logic_vector(6 downto 0);
    dout: out std_logic_vector(55 downto 0)
  );
end entity;

architecture structure of b_rom is
COMPONENT blk_mem_gen_v6_6
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(55 DOWNTO 0)
  );
END COMPONENT;
begin
  blk_mem_gen_v6_6_i1 : blk_mem_gen_v6_6
  PORT MAP (
    clka => clk,
    ena => ena,
    addra => addr,
    douta => dout
  );

end architecture;

----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity perm_rom is 
  PORT(
    clk: in std_logic;
    ena: in std_logic;
    addr: in std_logic_vector(6 downto 0);
    dout: out std_logic_vector(3 downto 0)
  );
end entity;

architecture structure of perm_rom is
COMPONENT blk_mem_gen_v6_7
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
  );
END COMPONENT;

begin
  blk_mem_gen_v6_7_i1 : blk_mem_gen_v6_7
  PORT MAP (
    clka => clk,
    ena => ena,
    addra => addr,
    douta => dout
  );

end architecture;

----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity dc_rom is 
  PORT(
    clk: in std_logic;
    ena: in std_logic;
    addr: in std_logic_vector(6 downto 0);
    dout: out std_logic_vector(2 downto 0)
  );
end entity;

architecture structure of dc_rom is
COMPONENT blk_mem_gen_v6_8
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
  );
END COMPONENT;

begin  
  blk_mem_gen_v6_8_i1 : blk_mem_gen_v6_8
  PORT MAP (
    clka => clk,
    ena => ena,
    addra => addr,
    douta => dout
  );
end architecture;