library IEEE;
use IEEE.std_logic_1164.all;
use work.data_types.all;

package monitor is
  constant width: integer := 14;
  signal m_stav : stav_t;
  signal m_cw_data_reg : std_logic_vector(width-1 downto 0);
  signal m_lq_data_reg : std_logic_vector(4*width-1 downto 0);
  signal m_ri_reg : std_logic_vector(width-1 downto 0);
  signal m_qi_reg : std_logic_vector(4*width-1 downto 0);
  signal m_cmpu_reg : std_logic_vector(width-1 downto 0);
  signal m_bs1_en : std_logic;
end package;
