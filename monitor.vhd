library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;

package monitor is
  constant width              : integer := 14;
  signal m_stav               : stav_t;
  signal m_cw_data_reg        : std_logic_vector(width-1 downto 0);
  signal m_lq_data_reg        : std_logic_vector(4*width-1 downto 0);
  signal m_ri_reg             : std_logic_vector(width-1 downto 0);
  signal m_qi_reg             : std_logic_vector(4*width-1 downto 0);
  signal m_cmpu_reg           : std_logic_vector(width-1 downto 0);
  signal m_bs1_en             : std_logic;
  signal m_bs1_reg            : std_logic_vector(width-1 downto 0);
  signal m_bs2_en             : std_logic;
  signal m_bs2_reg            : std_logic_vector(width-1 downto 0);
  signal m_cnu_en             : std_logic;
  signal m_cnu_reg            : std_logic_vector(width-1 downto 0);
  signal m_btos3_en           : std_logic;
  signal m_btos3_reg          : std_logic_vector(4*width-1 downto 0);
  signal m_add_i1_en          : std_logic;
  signal m_add_i1_rdy         : std_logic;
  signal m_lq_a_reg           : std_logic_vector(4*width-1 downto 0);
end package;
