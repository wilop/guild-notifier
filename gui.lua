GuildNotifier.gui = iup.hbox {}
GuildNotifier.gui_data = {
    icon = PROFILE_ICON or "",
    fgcolor1 = "",
    fgcolor2 = "",
    title = "Welcome",
    subtitle = "Pilot",
    msg = "Thanks for using Guild Notifier.\nHave a great journey!."
}

function GuildNotifier:create_gui()
    console_print("🔴 Entró a create_gui")
    local x_size =gkinterface.GetXResolution()
    local y_size =gkinterface.GetYResolution()
    local x_margin = (x_size - 324) / 2

    self.gui_icon_left = iup.label {title="", image = GuildNotifier.gui_data.icon, size="48x48", alignment = 'ACENTER'}
    self.gui_icon_right = iup.label {title="", image = GuildNotifier.gui_data.icon, size="48x48", alignment = 'ACENTER'}
    self.title = iup.label {title = GuildNotifier.gui_data.title, expand = 'HORIZONTAL', alignment = "ACENTER", wordwrap = 'YES'}
    self.subtitle = iup.label {title = GuildNotifier.gui_data.subtitle, expand = 'HORIZONTAL', alignment = "ACENTER", wordwrap = 'YES'}
-- local message = iup.label {title = msg  , expand = 'HORIZONTAL', alignment = "ACENTER", wordwrap = 'YES'}
    self.message = iup.label{title = GuildNotifier.gui_data.msg, alignment = "ACENTER", multiline = 'YES', wordwrap = 'YES', scrollbar = 'NO', expand = 'YES'}

    local wing_left = iup.label {title="", image = GuildNotifier.wing_left, size="128x64", alignment = 'ACENTER'}
    local wing_right = iup.label {title="", image = GuildNotifier.wing_right, size="128x64", alignment = 'ACENTER'}
    local top_separator = iup.label {title = '', image = '', size = 'x1', expand = 'HORIZONTAL', fgcolor = '40 180 240 125 *'}
    local bottom_separator = iup.label {title = '', image = '', size = "x2", expand = 'HORIZONTAL',fgcolor = '40 180 240 125 *'}

    if GuildNotifier.state == GuildNotifier.states["HIDDEN"] then return false end
    if GuildNotifier.state == GuildNotifier.states["IDLE"]  then
       -- print("IDLE")
        self.gui = iup.hbox{
            iup.fill{size = x_margin},
            iup.vbox{
                iup.fill{},
                iup.hbox {
                    wing_left,
                    iup.hbox {
                        iup.fill{size = -x_margin + 180},
                        self.gui_icon_left,
                        iup.fill{size = -x_margin + 180},
                    },
                    wing_right,
                    gap = 5,
                },

                iup.fill{size = 1},
            },
            iup.fill{size = x_margin},
        }

    elseif GuildNotifier.state == GuildNotifier.states["SHOWN"] then
     --   print("SHOWN")

        x_margin = (x_size - 800 ) /2

        self.gui = iup.hbox{
            iup.fill{size = x_margin},
            iup.vbox {
                iup.fill{size = y_size - 175},
                iup.hbox {
                    wing_left,
                    iup.hbox{
                        self.gui_icon_left,
                    },
                    iup.vbox {
                        top_separator,
                        self.title,
                        self.subtitle,
                        gap = '5',
                        iup.hbox {
                            iup.fill{size = -x_margin + 400},
                            self.message,
                            iup.fill{size = -x_margin + 400},
                        },
                    },
                    iup.hbox{
                        self.gui_icon_right,
                    },
                    wing_right,
                },
                bottom_separator,
            },
            iup.fill{size = x_margin},
        }

    elseif GuildNotifier.state == GuildNotifier.states["BATTLE"] then
       -- print("BATTLE")

        x_margin = (x_size - 650 ) /2

        self.gui = iup.hbox{
            iup.fill{size = x_margin},
            iup.vbox {
                iup.fill{size = y_size - 175},
                iup.hbox {
                    wing_left,
                    self.gui_icon_left,
                    iup.vbox {
                        top_separator,
                        self.title,
                        self.subtitle,
                        gap = '5',
                        iup.hbox {
                            iup.fill{size = -x_margin + 325},
                            self.message,
                            iup.fill{size = -x_margin + 325},
                        },
                    },
                    self.gui_icon_right,
                    wing_right,
                },
                bottom_separator,
            },
            iup.fill{size = x_margin},
        }

    end
    console_print("🔴 Salió de create_gui")
    return true
