---ION STORMS REPORTS

local storms_queue = {}
local storm_temp_reports = {}
local storm_chat_channel = 2096

---@class storm_report_receiver
GN.storm_report_receiver = {}
---Receives ION storm reports from the chat.
---@param e string The event "CHAT_MSG_CHANNEL_EMOTE".
---@param data table Data for this event {name, channelid, msg}
function GN.storm_report_receiver:OnEvent(e, data)
    if not GN.gn_enable then return end
    if not GN.storms then return end
    if e ~= "CHAT_MSG_CHANNEL_EMOTE" or data == nil then return end
    if data.channelid == nil or data.channelid ~= storm_chat_channel then return end
    if not GN.is_incoming(data.name) then return end
    local report_type, sectorids, location = string.match(data.msg, "^(%a+)%((%d+)%)%: (.-)$")
    local sectorid = tonumber(sectorids) or -1
    if ShortLocationStr(sectorid) ~= location then return end
    GN.storm_report_manager(sectorid, location, report_type, true)
end
RegisterEvent(GN.storm_report_receiver, "CHAT_MSG_CHANNEL_EMOTE")

---Inserts a report and sends a notification when a storm has started.
---@param e string The event "STORM_STARTED".
function GN:STORM_STARTED(e)
    if not GN.gn_enable then return end
    if not GN.storms then return end
    if e ~= "STORM_STARTED" then return end
    local sectorid = GetCurrentSectorid()
    GN.storm_report_manager(sectorid, nil,"STORM", false)
end
RegisterEvent(GN, "STORM_STARTED")

---Removes a report and sends a notification when a storm has stopped.
---@param e string The event "STORM_STOPPED".
function GN:STORM_STOPPED(e)
    if not GN.gn_enable then return end
    if not GN.storms then return end
    if e ~= "STORM_STOPPED" then return end
    local sectorid = GetCurrentSectorid()
    if storms_queue[sectorid] then
        GN.storm_report_manager(sectorid, nil, "CLEAR", false)
    end
    GN.send_storm_report()
end
RegisterEvent(GN, "STORM_STOPPED")

---Sends a chat message with storm and pushes a reporting notification.
---Also pushes the report in storms_queue.
---@param sectorid integer The sectorid with a storm.
---@param location string? The location of the storm.
---@param report_type string The type of report (STORM | CLEAR).
---@param incoming boolean True if the report is incoming or false if not.
function GN.storm_report_manager(sectorid, location ,report_type, incoming)
    if sectorid == nil then return end
    if report_type ~= "STORM" and report_type ~= "CLEAR" then return end
    local location_ = location or ShortLocationStr(sectorid) or ""
    local msg = string.format("%s(%d): %s", report_type, sectorid, location_)
    local title = incoming and "Reported" or "Reporting..."
    if not incoming then
        table.insert(storm_temp_reports, msg)
        GN.send_storm_report()
    end
    local processed = false
    if report_type == "STORM" then
        processed = GN.insert_storm_report(sectorid)
    elseif report_type == "CLEAR" then
        processed = GN.remove_storm_report(sectorid)
    end
    if processed then
        GN.push_notification(title, report_type, "\n"..location_, "STORM")
        GN.play_sound("STORM")
    end
    if processed  then
        GN.remove_storms_from_navmap()
        GN.add_storms_to_navmap()
        GN.save_storm_reports()
	end
end

function GN.send_storm_report()
    while #storm_temp_reports > 0 do
        local msg = table.remove(storm_temp_reports, 1)
        SendChat("/me "..tostring(msg), "CHANNEL", storm_chat_channel)
    end
end

---Inserts a new storm report if there is not one for this sector.
---@param sectorid integer The sectorid where the storm is present.
---@param time? integer The time when the storm was reported.
---@return boolean resul Returns true if a new report was inserted or false if not.
function GN.insert_storm_report(sectorid, time)
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
function GN.remove_storm_report(sectorid)
    if sectorid == -1  then return false end
	if not storms_queue[sectorid] then return false end
    storms_queue[sectorid] = nil
    return true
end

---Saves storms reports to file.
function GN.save_storm_reports()
    local reports_ = ""
    for sectorid, data in pairs(storms_queue) do
        reports_ = reports_ .. string.format('[%d]="Storm(%d)",\n', sectorid, data.time)
    end
    SaveSystemNotes(reports_, storm_chat_channel)
end

---Loads storm reports from file.
function GN.load_storm_reports()
    local reports = LoadSystemNotes(storm_chat_channel)
    local newer_than = os.time() - 6 * 60 * 60
    if reports == nil or #reports == 0 then return end
    for k,v in string.gmatch(reports, '%[(%d+)%]="Storm%((%d+)%)",') do
        local sectorid = tonumber(k) or -1
        local time = tonumber(v) or -1
        if sectorid ~= nil and time ~= nil then
            if time > newer_than then
                GN.insert_storm_report(sectorid, time)
            end
        end
    end
    GN.add_storms_to_navmap()
end

---Adds all storm reports to Navmap.
function GN.add_storms_to_navmap()
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
function GN.remove_storms_from_navmap()
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

---Load the storm saved reports and joins to the storm channel.
function GN.init_storm_reports()
    if not GN.gn_enable then return end
    if not GN.storms then return end
	GN.load_storm_reports()
    GN.join_chat_channel(storm_chat_channel)
end

---END of ION STORMS
