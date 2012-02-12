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
  port(clk : in std_logic;
       reset : in std_logic;
       cnt_overflow: in std_logic;
       cnt_reset: out std_logic;
       cnt_enable: out std_logic;
       cnt_overflow2: in std_logic;
       cnt_reset2: out std_logic;
       cnt_enable2: out std_logic;
       pc_reset: out std_logic;
       pc_en: out std_logic;
       valid: in std_logic;
       rdwr: out std_logic;
       req: out std_logic;
       cw_busy: in std_logic;
       lq_busy: in std_logic;
       lq_req: out std_logic;
       lq_busy1: in std_logic;
       lq_req1: out std_logic;
       lq_rdwr1: out std_logic;
       lq_rdwr: out std_logic;
       sample: out std_logic;
       ri_req: out std_logic;
       ri_busy: in std_logic;
       ri_req1: out std_logic;
       ri_busy1: in std_logic;
       ri_rdwr1: out std_logic
       );
end ldpc_dec_cu;

architecture behavior of ldpc_dec_cu is
signal stav : stav_t;
begin
  -- riadiaci automat      
  process(clk,reset)
    begin
      if reset='1' then
        stav <= RES;
      elsif rising_edge(clk) then
        case stav is
        when RES => stav <= STARTING;
        when STARTING => stav <= LOAD;
        when LOAD=> if valid='1' then
          stav <= STORE;
        end if;
        when STORE=> if cw_busy='0' and lq_busy='0' then
          if cnt_overflow2='1' then
            stav <= COMP;
          else
            stav <= LOAD;
          end if;
        end if;
        when COMP => if cnt_overflow='1' then
          stav <= PUSH;
        end if;
        when PUSH => stav <= RES;
        end case;
      end if;
    end process;
    
  process(stav)
    procedure Reset is
    begin
      pc_reset<='1';
      pc_en<='0';
      rdwr<='0';
      req<='0';
      cnt_reset<='1';
      cnt_reset2<='1';
      cnt_enable<='0';
      cnt_enable2<='0';
    end;
    procedure LdSerDes is
    begin
      cnt_reset<='0';
      cnt_reset2<='0';
      cnt_enable<='1';
      cnt_enable2<='0';      
      req<='0';
      lq_req<='0';
      lq_req1<='0';
      ri_req<='0';
      ri_req1<='0';
      pc_en<='0';
    end;
    procedure LdRAM is
    begin
      cnt_enable2<='1';
      pc_reset<='0';
      req<='1';
      rdwr<='0';
      lq_req<='1';
      lq_rdwr<='0';
      pc_en<='1';
    end;
    procedure LdRiLQCwPe is
    begin
      req<='0';
      rdwr<='1';
      lq_rdwr1<='0';
      ri_rdwr1<='0';
      ri_req1<='1';
      lq_req1<='1';
      cnt_enable2<='0';
    end;
    procedure Push is
    begin
    end;
    begin
      case stav is
        when RES => Reset;
        when STARTING => pc_en<='1';pc_reset<='0';
        when LOAD=> LdSerDes; -- nahravanie serdes zo vstupnej bit sekvencie
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
  port(clk : in std_logic;
       reset : in std_logic;
       din : in std_logic;
       dout : out std_logic;
       cnt_overflow: out std_logic;
       cnt_reset: in std_logic;
       cnt_enable: in std_logic;
       cnt_overflow2: out std_logic;
       cnt_reset2: in std_logic;
       cnt_enable2: in std_logic;
       pc_reset: in std_logic;
       pc_en: in std_logic;
       valid: out std_logic;
       rdwr: in std_logic;
       req: in std_logic;
       cw_busy: out std_logic;
       lq_busy: out std_logic;
       lq_req: in std_logic;
       lq_busy1: out std_logic;
       lq_req1: in std_logic;
       lq_rdwr1: in std_logic;
       lq_rdwr: in std_logic;
       sample: in std_logic;
       ri_req: in std_logic;
       ri_busy: out std_logic;
       ri_req1: in std_logic;
       ri_busy1: out std_logic;
       ri_rdwr1: in std_logic
       );
end ldpc_dec_pu;

architecture behavior of ldpc_dec_pu is

constant width                            :integer := 14;
constant addr_width                       :integer := 13;
signal serdes_out,cw_data_reg             :std_logic_vector(width-1 downto 0) := (others=>'0');
signal addr,lq_addr1,delay,ri_addr1       :std_logic_vector(addr_width-1 downto 0) := (others=>'0');
signal lq_data,lq_data_reg,lq_data_reg1   :std_logic_vector(4*width-1 downto 0) := (others=>'0');
signal sample_reg                         :std_logic := '0';
signal ri_reg,cw_reg,
       cmpu_reg,bs_reg1,bs_reg2,cnu_reg   :std_logic_vector(width-1 downto 0) := (others=>'0');
