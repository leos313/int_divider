library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--implementing an integer division (16 bit)
--q=(int)(a/b);
--modu= (a%b)

entity divider is
  port(
    clk 	: in std_logic;
	start	: in std_logic;
	reset	: in std_logic;
    a   	: in std_logic_vector(15 downto 0);
    b   	: in std_logic_vector(15 downto 0);
    done	: out std_logic;
    q   	: out std_logic_vector(15 downto 0);
	modu	: out std_logic_vector(15 downto 0)
  );
end divider;

architecture IMP of divider is
  type FSM_states is (reset_S,idle_S,start_S);
  signal current_state: FSM_states;
  signal q_temp_out : std_logic_vector(15 downto 0);
  signal modu_temp_out : std_logic_vector(15 downto 0);
  signal cnt_signal: integer range 0 to 16;
  
begin
  process (clk,reset)
  variable a_temp : std_logic_vector(15 downto 0); --accumulator (...)
  variable cnt : integer range 0 to 16;
  begin
    if reset='1' then --async reset
		current_state<=reset_S;
		q_temp_out<=(others=>'0');--16 bit (15 downto 0)
		modu_temp_out<=(others=>'0');--16 bit (15 downto 0)
		a_temp:=(others=>'0'); --16 bit (15 downto 0)
		cnt:=0;
		cnt_signal<=cnt;
	elsif (clk'event and clk='1') then 
		if (start='1' and (current_state=idle_S or current_state=reset_S)) then --starting the division (cnt=15)
			--cnt 15
			current_state<=start_S;
			cnt:=15;
			cnt_signal<=cnt;--only DEBUG
			a_temp:="000000000000000" & a(cnt); --shift and the other bit 
			if a_temp>=b then
				q_temp_out(15)<='1';
				a_temp:=a_temp-b; --I will do the shift at the beginning of every iteration
				--modu_temp_out<=a_temp-b;--to comment later(only debug)
			end if;
			cnt:=cnt-1;
		elsif (current_state=start_S and cnt>0) then --one division step every clock
			--cnt  14,13,12,.....3,2,1
			cnt_signal<=cnt;--only DEBUG
			a_temp:=a_temp(14 downto 0) & a(cnt);
			if a_temp>=b then
				q_temp_out(cnt)<='1';
				a_temp:=a_temp-b;
				--modu_temp_out<=a_temp-b;--to comment later(only debug)
			end if;		  
            cnt:=cnt-1;
		elsif (current_state=start_S and cnt=0) then --one division step every clock
			--cnt=0
			current_state<=idle_S;
			--cnt_signal<=cnt;--only DEBUG
			a_temp:=a_temp(14 downto 0) & a(0);
			if a_temp>=b then
				q_temp_out(0)<='1';
				modu_temp_out<=a_temp-b;
			else
			    modu_temp_out<=a_temp;
			end if;		  
		end if;
	end if;
  end process;
  
  --logic for output. Moore's FSM
  done <= '1' when current_state=idle_S else '0';
  modu <= modu_temp_out when current_state=idle_S else (others=>'0');
  q <= q_temp_out when current_state=idle_S else (others=>'0');
  
end IMP;