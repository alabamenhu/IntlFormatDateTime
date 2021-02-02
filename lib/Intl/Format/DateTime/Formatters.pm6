sub EXPORT {
    #unit module Formatters;
use Intl::CLDR;
=begin pod
    Formatters are the most fundamental part of this module.
    They are currently exported as a Map to be used in C<DateTime.rakumod> where they are
    applied to pattern files.  At their core, each one is a block with three implicit
    variables ($^c, $^dt, $^tz) for Calendar, DateTime, and TimeZone.  As of Dec 2020 in
    Rakudo, implicit positionals are the fastest (and let most of these be done on a single
    line too).  For formatters that don't use them all, a quick sink is used to ensure
    the arity of the block is still 3.

    For detailed information about each formatter, see the comments by each group.
=end pod

# First we have different variables needed by formatters
# This should eventually be read in from an appropriate XML file
my %tz-code-table = BEGIN Map.new: 'Europe/Andorra', 'adalv', 'Asia/Dubai', 'aedxb', 'Asia/Kabul', 'afkbl', 'America/Antigua', 'aganu', 'America/Anguilla', 'aiaxa', 'Europe/Tirane', 'altia', 'Asia/Yerevan', 'amevn', 'America/Curacao', 'ancur', 'Africa/Luanda', 'aolad', 'Antarctica/Casey', 'aqcas', 'Antarctica/Davis', 'aqdav', 'Antarctica/DumontDUrville', 'aqddu', 'Antarctica/Mawson', 'aqmaw', 'Antarctica/McMurdo', 'aqmcm', 'Antarctica/Palmer', 'aqplm', 'Antarctica/Rothera', 'aqrot', 'Antarctica/Syowa', 'aqsyw', 'Antarctica/Troll', 'aqtrl', 'Antarctica/Vostok', 'aqvos', 'America/Buenos_Aires', 'arbue', 'America/Argentina/Buenos_Aires', 'arbue', 'America/Cordoba', 'arcor', 'America/Argentina/Cordoba', 'arcor', 'America/Rosario', 'arcor', 'America/Catamarca', 'arctc', 'America/Argentina/Catamarca', 'arctc', 'America/Argentina/ComodRivadavia', 'arctc', 'America/Argentina/La_Rioja', 'arirj', 'America/Jujuy', 'arjuj', 'America/Argentina/Jujuy', 'arjuj', 'America/Argentina/San_Luis', 'arluq', 'America/Mendoza', 'armdz', 'America/Argentina/Mendoza', 'armdz', 'America/Argentina/Rio_Gallegos', 'arrgl', 'America/Argentina/Salta', 'arsla', 'America/Argentina/Tucuman', 'artuc', 'America/Argentina/San_Juan', 'aruaq', 'America/Argentina/Ushuaia', 'arush', 'Pacific/Pago_Pago', 'asppg', 'Pacific/Samoa', 'asppg', 'US/Samoa', 'asppg', 'Europe/Vienna', 'atvie', 'Australia/Adelaide', 'auadl', 'Australia/South', 'auadl', 'Australia/Broken_Hill', 'aubhq', 'Australia/Yancowinna', 'aubhq', 'Australia/Brisbane', 'aubne', 'Australia/Queensland', 'aubne', 'Australia/Darwin', 'audrw', 'Australia/North', 'audrw', 'Australia/Eucla', 'aueuc', 'Australia/Hobart', 'auhba', 'Australia/Tasmania', 'auhba', 'Australia/Currie', 'aukns', 'Australia/Lindeman', 'auldc', 'Australia/Lord_Howe', 'auldh', 'Australia/LHI', 'auldh', 'Australia/Melbourne', 'aumel', 'Australia/Victoria', 'aumel', 'Antarctica/Macquarie', 'aumqi', 'Australia/Perth', 'auper', 'Australia/West', 'auper', 'Australia/Sydney', 'ausyd', 'Australia/ACT', 'ausyd', 'Australia/Canberra', 'ausyd', 'Australia/NSW', 'ausyd', 'America/Aruba', 'awaua', 'Asia/Baku', 'azbak', 'Europe/Sarajevo', 'basjj', 'America/Barbados', 'bbbgi', 'Asia/Dhaka', 'bddac', 'Asia/Dacca', 'bddac', 'Europe/Brussels', 'bebru', 'Africa/Ouagadougou', 'bfoua', 'Europe/Sofia', 'bgsof', 'Asia/Bahrain', 'bhbah', 'Africa/Bujumbura', 'bibjm', 'Africa/Porto-Novo', 'bjptn', 'Atlantic/Bermuda', 'bmbda', 'Asia/Brunei', 'bnbwn', 'America/La_Paz', 'bolpb', 'America/Kralendijk', 'bqkra', 'America/Araguaina', 'braux', 'America/Belem', 'brbel', 'America/Boa_Vista', 'brbvb', 'America/Cuiaba', 'brcgb', 'America/Campo_Grande', 'brcgr', 'America/Eirunepe', 'brern', 'America/Noronha', 'brfen', 'Brazil/DeNoronha', 'brfen', 'America/Fortaleza', 'brfor', 'America/Manaus', 'brmao', 'Brazil/West', 'brmao', 'America/Maceio', 'brmcz', 'America/Porto_Velho', 'brpvh', 'America/Rio_Branco', 'brrbr', 'America/Porto_Acre', 'brrbr', 'Brazil/Acre', 'brrbr', 'America/Recife', 'brrec', 'America/Sao_Paulo', 'brsao', 'Brazil/East', 'brsao', 'America/Bahia', 'brssa', 'America/Santarem', 'brstm', 'America/Nassau', 'bsnas', 'Asia/Thimphu', 'btthi', 'Asia/Thimbu', 'btthi', 'Africa/Gaborone', 'bwgbe', 'Europe/Minsk', 'bymsq', 'America/Belize', 'bzbze', 'America/Creston', 'cacfq', 'America/Edmonton', 'caedm', 'Canada/Mountain', 'caedm', 'America/Rainy_River', 'caffs', 'America/Fort_Nelson', 'cafne', 'America/Glace_Bay', 'caglb', 'America/Goose_Bay', 'cagoo', 'America/Halifax', 'cahal', 'Canada/Atlantic', 'cahal', 'America/Iqaluit', 'caiql', 'America/Moncton', 'camon', 'America/Montreal', 'camtr', 'America/Pangnirtung', 'capnt', 'America/Resolute', 'careb', 'America/Regina', 'careg', 'Canada/East-Saskatchewan', 'careg', 'Canada/Saskatchewan', 'careg', 'America/St_Johns', 'casjf', 'Canada/Newfoundland', 'casjf', 'America/Nipigon', 'canpg', 'America/Thunder_Bay', 'cathu', 'America/Toronto', 'cator', 'Canada/Eastern', 'cator', 'America/Vancouver', 'cavan', 'Canada/Pacific', 'cavan', 'America/Winnipeg', 'cawnp', 'Canada/Central', 'cawnp', 'America/Blanc-Sablon', 'caybx', 'America/Cambridge_Bay', 'caycb', 'America/Dawson', 'cayda', 'America/Dawson_Creek', 'caydq', 'America/Rankin_Inlet', 'cayek', 'America/Inuvik', 'cayev', 'America/Whitehorse', 'cayxy', 'Canada/Yukon', 'cayxy', 'America/Swift_Current', 'cayyn', 'America/Yellowknife', 'cayzf', 'America/Coral_Harbour', 'cayzs', 'America/Atikokan', 'cayzs', 'Indian/Cocos', 'cccck', 'Africa/Lubumbashi', 'cdfbm', 'Africa/Kinshasa', 'cdfih', 'Africa/Bangui', 'cfbgf', 'Africa/Brazzaville', 'cgbzv', 'Europe/Zurich', 'chzrh', 'Africa/Abidjan', 'ciabj', 'Pacific/Rarotonga', 'ckrar', 'Pacific/Easter', 'clipc', 'Chile/EasterIsland', 'clipc', 'America/Punta_Arenas', 'clpuq', 'America/Santiago', 'clscl', 'Chile/Continental', 'clscl', 'Africa/Douala', 'cmdla', 'Asia/Shanghai', 'cnsha', 'Asia/Chongqing', 'cnsha', 'Asia/Chungking', 'cnsha', 'Asia/Harbin', 'cnsha', 'PRC', 'cnsha', 'Asia/Urumqi', 'cnurc', 'Asia/Kashgar', 'cnurc', 'America/Bogota', 'cobog', 'America/Costa_Rica', 'crsjo', 'CST6CDT', 'cst6cdt', 'America/Havana', 'cuhav', 'Cuba', 'cuhav', 'Atlantic/Cape_Verde', 'cvrai', 'Indian/Christmas', 'cxxch', 'Asia/Famagusta', 'cyfmg', 'Asia/Nicosia', 'cynic', 'Europe/Nicosia', 'cynic', 'Europe/Prague', 'czprg', 'Europe/Berlin', 'deber', 'Europe/Busingen', 'debsngn', 'Africa/Djibouti', 'djjib', 'Europe/Copenhagen', 'dkcph', 'America/Dominica', 'dmdom', 'America/Santo_Domingo', 'dosdq', 'Africa/Algiers', 'dzalg', 'Pacific/Galapagos', 'ecgps', 'America/Guayaquil', 'ecgye', 'Europe/Tallinn', 'eetll', 'Africa/Cairo', 'egcai', 'Egypt', 'egcai', 'Africa/El_Aaiun', 'eheai', 'Africa/Asmera', 'erasm', 'Africa/Asmara', 'erasm', 'Africa/Ceuta', 'esceu', 'Atlantic/Canary', 'eslpa', 'Europe/Madrid', 'esmad', 'EST5EDT', 'est5edt', 'Africa/Addis_Ababa', 'etadd', 'Europe/Helsinki', 'fihel', 'Europe/Mariehamn', 'fimhq', 'Pacific/Fiji', 'fjsuv', 'Atlantic/Stanley', 'fkpsy', 'Pacific/Kosrae', 'fmksa', 'Pacific/Ponape', 'fmpni', 'Pacific/Pohnpei', 'fmpni', 'Pacific/Truk', 'fmtkk', 'Pacific/Chuuk', 'fmtkk', 'Pacific/Yap', 'fmtkk', 'Atlantic/Faeroe', 'fotho', 'Atlantic/Faroe', 'fotho', 'Europe/Paris', 'frpar', 'Africa/Libreville', 'galbv', 'Asia/Gaza', 'gaza', 'Europe/London', 'gblon', 'Europe/Belfast', 'gblon', 'GB', 'gblon', 'GB-Eire', 'gblon', 'America/Grenada', 'gdgnd', 'Asia/Tbilisi', 'getbs', 'America/Cayenne', 'gfcay', 'Europe/Guernsey', 'gggci', 'Africa/Accra', 'ghacc', 'Europe/Gibraltar', 'gigib', 'America/Danmarkshavn', 'gldkshvn', 'America/Godthab', 'glgoh', 'America/Nuuk', 'glgoh', 'America/Scoresbysund', 'globy', 'America/Thule', 'glthu', 'Africa/Banjul', 'gmbjl', 'Etc/GMT', 'gmt', 'Etc/GMT+0', 'gmt', 'Etc/GMT-0', 'gmt', 'Etc/GMT0', 'gmt', 'Etc/Greenwich', 'gmt', 'GMT', 'gmt', 'GMT+0', 'gmt', 'GMT-0', 'gmt', 'GMT0', 'gmt', 'Greenwich', 'gmt', 'Africa/Conakry', 'gncky', 'America/Guadeloupe', 'gpbbr', 'America/Marigot', 'gpmsb', 'America/St_Barthelemy', 'gpsbh', 'Africa/Malabo', 'gqssg', 'Europe/Athens', 'grath', 'Atlantic/South_Georgia', 'gsgrv', 'America/Guatemala', 'gtgua', 'Pacific/Guam', 'gugum', 'Africa/Bissau', 'gwoxb', 'America/Guyana', 'gygeo', 'Asia/Hebron', 'hebron', 'Asia/Hong_Kong', 'hkhkg', 'Hongkong', 'hkhkg', 'America/Tegucigalpa', 'hntgu', 'Europe/Zagreb', 'hrzag', 'America/Port-au-Prince', 'htpap', 'Europe/Budapest', 'hubud', 'Asia/Jayapura', 'iddjj', 'Asia/Jakarta', 'idjkt', 'Asia/Makassar', 'idmak', 'Asia/Ujung_Pandang', 'idmak', 'Asia/Pontianak', 'idpnk', 'Europe/Dublin', 'iedub', 'Eire', 'iedub', 'Europe/Isle_of_Man', 'imdgs', 'Asia/Calcutta', 'inccu', 'Asia/Kolkata', 'inccu', 'Indian/Chagos', 'iodga', 'Asia/Baghdad', 'iqbgw', 'Asia/Tehran', 'irthr', 'Iran', 'irthr', 'Atlantic/Reykjavik', 'isrey', 'Iceland', 'isrey', 'Europe/Rome', 'itrom', 'Asia/Jerusalem', 'jeruslm', 'Asia/Tel_Aviv', 'jeruslm', 'Israel', 'jeruslm', 'Europe/Jersey', 'jesth', 'America/Jamaica', 'jmkin', 'Jamaica', 'jmkin', 'Asia/Amman', 'joamm', 'Asia/Tokyo', 'jptyo', 'Japan', 'jptyo', 'Africa/Nairobi', 'kenbo', 'Asia/Bishkek', 'kgfru', 'Asia/Phnom_Penh', 'khpnh', 'Pacific/Kiritimati', 'kicxi', 'Pacific/Enderbury', 'kipho', 'Pacific/Tarawa', 'kitrw', 'Indian/Comoro', 'kmyva', 'America/St_Kitts', 'knbas', 'Asia/Pyongyang', 'kpfnj', 'Asia/Seoul', 'krsel', 'ROK', 'krsel', 'Asia/Kuwait', 'kwkwi', 'America/Cayman', 'kygec', 'Asia/Aqtau', 'kzaau', 'Asia/Aqtobe', 'kzakx', 'Asia/Almaty', 'kzala', 'Asia/Atyrau', 'kzguw', 'Asia/Qostanay', 'kzksn', 'Asia/Qyzylorda', 'kzkzo', 'Asia/Oral', 'kzura', 'Asia/Vientiane', 'lavte', 'Asia/Beirut', 'lbbey', 'America/St_Lucia', 'lccas', 'Europe/Vaduz', 'livdz', 'Asia/Colombo', 'lkcmb', 'Africa/Monrovia', 'lrmlw', 'Africa/Maseru', 'lsmsu', 'Europe/Vilnius', 'ltvno', 'Europe/Luxembourg', 'lulux', 'Europe/Riga', 'lvrix', 'Africa/Tripoli', 'lytip', 'Libya', 'lytip', 'Africa/Casablanca', 'macas', 'Europe/Monaco', 'mcmon', 'Europe/Chisinau', 'mdkiv', 'Europe/Tiraspol', 'mdkiv', 'Europe/Podgorica', 'metgd', 'Indian/Antananarivo', 'mgtnr', 'Pacific/Kwajalein', 'mhkwa', 'Kwajalein', 'mhkwa', 'Pacific/Majuro', 'mhmaj', 'Europe/Skopje', 'mkskp', 'Africa/Bamako', 'mlbko', 'Africa/Timbuktu', 'mlbko', 'Asia/Rangoon', 'mmrgn', 'Asia/Yangon', 'mmrgn', 'Asia/Choibalsan', 'mncoq', 'Asia/Hovd', 'mnhvd', 'Asia/Ulaanbaatar', 'mnuln', 'Asia/Ulan_Bator', 'mnuln', 'Asia/Macau', 'momfm', 'Asia/Macao', 'momfm', 'Pacific/Saipan', 'mpspn', 'America/Martinique', 'mqfdf', 'Africa/Nouakchott', 'mrnkc', 'America/Montserrat', 'msmni', 'MST7MDT', 'mst7mdt', 'Europe/Malta', 'mtmla', 'Indian/Mauritius', 'muplu', 'Indian/Maldives', 'mvmle', 'Africa/Blantyre', 'mwblz', 'America/Chihuahua', 'mxchi', 'America/Cancun', 'mxcun', 'America/Hermosillo', 'mxhmo', 'America/Matamoros', 'mxmam', 'America/Mexico_City', 'mxmex', 'Mexico/General', 'mxmex', 'America/Merida', 'mxmid', 'America/Monterrey', 'mxmty', 'America/Mazatlan', 'mxmzt', 'Mexico/BajaSur', 'mxmzt', 'America/Ojinaga', 'mxoji', 'America/Bahia_Banderas', 'mxpvr', 'America/Santa_Isabel', 'mxstis', 'America/Tijuana', 'mxtij', 'America/Ensenada', 'mxtij', 'Mexico/BajaNorte', 'mxtij', 'Asia/Kuching', 'mykch', 'Asia/Kuala_Lumpur', 'mykul', 'Africa/Maputo', 'mzmpm', 'Africa/Windhoek', 'nawdh', 'Pacific/Noumea', 'ncnou', 'Africa/Niamey', 'nenim', 'Pacific/Norfolk', 'nfnlk', 'Africa/Lagos', 'nglos', 'America/Managua', 'nimga', 'Europe/Amsterdam', 'nlams', 'Europe/Oslo', 'noosl', 'Asia/Katmandu', 'npktm', 'Asia/Kathmandu', 'npktm', 'Pacific/Nauru', 'nrinu', 'Pacific/Niue', 'nuiue', 'Pacific/Auckland', 'nzakl', 'Antarctica/South_Pole', 'nzakl', 'NZ', 'nzakl', 'Pacific/Chatham', 'nzcht', 'NZ-CHAT', 'nzcht', 'Asia/Muscat', 'ommct', 'America/Panama', 'papty', 'America/Lima', 'pelim', 'Pacific/Gambier', 'pfgmr', 'Pacific/Marquesas', 'pfnhv', 'Pacific/Tahiti', 'pfppt', 'Pacific/Port_Moresby', 'pgpom', 'Pacific/Bougainville', 'pgraw', 'Asia/Manila', 'phmnl', 'Asia/Karachi', 'pkkhi', 'Europe/Warsaw', 'plwaw', 'Poland', 'plwaw', 'America/Miquelon', 'pmmqc', 'Pacific/Pitcairn', 'pnpcn', 'America/Puerto_Rico', 'prsju', 'PST8PDT', 'pst8pdt', 'Atlantic/Madeira', 'ptfnc', 'Europe/Lisbon', 'ptlis', 'Portugal', 'ptlis', 'Atlantic/Azores', 'ptpdl', 'Pacific/Palau', 'pwror', 'America/Asuncion', 'pyasu', 'Asia/Qatar', 'qadoh', 'Indian/Reunion', 'rereu', 'Europe/Bucharest', 'robuh', 'Europe/Belgrade', 'rsbeg', 'Europe/Astrakhan', 'ruasf', 'Asia/Barnaul', 'rubax', 'Asia/Chita', 'ruchita', 'Asia/Anadyr', 'rudyr', 'Asia/Magadan', 'rugdx', 'Asia/Irkutsk', 'ruikt', 'Europe/Kaliningrad', 'rukgd', 'Asia/Khandyga', 'rukhndg', 'Asia/Krasnoyarsk', 'rukra', 'Europe/Samara', 'rukuf', 'Europe/Kirov', 'rukvx', 'Europe/Moscow', 'rumow', 'W-SU', 'rumow', 'Asia/Novokuznetsk', 'runoz', 'Asia/Omsk', 'ruoms', 'Asia/Novosibirsk', 'ruovb', 'Asia/Kamchatka', 'rupkc', 'Europe/Saratov', 'rurtw', 'Asia/Srednekolymsk', 'rusred', 'Asia/Tomsk', 'rutof', 'Europe/Ulyanovsk', 'ruuly', 'Asia/Ust-Nera', 'ruunera', 'Asia/Sakhalin', 'ruuus', 'Europe/Volgograd', 'ruvog', 'Asia/Vladivostok', 'ruvvo', 'Asia/Yekaterinburg', 'ruyek', 'Asia/Yakutsk', 'ruyks', 'Africa/Kigali', 'rwkgl', 'Asia/Riyadh', 'saruh', 'Pacific/Guadalcanal', 'sbhir', 'Indian/Mahe', 'scmaw', 'Africa/Khartoum', 'sdkrt', 'Europe/Stockholm', 'sesto', 'Asia/Singapore', 'sgsin', 'Singapore', 'sgsin', 'Atlantic/St_Helena', 'shshn', 'Europe/Ljubljana', 'silju', 'Arctic/Longyearbyen', 'sjlyr', 'Atlantic/Jan_Mayen', 'sjlyr', 'Europe/Bratislava', 'skbts', 'Africa/Freetown', 'slfna', 'Europe/San_Marino', 'smsai', 'Africa/Dakar', 'sndkr', 'Africa/Mogadishu', 'somgq', 'America/Paramaribo', 'srpbm', 'Africa/Juba', 'ssjub', 'Africa/Sao_Tome', 'sttms', 'America/El_Salvador', 'svsal', 'America/Lower_Princes', 'sxphi', 'Asia/Damascus', 'sydam', 'Africa/Mbabane', 'szqmn', 'America/Grand_Turk', 'tcgdt', 'Africa/Ndjamena', 'tdndj', 'Indian/Kerguelen', 'tfpfr', 'Africa/Lome', 'tglfw', 'Asia/Bangkok', 'thbkk', 'Asia/Dushanbe', 'tjdyu', 'Pacific/Fakaofo', 'tkfko', 'Asia/Dili', 'tldil', 'Asia/Ashgabat', 'tmasb', 'Asia/Ashkhabad', 'tmasb', 'Africa/Tunis', 'tntun', 'Pacific/Tongatapu', 'totbu', 'Europe/Istanbul', 'trist', 'Asia/Istanbul', 'trist', 'Turkey', 'trist', 'America/Port_of_Spain', 'ttpos', 'Pacific/Funafuti', 'tvfun', 'Asia/Taipei', 'twtpe', 'ROC', 'twtpe', 'Africa/Dar_es_Salaam', 'tzdar', 'Europe/Kiev', 'uaiev', 'Europe/Zaporozhye', 'uaozh', 'Europe/Simferopol', 'uasip', 'Europe/Uzhgorod', 'uauzh', 'Africa/Kampala', 'ugkla', 'Pacific/Wake', 'umawk', 'Pacific/Johnston', 'umjon', 'Pacific/Midway', 'ummdy', 'Etc/Unknown', 'unk', 'America/Adak', 'usadk', 'America/Atka', 'usadk', 'US/Aleutian', 'usadk', 'America/Indiana/Marengo', 'usaeg', 'America/Anchorage', 'usanc', 'US/Alaska', 'usanc', 'America/Boise', 'usboi', 'America/Chicago', 'uschi', 'US/Central', 'uschi', 'America/Denver', 'usden', 'America/Shiprock', 'usden', 'Navajo', 'usden', 'US/Mountain', 'usden', 'America/Detroit', 'usdet', 'US/Michigan', 'usdet', 'Pacific/Honolulu', 'ushnl', 'US/Hawaii', 'ushnl', 'America/Indianapolis', 'usind', 'America/Fort_Wayne', 'usind', 'America/Indiana/Indianapolis', 'usind', 'US/East-Indiana', 'usind', 'America/Indiana/Vevay', 'usinvev', 'America/Juneau', 'usjnu', 'America/Indiana/Knox', 'usknx', 'America/Knox_IN', 'usknx', 'US/Indiana-Starke', 'usknx', 'America/Los_Angeles', 'uslax', 'US/Pacific', 'uslax', 'US/Pacific-New', 'uslax', 'America/Louisville', 'uslui', 'America/Kentucky/Louisville', 'uslui', 'America/Menominee', 'usmnm', 'America/Metlakatla', 'usmtm', 'America/Kentucky/Monticello', 'usmoc', 'America/North_Dakota/Center', 'usndcnt', 'America/North_Dakota/New_Salem', 'usndnsl', 'America/New_York', 'usnyc', 'US/Eastern', 'usnyc', 'America/Indiana/Vincennes', 'usoea', 'America/Nome', 'usome', 'America/Phoenix', 'usphx', 'US/Arizona', 'usphx', 'America/Sitka', 'ussit', 'America/Indiana/Tell_City', 'ustel', 'America/Indiana/Winamac', 'uswlz', 'America/Indiana/Petersburg', 'uswsq', 'America/North_Dakota/Beulah', 'usxul', 'America/Yakutat', 'usyak', 'Etc/UTC', 'utc', 'Etc/UCT', 'utc', 'Etc/Universal', 'utc', 'Etc/Zulu', 'utc', 'UCT', 'utc', 'UTC', 'utc', 'Universal', 'utc', 'Zulu', 'utc', 'Etc/GMT-1', 'utce01', 'Etc/GMT-2', 'utce02', 'Etc/GMT-3', 'utce03', 'Etc/GMT-4', 'utce04', 'Etc/GMT-5', 'utce05', 'Etc/GMT-6', 'utce06', 'Etc/GMT-7', 'utce07', 'Etc/GMT-8', 'utce08', 'Etc/GMT-9', 'utce09', 'Etc/GMT-10', 'utce10', 'Etc/GMT-11', 'utce11', 'Etc/GMT-12', 'utce12', 'Etc/GMT-13', 'utce13', 'Etc/GMT-14', 'utce14', 'Etc/GMT+1', 'utcw01', 'Etc/GMT+2', 'utcw02', 'Etc/GMT+3', 'utcw03', 'Etc/GMT+4', 'utcw04', 'Etc/GMT+5', 'utcw05', 'EST', 'utcw05', 'Etc/GMT+6', 'utcw06', 'Etc/GMT+7', 'utcw07', 'MST', 'utcw07', 'Etc/GMT+8', 'utcw08', 'Etc/GMT+9', 'utcw09', 'Etc/GMT+10', 'utcw10', 'HST', 'utcw10', 'Etc/GMT+11', 'utcw11', 'Etc/GMT+12', 'utcw12', 'America/Montevideo', 'uymvd', 'Asia/Samarkand', 'uzskd', 'Asia/Tashkent', 'uztas', 'Europe/Vatican', 'vavat', 'America/St_Vincent', 'vcsvd', 'America/Caracas', 'veccs', 'America/Tortola', 'vgtov', 'America/St_Thomas', 'vistt', 'America/Virgin', 'vistt', 'Asia/Saigon', 'vnsgn', 'Asia/Ho_Chi_Minh', 'vnsgn', 'Pacific/Efate', 'vuvli', 'Pacific/Wallis', 'wfmau', 'Pacific/Apia', 'wsapw', 'Asia/Aden', 'yeade', 'Indian/Mayotte', 'ytmam', 'Africa/Johannesburg', 'zajnb', 'Africa/Lusaka', 'zmlun', 'Africa/Harare', 'zwhre';
my \days = <sun mon tue wed thu fri sat>;


# Next there are several support functions that are needed; stubbed so that
# formatters get the main attention in this file
sub     julian-day            { ... } # Calculates the julian date for a date
sub     iso8601-inner         { ... } # A utility sub for handling offsets in ISO 6801 format
sub     gmt-inner             { ... } # A utility sub for handling offsets in standard GMT format
sub     meta-tz               { ... } # A utility sub to get the meta timezone for an olson id (maybe should go in DateTime::Timezones)
sub     day-period-basic      { ... } # Calculates the day period, only including noon/midnight if allowed
sub     day-period-flex       { ... } # Calculates the locale-specific day period




my \formatters = Map.new:
    # The 'a' series indicate the time of day.  1..3 are identical at the moment
    'a',      { sink $^tz; $^c.day-periods.format.abbreviated{ $^dt.hour < 12 ?? 'am' !! 'pm'} },
    'aa',     { sink $^tz; $^c.day-periods.format.abbreviated{ $^dt.hour < 12 ?? 'am' !! 'pm'} },
    'aaa',    { sink $^tz; $^c.day-periods.format.abbreviated{ $^dt.hour < 12 ?? 'am' !! 'pm'} },
    'aaaa',   { sink $^tz; $^c.day-periods.format.wide{        $^dt.hour < 12 ?? 'am' !! 'pm'} },
    'aaaaa',  { sink $^tz; $^c.day-periods.format.narrow{      $^dt.hour < 12 ?? 'am' !! 'pm'} },

    # The 'A' series indicates the milliseconds-in-day, with the quantity of As
    # indicating the minimum number of digits.  60·60·24·1000 = 86_400_000, so we should
    # plan on handling up to 8.  Note that TR 35 says we maintain discontinuity with DST,
    # so it's simple math
    'A',        { sink $^c, $^tz; my $ms = ($^dt.hour * 3600000 + $^dt.minute * 60000 + $^dt.second * 1000).floor;                                                $ms },
    'AA',       { sink $^c, $^tz; my $ms = ($^dt.hour * 3600000 + $^dt.minute * 60000 + $^dt.second * 1000).floor; ($ms.chars < 2 ?? '0' x (2-$ms.chars) !! '') ~ $ms },
    'AAA',      { sink $^c, $^tz; my $ms = ($^dt.hour * 3600000 + $^dt.minute * 60000 + $^dt.second * 1000).floor; ($ms.chars < 3 ?? '0' x (3-$ms.chars) !! '') ~ $ms },
    'AAAA',     { sink $^c, $^tz; my $ms = ($^dt.hour * 3600000 + $^dt.minute * 60000 + $^dt.second * 1000).floor; ($ms.chars < 4 ?? '0' x (4-$ms.chars) !! '') ~ $ms },
    'AAAAA',    { sink $^c, $^tz; my $ms = ($^dt.hour * 3600000 + $^dt.minute * 60000 + $^dt.second * 1000).floor; ($ms.chars < 5 ?? '0' x (5-$ms.chars) !! '') ~ $ms },
    'AAAAAA',   { sink $^c, $^tz; my $ms = ($^dt.hour * 3600000 + $^dt.minute * 60000 + $^dt.second * 1000).floor; ($ms.chars < 6 ?? '0' x (6-$ms.chars) !! '') ~ $ms },
    'AAAAAAA',  { sink $^c, $^tz; my $ms = ($^dt.hour * 3600000 + $^dt.minute * 60000 + $^dt.second * 1000).floor; ($ms.chars < 7 ?? '0' x (7-$ms.chars) !! '') ~ $ms },
    'AAAAAAAA', { sink $^c, $^tz; my $ms = ($^dt.hour * 3600000 + $^dt.minute * 60000 + $^dt.second * 1000).floor; ($ms.chars < 8 ?? '0' x (8-$ms.chars) !! '') ~ $ms },

    # The 'b' series also indicates the time period of the day, but includes special indicators for noon and midnight.
    'b',      { sink $^tz; $^c.day-periods.format.abbreviated{ day-period-basic $^dt } },
    'bb',     { sink $^tz; $^c.day-periods.format.abbreviated{ day-period-basic $^dt } },
    'bbb',    { sink $^tz; $^c.day-periods.format.abbreviated{ day-period-basic $^dt } },
    'bbbb',   { sink $^tz; $^c.day-periods.format.wide{        day-period-basic $^dt } },
    'bbbbb',  { sink $^tz; $^c.day-periods.format.narrow{      day-period-basic $^dt } },

    # The 'B' series also indicates the time period of the day, but uses locale-specific periods
    'B',      { sink $^tz; $^c.day-periods.format.abbreviated{ day-period-flex $^dt } },
    'BB',     { sink $^tz; $^c.day-periods.format.abbreviated{ day-period-flex $^dt } },
    'BBB',    { sink $^tz; $^c.day-periods.format.abbreviated{ day-period-flex $^dt } },
    'BBBB',   { sink $^tz; $^c.day-periods.format.wide{        day-period-flex $^dt } },
    'BBBBB',  { sink $^tz; $^c.day-periods.format.narrow{      day-period-flex $^dt } },

    # The 'c' series gives us the day of the week.  Note that the day-of-week's number may change on locale.  In
    # English areas, Sunday is '1', but in Spanish areas, Sunday is '7'
    'c',      { sink $^tz; sink $^c;                           ~ $^dt.day-of-week   }, # TODO adjust for first day of week
    'cc',     { sink $^tz; sink $^c;                         0 ~ $^dt.day-of-week   }, # TODO adjust for first day of week
    'ccc',    { sink $^tz; $^c.days.stand-alone.abbreviated{days[$^dt.day-of-week]} },
    'cccc',   { sink $^tz; $^c.days.stand-alone.wide{       days[$^dt.day-of-week]} },
    'ccccc',  { sink $^tz; $^c.days.stand-alone.narrow{     days[$^dt.day-of-week]} },
    'cccccc', { sink $^tz; $^c.days.stand-alone.short{      days[$^dt.day-of-week]} },
    # The 'C' series indicates a numeric hour with, potentially, period of day.  It is not used in
    # direct pattern generation, rather in pattern selection.  As such, it need need not (and cannot, in fact)
    # be implemented here.

    # The 'd' series is the day of the month, with or without padding if one digit:
    'd',      { sink $^tz; sink $^c;                               ~  $^dt.day },
    'dd',     { sink $^tz; sink $^c; ($^dt.day <  10 ?? '0' !! '') ~  $^dt.day },

    # The 'D' series is the day of the year, with or without padding
    'D',      { sink $^tz; sink $^c;                                                                              ~ $^dt.day-of-year },
    'DD',     { sink $^tz; sink $^c;                                         ($^dt.day-of-year < 10 ?? '0' !! '') ~ $^dt.day-of-year },
    'DDD',    { sink $^tz; sink $^c; ($^dt.day-of-year < 100 ?? '0' !! '') ~ ($^dt.day-of-year < 10 ?? '0' !! '') ~ $^dt.day-of-year },

    # The 'e' series gives us the day of the week and is the same as the 'c' series, except that it uses
    # formatted forms (needed for some languages).  Recall the day-of-week's number may change on locale.
    'e',      { sink $^tz; sink $^c;                         ~ $^dt.day-of-week   }, # TODO adjust for first day of week
    'ee',     { sink $^tz; sink $^c;                       0 ~ $^dt.day-of-week   }, # TODO adjust for first day of week
    'eee',    { sink $^tz; $^c.days.format.abbreviated{days[$^dt.day-of-week]} },
    'eeee',   { sink $^tz; $^c.days.format.wide{       days[$^dt.day-of-week]} },
    'eeeee',  { sink $^tz; $^c.days.format.narrow{     days[$^dt.day-of-week]} },
    'eeeeee', { sink $^tz; $^c.days.format.short{      days[$^dt.day-of-week]} },

    # The 'E' series is identical to the 'E' series, except that it doesn't allow for numerical forms.
    'E',      { sink $^tz; $^c.days.format.abbreviated{days[$^dt.day-of-week]} },
    'EE',     { sink $^tz; $^c.days.format.abbreviated{days[$^dt.day-of-week]} },
    'EEE',    { sink $^tz; $^c.days.format.abbreviated{days[$^dt.day-of-week]} },
    'EEEE',   { sink $^tz; $^c.days.format.wide{       days[$^dt.day-of-week]} },
    'EEEEE',  { sink $^tz; $^c.days.format.narrow{     days[$^dt.day-of-week]} },
    'EEEEEE', { sink $^tz; $^c.days.format.short{      days[$^dt.day-of-week]} },

    # There is presently no 'f' series.
    # The 'F' series has represents the 'day of week in month'.  Basically, the week number counting from
    # the first day of the month, rather than a Sunday.
    'F',      { sink $^tz; sink $^c; $^dt.day-of-month % 7},

    # The 'g' series is the modified Julian day, based on localtime at midnight, perhaps with zero-padding.
    # There is no specific maximum, but at present time, we're in the 2million, so we hedge our bets
    # for several additional: TODO check julian calculations
    'g',         { sink $^tz; sink $^c;          ~$^dt.&julian-day                                                     },
    'gg',        { sink $^tz; sink $^c; my $jd = ~$^dt.&julian-day; ($jd.chars < 2 ?? '0' x (2-$jd.chars) !! '') ~ $jd },
    'ggg',       { sink $^tz; sink $^c; my $jd = ~$^dt.&julian-day; ($jd.chars < 3 ?? '0' x (3-$jd.chars) !! '') ~ $jd },
    'gggg',      { sink $^tz; sink $^c; my $jd = ~$^dt.&julian-day; ($jd.chars < 4 ?? '0' x (4-$jd.chars) !! '') ~ $jd },
    'ggggg',     { sink $^tz; sink $^c; my $jd = ~$^dt.&julian-day; ($jd.chars < 5 ?? '0' x (5-$jd.chars) !! '') ~ $jd },
    'gggggg',    { sink $^tz; sink $^c; my $jd = ~$^dt.&julian-day; ($jd.chars < 6 ?? '0' x (6-$jd.chars) !! '') ~ $jd },
    'ggggggg',   { sink $^tz; sink $^c; my $jd = ~$^dt.&julian-day; ($jd.chars < 7 ?? '0' x (7-$jd.chars) !! '') ~ $jd },
    'gggggggg',  { sink $^tz; sink $^c; my $jd = ~$^dt.&julian-day; ($jd.chars < 8 ?? '0' x (8-$jd.chars) !! '') ~ $jd },
    'ggggggggg', { sink $^tz; sink $^c; my $jd = ~$^dt.&julian-day; ($jd.chars < 9 ?? '0' x (9-$jd.chars) !! '') ~ $jd },

    # The 'G' series calculates the era.
    # TODO: implement non-Gregorian calendars whose eras may be quite different (Japanese is a great test case)
    'G',      { sink $^tz; $^c.eras.abbreviation{ $^dt.year > 0 ?? 1 !! 0 } },                 # See above on non-gregorian
    'GG',     { sink $^tz; $^c.eras.abbreviation{ $^dt.year > 0 ?? 1 !! 0 } },                 # See above on non-gregorian
    'GGG',    { sink $^tz; $^c.eras.abbreviation{ $^dt.year > 0 ?? 1 !! 0 } },                 # See above on non-gregorian
    'GGGG',   { sink $^tz; $^c.eras.wide{         $^dt.year > 0 ?? 1 !! 0 } },                 # See above on non-gregorian
    'GGGGG',  { sink $^tz; $^c.eras.narrow{       $^dt.year > 0 ?? 1 !! 0 } },                 # See above on non-gregorian

    # The 'h' series indicates 12-hour clocks that are 1-indexed (1..12)
    'h',      { sink $^tz; sink $^c;                                             ~ (($^dt.hour+11) % 12 + 1) }, #  1-12
    'hh',     { sink $^tz; sink $^c; ($^dt.hour = 0|10|11|12|22|23 ?? '0' !! '') ~ (($^dt.hour+11) % 12 + 1) }, # 01-12

    # The 'H' series indicates 24 hour clocks that are 0-index (0..23)
    'H',      { sink $^tz; sink $^c;                               ~ $^dt.hour }, #  0-23
    'HH',     { sink $^tz; sink $^c; ($^dt.hour < 10 ?? '0' !! '') ~ $^dt.hour }, # 00-23

    # The 'i' and 'I' series are presently undefined
    # The 'j' and 'J' series are used in input skeletons, but not for pattern data (TR35)

    # The 'k' series indicates 24 hour clocks that are 1-index (1..24)
    'k',      { sink $^tz; sink $^c;                              ~ ($^dt.hour + 1) }, #  1-24
    'kk',     { sink $^tz; sink $^c; ($^dt.hour < 9 ?? '0' !! '') ~ ($^dt.hour + 1) }, # 01-24

    # The 'K' series indicates 12 hour clocks that are 0-index (0..11)
    'K',      { sink $^tz; sink $^c;                                    ~ ($^dt.hour % 12) }, #  0-11
    'KK',     { sink $^tz; sink $^c; ($^dt.hour % 12 < 10 ?? '0' !! '') ~ ($^dt.hour % 12) }, # 00-11

    # The 'l' series is deprecated and per TR35 is to be ignored
    'l',      { sink $^tz; sink $^c; sink $^dt; '' },
    # The 'L' series shows the stand-alone month name or number (e.g. when days are not shown)
    'L',      { sink $^tz; sink $^c;                                   $^dt.month   },
    'LL',     { sink $^tz; sink $^c;  ($^dt.month < 10 ?? '0' !! '') ~ $^dt.month   },
    'LLL',    { sink $^tz;      $^c.months.stand-alone.abbreviated{    $^dt.month } },
    'LLLL',   { sink $^tz;      $^c.months.stand-alone.wide{           $^dt.month } },
    'LLLLL',  { sink $^tz;      $^c.months.stand-alone.narrow{         $^dt.month } },

    # The 'm' series indicates the minutes, with or without padding
    'm',      { sink $^tz; sink $^c;                                  $^dt.minute  },
    'mm',     { sink $^tz; sink $^c; ($^dt.minute < 10 ?? '0' !! '') ~$^dt.minute  },
    # The 'M' series indicates the formatted month name/number (e.g. when days are shown)
    'M',      { sink $^tz; sink $^c;                                  $^dt.month   },
    'MM',     { sink $^tz; sink $^c; ($^dt.month < 10 ?? '0' !! '') ~ $^dt.month   },
    'MMM',    { sink $^tz;      $^c.months.format.abbreviated{        $^dt.month } }, # for 1|2 see L
    'MMMM',   { sink $^tz;      $^c.months.format.wide{               $^dt.month } },
    'MMMMM',  { sink $^tz;      $^c.months.format.narrow{             $^dt.month } },
    # The 'n' series is presently undefined
    # The 'N' series is presently undefined
    # The 'o' series is presently undefined
    # The 'O' series indicates timezone information as GMT offset, OO and OOO are unused/reserved
    # TODO: Ensure that fallbacks for zero-format work (they currently don't).
    'O',      { sink $^c;  gmt-inner($^tz, $^dt.offset, 'short') },
    'OOOO',   { sink $^c;  gmt-inner($^tz, $^dt.offset, 'long' ) },
    # The 'p' series is presently undefined
    # The 'P' series is presently undefined
    # The 'q' series is the quarter in stand-alone form (or numerical with/without padding)
    'q',        { sink $^tz;                                       ($^dt.month + 2) div 3   },
    'qq',       { sink $^tz;                                '0' ~  ($^dt.month + 2) div 3   },
    'qqq',      { sink $^tz; $^c.quarters.stand-alone.abbreviated{ ($^dt.month + 2) div 3 } },
    'qqqq',     { sink $^tz; $^c.quarters.stand-alone.wide{        ($^dt.month + 2) div 3 } },
    'qqqqq',    { sink $^tz; $^c.quarters.stand-alone.narrow{      ($^dt.month + 2) div 3 } },
    # The 'q' series is the quarter in formatted form (or numerical with/without padding)
    'Q',        { sink $^tz;                                      ($^dt.month + 2) div 3   },
    'QQ',       { sink $^tz;                               '0' ~  ($^dt.month + 2) div 3   },
    'QQQ',      { sink $^tz;      $^cquarters.format.abbreviated{ ($^dt.month + 2) div 3 } },
    'QQQQ',     { sink $^tz;      $^cquarters.format.wide{        ($^dt.month + 2) div 3 } },
    'QQQQQ',    { sink $^tz;      $^cquarters.format.narrow{      ($^dt.month + 2) div 3 } },
    # The 'r' series indicates the gregorian year in which the current year begins, with padding
    'r',       { sink $^tz; sink $^c; my $temp = $^dt.year.Str;                                              $temp  }, # TODO calculate for solar calendar years
    'rr',      { sink $^tz; sink $^c; my $temp = $^dt.year.Str; $temp.chars > 2 ?? $temp !! (0 x (2-$temp) ~ $temp) }, # TODO calculate for solar calendar years
    'rrr',     { sink $^tz; sink $^c; my $temp = $^dt.year.Str; $temp.chars > 3 ?? $temp !! (0 x (3-$temp) ~ $temp) }, # TODO calculate for solar calendar years
    'rrrr',    { sink $^tz; sink $^c; my $temp = $^dt.year.Str; $temp.chars > 4 ?? $temp !! (0 x (4-$temp) ~ $temp) }, # TODO calculate for solar calendar years
    'rrrrr',   { sink $^tz; sink $^c; my $temp = $^dt.year.Str; $temp.chars > 5 ?? $temp !! (0 x (5-$temp) ~ $temp) }, # TODO calculate for solar calendar years
    'rrrrrr',  { sink $^tz; sink $^c; my $temp = $^dt.year.Str; $temp.chars > 6 ?? $temp !! (0 x (6-$temp) ~ $temp) }, # TODO calculate for solar calendar years
    # The 'R' series is presently undefined
    # The 's' series indicates the seconds of the current minute, with or without padding
    's',       { sink $^tz; sink $^c;                                 ~ $^dt.second.floor },
    'ss',      { sink $^tz; sink $^c; ($^dt.second < 10 ?? '0' !! '') ~ $^dt.second.floor },
    # The 'S' series indicates fractional time, truncated, but with a specific number of digits.  9 digits should be sufficient
    'S',       { sink $^tz; sink $^c; my $S = $^dt.second - $^dt.second.floor; $S = $S.Str.substr(2, 1); $S ~ ('0' x (1 - $S.chars)) },
    'SS',      { sink $^tz; sink $^c; my $S = $^dt.second - $^dt.second.floor; $S = $S.Str.substr(2, 2); $S ~ ('0' x (2 - $S.chars)) },
    'SSS',     { sink $^tz; sink $^c; my $S = $^dt.second - $^dt.second.floor; $S = $S.Str.substr(2, 3); $S ~ ('0' x (3 - $S.chars)) },
    'SSSS',    { sink $^tz; sink $^c; my $S = $^dt.second - $^dt.second.floor; $S = $S.Str.substr(2, 4); $S ~ ('0' x (4 - $S.chars)) },
    'SSSSS',   { sink $^tz; sink $^c; my $S = $^dt.second - $^dt.second.floor; $S = $S.Str.substr(2, 5); $S ~ ('0' x (5 - $S.chars)) },
    'SSSSSS',  { sink $^tz; sink $^c; my $S = $^dt.second - $^dt.second.floor; $S = $S.Str.substr(2, 6); $S ~ ('0' x (6 - $S.chars)) },
    'SSSSSSS', { sink $^tz; sink $^c; my $S = $^dt.second - $^dt.second.floor; $S = $S.Str.substr(2, 7); $S ~ ('0' x (7 - $S.chars)) },
    'SSSSSSSS',{ sink $^tz; sink $^c; my $S = $^dt.second - $^dt.second.floor; $S = $S.Str.substr(2, 8); $S ~ ('0' x (8 - $S.chars)) },
    'SSSSSSSSS',{sink $^tz; sink $^c; my $S = $^dt.second - $^dt.second.floor; $S = $S.Str.substr(2, 9); $S ~ ('0' x (9 - $S.chars)) },
    # The 't' series is presently undefined
    # The 'T' series is presently undefined
    # The 'u' series indicates the extended year numeric which is unique to each calendar system, with padding.
    # TODO: implement for other calendar systems.  Gregorian
    'u',       { sink $^tz; sink $^c; $^dt.year }, # I think this is right for Gregorian: julian 1 BC = 0; 2 BC = -1

    # The 'v' series is the generic non-location format (e.g. common use forms like "Eastern Time"). 'vv' and 'vvv' are undefinde
    # Both lengths fall back to 'VVVV', although the 'v' falls back further to short GMT
    'v',       { $^tz.metazones{meta-tz $^dt}.short{$^dt.is-dst ?? 'daylight' !! 'standard'} // formatters<VVVV>($^c, $^dt, $^tz) }, # TODO: handle further fall back to only be short GMT (e.g. O rather than OOOO like VVVV uses)
    'vvvv',    { $^tz.metazones{meta-tz $^dt}.long{ $^dt.is-dst ?? 'daylight' !! 'standard'} // formatters<VVVV>($^c, $^dt, $^tz) },

    # The 'V' series gives strong preference to the exemplar city / timezone ID.
    'V',       { sink $^c; %tz-code-table{$^dt.olson-id} // 'unk' },
    'VV',      { sink $^c, $^tz; $^dt.olson-id },
    'VVV',     { sink $^c; $^tz.zones{$^dt.olson-id}.exemplar-city // $^tz.zones<Etc/Unknown>.exemplar-city },
    'VVVV',    { sink $^c; do with $^tz.zones{$^dt.olson-id} -> $zone { $tz.region-format.generic.subst: '{0}', $zone } else { formatters<OOOO>($c, $dt, $tz) }
    },

    # The 'x' series uses the ISO8601 standard as the basis for showing the timezone
    'x',        { sink $^c, $^tz; iso8601-inner $^dt.offset                                            },
    'xx',       { sink $^c, $^tz; iso8601-inner $^dt.offset, :force-minutes                            },
    'xxx',      { sink $^c, $^tz; iso8601-inner $^dt.offset, :force-minutes,                 :extended },
    'xxxx',     { sink $^c, $^tz; iso8601-inner $^dt.offset, :force-minutes, :allow-seconds,           },
    'xxxxx',    { sink $^c, $^tz; iso8601-inner $^dt.offset, :force-minutes, :allow-seconds, :extended },

    # THe 'X' series is identical to the 'x', except that it formats as simple 'Z' if .offset == 0
    'X',        { sink $^c, $^tz; $^dt.offset == 0 ?? 'Z' !! formatters<x>(    $c, $dt, $tz) },
    'XX',       { sink $^c, $^tz; $^dt.offset == 0 ?? 'Z' !! formatters<xx>(   $c, $dt, $tz) },
    'XXX',      { sink $^c, $^tz; $^dt.offset == 0 ?? 'Z' !! formatters<xxx>(  $c, $dt, $tz) },
    'XXXX',     { sink $^c, $^tz; $^dt.offset == 0 ?? 'Z' !! formatters<xxxx>( $c, $dt, $tz) },
    'XXXXX',    { sink $^c, $^tz; $^dt.offset == 0 ?? 'Z' !! formatters<xxxxx>($c, $dt, $tz) },

    'y',        { sink $^c, $^tz; $^dt.year },
    'yy',       { sink $^c, $^tz; $^dt.year.Str.substr(*-2,2) },
    'yyy',      { sink $^c, $^tz; '0' x (3 - $^dt.year.Str.chars ) ~ $^dt.year },
    'yyyy',     { sink $^c, $^tz; '0' x (4 - $^dt.year.Str.chars ) ~ $^dt.year },
    'yyyyy',    { sink $^c, $^tz; '0' x (5 - $^dt.year.Str.chars ) ~ $^dt.year },

    # THe 'Y' series is the year, but with transitions on weeks.  Quantity of letters defines zero padding
    # except for YY, which is exactly two digits.  Examples use up to 5 digits, but raerly will need more
    # than four, so we just go to six for now.
    'Y',        { sink $^c, $^tz; $^dt.week-year },
    'YY',       { sink $^c, $^tz; $^dt.week-year.Str.substr(*-2,2) },
    'YYY',      { sink $^c, $^tz; '0' x (3 - $^dt.week-year.Str.chars ) ~ $^dt.week-year },
    'YYYY',     { sink $^c, $^tz; '0' x (4 - $^dt.week-year.Str.chars ) ~ $^dt.week-year },
    'YYYYY',    { sink $^c, $^tz; '0' x (5 - $^dt.week-year.Str.chars ) ~ $^dt.week-year },
    'YYYYY',    { sink $^c, $^tz; '0' x (6 - $^dt.week-year.Str.chars ) ~ $^dt.week-year },

    # The 'z' series is the non-location format (e.g. metazone) that distinguishes daylight savings time.
    # Fallsback to the O series based on length.  'z', 'zz', 'zzz' are intentionally identical
    # TODO: fallback not currently handled
    'z',       { sink $^c; do with $^tz.metazones{meta-tz $^dt} { $dt.is-dst ?? .short.daylight !! .short.standard } else { formatters<O>($c,$dt,$tz) } },
    'zz',      { sink $^c; $^dt.is-dst ?? $^tz.metazones{meta-tz $^dt}.short.daylight !! $^tz.metazones{meta-tz $^dt}.short.standard },
    'zzz',     { sink $^c; $^dt.is-dst ?? $^tz.metazones{meta-tz $^dt}.short.daylight !! $^tz.metazones{meta-tz $^dt}.short.standard },
    'zzzz',    { sink $^c; $^dt.is-dst ?? $^tz.metazones{meta-tz $^dt}.long.daylight  !! $^tz.metazones{meta-tz $^dt}.long.standard  },

    # The 'Z' series mimics several other ones (and <Z ZZ ZZZ> are identical), and delegates accordingly.
    # See TR 35 for details
    'Z',        { formatters<xxxx>( $^c, $^dt, $^tz) },
    'ZZ',       { formatters<xxxx>( $^c, $^dt, $^tz) },
    'ZZZ',      { formatters<xxxx>( $^c, $^dt, $^tz) },
    'ZZZZ',     { formatters<OOOO>( $^c, $^dt, $^tz) },
    'ZZZZZ',    { formatters<XXXXX>($^c, $^dt, $^tz) },
;


################
# SUPPORT SUBS #
################



# This data and associated method definitely belong somewhere else
# But since the formatter is the only one that's using it at the moment... I'm lazy
my %tz-meta := BEGIN do {
    my %tz-meta;
    for %?RESOURCES<metazones.data>.lines {
        constant DELIMITER = ',';
        my @elements = .split(DELIMITER);
        my $tz = @elements.shift;
        my @forms;
        while @elements {
            @forms.push(List.new(.shift, .shift.Int, .shift.Int)) with @elements;
        }
        %tz-meta{$tz} := @forms;
    }
    %tz-meta
}
sub meta-tz(DateTime $dt) is export(:manual) {
    CATCH {die "In order to format using a timezone name, you must load DateTime::Timezones";}
    my $olson = $dt.olson-id;
    with %tz-meta{$olson} -> @meta-list {
        my $posix = $dt.posix;
        for @meta-list -> ($name, $start, $end) {
            return $name if $start ≤ $posix < $end;
        }
    }
    $olson # Default to kicking it back.  Or should we throw?
}

#| Calculates the day-period for the locale (via $*language).
#| Priority is midnight/noon --> specific periods --> am/pm
sub day-period-flex(DateTime $dt) is export(:manual) {
    my \time = $dt.hour * 60 + $dt.minute;
    my \rules := cldr{$*language}.dates.day-period-rules.standard;

    return 'midnight' if rules.midnight.used && time == rules.midnight.at;
    return 'noon'     if rules.noon.used     && time == rules.noon.at;

    for <morning1 morning2 afternoon1 afternoon2 evening1 evening2 night1 night2> -> $period {
        my \period = rules{$period};
        next unless period.used;

        # Does the period cross midnight?
        if period.from > period.before {
            return $period
            if time ≥ period.from
                || time < period.before;
        } else {
            return $period
            if period.from ≤ time < period.before;
        }
    }

    # am and pm are guaranteed and are the fallbacks if periods don't exist
    time < 720 ?? 'am' !! 'pm';
}

#| Calculates the day-period for the locale (via $*language).
#| Priority is midnight/noon --> am/pm.  Requires midnight/noon to be localized
#| and set to exactly 0:00/12:00.
sub day-period-basic(DateTime $dt) is export(:manual) {
    my \time = $dt.hour * 60 + $dt.minute;
    my \rules := cldr{$*language}.dates.day-period-rules.standard;

    return 'midnight' if rules.midnight.used && time == rules.midnight.at ==   0;
    return 'noon'     if rules.noon.used     && time == rules.noon.at     == 720;

    # am and pm are guaranteed and are the fallbacks of periods don't exist
    time < 720 ?? 'am' !! 'pm';
}

# CALCULATION SUBS
#| Determines the Julain Day for a given date
sub julian-day (
    DateTime \d #= The DateTime used in the Julian Day calculation
                ) is export(:manual) {
    # TODO: This assumes a gregorian calendar.  Eventually, this can be made more simple
    #       by converting to a Julian calendar and then doing more simple math (but since
    #       most will use gregorian, this is probably a bit faster than doing the conversion
    #       first.
    (1461 * (d.year + 4800 + (d.month -14) div 12)) div 4
        + (367 * (d.month - 2 - 12 * ((d.month - 14) div 12))) div 12
        + (3 * ((d.year + 4900 + (d.month - 14) div 12) div 100)) div 4
        + d.day + 32075
}
#| Formats an offset into a standard GMT format for use in date/time formatting.
sub gmt-inner (
    \tz,     #= The localized timezone data
    \offset, #= The offset to format
    \length  #= The length (long: show minutes always; short: minutes only if != 0)
) is export(:manual) {
    # TODO: Check CLDR ticket #5382 to see if there is a separate short version.
    #
    # While the 'pattern' looks like a normal timepattern, based on the way that TR35
    # is written, it seems that in reality, we just treat HH:mm as a unique entity:
    #   Offset of  5h:      ±5
    #   Offset of  5h30m:   ±5:30
    #   Offset of 10h30m:  ±10:30
    #   Offset of 10h:     ±10
    # When it is "long", we should always show the full four digit form, and if seconds != 0, also those.
    # This is a relatively recent addition to the formatting standard, so things here may change, but
    # I also don't really see this one being used all that much either.

    return (tz.gmt-zero-offset // 'GMT')
    if offset == 0;

    my ($second, $minute, $hour) = offset.abs.polymod: 60,60;
    my \pattern = tz.hour-format.split(';').[offset < 0];


    if \length eq 'short' {
        tz.gmt-format.subst:
            '{0}',
            pattern
                .subst('HH', $hour)
                .subst(':mm', offset % 60 == 0 ?? ":mm" !! '')   # quickfix to chop off minutes, may not be accurate
                .subst('mm', $minute < 10 ?? "0$minute" !! ~$minute)
    } else {
        tz.gmt-format.subst:
            '{0}',
            pattern
                .subst('HH', $hour   < 10 ?? "0$hour"   !! ~$hour)
                .subst('mm', $minute < 10 ?? "0$minute" !! ~$minute)
        #.subst('ss', $minute < 10 ?? "0$second" !! ~$second) # we're supposed to magically know the format for this?
    }
}

#| Formats an offset into the ISO 8601 standard for use in date/time formatting
sub iso8601-inner (
    \offset,          #= The offset to calculate
    :$force-minutes,  #= If true, minutes will always be shown
    :$allow-seconds,  #= If true, seconds will be shown if != 0
    :$extended        #= If true, colons will be used as delimiters
) is export(:manual) {
    # The ISO 8601 format is defined as follows
    #     ± <hours> : <minutes> : <seconds>
    # The minutes and seconds are only shown if not 0 (or if $minute is true)
    # The colons are only used if $extended is true

    my $result = offset < 0 ?? '-' !! '+';

    my ($second, $minute, $hour) = offset.abs.polymod: 60,60;

    $result ~= $hour < 10 ?? "0$hour" !! ~$hour;
    $result ~= (':' if $extended) ~ $minute < 10 ?? "0$minute" !! ~$minute
    if $force-minutes
        || $minute != 0
        || $allow-seconds && $second != 0;


    # Per TR 35, using seconds is technically not correct ISO 8601, but this should be a rare
    # situation, as no modern timezones have an offset where $second != 0.
    $result ~= (':' if $extended) ~ $minute < 10 ?? "0$minute" !! ~$minute
    if $allow-seconds
        && $second != 0;

    $result;
}

    Map.new: '%formatters' => formatters;
}