-- dekoder ldpc kodu, realizuje algoritmus
-- for l=1:I
--   for c=1:n                    
--      vi=find(H(c,:))';
--      Lq=LQ(vi)-Lr(c,vi);
--      for idx=1:length(vi)
--         v=vi(idx);
--         b=getB(H,c,v,p0,p);
--            if -codeword(v)*Lq(idx)>=b
--                Lq(idx)=-codeword(v);
--            else
--                Lq(idx)=codeword(v);
--            end
--      end
--                
--      tmp=prod(Lq);
--      for idx=1:length(vi)
--         v=vi(idx);
--         Lr(c,v)=tmp*Lq(idx);                                                                      
--         LQ(v)=LQ(v)+Lr(c,v);
--      end
-- end
--
-- dec=LQ;
-- dec(find(LQ>=0))=0;
-- dec(find(LQ<0))=1;
--
--function [b]=getB(pcm,c,v,p0,p)
--left=(1-p0)/p0;
--dc=sum(pcm(c,:));
--dv=sum(pcm(:,v));
--dv=full(dv(1,1));
--dc=full(dc(1,1));
--min=ceil((dv-1)/2);
--max=dv;
--b=max;
--for i=min:max
--    t=(1-2*p)^(dc-1);
--    right=((1+t)/(1-t))^(2*i-dv+1);
--    if left<=right
--        b=i;
--        break;
--    end
--end
--end

library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;
use work.monitor.all;

entity ldpc_dec_cu is
  port(clk                  : IN STD_LOGIC;
       rst                  : IN STD_LOGIC;
       cnt_overflow         : IN STD_LOGIC;
       cnt_rst              : OUT STD_LOGIC;
       cnt_en               : OUT STD_LOGIC;
       cnt_overflow2        : IN STD_LOGIC;
       cnt_rst2             : OUT STD_LOGIC;
       cnt_en2              : OUT STD_LOGIC;
       sc_rst               : OUT STD_LOGIC;
       sc_en                : OUT STD_LOGIC;
       lc_rst               : OUT STD_LOGIC;
       lc_en                : OUT STD_LOGIC;
       serdes_valid         : IN STD_LOGIC;
       cw_ram_ena           : OUT STD_LOGIC;
       cw_ram_enb           : OUT STD_LOGIC;
       lq_ram_ena           : OUT STD_LOGIC;
       lq_ram_enb           : OUT STD_LOGIC;
       ri_ram_ena           : OUT STD_LOGIC;
       ri_ram_enb           : OUT STD_LOGIC;
       b_rom_ena            : OUT STD_LOGIC;
       mmu_ena              : OUT STD_LOGIC;
       sample               : OUT STD_LOGIC;
       btos1_en             : OUT STD_LOGIC;
       btos1_rdy            : IN STD_LOGIC;
       cmpt                 : OUT STD_LOGIC
       );
end ldpc_dec_cu;

architecture behavior of ldpc_dec_cu is
signal stav : stav_t;
begin
  -- riadiaci automat      
  process(clk)
    begin
      if rising_edge(clk) then
        if rst='1' then
          stav <= RES;
        else
          case stav is
          when RES => stav <= STARTING;
          when STARTING => stav <= WAITING;
          when WAITING=> if serdes_valid='1' then
            stav <= STORE;
          end if;
          when STORE=> 
            if cnt_overflow2='1' then
              stav <= COMP;
            else
              stav <= WAITING;
            end if;
          when COMP => if cnt_overflow='1' then
            stav <= PUSH;
          end if;
          when PUSH => stav <= RES;
          end case;
        end if;
      end if;
    end process;
    
  process(stav)
    procedure Reset is
    begin
      sc_rst<='1';
      sc_en<='0';
      lc_rst<='1';
      lc_en<='0';
      cw_ram_ena<='0';
      cw_ram_enb<='0';
      lq_ram_ena<='0';
      lq_ram_enb<='0';
      ri_ram_ena<='0';
      ri_ram_enb<='0';
      cnt_rst<='1';
      cnt_rst2<='1';
      cnt_en<='0';
      cnt_en2<='0';
      btos1_en<='1';
      cmpt<='0';
      mmu_ena<='0';
      b_rom_ena<='0';
    end;
    procedure LdSerDes is
    begin
      cnt_rst<='0';
      cnt_rst2<='0';
      cnt_en<='1';
      cnt_en2<='0';      
      cw_ram_ena<='0';
      lq_ram_ena<='0';
      sc_en<='0';
      lc_rst<='1';
      lc_en<='0';
      mmu_ena<='0';
      b_rom_ena<='0';
    end;
    procedure LdRAM is
    begin
      cnt_en2<='1';
      sc_rst<='0';
      sc_en<='1';
      cw_ram_ena<='1';
      cw_ram_enb<='0';
      lq_ram_ena<='1';
      lq_ram_enb<='0';
    end;
    procedure LdRiLQCwPe is
    begin
      cnt_en2<='0';
      cmpt<='1';
      cw_ram_ena<='0';
      cw_ram_enb<='1';
      lq_ram_ena<='0';
      lq_ram_enb<='1';
      lc_rst<='0';
      lc_en<='1';
      b_rom_ena<='1';
      mmu_ena<='1';
