local p = {}
local getArgs = require("Module:Arguments").getArgs

local tiercolors = {
	[0] = "#cfcfcf", -- in case of overflow

	"#ff7f7f",
	"#ffbf7f",
	"#ffdf7f",
	"#ffff7f",
	"#bfff7f",
	"#7fff7f",
	"#7fffff",
	"#7fbfff",
	"#7f7fff",
	"#ff7fff",
	"#bf7fbf"
}

local function getTable(arg)
	local raw = arg
		:gsub("%s,", ",")
		:gsub(",%s", ",")
		:gsub("^,+", "")
		:gsub(",+$", "")
		:gsub(",,+", ",")

	if raw == "" then return end

	local t = {}

	for entry in string.gmatch(raw, "[^,]+") do
		table.insert(t, entry)
	end

	return t
end

function p.main(frame)
	local args = getArgs(frame)

	-- early error if no items
	if not args.items then
		error("You need to provide a list of images in the items parameter. You can separate them with commas if there is more than one")
	end

	local tiers

	if not args.tiers then
		tiers = {"S", "A", "B", "C", "D", "F"}
	else
		tiers = getTable(args.tiers)
	end

	local items = getTable(args.items)

	local tierparent = mw.html.create("div")
		:addClass("tier-list--parent")

	local tierlist = mw.html.create("div")
		:addClass("tier-list")
		:css("--item-size", args.itemsize or "85px")

    -- insert each tier
	for k,v in ipairs(tiers) do
		tierlist
			:tag("div")
				:addClass("tier-list--row")
				:tag("div")
					:addClass("tier-list--tier")
					:css("--tier-bg", k <= #tiercolors and tiercolors[k] or tiercolors[0])
					:wikitext(v)
					:done()
				:tag("div")
					:addClass("tier-list--rack")
	end

    -- watermark. Dont remove this or u die
	local watermark = mw.html.create("div")
		:addClass("tier-list--watermark")
		:wikitext("[[File:SEWH Wiki logo white horizontal.png|250px]]")
	tierlist:node(watermark)

	local untiereditems = mw.html.create("div")
		:addClass("tier-list--untiered-rack")

	for _,v in ipairs(items) do
		untiereditems
			:tag("div")
				:addClass("tier-list--item")
				:wikitext(v)
	end

    -- create a tabber for untiered items
    -- hopefully ill make it so there can be more than one
	local untieredcontainer = mw.ext.tabber.render( {
		{
			label = args.name or "Items",
			content = tostring(untiereditems)
		}
	} )

	tierparent:node(tierlist)

	return
		tostring(tierparent) ..
		tostring(mw.html.create("br")) ..
		tostring(untieredcontainer)
end

return p
