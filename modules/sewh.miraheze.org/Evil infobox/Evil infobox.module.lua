-- still a wip

local frm = mw.getCurrentFrame()
local getArgs = require("Module:Arguments").getArgs
require("Module:Mw.html extension")

-- helper functions
local function error(message)
    local error = mw.html.create("strong")
        :addClass("error")
        :wikitext(message)

    return error
end

local function is(val, expected)
    return type(val) == expected
end

local function remove(str, pattern)
    if not is(str, "string") then
        return str
    end

    return str:gsub(pattern, "")
end



-- components
local Components = {}

function Components.row(infobox, args)
    local row = mw.html.create("tr")
        :addClass("infobox-row")
        :th {
            args[1] or "No heading..."
        }
        :td {
            args[2] or "No data..."
        }
        :allDone()
        :addClasses(args.class)
        :addCss(args.css)

    return row
end

function Components.title(infobox, args)
    local title = mw.html.create("tr")
        :addClass("infobox-title")
        :th {
            args[1] or "No title...",
            attr = {colspan = 2},
            css = {
                ["-webkit-text-stroke"] = "4px black",
                ["paint-order"] = "stroke fill"
            }
        }
        :allDone()
        :addClasses(args.class)
        :addCss(args.css)

    return title
end

function Components.subtitle(infobox, args)
    local subtitle = mw.html.create("tr")
        :addClass("infobox-subtitle")
        :th {
            args[1] or "No subtitle...",
            attr = {colspan = 2},
            css = {
                ["-webkit-text-stroke"] = "4px black",
                ["paint-order"] = "stroke fill"
            }
        }
        :allDone()
        :addClasses(args.class)
        :addCss(args.css)

    return subtitle
end

function Components.header(infobox, args)
    local header = mw.html.create("tr")
        :addClass("infobox-header")
        :th {
            args[1] or "No heading...",
            attr = {colspan = 2},
            css = {
                ["-webkit-text-stroke"] = "4px black",
                ["paint-order"] = "stroke fill"
            }
        }
        :allDone()
        :addClasses(args.class)
        :addCss(args.css)

    return header
end

function Components.textarea(infobox, args)
    local textarea = mw.html.create("tr")
        :addClass("infobox-textarea")
        :td {
            args[1] or "No text here...",
            attr = {colspan = 2}
        }
        :allDone()
        :addClasses(args.class)
        :addCss(args.css)

    return textarea
end

function Components.currency(infobox, args)
    local template = frm:expandTemplate{
        title = "Currency",
        args = {
            args.currency or "Dosh",
            args.price or "?",
            "n"
        }
    }

    local currency = mw.html.create("tr")
        :addClass("infobox-currency")
        :td {
            template,
            attr = {colspan = 2}
        }
        :allDone()
        :addClasses(args.class)
        :addCss(args.css)

    return currency
end

function Components.image(infobox, args)
    if args == false then return end

    local images = {}

    for k,v in pairs(args) do
        if k:match("^image%d+$") then
            local id = tonumber(k:match("%d+"))
            images[id] = v
        end
    end

    local result

    local function makeImage(args)
        local imagetext = ("[[File:%s|%spx]]"):format(
            remove(args.file, "File:"),
            (args.width and remove(args.width, "px") or 100) ..
            (args.height and "x" .. remove(args.height, "px") or "")
        )

        local imagecaption = ""
        if args.caption then
            imagecaption = mw.html.create("div")
                :addClass("infobox-image-caption")
                :wikitextParsed(args.caption)
        end

        local imagediv = mw.html.create("div")
            :addClass("infobox-image")
            :wikitext(imagetext)

        return tostring(imagediv) .. tostring(imagecaption)
    end

    if #images == 1 then
        result = makeImage(images[1])
    elseif #images > 1 then
        tabberargs = {}

        for k,v in ipairs(images) do
            local image = makeImage(v)

            tabberargs["tab" .. k] = v.name or "Image " .. k
            tabberargs["content" .. k] = image
        end

        result = frm:expandTemplate {
            title = "Tabber",
            args = tabberargs
        }
    else
        error("You need at least one image boi")
    end

    local row = mw.html.create("tr")
        :addClass("infobox-image-wrapper")
        :td {
            result,
            attr = {colspan = 2}
        }
        :allDone()
        :addClasses(args.class)
        :addCss(args.css)

    return row
end



-- infobox
local Infobox = {}
Infobox.__index = Infobox

-- create infobox
function Infobox.new(args)
    local obj = setmetatable({
        args = args,
        rows = {}
    }, Infobox)
    return obj
end

-- add a component
function Infobox:add(component, args)
    local component = Components[component](self, args)
    table.insert(self.rows, component)

    return self
end

-- collect image parameters
function Infobox:collectImageParams()
    local meta = {
        __index = function(tbl, key)
            local new = setmetatable({}, meta)
            tbl[key] = new
            return new
        end
    }
    local imageargs = setmetatable({}, meta)
    local validargs = {
        file = true,
        width = true,
        height = true,
        caption = true
    }

    for k,v in pairs(args) do
        local imageid = k:match("^image%d+")
        local arg = k:match("%-%w+$")
        if imageid and arg then
            arg = arg:gsub("^%-")
            if validargs[arg] then
                imageargs[imageid][arg] = v
            end
        end
    end

    if not next(imageargs) then
        return false
    end

    return imageargs
end

-- convert to string
function Infobox:tostring()
    local infobox = mw.html.create("table")
        :addClasses {
            "infobox-wrapper",
            "infobox",
            "border--beveled-background"
        }
        :addCss {
            height = "fit-content"
        }

    for _,row in ipairs(self.rows) do
        infobox:node(row)
    end

    return tostring(infobox)
end

return Infobox