save_to_local_storage = ->
	window.localStorage["gc2.savefile"] = sstr_to_b64(export_save())

hexstr = "0123456789abcdef"
bitmap = {
	"0": "0000",
	"1": "0001",
	"2": "0010",
	"3": "0011",
	"4": "0100",
	"5": "0101",
	"6": "0110",
	"7": "0111",
	"8": "1000",
	"9": "1001",
	"a": "1010",
	"b": "1011",
	"c": "1100",
	"d": "1101",
	"e": "1110",
	"f": "1111"
};

bitfield_to_sstr = (bitfield) ->

	output = ""

	while bitfield.length % 8 != 0
		bitfield += "0"

	len = bitfield.length / 8
	lenstr = "" + len

	for i in [1..(lenstr.length)]
		output += "`"

	output += lenstr

	for a in [0..(bitfield.length - 1)] by 4
		output += hexstr[parseInt(bitfield.substr(a, 4), 2)]

	return output


sstr_to_bitfield = (sstr) ->

	output = ""

	len = 0

	for char in sstr
		if(char == "`")
			len += 1
		else if(len > 0)
			len -= 1
		else
			output += bitmap[char]

	return output


export_save = ->

	d01_version = "0.10"

	d02_savetime = "" + new Date().getTime()

	d03_basedata = [
		if basedata.game_started then repr_sstr(basedata.play_time) else "-1",
		repr_sstr(basedata.total_play_time),
		repr_sstr(Math.floor(basedata.goomies)),
		repr_sstr(Math.floor(basedata.total_goomies)),
		repr_sstr(Math.floor(basedata.total_total_goomies)),
		repr_sstr(basedata.clicks),
		repr_sstr(basedata.total_clicks)
		# GPS, EXPPS, and GPC are recalculable, and so are not included here.
	].join("|")

	d04_goomystats = [
		repr_sstr(Math.floor(goomy.exp)),
		repr_sstr(Math.floor(sliggoo.exp)),
		repr_sstr(Math.floor(goodra.exp))
	].join("|")

	d05_generators = (->
		gen_stats = []
		for generator in generators
			gen_stat_string = [generator.count, generator.level].join(",")
			gen_stats.push(gen_stat_string)
		return gen_stats.join("|")
	)()

	d06_upgrades = (->
		upgrade_bought = ""
		upgrade_unlocked = ""
		for i in [1..200]
			if item_ids[i] and item_ids[i].bought
				upgrade_bought += "1"
			else
				upgrade_bought += "0"
			if item_ids[i] and !item_ids[i].locked
				upgrade_unlocked += "1"
			else
				upgrade_unlocked += "0"
		return bitfield_to_sstr(upgrade_unlocked) + "|" + bitfield_to_sstr(upgrade_bought)
	)()

	return [d01_version, d02_savetime, d03_basedata, d04_goomystats, d05_generators, d06_upgrades].join("||")