signal lq_reg,lq_new_reg,lq_delay_reg,
       ris,ris1,qi_reg                    :std_logic_vector(width*4-1 downto 0) := (others=>'0');
signal perm_reg,perm_reg1,perm_reg2       :std_logic_vector(3 downto 0) := (others=>'0');
signal degc_reg                           :std_logic_vector(2 downto 0) := (others=>'0');
signal b_reg                              :std_logic_vector(width*4-1 downto 0) := (others=>'0');

component serdes is
  generic(width: integer := 18);
  port(clk : in std_logic;
       reset : in std_logic;
       din : in std_logic;
       dout : out std_logic_vector(width-1 downto 0);
       valid : out std_logic
       );
end component;

component ram is
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
end component;

component dpram is
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
end component;

component btos is
  generic(width: integer:=4);
  port(clk : in std_logic;
       reset: in std_logic;
       din: in std_logic;
       dout: out std_logic_vector(width-1 downto 0)
       );
end component;

component btos_array is
  generic(width: integer := 14);
  port(clk: in std_logic;
       reset: in std_logic;
       din: in std_logic_vector(width-1 downto 0);
       dout : out std_logic_vector(width*4-1 downto 0)
       );
end component;

component cmpu is
  generic(width : integer := 14);
  port(clk : in std_logic;
       reset : in std_logic;
       cw : in std_logic_vector(width-1 downto 0);
       bin : in std_logic_vector(width*4-1 downto 0);
       qin : in std_logic_vector(width*4-1 downto 0);
       dout : out std_logic_vector(width-1 downto 0)
       );
end component;

component barrel_shifter is
  generic(width : integer := 14);
  port( clk : in std_logic;
        reset: in std_logic;
        din : in std_logic_vector(width-1 downto 0);
        rot : in std_logic_vector(3 downto 0);
        dout : out std_logic_vector(width-1 downto 0)
        );
end component;

component cnu is
  generic(width: integer:=7);
  port(clk : in std_logic;
       reset : in std_logic;
       din : in std_logic;
       dout : out std_logic;
       sample : in std_logic
       );
end component;

component adder_array is
  generic(width: integer := 14);
  port(clk : in std_logic;
       reset : in std_logic;
       din1: in std_logic_vector(width*4-1 downto 0);
       din2: in std_logic_vector(width*4-1 downto 0);
       dout: out std_logic_vector(width*4-1 downto 0)
       );
end component;

component diff_array is
  generic(width: integer := 14);
  port(clk : in std_logic;
       reset : in std_logic;
       din1: in std_logic_vector(width*4-1 downto 0);
       din2: in std_logic_vector(width*4-1 downto 0);
       dout: out std_logic_vector(width*4-1 downto 0)
       );
end component;

component counter is
  generic(width: integer := 4; max: integer:= 14);
  port(clk: in std_logic;
       reset: in std_logic;
       enable : in std_logic;
       overflow : out std_logic
       );
end component;

component pc is
  generic(width: integer:=10);
  port(clk : in std_logic;
       reset : in std_logic;
       en : in std_logic;
       dout : out std_logic_vector(width-1 downto 0)
       );
end component;

