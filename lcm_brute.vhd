library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity lcm_brute is
	port(	reset	: in std_logic;
		clk	: in std_logic;
		din	: in std_logic_vector(7 downto 0);
		lcm	: out std_logic_vector(7 downto 0);
		done	: out std_logic
	);
end lcm_brute;

architecture arc_lcm_brute of lcm_brute is
	type state_type is (reset_state, load_mick, load_keith, bigger_or_smaller,
		mick_bigger, keith_bigger, test_lcm, subt, finished);
	signal state_reg, state_next : state_type;
	signal mick_reg, mick_next : std_logic_vector(7 downto 0);
	signal keith_reg, keith_next : std_logic_vector(7 downto 0);
	signal big_reg, big_next : std_logic_vector(7 downto 0);
	signal small_reg, small_next : std_logic_vector(7 downto 0);
	signal big_copy_reg, big_copy_next : std_logic_vector(7 downto 0);
	signal accum_reg, accum_next : std_logic_vector(7 downto 0);
begin
	-- The ASMD chart was converting using the four-segment description (detailed on pages 391-394 of the textbook).
	-- Control Path: State Register
	process(clk, reset)
	begin
		if reset = '1' then
			state_reg <= reset_state;
		elsif clk'event and clk = '1' then
			state_reg <= state_next;
		end if;
	end process;
	-- Control Path: Combinational Logic
	process(state_reg, big_next, accum_reg, big_copy_reg, keith_reg, mick_reg, big_reg, small_reg)
	begin
		-- Default Values
		done <= '0';
		lcm <= (others => '0');
		case state_reg is
			when reset_state =>
				state_next <= load_mick;
			when load_mick =>
				state_next <= load_keith;
			when load_keith =>
				state_next <= bigger_or_smaller;
			when bigger_or_smaller =>
				if keith_reg >= mick_reg then
					state_next <= keith_bigger;
				else
					state_next <= mick_bigger;
				end if;
			when mick_bigger =>
				state_next <= test_lcm;
			when keith_bigger =>
				state_next <= test_lcm;
			when test_lcm =>
				if big_reg = "00000000" then
					state_next <= finished;
				else
					state_next <= subt;
				end if;
			when subt =>
				if big_next < small_reg then
					state_next <= test_lcm;
				else
					state_next <= subt;
				end if;
			when finished =>
				state_next <= finished;
				done <= '1';
				lcm <= accum_reg - big_copy_reg;
		end case;
	end process;
	-- Data Path: Data Register
	-- Can easily be combined with the "Control Path: State Register" block.
	process(clk, reset)
	begin
		if reset = '1' then
			mick_reg <= (others => '0');
			keith_reg <= (others => '0');
			big_reg <= (others => '0');
			small_reg <= (others => '0');
			big_copy_reg <= (others => '0');
			accum_reg <= (others => '0');
		elsif clk'event and clk = '1' then
			mick_reg <= mick_next;
			keith_reg <= keith_next;
			big_reg <= big_next;
			small_reg <= small_next;
			big_copy_reg <= big_copy_next;
			accum_reg <= accum_next;
		end if;
	end process;
	-- Data Path: Combinational Logic
	-- Can easily be combined with the "Control Path: Combinational Logic" block.
	process(state_reg, mick_reg, keith_reg, big_reg, small_reg, big_copy_reg, accum_reg, din)
	begin
		-- Default Values
		mick_next <= mick_reg;
		keith_next <= keith_reg;
		big_next <= big_reg;
		small_next <= small_reg;
		big_copy_next <= big_copy_reg;
		accum_next <= accum_reg;
		case state_reg is
			when reset_state =>
			when load_mick =>
				mick_next <= din;
			when load_keith =>
				keith_next <= din;
			when bigger_or_smaller =>
			when mick_bigger =>
				big_next <= mick_reg;
				small_next <= keith_reg;
				big_copy_next <= mick_reg;
				accum_next <= (others => '0');
			when keith_bigger =>
				big_next <= keith_reg;
				small_next <= mick_reg;
				big_copy_next <= keith_reg;
				accum_next <= (others => '0');
			when test_lcm =>
				accum_next <= accum_reg + big_copy_reg;
				big_next <= accum_reg + big_copy_reg;
			when subt => 
				big_next <= big_reg - small_reg;
			when finished =>
		end case;
	end process;
end arc_lcm_brute;
