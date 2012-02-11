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
use IEEE.std_logic_unsigned.all;

entity ldpc_decoder is
  port(clk : in std_logic;
       reset : in std_logic;
       din : in std_logic;
       dout : out std_logic_vector(14*4-1 downto 0)
       );
end ldpc_decoder;

architecture behavior of ldpc_decoder is
type stav_t is (RES,LOAD,STORE,COMP,PUSH);
signal stav : stav_t;
constant width                            :integer := 14;
constant addr_width                       :integer := 13;
signal serdes_out,serdes_out_reg          :std_logic_vector(width-1 downto 0);
signal addr,lq_addr1,delay,ri_addr1       :std_logic_vector(addr_width-1 downto 0) := (others=>'0');
signal lq_data,lq_data_reg,lq_data_reg1   :std_logic_vector(4*width-1 downto 0);
signal cw_busy,lq_busy,lq_req,lq_busy1,
       lq_req1, lq_rdwr1,
       lq_rdwr,valid,sample_reg,
       cnt_enable,req,rdwr,
       cnt_overflow, cnt_reset,pc_reset,
       cnt_reset2,cnt_overflow2,
       cnt_enable2,ri_req,ri_busy,
       ri_req1,ri_busy1,ri_rdwr1          :std_logic;
signal ri_reg,cw_reg,
       cmpu_reg,bs_reg1,bs_reg2,cnu_reg   :std_logic_vector(width-1 downto 0);
signal lq_reg,lq_new_reg,lq_delay_reg,
       ris,ris1,qi_reg                    :std_logic_vector(width*4-1 downto 0);
signal perm_reg,perm_reg1,perm_reg2       :std_logic_vector(3 downto 0);
signal degc_reg                           :std_logic_vector(2 downto 0);
signal b_reg                              :std_logic_vector(width*4-1 downto 0);

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
       dout : out std_logic_vector(width-1 downto 0)
       );
end component;

begin
  -- riadiaci automat
  process(clk,reset) 
    begin
      if reset='1' then
        addr<=(others=>'0');
      elsif rising_edge(clk) then
        addr <= addr+1;
      end if;
    end process;
 counter1: counter
    generic map(width=>13,max=>6000)
    port map(clk=>clk,reset=>cnt_reset,enable=>cnt_enable,overflow=>cnt_overflow);
  counter2: counter
    generic map(width=>5,max=>24)
    port map(clk=>clk,reset=>cnt_reset2,enable=>cnt_enable2,overflow=>cnt_overflow2);
  pc1: pc
    generic map(width=>addr_width)
    port map(clk=>clk,reset=>pc_reset,dout=>addr);
  process(clk,reset)
    begin
      if reset='1' then
        stav <= RES;
      elsif rising_edge(clk) then
        case stav is
        when RES => stav <= LOAD;
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
      req<='0';
    end;
    procedure LdSerDes is
    begin

      cnt_enable<='1';
      req<='0';
    end;
    procedure LdRAM is
    begin
--      cnt_enable='0';
      pc_reset<='0';
      req<='1';
      rdwr<='0';
    end;
    procedure LdRiLQCwPe is
    begin
      req<='1';
      rdwr<='1';
      lq_rdwr1<='0';
      ri_rdwr1<='0';
      ri_req1<='1';
      lq_req1<='1';
    end;
    procedure Push is
    begin
    end;
    begin
      case stav is
        when RES => Reset;
        when LOAD=> LdSerDes; -- nahravanie serdes zo vstupnej bit sekvencie
        when STORE=> LdRAM; -- ulozenie vystupu serdes do pamate
        when COMP=> LdRiLQCwPe; -- spustenie ldpc algoritmu
        when PUSH => Push;
      end case;
  end process;
        
  -- vstupna cast, uklada prijate bity do pamate -------------------------------
  delay<=addr;
  serdes1: serdes -- prevod do paralelnej formy
    generic map(width=>14)
    port map(clk=>clk,reset=>reset,din=>din,valid=>valid,dout=>serdes_out);
  codeword_ram: ram -- ukladanie do pamate codeword
    generic map(word_length=>14,addr_width=>13)
    -- addr je skor oproti addr lq_ram o latenciu btos_array
    port map(clk=>clk,reset=>reset,data=>serdes_out_reg,addr=>delay,rdwr=>rdwr,req=>req,busy=>cw_busy);
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
end architecture;