--      sc_en<='1';
    end;
    procedure Push is
    begin
    end;
    begin
      case stav is
        when RES => Reset;
        when STARTING => -- nothing
        when WAITING=> LdSerDes; -- nahravanie serdes zo vstupnej bit sekvencie
        when STORE=> LdRAM; -- ulozenie vystupu serdes do pamate
        when COMP=> LdRiLQCwPe; -- spustenie ldpc algoritmu
        when PUSH => Push;
      end case;
  end process;
  
  -- monitorovacie signaly
  m_stav <= stav;
end architecture;

----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.monitor.all;

entity ldpc_dec_pu is
  port(clk                : IN STD_LOGIC;
       rst                : IN STD_LOGIC;
       din                : IN STD_LOGIC;
       dout               : OUT STD_LOGIC;
       cnt_overflow       : OUT STD_LOGIC;
       cnt_rst            : IN STD_LOGIC;
       cnt_en             : IN STD_LOGIC;
       cnt_overflow2      : OUT STD_LOGIC;
       cnt_rst2           : IN STD_LOGIC;
       cnt_en2            : IN STD_LOGIC;
       sc_rst             : IN STD_LOGIC;
       sc_en              : IN STD_LOGIC;
       lc_rst             : IN STD_LOGIC;
       lc_en              : IN STD_LOGIC;
       serdes_valid       : OUT STD_LOGIC;
       cw_ram_ena         : IN STD_LOGIC;
       cw_ram_enb         : IN STD_LOGIC;
       lq_ram_ena         : IN STD_LOGIC;
       lq_ram_enb         : IN STD_LOGIC;
       ri_ram_ena         : IN STD_LOGIC;
       ri_ram_enb         : IN STD_LOGIC;
       b_rom_ena          : IN STD_LOGIC;
       mmu_ena            : IN STD_LOGIC;
       sample             : IN STD_LOGIC;
       btos1_en           : IN STD_LOGIC;
       btos1_rdy          : OUT STD_LOGIC;
       cmpt               : IN STD_LOGIC
       );
end ldpc_dec_pu;

architecture behavior of ldpc_dec_pu is
constant width                            :integer := 14;
constant addr_width                       :integer := 5;
type st_addr_delay_t is array (1 downto 0) of std_logic_vector(addr_width-1 downto 0);
type bit_delay_t is array(15 downto 0) of std_logic_vector(width-1 downto 0);
type lq_delay_t is array(15 downto 0) of std_logic_vector(4*width-1 downto 0);
type perm_delay_t is array(15 downto 0) of std_logic_vector(3 downto 0);
type mmu_delay_t is array(15 downto 0) of std_logic_vector(4 downto 0);
type ld_addr_delay_t is array(15 downto 0) of std_logic_vector(6 downto 0);
type b_rom_delay_t is array(3 downto 0) of std_logic_vector(4*width-1 downto 0);
signal lq_delay_sr                        :lq_delay_t :=(others=>(others=>'0'));
signal st_addr                            :std_logic_vector(addr_width-1 downto 0);
signal cw_delay_sr                        :bit_delay_t :=(others=>(others=>'0'));
signal perm_sr                            :perm_delay_t :=(others=>(others=>'0'));
signal mmu_delay_sr                       :mmu_delay_t :=(others=>(others=>'0'));
signal b_rom_delay_sr                     :b_rom_delay_t:=(others=>(others=>'0'));
signal ld_addr_sr                         :ld_addr_delay_t :=(others=>(others=>'0'));
signal serdes_out,sr_delayed              :std_logic_vector(width-1 downto 0) := (others=>'0');
signal lq_addr1,delay,ri_addr1            :std_logic_vector(addr_width-1 downto 0) := (others=>'0');
signal lq_data,lq_data_reg,lq_data_reg1   :std_logic_vector(4*width-1 downto 0) := (others=>'0');
signal sample_reg, valid_s,lq_ram_ena_d,
       cw_ram_ena_d,sc_en_d,sc_rst_d      :std_logic := '0';