end

function GuildNotifier:set_gui_data(data)

    if not self.title or not self.gui then
        console_print("⚠️ Intento de update sin GUI listo")
        return
    end
    console_print("🔴 Entrando a set_gui_data")
    self.gui_data.title = data.title
    self.gui_data.subtitle = data.subtitle
    self.gui_data.msg = data.msg
    self.title.title = self.gui_data.title
    self.subtitle.title = self.gui_data.subtitle
    self.message.title = self.gui_data.msg

    self:set_icon(data.icon)
    self:icon_blinker(250, 5)
    self:refresh()
    console_print("🔴 Salió de set_gui_data")
end

function GuildNotifier:set_icon(icon)
    self.gui_data.icon = GuildNotifier.icons[icon]
    self.gui_icon_left.image = self.gui_data.icon
    self.gui_icon_right.image = self.gui_data.icon
end

function GuildNotifier:icon_blinker(timeout, times)
    if not self.gui_icon_left or not self.gui_icon_right then
        return
    end

    local function blink(n)
    if n <= 0 then return end
        if not self.gui_icon_left or not self.gui_icon_right then return end
        self.gui_icon_left.size = '52x52'
        self.gui_icon_right.size = '52x52'
        GuildNotifier:refresh()
        Timer():SetTimeout(timeout, function()

         if not self.gui_icon_left or not self.gui_icon_right then return end
            self.gui_icon_left.size = '48x48'
            self.gui_icon_right.size = '48x48'
            self:refresh()

            Timer():SetTimeout(timeout, function()
                blink(n - 1)
                return
            end)
        end)

    end
    blink(times)
end

function GuildNotifier:fade(timeout, state)
    console_print("🔴 Entrando a fade")
    if not GuildNotifier.states[state] then return false end
    if GuildNotifier.states[state] == GuildNotifier.state then return end

    GuildNotifier.state = GuildNotifier.states[state]

    if GuildNotifier.state == GuildNotifier.states["HIDDEN"]  then
        self:hide()
        return true
    else

        local function animate(s)
--             if s <= 0 then
--                 return
--             end
           --self:refresh()
            self:destroy_gui()
--             Timer():SetTimeout(timeout, function()
                self:init()
--                 animate(s - 1)
--                 return
--             end)
        end
            console_print("🔴 fade xpcall: ".. tostring(xpcall(animate, debug.traceback, 1)))

    end
    console_print("🔴 Saliendo de fade")
    return true
end

function GuildNotifier:refresh()
-- -- Suponiendo que HUD.pluginlayer es tu contenedor (vbox/hbox/etc)
--     local found = false
--     local i = 0
--     while HUD.pluginlayer[i] do
--         if HUD.pluginlayer[i] == self.gui then
--             found = true
--             break
--         end
--         i = i + 1
--     end
--
--     if found then
--         print("✅ self.gui encontrado en la lista de hijos de HUD.pluginlayer")
--     else
--         print("❌ self.gui no aparece en los hijos de HUD.pluginlayer")
--     end

    if GuildNotifier.states["HIDDEN"] ~= GuildNotifier.state then
        iup.Refresh(self.gui)
    end
end

function GuildNotifier:show()
    if GuildNotifier.states["HIDDEN"] ~= GuildNotifier.state then
        iup.Append(HUD.pluginlayer, self.gui)
        iup.Refresh(self.gui)
       -- GuildNotifier.state = GuildNotifier.states["IDLE"]
    end
end

function GuildNotifier:hide()
    iup.Detach(self.gui)
end

function GuildNotifier:destroy_gui()
    if self.gui ~= nil then
        iup.Destroy(self.gui)
        self.gui = nil
    end
end

function GuildNotifier:init()
    if not GuildNotifier.gn_enable then return end
    if self:create_gui() then
        self:show()
        console_print("Starting...")
    else
        self:hide()
    end
end

GuildNotifier:init()

-- Event handlers
function GuildNotifier:rHUDxscale(e, data)
    --print("Antes del sesastre")
    self:init()
end

RegisterEvent(GuildNotifier, 'rHUDxscale')