begin
  
  -- pocitadla
  counter1: counter -- pocitadlo poctu hodinovych cyklov (clk ticks) iteracii ldpc dekoderu
    generic map(width=>13,max=>6000)
    port map(clk=>clk,reset=>cnt_reset,enable=>cnt_enable,overflow=>cnt_overflow);
  counter2: counter -- pocitadlo cyklov plnenia pamati (pocita sa od nuly, a po preteceni nasleduje este jeden load a store, preto 24-2)
    generic map(width=>5,max=>23)
    port map(clk=>clk,reset=>cnt_reset2,enable=>cnt_enable2,overflow=>cnt_overflow2);
  pc1: pc -- generator adresy
    generic map(width=>addr_width)
    port map(clk=>clk,reset=>pc_reset,en=>pc_en,dout=>addr);

        
  -- vstupna cast, uklada prijate bity do pamate -------------------------------
  delay<=addr;
  
  -- arbiter pre codeword_ram
  process(rdwr)
    begin
      if rdwr='1' then
        cw_data_reg<=serdes_out;
      end if;
  end process;
  serdes1: serdes -- prevod do paralelnej formy
    generic map(width=>14)
    port map(clk=>clk,reset=>reset,din=>din,valid=>valid,dout=>serdes_out);
  codeword_ram: ram -- ukladanie do pamate codeword
    generic map(word_length=>14,addr_width=>13)
    -- addr je skor oproti addr lq_ram o latenciu btos_array
    port map(clk=>clk,reset=>reset,data=>cw_data_reg,addr=>delay,rdwr=>rdwr,req=>req,busy=>cw_busy);
  btos_array1: btos_array -- prevod bitu na znamienkovy tvar
    port map(clk=>clk,reset=>reset,din=>serdes_out,dout=>lq_data);
  lq_ram: dpram -- dual port pamat lq
    generic map(word_length=>56, addr_width=>13)
    -- lq_ram addr oproti addr codeword_ram je opozdena o latanciu btos_array1
    port map(clk=>clk,reset=>reset,
      data=>lq_data_reg,addr=>addr,rdwr=>rdwr,req=>req,busy=>lq_busy,
      data1=>lq_data_reg1,addr1=>lq_addr1,rdwr1=>lq_rdwr1,req1=>lq_req1,busy1=>lq_busy1);
  ri_ram: dpram -- dual port pamat Ri
    generic map(word_length=>14, addr_width=>13)
    port map(clk=>clk,reset=>reset,
      data=>ri_reg,addr=>addr,rdwr=>rdwr,req=>ri_req,busy=>ri_busy,
      data1=>bs_reg2,addr1=>ri_addr1,rdwr1=>ri_rdwr1,req1=>ri_req1,busy1=>ri_busy1);
    
    
  -- realizacia ldpc algoritmu -------------------------------------------------
  btos_array2: btos_array
    port map(clk=>clk,reset=>reset,din=>ri_reg,dout=>ris);
  diff_array1: diff_array
    port map(clk=>clk,reset=>reset,din1=>lq_reg,din2=>ris,dout=>qi_reg);
  cmpu1: cmpu
    port map(clk=>clk,reset=>reset,cw=>cw_reg,bin=>b_reg,qin=>qi_reg,dout=>cmpu_reg);
  barrel_shifter1: barrel_shifter
    port map(clk=>clk,reset=>reset,din=>cmpu_reg,rot=>perm_reg1,dout=>bs_reg1);
  g1: for i in 0 to width-1 generate
    cnu1: cnu
      port map(clk=>clk,reset=>reset,din=>bs_reg1(i),dout=>cnu_reg(i),sample=>sample_reg);
  end generate;
  barrel_shifter2: barrel_shifter -- TODO: pozor tento barrel shifter musi rotovat na opacnu stranu, PREROBIT !!!
    port map(clk=>clk,reset=>reset,din=>cnu_reg,rot=>perm_reg2,dout=>bs_reg2);
  btos_array3: btos_array
    port map(clk=>clk,reset=>reset,din=>bs_reg2,dout=>ris1);
  adder_array1: adder_array
    port map(clk=>clk,reset=>reset,din1=>lq_delay_reg,din2=>ris1,dout=>lq_data_reg1);
    
  -- monitor
  m_cw_data_reg <= cw_data_reg;
end architecture;


library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;
use work.monitor.all;

entity tb_ldpc_dec is
  generic(T : time := 10 ns);
end tb_ldpc_dec;

architecture dut of tb_ldpc_dec is
signal clk : std_logic := '1';
signal rst : std_logic := '1';
signal din,dout : std_logic :='0';


signal idx : integer :=335;  

constant serdes_data : std_logic_vector(13 downto 0) := "10111110000110";
constant dec_data : std_logic_vector(336 downto 0) :="0100101110111110010000110010110001000000110100110101111100100111000101100000100100101110101110100000001011100011011110011000000101111101011000110110101000010100010001010101000111011111010010011010110111100011011111110000000111110010111001110010010010101100000010101011001101011011111000111010001000001111111101111010011111010111111111001";

signal cnt_overflow,
       cnt_reset,
       cnt_enable,
       cnt_overflow2,
       cnt_reset2,
       cnt_enable2,
       pc_reset,
       pc_en,
       valid,
       rdwr,
       req,
       cw_busy,
       lq_busy,
       lq_req,
       lq_busy1,
       lq_req1,
       lq_rdwr1,
       lq_rdwr,
       sample,
       ri_req,
       ri_busy,
       ri_req1,
       ri_busy1,
       ri_rdwr1: std_logic;

component ldpc_dec_cu is
  port(clk : in std_logic;
       reset : in std_logic;
       cnt_overflow: in std_logic;
       cnt_reset: out std_logic;
       cnt_enable: out std_logic;
       cnt_overflow2: in std_logic;
       cnt_reset2: out std_logic;
       cnt_enable2: out std_logic;
       pc_reset: out std_logic;
       pc_en: out std_logic;
       valid: in std_logic;
       rdwr: out std_logic;
       req: out std_logic;
       cw_busy: in std_logic;
       lq_busy: in std_logic;
       lq_req: out std_logic;
       lq_busy1: in std_logic;
       lq_req1: out std_logic;
       lq_rdwr1: out std_logic;
       lq_rdwr: out std_logic;
       sample: out std_logic;
       ri_req: out std_logic;
       ri_busy: in std_logic;
       ri_req1: out std_logic;
       ri_busy1: in std_logic;
       ri_rdwr1: out std_logic
       );
