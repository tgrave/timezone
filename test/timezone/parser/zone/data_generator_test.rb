require 'timezone/parser/zone/data_generator'
require 'minitest/autorun'

describe Timezone::Parser::Zone::DataGenerator do
  it 'properly parses Asia/Hebron Zion rules' do
    Timezone::Parser.zones.clear
    Timezone::Parser.rules.clear

    Timezone::Parser.rule("Rule	Zion	1940	only	-	Jun	 1	0:00	1:00	D")
    Timezone::Parser.rule("Rule	Zion	1942	1944	-	Nov	 1	0:00	0	S")
    Timezone::Parser.rule("Rule	Zion	1943	only	-	Apr	 1	2:00	1:00	D")
    Timezone::Parser.rule("Rule	Zion	1944	only	-	Apr	 1	0:00	1:00	D")
    Timezone::Parser.rule("Rule	Zion	1945	only	-	Apr	16	0:00	1:00	D")
    Timezone::Parser.rule("Rule	Zion	1945	only	-	Nov	 1	2:00	0	S")
    Timezone::Parser.rule("Rule	Zion	1946	only	-	Apr	16	2:00	1:00	D")
    Timezone::Parser.rule("Rule	Zion	1946	only	-	Nov	 1	0:00	0	S")
    Timezone::Parser.rule("Rule	Zion	1948	only	-	May	23	0:00	2:00	DD")
    Timezone::Parser.rule("Rule	Zion	1948	only	-	Sep	 1	0:00	1:00	D")
    Timezone::Parser.rule("Rule	Zion	1948	1949	-	Nov	 1	2:00	0	S")
    Timezone::Parser.rule("Rule	Zion	1949	only	-	May	 1	0:00	1:00	D")

    Timezone::Parser.zone('Zone	Asia/Hebron	2:20:23	-	LMT	1900 Oct')
    Timezone::Parser.zone('2:00	Zion	EET	1948 May 15')

    zones = Timezone::Parser::Zone.generate('Asia/Hebron')

    assert_equal 12, zones.count

    assert_equal -377705116800000, zones[0].start_date
    assert_equal -2185410023000, zones[0].end_date
    assert !zones[0].dst
    assert_equal 8423, zones[0].offset
    assert_equal 'LMT', zones[0].name

    assert_equal "-9999-01-01T00:00:00Z", JSON.parse(zones[0].to_json)['_from']
    assert_equal "1900-09-30T21:39:37Z", JSON.parse(zones[0].to_json)['_to']

    assert_equal -2185410023000, zones[1].start_date
    assert_equal -933645600000, zones[1].end_date
    assert !zones[1].dst
    assert_equal 7_200, zones[1].offset
    assert_equal 'EET', zones[1].name

    assert_equal -933645600000, zones[2].start_date
    assert_equal -857358000000, zones[2].end_date
    assert zones[2].dst
    assert_equal 10_800, zones[2].offset
    assert_equal 'EET', zones[2].name

    assert_equal -857358000000, zones[3].start_date
    assert_equal -844300800000, zones[3].end_date
    assert !zones[3].dst
    assert_equal 7_200, zones[3].offset
    assert_equal 'EET', zones[3].name

    assert_equal -844300800000, zones[4].start_date
    assert_equal -825822000000, zones[4].end_date
    assert zones[4].dst
    assert_equal 10_800, zones[4].offset
    assert_equal 'EET', zones[4].name
  end

  it 'properly parses Asia/Nicosia' do
    Timezone::Parser.zones.clear
    Timezone::Parser.rules.clear

    Timezone::Parser.rule("Rule	Cyprus	1975	only	-	Apr	13	0:00	1:00	S")
    Timezone::Parser.rule("Rule	Cyprus	1975	only	-	Oct	12	0:00	0	-")
    Timezone::Parser.rule("Rule	Cyprus	1976	only	-	May	15	0:00	1:00	S")
    Timezone::Parser.rule("Rule	Cyprus	1976	only	-	Oct	11	0:00	0	-")
    Timezone::Parser.rule("Rule	Cyprus	1977	1980	-	Apr	Sun>=1	0:00	1:00	S")
    Timezone::Parser.rule("Rule	Cyprus	1977	only	-	Sep	25	0:00	0	-")
    Timezone::Parser.rule("Rule	Cyprus	1978	only	-	Oct	2	0:00	0	-")
    Timezone::Parser.rule("Rule	Cyprus	1979	1997	-	Sep	lastSun	0:00	0	-")
    Timezone::Parser.rule("Rule	Cyprus	1981	1998	-	Mar	lastSun	0:00	1:00	S")
    Timezone::Parser.rule("Rule	EUAsia	1981	max	-	Mar	lastSun	 1:00u	1:00	S")
    Timezone::Parser.rule("Rule	EUAsia	1979	1995	-	Sep	lastSun	 1:00u	0	-")
    Timezone::Parser.rule("Rule	EUAsia	1996	max	-	Oct	lastSun	 1:00u	0	-")

    Timezone::Parser.zone('Zone	Asia/Nicosia	2:13:28 -	LMT	1921 Nov 14')
    Timezone::Parser.zone('			2:00	Cyprus	EE%sT	1998 Sep')
    Timezone::Parser.zone('			2:00	EUAsia	EE%sT')


    zones = Timezone::Parser::Zone.generate('Asia/Nicosia')

    assert zones[-2].dst
    assert_equal 10_800, zones[-2].offset
    assert_equal 2531955600000, zones[-2].start_date
    assert_equal 2550704400000, zones[-2].end_date
    assert_equal 'EEST', zones[-2].name

    assert !zones.last.dst
    assert_equal 7_200, zones.last.offset
    assert_equal 2550704400000, zones.last.start_date
    assert_equal 253402300799000, zones.last.end_date
    assert_equal 'EET', zones.last.name

    assert_equal 154, zones.count
  end

  it 'properly parses negative times' do
    Timezone::Parser.zones.clear
    Timezone::Parser.rules.clear

    Timezone::Parser.zone('Zone	Africa/Abidjan	-0:16:08 -	LMT	1912')
    Timezone::Parser.zone('0:00	-	GMT')

    zones = Timezone::Parser::Zone.generate('Africa/Abidjan')

    assert_equal zones.count, 2

    assert_equal zones[0].name, 'LMT'
    assert_equal zones[0].offset, -968
    assert_equal zones[0].dst, false
    assert_equal zones[0].end_date, -1830383032000

    assert_equal zones[1].name, 'GMT'
    assert_equal zones[1].offset, 0
    assert_equal zones[1].dst, false
  end

  it 'properly parses GMT' do
    Timezone::Parser.zones.clear
    Timezone::Parser.rules.clear

    Timezone::Parser.zone('Zone  Etc/GMT+12  -12 - GMT+12')

    zones = Timezone::Parser::Zone.generate('Etc/GMT+12')

    assert_equal zones[0].offset, -43200
    assert_equal zones[0].name, 'GMT+12'
  end

  it 'properly parses rule only zones' do
    Timezone::Parser.zones.clear
    Timezone::Parser.rules.clear

    Timezone::Parser.rule('Rule	US	1918	1919	-	Mar	lastSun	2:00	1:00	D')
    Timezone::Parser.rule('Rule	US	1918	1919	-	Oct	lastSun	2:00	0	S')
    Timezone::Parser.rule('Rule	US	1942	only	-	Feb	9	2:00	1:00	W # War')
    Timezone::Parser.rule('Rule	US	1945	only	-	Aug	14	23:00u	1:00	P # Peace')
    Timezone::Parser.rule('Rule	US	1945	only	-	Sep	30	2:00	0	S')
    Timezone::Parser.rule('Rule	US	1967	2006	-	Oct	lastSun	2:00	0	S')
    Timezone::Parser.rule('Rule	US	1967	1973	-	Apr	lastSun	2:00	1:00	D')
    Timezone::Parser.rule('Rule	US	1974	only	-	Jan	6	2:00	1:00	D')
    Timezone::Parser.rule('Rule	US	1975	only	-	Feb	23	2:00	1:00	D')
    Timezone::Parser.rule('Rule	US	1976	1986	-	Apr	lastSun	2:00	1:00	D')
    Timezone::Parser.rule('Rule	US	1987	2006	-	Apr	Sun>=1	2:00	1:00	D')
    Timezone::Parser.rule('Rule	US	2007	max	-	Mar	Sun>=8	2:00	1:00	D')
    Timezone::Parser.rule('Rule	US	2007	max	-	Nov	Sun>=1	2:00	0	S')

    Timezone::Parser.zone('Zone	PST8PDT		 -8:00	US	P%sT')

    zones = Timezone::Parser::Zone.generate('PST8PDT')

    assert_equal zones[0].offset, -28800
    assert_equal zones[0].name, 'PT'

    assert_equal zones[1].offset, -25200
    assert_equal zones[1].name, 'PDT'
  end

  it 'parses morocco rules' do
    Timezone::Parser.zones.clear
    Timezone::Parser.rules.clear
    Timezone::Parser.rule('Rule	Morocco	2011	only	-	Jul	31	 0	0	-')
  end
end