signal f_en                               :std_logic_vector(12 downto 0) :=(others=>'0');
signal ri_reg,
       cmpu_reg,bs_reg1,bs_reg2,cnu_reg   :std_logic_vector(width-1 downto 0) := (others=>'0');
signal lq_new_reg,
       ris,ris1,qi_reg                    :std_logic_vector(width*4-1 downto 0) := (others=>'0');
signal degc_reg                           :std_logic_vector(2 downto 0) := (others=>'0');
signal dummy                              :std_logic;
signal cnt_iter                           :std_logic_vector(2 downto 0);
signal cnt_overflow_tmp,btos2_en          :std_logic;

component serdes is
  generic(width: integer := 18);
  port(clk : in std_logic;
       rst : in std_logic;
       din : in std_logic;
       dout : out std_logic_vector(width-1 downto 0);
       valid : out std_logic
       );
end component;

component lq_ram is
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
end component;

component ri_ram is
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
end component;


component cw_ram is
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
end component;

component b_rom is 
  PORT(
    clk: in std_logic;
    ena: in std_logic;
    addr: in std_logic_vector(6 downto 0);
    dout: out std_logic_vector(55 downto 0)
  );
end component;


component btos_array is
  generic(width: integer := 14);
  port(clk: in std_logic;
       rst: in std_logic;
       en: in std_logic;
       rdy: out std_logic;
       din: in std_logic_vector(width-1 downto 0);
       dout : out std_logic_vector(width*4-1 downto 0)
       );
end component;

component cmpu is
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
end component;

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

component cnu_array is
  generic(width: integer:= 14);
  port (clk: in std_logic;
        rst: in std_logic;
        en : in std_logic;
        rdy: out std_logic;
        sample: in std_logic;
        din: in std_logic_vector(width-1 downto 0);
        dout: out std_logic_vector(width-1 downto 0)
        );
end component;


component adder_array is
  generic(width: integer := 14);
  port(clk : in std_logic;
       rst : in std_logic;
       en: in std_logic;
       rdy: out std_logic;
       din1: in std_logic_vector(width*4-1 downto 0);
       din2: in std_logic_vector(width*4-1 downto 0);
       dout: out std_logic_vector(width*4-1 downto 0)
       );
end component;

component diff_array is
  generic(width: integer := 14);
  port(clk : in std_logic;
       rst : in std_logic;
       en : in std_logic;
       rdy: out std_logic;
       din1: in std_logic_vector(width*4-1 downto 0);
       din2: in std_logic_vector(width*4-1 downto 0);
       dout: out std_logic_vector(width*4-1 downto 0)
       );
end component;

component counter is
  generic(width: integer := 4; max: integer:= 14; dao: boolean:=false);
  port(clk: in std_logic;
       rst: in std_logic;
       enable : in std_logic;
       overflow : out std_logic
       );
end component;

component pc is
  generic(width: integer:=10;max: integer:=23);
  port(clk : in std_logic;
       rst : in std_logic;
       en : in std_logic;
       dout : out std_logic_vector(width-1 downto 0)
       );
end component;

component mmu is 
  PORT(
    clk: in std_logic;
    ena: in std_logic;
    addr: in std_logic_vector(6 downto 0);
    dout: out std_logic_vector(4 downto 0)
  );
