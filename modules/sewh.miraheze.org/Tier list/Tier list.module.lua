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

local function remove(str, pattern)
	if type(str) ~= "string" then return "" end

	return str:gsub(pattern, "")
end

local function collectArgs(raw, defaults)
	local meta = {
		__index = function(tbl, key)
			local new = setmetatable({}, meta)
			tbl[key] = new
			return new
		end
	}
	local result = setmetatable({}, meta)

	for _,v in pairs(defaults) do
		if raw[v] then
			result[1][v] = raw[v]
		end
	end

	for k,v in pairs(raw) do
		local id = k:match("%d+$")
		if id then
			local name = remove(k, id)
			id = tonumber(id)

			result[id][name] = v
		end
	end
	
	return result
end

function p.main(frame)
	local rawargs = getArgs(frame)
	local args = collectArgs(rawargs, {
		"name", "items", "overlay"
	})

	-- early error if no items
	if not args[1].items then
		error("You need to provide a list of images in the items parameter. You can separate them with commas if there is more than one")
	end

	local tiers

	if not rawargs.tiers then
		tiers = {"S", "A", "B", "C", "D", "F"}
	else
		tiers = getTable(args.tiers)
	end

	local tierparent = mw.html.create("div")
		:addClass("tier-list--parent")

	local tierlist = mw.html.create("div")
		:addClass("tier-list")
		:css("--item-size", rawargs.itemsize or "85px")

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

	local untieredtabs = {}

	for _,v in ipairs(args) do
		local untiereditems = mw.html.create("div")
			:addClass("tier-list--untiered-rack")
		local items = getTable(v.items)

		if v.overlay then
			for _,i in ipairs(items) do
				untiereditems
					:tag("div")
						:addClass("tier-list--item")
						:wikitext(i)
						:tag("div")
							:addClass("tier-list--overlay")
							:wikitext(v.overlay)
			end
		else
			for _,i in ipairs(items) do
				untiereditems
					:tag("div")
						:addClass("tier-list--item")
						:wikitext(i)
			end
		end

		table.insert(untieredtabs, {
			label = v.name or "Items",
			content = tostring(untiereditems)
		})
	end

    -- create a tabber for untiered items
    -- hopefully ill make it so there can be more than one
	local untieredcontainer = mw.ext.tabber.render(untieredtabs)

	tierparent:node(tierlist)

	return
		tostring(tierparent) ..
		tostring(mw.html.create("br")) ..
		tostring(untieredcontainer)
end

return p
