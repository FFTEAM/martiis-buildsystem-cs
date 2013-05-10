-- lua demo script

config="/lib/tuxbox/plugins/fritzcall/fb.conf"
on="ein"
off="aus"

C={}
C["FRITZBOXIP"]="fritz.box"
C["FRITZBOXPORT"]=1012
C["All"]=1
C["Phone_1"]=123456
C["Phone_1_name"]="MyPhoneName1"
C["Phone_2"]=789012
C["Phone_2_name"]="MyPhoneName2"
C["Phone_3"]=345678
C["Phone_3_name"]="MyPhoneName3"
C["debug"]=0
C["invers"]=0
C["ip"]="127.0.0.1"
C["monDisconnect"]=0
C["monRing"]=1
C["muteRing"]=1
C["popup"]=1

function num2onoff(a)
	if (tonumber(a) == 0) then return off end
	return on
end

function onoff2num(a)
	if (a == on) then return 1 end
	return 0
end

-- fixme
autostart=0

function set_autostart(a)
	-- fixme
	autostart=onoff2num(a)
end

function set_string(k, v) C[k]=v end
function set_bool(k, v) C[k]=onoff2num(v) end

function load()
	-- missing: autostart handling
	local f = io.open(config, "r")
	if f then
		for line in f:lines() do
			local key, val = line:match("^([^=#]+)=([^\n]*)")
			if (key) then
				if (val == nil) then
					val=""
				end
				C[key]=val
			end
		end
		f:close()
	end
end

function save()
	-- missing: autostart handling
	local f = io.open(config, "w")
	if f then
		local key, val
		for key, val in pairs(C) do
			f:write(key .. "=" .. val .. "\n")
		end
		f:close()
	end
end

load()

local m = menue.new{name="FritzBox CallMonitor", icon="settings"}
m:addItem{type="back"}
m:addItem{type="separator"}
m:addItem{type="forwarder", name="Speichern", action="save", icon="rot", directkey=RC["red"]}
m:addItem{type="separator"}
m:addItem{type="chooser", name="Autostart", value=num2onoff(autostart), action="set_autostart", options={ on, off }}
m:addItem{type="stringinput", id="FRITZBOXIP", name="FritzBox IP/Name", value=C["FRITZBOXIP"], action="set_string", sms=1}
m:addItem{type="stringinput", id="FRITZBOXPORT", name="FritzBox Port", value=C["FRITZBOXPORT"], action="set_string", enabled=1, valid_chars="0123456789"}
m:addItem{type="chooser", id="debug", name="Debug (nur in Telnet)", value=num2onoff(C["debug"]), action="set_bool", options={ off, on }}
m:addItem{type="separator"}
m:addItem{type="stringinput", id="Phone_1", name="Rufnummer 1", value=C["Phone_1"], action="set_Phone_1", valid_chars="0123456789"}
m:addItem{type="stringinput", id="Phone_1_name", name="Rufnummer 1 Name", value=C["Phone_1_name"], action="set_string", sms=1}
m:addItem{type="stringinput", id="Phone_2", name="Rufnummer 2", value=C["Phone_2"], action="set_Phone_2", valid_chars="0123456789"}
m:addItem{type="stringinput", id="Phone_2_name", name="Rufnummer 2 Name", value=C["Phone_2_name"], action="set_string", sms=1}
m:addItem{type="stringinput", id="Phone_3", name="Rufnummer 3", value=C["Phone_3"], action="set_Phone_3", valid_chars="0123456789"}
m:addItem{type="stringinput", id="Phone_3_name", name="Rufnummer 3 Name", value=C["Phone_3_name"], action="set_string", sms=1}
m:addItem{type="separator"}
m:addItem{type="chooser", id="All", name="Alle Rufnummern überwachen", value=num2onoff(C["All"]), action="setbool", options={ on, off }, directkey=RC["1"]}
m:addItem{type="chooser", id="monRing", name="Eingehende Anrufe anzeigen", value=num2onoff(C["monRing"]), action="set_bool", options={ on, off }, directkey=RC["2"]}
m:addItem{type="chooser", id="monDisconnect", name="Dauer und Ende des Anrufs anzeigen", value=num2onoff(C["monDisconnect"]), action="set_bool", options={ on, off }, directkey=RC["3"]}
m:addItem{type="chooser", id="muteRing", name="Ton aus bei Anruf", value=num2onoff(C["muteRing"]), action="set_bool", options={ on, off }, directkey=RC["4"]}
m:addItem{type="chooser", id="popup", name="Popup statt normaler Meldung", value=num2onoff(C["popup"]), action="set_bool", options={ on, off }, directkey=RC["5"]}
m:addItem{type="chooser", id="invers", name="Inverssuche (GoYellow)", value=num2onoff(C["invers"]), action="set_bool", options={ on, off }, directkey=RC["6"]}
m:exec()