end component;
begin
  
  -- pocitadla
  --counter_i1: counter -- pocitadlo poctu hodinovych cyklov (clk ticks) iteracii ldpc dekoderu
  --  generic map(width=>7,max=>76)
  --  port map(clk=>clk,rst=>cnt_rst,enable=>cnt_en,overflow=>cnt_overflow);
  counter_i1: counter
    generic map(width=>7,max=>76,dao=>true)
    port map(clk=>clk,rst=>lc_rst,enable=>lc_en,overflow=>cnt_overflow_tmp);
  counter_i2: counter -- pocitadlo cyklov plnenia pamati (pocita sa od nuly, a po preteceni nasleduje este jeden load a store, preto 24-2)
    generic map(width=>5,max=>23)
    port map(clk=>clk,rst=>cnt_rst2,enable=>cnt_en2,overflow=>cnt_overflow2);
  pc_i1: pc -- adresa pamati ulozenia cw a lq
    generic map(width=>addr_width,max=>23)
    port map(clk=>clk,rst=>sc_rst_d,en=>sc_en_d,dout=>st_addr);
  pc_i2: pc -- adresa pamati citania ri a indexu mmu
    generic map(width=>7,max=>76)
    port map(clk=>clk,rst=>lc_rst,en=>lc_en,dout=>ld_addr_sr(0));
  ic_i1: pc -- pocitadlo iteracii ldpc dekodera
    generic map(width=>3,max=>5)
    port map(clk=>clk,rst=>lc_rst,en=>cnt_overflow_tmp,dout=>cnt_iter);
  
  cnt_overflow<='1' when cnt_iter="101" else '0';
        
  -- vstupna cast, uklada prijate bity do pamate -------------------------------
  process(clk)
    begin
      if rising_edge(clk) then
        if rst='1' then
          ld_addr_sr<=(others=>(others=>'Z'));
          cw_delay_sr<=(others=>(others=>'Z'));
          lq_delay_sr<=(others=>(others=>'Z'));
          mmu_delay_sr<=(others=>(others=>'Z'));
          ld_addr_sr<=(others=>(others=>'Z'));
          sr_delayed<=(others=>'0');
          b_rom_delay_sr<=(others=>(others=>'Z'));
          lq_ram_ena_d<='0';
          cw_ram_ena_d<='0';
          sc_en_d<='0';
          sc_rst_d<='1';
        else
          lq_ram_ena_d<=lq_ram_ena;
          cw_ram_ena_d<=cw_ram_ena;
          sc_en_d<=sc_en;
          sc_rst_d<=sc_rst;
          ld_addr_sr(ld_addr_sr'left downto 1)<=ld_addr_sr(ld_addr_sr'left-1 downto 0);
          cw_delay_sr(cw_delay_sr'left downto 1)<=cw_delay_sr(cw_delay_sr'left-1 downto 0);
          lq_delay_sr(lq_delay_sr'left downto 1)<=lq_delay_sr(lq_delay_sr'left-1 downto 0);
          mmu_delay_sr(mmu_delay_sr'left downto 1)<=mmu_delay_sr(mmu_delay_sr'left-1 downto 0);
          b_rom_delay_sr(b_rom_delay_sr'left downto 1)<=b_rom_delay_sr(b_rom_delay_sr'left-1 downto 0);
          sr_delayed<=serdes_out;
          f_en(1)<=f_en(0);
        end if;
      end if;
    end process;
  

  serdes_i1: serdes -- prevod do paralelnej formy
    generic map(width=>14)
    PORT MAP(
      clk   => clk,
      rst   => rst,
      din   => din,
      valid => serdes_valid,
      dout  => serdes_out
    );
  cw_ram_i1: cw_ram -- ukladanie do pamate codeword
    --generic map(word_length=>14,addr_width=>13)
    -- addr je skor oproti addr lq_ram o latenciu btos_array
    --port map(clk=>clk,reset=>reset,data=>cw_data_reg,addr=>,rdwr=>rdwr,req=>req,busy=>cw_busy);    
    PORT MAP (
      clk  => clk,
      rst  => rst,
      ena  => cw_ram_ena_d,
      addra=> st_addr,
      dina => sr_delayed,
      enb  => cw_ram_enb,
      addrb=> mmu_delay_sr(0),
      doutb=> cw_delay_sr(0)
    );
  btos_array_i1: btos_array -- prevod bitu na znamienkovy tvar
    PORT MAP(
      clk   => clk,
      rst   => rst,
      en    => btos1_en,
      rdy   => btos1_rdy,
      din   => serdes_out,
      dout  => lq_data
    );
  lq_ram_i1: lq_ram -- dual port pamat lq
    --generic map(word_length=>56, addr_width=>13)
    -- lq_ram addr oproti addr codeword_ram je opozdena o latanciu btos_array1 pri zapise
    PORT MAP(
     clk   => clk,
     rst   => rst,
     ena   => lq_ram_ena_d,
     addra => st_addr,
     dina  => lq_data,
     clkb  => clk,
     enb   => lq_ram_enb,
     addrb => mmu_delay_sr(0),
     doutb => lq_delay_sr(0)
    );      
      
  ri_ram_i1: ri_ram -- dual port pamat Ri
    PORT MAP(
      clk   => clk,
      rst   => rst,
      ena   => ri_ram_ena,
      addra => ld_addr_sr(14), -- tu ma byt ld_addr_reg naozaj
      dina  => bs_reg2,
      enb   => ri_ram_enb,
      addrb => ld_addr_sr(0),
      doutb => ri_reg
    );
  b_rom_i1: b_rom
    PORT MAP(
      clk   => clk,
      ena   => b_rom_ena,
      addr  => ld_addr_sr(0),
      dout  => b_rom_delay_sr(0)
    );
  mmu_i1: mmu -- mapping unit
    PORT MAP(
      clk  => clk,
      ena  => mmu_ena,
      addr => ld_addr_sr(0),
      dout => mmu_delay_sr(0)
    );

