---ION STORMS REPORTS

local storms_queue = {}
local current_systemid = 0
local current_sectorid = 0
local storm_chat_channel = 2096
local max_storms_queue = 100

---@class storm_report_receiver
GuildNotifier.storm_report_receiver = {}
---Receives ION storm reports from the chat.
---@param e string The event "CHAT_MSG_CHANNEL_EMOTE".
---@param data table Data for this event {name, channelid, msg}
function GuildNotifier.storm_report_receiver:OnEvent(e, data)
    if not GuildNotifier.gn_enable then return end
    if not GuildNotifier.storms then return end
    if e ~= "CHAT_MSG_CHANNEL_EMOTE" or data == nil then return end
    if data.channelid == nil or data.channelid ~= storm_chat_channel then return end
    if not GuildNotifier.is_incoming(data.name) then return end
    local sectorids, location = string.match(data.msg, "^STORM%((%d+)%)%: (.-)$")
    local sectorid = tonumber(sectorids) or -1
    if ShortLocationStr(sectorid) ~= location then return end
    GuildNotifier.push_storm_report(sectorid, location)
    GuildNotifier.push_notification("New ION Storm", "Reported!","\n"..location, "STORM")
    GuildNotifier.play_sound("STORM")
end
RegisterEvent(GuildNotifier.storm_report_receiver, "CHAT_MSG_CHANNEL_EMOTE")

---Get de sectorid when the sector has changed.
---@param e string The event "SECTOR_CHANGED".
---@param sectorid integer The sectorid.
function GuildNotifier:SECTOR_CHANGED(e, sectorid)
    if not GuildNotifier.gn_enable then return end
    if not GuildNotifier.storms then return end
    if e ~= "SECTOR_CHANGED" then return end
    if sectorid == nil then return end

    if IsStormPresent() then GuildNotifier.send_storm_report(sectorid) end
    local system_changed =  GuildNotifier.update_system(sectorid)
    GuildNotifier.show_storm_report(system_changed)
end
RegisterEvent(GuildNotifier, "SECTOR_CHANGED");

---Update the system ID.
---@param sectorid integer The sectorid.
---@return boolean resul Returns true if the system ID was updated and false if not.
function GuildNotifier.update_system(sectorid)
    if sectorid == nil then return false end
    current_sectorid = sectorid
    local system = GetCurrentSystemid() or -1
    if current_systemid == system then return false end
    current_systemid = system
    return true
end

---Sends a chat message with storm and pushes a reporting notification.
---Also pushes the report in storms_queue.
---@param sectorid integer The sectorid with a storm.
function GuildNotifier.send_storm_report(sectorid)
    if sectorid == nil then return end
    local location = ShortLocationStr(sectorid) or ""
    local msg = string.format("STORM(%d): %s", sectorid, location)
    local send_report = GuildNotifier.send_battle_messages
	send_report(tostring(storm_chat_channel), msg)
    GuildNotifier.push_storm_report(sectorid, location)
    GuildNotifier.push_notification("Reporting...", "New ION Storm", "\n"..location, "STORM")
    GuildNotifier.play_sound("STORM")
end

---Adds a new storm report if there is not one for this sector.
---@param sectorid integer The sectorid where the storm is present.
---@return boolean resul Returns true if there is a new report or false if not.
function GuildNotifier.push_storm_report(sectorid, location)
	if storms_queue[sectorid] then return false end
    if #storms_queue >= max_storms_queue then
        table.remove(storms_queue, 1)
    end
    local systemid, x, y = SplitSectorID(sectorid)
    local current_report = {
        sectorid = sectorid,
        systemid = systemid,
        x = x,
        y = y,
        distance = 0,
        location = location
    }
    table.insert(storms_queue, current_report)
    return true
end

---Show a GN notification with a storm's report.
---@param system boolean The range of searching. A true means reports for all system storms, false just neighbor storms.
function GuildNotifier.show_storm_report(system)
    if #storms_queue == 0 then return end
    local distance = system and 16 or 1
    local storms = get_system_storms(distance)
    local report = GuildNotifier.get_storm_report(storms)
    GuildNotifier.push_notification("System", "ION Storms", report, "STORM")
end

---Convert a table of storms reports in a string with storm's locations.
---@param storms table The system storm reports.
---@return string locations Locations of the storm reports.
function GuildNotifier.get_storm_report(storms)
    local locations = ""
	if #storms == 0 then return locations end
    for k, v in ipairs(storms) do
        locations = locations.." "..v.location
        if k == 10 then break end
    end
    return locations
end

---Gets storms in current system.
---@param max_distance integer Maximum distance in sectors where you want to find storms.
---@return table system_storms A table with the located storms.
function GuildNotifier.get_system_storms(max_distance)
    local system_storms = {}
    local _, x1, y1 = SplitSectorID(current_sectorid)
	for _,v  in ipairs(storms_queue) do
        if v.systemid == current_systemid then
            local distance = GuildNotifier.get_storm_distance(x1, y1, v.x, v.y)
            if distance > 0 and distance <= max_distance then
                v.distance = distance
                table.insert(system_storms, v)
            end
        end
    end
    table.sort(system_storms, function(a, b) return a.distance < b.distance end)
    return system_storms
end

---Gets the Euclidian distance from player to a storm.
---@param x1 integer Player x coordinate.
---@param y1 integer Player y coordinate.
---@param x2 integer Storm x coordinate.
---@param y2 integer Storm y coordinate.
---@return integer distance The distance (in sectors).
function GuildNotifier.get_storm_distance(x1, y1, x2, y2)
    if x1 == nil or y1 == nil or x2 == nil or y2 == nil then return -1 end
    local distance = math.sqrt((x1 - x2)^2 + (y1 - y2)^2) or -1
    return distance
end

---END of ION STORMS