end component;

component ldpc_dec_pu is
  port(clk : in std_logic;
       reset : in std_logic;
       din : in std_logic;
       dout : out std_logic;
       cnt_overflow: out std_logic;
       cnt_reset: in std_logic;
       cnt_enable: in std_logic;
       cnt_overflow2: out std_logic;
       cnt_reset2: in std_logic;
       cnt_enable2: in std_logic;
       pc_reset: in std_logic;
       pc_en: in std_logic;
       valid: out std_logic;
       rdwr: in std_logic;
       req: in std_logic;
       cw_busy: out std_logic;
       lq_busy: out std_logic;
       lq_req: in std_logic;
       lq_busy1: out std_logic;
       lq_req1: in std_logic;
       lq_rdwr1: in std_logic;
       lq_rdwr: in std_logic;
       sample: in std_logic;
       ri_req: in std_logic;
       ri_busy: out std_logic;
       ri_req1: in std_logic;
       ri_busy1: out std_logic;
       ri_rdwr1: in std_logic
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
  
  tb_proc: process
    variable load_cnt : integer := 0;
    variable store_cnt : integer := 0;
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

      assert m_stav=LOAD report "Load assert failed" severity error;
      if m_stav=LOAD then
        load_cnt:=load_cnt+1;
      end if;

      wait for 13*T;

      assert m_stav=STORE report "Store assert failed" severity error;
      if m_stav=STORE then
        store_cnt:=store_cnt+1;
      end if;
      wait for T/2;
    end loop;
    assert load_cnt=24 report "Load count assert failed" severity error;
    assert store_cnt=24 report "Store count assert failed" severity error;
    wait for T/2;
    assert m_stav=COMP report "Comp assert failed" severity error;
    wait for T/2;
    
    -- kontrola vystupov pamati
    
    
    wait;
  end process;

 
  process(clk,rst)
    begin
      if rst='1' then
        idx<=336;
      elsif rising_edge(clk) and (m_stav=LOAD or m_stav=STORE or m_stav=STARTING) then
        din<=dec_data(idx);
        idx<=idx-1;
      end if;
    end process;



  -- instanciacia entit  
  ldpc_dec_cu1: ldpc_dec_cu
    port map(
       clk=>clk,
       reset=>rst,
       cnt_overflow=>cnt_overflow,
       cnt_reset=>cnt_reset,
       cnt_enable=>cnt_enable,
       cnt_overflow2=>cnt_overflow2,
       cnt_reset2=>cnt_reset2,
       cnt_enable2=>cnt_enable2,
       pc_reset=>pc_reset,
       pc_en=>pc_en,
       valid=>valid,
       rdwr=>rdwr,
       req=>req,
       cw_busy=>cw_busy,
       lq_busy=>lq_busy,
       lq_req=>lq_req,
       lq_busy1=>lq_busy1,
       lq_req1=>lq_req1,
       lq_rdwr1=>lq_rdwr1,
       lq_rdwr=>lq_rdwr,
       sample=>sample,
       ri_req=>ri_req,
       ri_busy=>ri_busy,
       ri_req1=>ri_req1,
       ri_busy1=>ri_busy1,
       ri_rdwr1=>ri_rdwr1
    );
  ldpc_dec_pu1: ldpc_dec_pu
    port map(
       clk=>clk,
       reset=>rst,
       din=>din,
       dout=>dout,
       cnt_overflow=>cnt_overflow,
       cnt_reset=>cnt_reset,
       cnt_enable=>cnt_enable,
       cnt_overflow2=>cnt_overflow2,
       cnt_reset2=>cnt_reset2,
       cnt_enable2=>cnt_enable2,
       pc_reset=>pc_reset,
       pc_en=>pc_en,
       valid=>valid,
       rdwr=>rdwr,
       req=>req,
       cw_busy=>cw_busy,
       lq_busy=>lq_busy,
       lq_req=>lq_req,
       lq_busy1=>lq_busy1,
       lq_req1=>lq_req1,
       lq_rdwr1=>lq_rdwr1,
       lq_rdwr=>lq_rdwr,
       sample=>sample,
       ri_req=>ri_req,
       ri_busy=>ri_busy,
       ri_req1=>ri_req1,
       ri_busy1=>ri_busy1,
       ri_rdwr1=>ri_rdwr1
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