--    generic map(word_length=>14, addr_width=>13)
--    port map(clk=>clk,reset=>reset,
--      data=>ri_reg,addr=>addr,rdwr=>rdwr,req=>ri_req,busy=>ri_busy,
--      data1=>bs_reg2,addr1=>ri_addr1,rdwr1=>ri_rdwr1,req1=>ri_req1,busy1=>ri_busy1);
    
    
  -- realizacia ldpc algoritmu -------------------------------------------------
  f_en(0)<=cmpt;
  btos2_en<= '0' when cnt_iter=(cnt_iter'range=>'0') else '1';
  btos_array_i2: btos_array -- latency 1
    PORT MAP(
      clk   => clk,
      rst   => rst,
      en    => btos2_en,
      rdy   => dummy,
      din   => ri_reg,
      dout  => ris
    );
  diff_array_i1: diff_array -- latency 1
    PORT MAP(
      clk   => clk,
      rst   => rst,
      en    => f_en(1),
      rdy   => f_en(2),
      din1  => lq_delay_sr(0),
      din2  => ris,
      dout  => qi_reg
    );
  cmpu_i1: cmpu -- latency 2
    PORT MAP(
      clk   => clk,
      rst   => rst,
      en    => f_en(2),
      rdy   => f_en(3),
      cw    => cw_delay_sr(1),
      bin   => b_rom_delay_sr(3),
      qin   => qi_reg,
      dout  => cmpu_reg
    );
  barrel_shifter_i1: barrel_shifter -- latency 2
    PORT MAP(
      clk   => clk,
      rst   => rst,
      en    => f_en(3),
      rdy   => f_en(4),
      din   => cmpu_reg,
      rot   => perm_sr(4),
      dout  => bs_reg1
    );
  cnu_array_i1:cnu_array -- latency 7
    PORT MAP(
      clk   => clk,
      rst   => rst,
      en    => f_en(4),
      rdy   => f_en(5),
      din   => bs_reg1,
      dout  => cnu_reg,
      sample=> sample_reg
    );
  barrel_shifter_i2: barrel_shifter -- latency 2 -- TODO: pozor tento barrel shifter musi rotovat na opacnu stranu, PREROBIT !!!
    PORT MAP(
      clk   => clk,
      rst   => rst,
      en    => f_en(5),
      rdy   => f_en(6),
      din   => cnu_reg,
      rot   => perm_sr(13),
      dout  => bs_reg2
    );
  btos_array_i3: btos_array -- latency 1
    PORT MAP(
      clk   => clk,
      rst   => rst,
      en    => f_en(6),
      rdy   => f_en(7),
      din   => bs_reg2,
      dout  => ris1
    );
  adder_array_i1: adder_array -- latency 1
    PORT MAP(
      clk   => clk,
      rst   => rst,
      en    => f_en(7),
      rdy   => f_en(8),
      din1  => lq_delay_sr(15), 
      din2  => ris1,
      dout  => lq_data_reg1
    );
    
  -- monitor
  m_cw_data_reg <= cw_delay_sr(0);
  m_lq_data_reg <= lq_delay_sr(0);
  m_ri_reg <= ri_reg;
  m_qi_reg <= qi_reg;
  m_cmpu_reg <= cmpu_reg;
  m_bs1_en <= f_en(3);
end architecture;


library IEEE;
use IEEE.std_logic_1164.all;
use std.textio.all;
use work.data_types.all;
use work.monitor.all;
use work.txt_util.all;

entity tb_ldpc_dec is
  generic(
   T : time := 10 ns;
   ri_file_n: string:="ri.dat";
   qi_file_n: string:="qi.dat";
   din_file_n: string:="codeword.dat";
   lq_file_n: string:="codeword_lq.dat";
   mmu_file_n: string:="mmu.dat"
  );
end tb_ldpc_dec;

architecture dut of tb_ldpc_dec is

signal din,dout : std_logic :='0';

file ri_file: text OPEN read_mode is ri_file_n;
file din_file: text OPEN read_mode is din_file_n;
file lq_file: text OPEN read_mode is lq_file_n;
file mmu_file: text OPEN read_mode is mmu_file_n;
file qi_file: text OPEN read_mode is qi_file_n;


constant serdes_data : std_logic_vector(13 downto 0) := "10111110000110";
signal dec_data : std_logic_vector(0 to 335);
signal dec_lq_data : std_logic_vector(0 to 336*4-1);

type mmu_t is array (0 to 76) of integer;
signal mmu : mmu_t := (3,6,7,10,13,1,5,7,8,11,13,14,1,2,5,8,9,14,15,0,3,
6,10,15,16,3,4,10,11,12,16,17,1,2,5,8,17,18,3,4,9,10,
18,19,3,7,10,11,19,20,0,1,2,5,8,20,21,1,4,5,8,21,22,
3,6,9,10,12,22,23,0,1,5,8,12,13,23);


       
       
       signal clk                  : STD_LOGIC :='1';
       signal rst                  : STD_LOGIC :='1';
       signal cnt_overflow         : STD_LOGIC;
       signal cnt_rst              : STD_LOGIC;
       signal cnt_en               : STD_LOGIC;
       signal cnt_overflow2        : STD_LOGIC;
       signal cnt_rst2             : STD_LOGIC;
       signal cnt_en2              : STD_LOGIC;
       signal sc_rst               : STD_LOGIC;
       signal sc_en                : STD_LOGIC;
       signal lc_rst               : STD_LOGIC;
       signal lc_en                : STD_LOGIC;
       signal serdes_valid         : STD_LOGIC;
       signal cw_ram_ena           : STD_LOGIC;
       signal cw_ram_enb           : STD_LOGIC;
       signal lq_ram_ena           : STD_LOGIC;
       signal lq_ram_enb           : STD_LOGIC;
       signal ri_ram_ena           : STD_LOGIC;
       signal ri_ram_enb           : STD_LOGIC;
       signal b_rom_ena            : STD_LOGIC;
       signal mmu_ena              : STD_LOGIC;
       signal sample               : STD_LOGIC;
       signal btos1_en             : STD_LOGIC;
       signal btos1_rdy            : STD_LOGIC;
       signal cmpt                 : STD_LOGIC;

component ldpc_dec_cu is
  port(clk                  : IN STD_LOGIC;
       rst                  : IN STD_LOGIC;
       cnt_overflow         : IN STD_LOGIC;
       cnt_rst              : OUT STD_LOGIC;
       cnt_en               : OUT STD_LOGIC;
       cnt_overflow2        : IN STD_LOGIC;
       cnt_rst2             : OUT STD_LOGIC;
       cnt_en2              : OUT STD_LOGIC;
       sc_rst               : OUT STD_LOGIC;
       sc_en                : OUT STD_LOGIC;
       lc_rst               : OUT STD_LOGIC;
       lc_en                : OUT STD_LOGIC;
       serdes_valid         : IN STD_LOGIC;
       cw_ram_ena           : OUT STD_LOGIC;
       cw_ram_enb           : OUT STD_LOGIC;
       lq_ram_ena           : OUT STD_LOGIC;
       lq_ram_enb           : OUT STD_LOGIC;
       ri_ram_ena           : OUT STD_LOGIC;
       ri_ram_enb           : OUT STD_LOGIC;
       b_rom_ena            : OUT STD_LOGIC;
       mmu_ena              : OUT STD_LOGIC;
       sample               : OUT STD_LOGIC;
       btos1_en             : OUT STD_LOGIC;
       btos1_rdy            : IN STD_LOGIC;
       cmpt                 : OUT STD_LOGIC
       );
end component;

component ldpc_dec_pu is
  port(clk                : IN STD_LOGIC;
       rst                : IN STD_LOGIC;
       din                : IN STD_LOGIC;
       dout               : OUT STD_LOGIC;
       cnt_overflow       : OUT STD_LOGIC;
       cnt_rst            : IN STD_LOGIC;
       cnt_en             : IN STD_LOGIC;
       cnt_overflow2      : OUT STD_LOGIC;
       cnt_rst2           : IN STD_LOGIC;
       cnt_en2            : IN STD_LOGIC;
       sc_rst             : IN STD_LOGIC;
       sc_en              : IN STD_LOGIC;
       lc_rst             : IN STD_LOGIC;
       lc_en              : IN STD_LOGIC;
       serdes_valid       : OUT STD_LOGIC;
       cw_ram_ena         : IN STD_LOGIC;
       cw_ram_enb         : IN STD_LOGIC;
       lq_ram_ena         : IN STD_LOGIC;
       lq_ram_enb         : IN STD_LOGIC;
       ri_ram_ena         : IN STD_LOGIC;
       ri_ram_enb         : IN STD_LOGIC;
       b_rom_ena          : IN STD_LOGIC;
       mmu_ena            : IN STD_LOGIC;
       sample             : IN STD_LOGIC;
       btos1_en           : IN STD_LOGIC;
       btos1_rdy          : OUT STD_LOGIC;
       cmpt               : IN STD_LOGIC
       );
end component;


component serdes is
  generic(width: integer := 14);
  port(clk : in std_logic;
       reset : in std_logic;
       din : in std_logic;
       dout : out std_logic_vector(width-1 downto 0);
       valid : out std_logic
       );
end component;

begin
  clk <= not clk after T/2;
  
  init_data:process
    variable idx: integer:= 0;
    variable l: line;
    variable d: string(dec_data'range);
    variable lq: string(dec_lq_data'range);
--    variable qi: string(qi_data'range);
  begin
    while not endfile(din_file) loop
      readline(din_file,l);
      read(l,d);
      dec_data<=to_std_logic_vector(d);
    end loop;
    while not endfile(lq_file) loop
      readline(lq_file,l);
      read(l,lq);
      dec_lq_data<=to_std_logic_vector(lq);
    end loop;
--    while not endfile(qi_file) loop
--      readline(qi_file,l);
--      read(l,qi);
--      qi_data<=to_std_logic_vector(qi);
--    end loop;
    wait;
  end process;
  
  tb_proc: process
    variable wait_cnt : integer := 0;
    variable store_cnt : integer := 0;
    variable qi_data : std_logic_vector(13 downto 0);
    variable qi_row : string(qi_data'range);
  begin

    rst<='1';
    wait for T;
    rst<='0';
    wait for T;

    assert m_stav=RES report "Reset assert failed" severity error;
    for i in 0 to 23 loop
      wait for T/2;
      if i=0 then
        assert m_stav=STARTING report "Starting assertion violated";
        wait for T;
      end if;

      assert m_stav=WAITING report "Wait assert failed" severity error;
      if m_stav=WAITING then
        wait_cnt:=wait_cnt+1;
      end if;

      wait for 13*T;

      assert m_stav=STORE report "Store assert failed" severity error;
      if m_stav=STORE then
        store_cnt:=store_cnt+1;
      end if;
      wait for T/2;
    end loop;
    assert wait_cnt=24 report "Load count assert failed" severity error;
    assert store_cnt=24 report "Store count assert failed" severity error;
    wait for T/2;
    assert m_stav=COMP report "Comp assert failed" severity error;
    wait for T/2;
    
    -- kontrola vystupov pamati
    wait for T;
    wait for T/2;
    for i in 0 to mmu'high  loop
      assert m_cw_data_reg=dec_data( mmu(i)*14 to (mmu(i)+1)*14-1 ) report "CW ram read assertion failed";
      assert m_lq_data_reg=dec_lq_data(mmu(i)*14*4 to (mmu(i)+1)*14*4-1) report "LQ ram read assertion failed";
      if m_bs1_en='1' then
        if not endfile(qi_file) then
          str_read(qi_file,qi_row);
          qi_data:=to_std_logic_vector(qi_row);
          assert m_cmpu_reg=qi_data report "Cmpu assertion failed";
        else
          assert false report "EOF reached";
        end if;
      end if;
      wait for T;
    end loop;
    wait for T/2;
    
    wait;
  end process;

 
  process(clk,rst)
    variable ixx: integer;
    begin
      if rst='1' then
        ixx:=0;
      elsif rising_edge(clk) and (m_stav=WAITING or m_stav=STORE or m_stav=STARTING) then
        ixx:=ixx+1;
      end if;
      if ixx<=335 then
        din<=dec_data(ixx);
      end if;
    end process;



  -- instanciacia entit  
  ldpc_dec_cu1: ldpc_dec_cu
    port map(
       clk             => clk,
       rst             => rst,
       cnt_overflow    => cnt_overflow,
       cnt_rst         => cnt_rst,
       cnt_en          => cnt_en,
       cnt_overflow2   => cnt_overflow2,
       cnt_rst2        => cnt_rst2,
       cnt_en2         => cnt_en2,
       sc_rst          => sc_rst,
       sc_en           => sc_en,
       lc_rst          => lc_rst,
       lc_en           => lc_en,
       serdes_valid    => serdes_valid,
       cw_ram_ena      => cw_ram_ena,
       cw_ram_enb      => cw_ram_enb,
       lq_ram_ena      => lq_ram_ena,
       lq_ram_enb      => lq_ram_enb,
       ri_ram_ena      => ri_ram_ena,
       ri_ram_enb      => ri_ram_enb,
       b_rom_ena       => b_rom_ena,
       mmu_ena         => mmu_ena,
       sample          => sample,
       btos1_en        => btos1_en,
       btos1_rdy       => btos1_rdy,
       cmpt            => cmpt
    );
  ldpc_dec_pu1: ldpc_dec_pu
    port map(
       clk             => clk,
       rst             => rst,
       din             => din,
       dout            => dout, 
       cnt_overflow    => cnt_overflow,
       cnt_rst         => cnt_rst,
       cnt_en          => cnt_en,
       cnt_overflow2   => cnt_overflow2,
       cnt_rst2        => cnt_rst2,
       cnt_en2         => cnt_en2,
       sc_rst          => sc_rst,
       sc_en           => sc_en,
       lc_rst          => lc_rst,
       lc_en           => lc_en,
       serdes_valid    => serdes_valid,
       cw_ram_ena      => cw_ram_ena,
       cw_ram_enb      => cw_ram_enb,
       lq_ram_ena      => lq_ram_ena,
       lq_ram_enb      => lq_ram_enb,
       ri_ram_ena      => ri_ram_ena,
       ri_ram_enb      => ri_ram_enb,
       b_rom_ena       => b_rom_ena,
       mmu_ena         => mmu_ena,
       sample          => sample,
       btos1_en        => btos1_en,
       btos1_rdy       => btos1_rdy,
       cmpt            => cmpt
    );
    
end architecture;


library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;
use work.monitor.all;

entity tb_serdes is
  generic(T : time := 10 ns);
end tb_serdes;

architecture dut of tb_serdes is
signal clk,rst : std_logic:='1';
signal serdes_in : std_logic;
signal serdes_out : std_logic_vector(13 downto 0);
signal serdes_valid : std_logic;
signal sd_v : std_logic:='0';
constant serdes_data : std_logic_vector(13 downto 0) := "10111110000110";

component serdes is
  generic(width: integer := 14);
  port(clk : in std_logic;
       reset : in std_logic;
       din : in std_logic;
       dout : out std_logic_vector(width-1 downto 0);
       valid : out std_logic
       );
end component;

begin
  clk <= not clk after T/2;
  rst <= '1', '0' after T;
  serdes1: serdes
    port map(clk=>clk,reset=>rst,din=>serdes_in,dout=>serdes_out,valid=>serdes_valid);
  
  tb_proc: process

  begin    
    if rst='0' then
      for i in 13 downto 0 loop
        serdes_in<=serdes_data(i);
        wait for T;
        if i=0 then
          assert serdes_valid='1' report "Serdes valid assertion failed" severity error;
          sd_v <= sd_v or serdes_valid;
        end if;
        if i=12 and sd_v='1' then
          assert serdes_out=serdes_data report "Serdes data assertion failed" severity error;  
        end if;
      end loop;
    

    else
      wait for T;
    end if;
  end process;
  
end;