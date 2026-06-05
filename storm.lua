---ION STORMS REPORTS

local storms_queue = {}
local storm_temp_reports = {}
local current_systemid = 0
local current_sectorid = 0
local storm_chat_channel = 2096

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
    local report_type, sectorids, location = string.match(data.msg, "^(%a+)%((%d+)%)%: (.-)$")
    local sectorid = tonumber(sectorids) or -1
    if ShortLocationStr(sectorid) ~= location then return end
    GuildNotifier.storm_report_manager(sectorid, location, report_type, true)
end
RegisterEvent(GuildNotifier.storm_report_receiver, "CHAT_MSG_CHANNEL_EMOTE")

---Inserts a report and sends a notification when a storm has started.
---@param e string The event "STORM_STARTED".
function GuildNotifier:STORM_STARTED(e)
    if not GuildNotifier.gn_enable then return end
    if not GuildNotifier.storms then return end
    if e ~= "STORM_STARTED" then return end
    local sectorid = GetCurrentSectorid()
    GuildNotifier.storm_report_manager(sectorid, nil,"STORM", false)
end
RegisterEvent(GuildNotifier, "STORM_STARTED")

---Removes a report and sends a notification when a storm has stopped.
---@param e string The event "STORM_STOPPED".
function GuildNotifier:STORM_STOPPED(e)
    if not GuildNotifier.gn_enable then return end
    if not GuildNotifier.storms then return end
    if e ~= "STORM_STOPPED" then return end
    local sectorid = GetCurrentSectorid()
    if storms_queue[sectorid] then
        GuildNotifier.storm_report_manager(sectorid, nil, "CLEAR", false)
    end
    GuildNotifier.send_storm_report()
end
RegisterEvent(GuildNotifier, "STORM_STOPPED")

---Get de sectorid when the sector has changed.
---@param e string The event "SECTOR_CHANGED".
---@param sectorid integer The sectorid.
function GuildNotifier:SECTOR_CHANGED(e, sectorid)
    if not GuildNotifier.gn_enable then return end
    if not GuildNotifier.storms then return end
    if e ~= "SECTOR_CHANGED" then return end
    if sectorid == nil then return end
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
---@param location string? The location of the storm.
---@param report_type string The type of report (STORM | CLEAR).
---@param incoming boolean True if the report is incoming or false if not.
function GuildNotifier.storm_report_manager(sectorid, location ,report_type, incoming)
    if sectorid == nil then return end
    if report_type ~= "STORM" and report_type ~= "CLEAR" then return end
    local location_ = location or ShortLocationStr(sectorid) or ""
    local msg = string.format("%s(%d): %s", report_type, sectorid, location_)
    local title = incoming and "Reported" or "Reporting..."
    if not incoming then
        table.insert(storm_temp_reports, msg)
        GuildNotifier.send_storm_report()
    end
    local processed = false
    if report_type == "STORM" then
        processed = GuildNotifier.insert_storm_report(sectorid)
    elseif report_type == "CLEAR" then
        processed = GuildNotifier.remove_storm_report(sectorid)
    end
    if processed then
        GuildNotifier.push_notification(title, report_type, "\n"..location_, "STORM")
        GuildNotifier.play_sound("STORM")
    end
    if processed  then
        GuildNotifier.remove_storms_from_navmap()
        GuildNotifier.add_storms_to_navmap()
        GuildNotifier.save_storm_reports()
	end
end

function GuildNotifier.send_storm_report()
    while #storm_temp_reports > 0 do
        local msg = table.remove(storm_temp_reports, 1)
--         GuildNotifier.send_battle_messages(channel, msg)
        SendChat("/me "..tostring(msg), "CHANNEL", storm_chat_channel)
    end
end

---Inserts a new storm report if there is not one for this sector.
---@param sectorid integer The sectorid where the storm is present.
---@param time? integer The time when the storm was reported.
---@return boolean resul Returns true if a new report was inserted or false if not.
function GuildNotifier.insert_storm_report(sectorid, time)
    if sectorid == -1 or time == -1 then return false end
	if storms_queue[sectorid] then return false end
    local systemid, x, y = SplitSectorID(sectorid)
    local location_ = ShortLocationStr(sectorid)
    local current_report = {
        systemid = systemid,
        x = x,
        y = y,
        distance = 0,
        location = location_,
        time = time or os.time()
    }
    storms_queue[sectorid] = current_report
    return true
end

---Removes a storm report.
---@param sectorid integer The sectorid where the storm stopped.
---@return boolean resul Returns true if the report was removed or false if not.
function GuildNotifier.remove_storm_report(sectorid)
    if sectorid == -1  then return false end
	if not storms_queue[sectorid] then return false end
    storms_queue[sectorid] = nil
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
    GuildNotifier.play_sound("STORM")
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

---Saves storms reports to file.
function GuildNotifier.save_storm_reports()
    local reports_ = ""
    for sectorid, data in pairs(storms_queue) do
        reports_ = reports_ .. string.format('[%d]="Storm(%d)",\n', sectorid, data.time)
    end
    SaveSystemNotes(reports_, storm_chat_channel)
end

---Loads storm reports from file.
function GuildNotifier.load_storm_reports()
    local reports = LoadSystemNotes(storm_chat_channel)
    local newer_than = os.time() - 6 * 60 * 60
    if reports == nil or #reports == 0 then return end
    for k,v in string.gmatch(reports, '%[(%d+)%]="Storm%((%d+)%)",') do
        local sectorid = tonumber(k) or -1
        local time = tonumber(v) or -1
        if sectorid ~= nil and time ~= nil then
            if time > newer_than then
                GuildNotifier.insert_storm_report(sectorid, time)
            end
        end
    end
    GuildNotifier.add_storms_to_navmap()
end

---Adds all storm reports to Navmap.
function GuildNotifier.add_storms_to_navmap()
    for sectorid, data in pairs(storms_queue) do
        if SystemNotes[data.systemid] == nil then
            SystemNotes[data.systemid] = {[sectorid] = ""}
        end
        local old_note = SystemNotes[data.systemid][sectorid] or ""
        local new_note = string.format("\nStorm(%d)", data.time)
        local match_note = string.match(old_note, string.format(",?\nStorm%%(%d+%%)", data.time))
        if match_note == nil then
            new_note = old_note .. new_note
            SystemNotes[data.systemid][sectorid] = new_note
        end
    end
end

--- Removes all storm reports from Navmap.
function GuildNotifier.remove_storms_from_navmap()
    for system in pairs(SystemNotes) do
        if system ~= storm_chat_channel then
            for sector in pairs(SystemNotes[system]) do
                local old_note = SystemNotes[system][sector]
                if type(old_note) == "string" then
                    local new_note = string.gsub(old_note,",?\nStorm%(%d+%)", "")
                    SystemNotes[system][sector] = new_note
                end
            end
        end
    end
end

---END of ION STORMS
