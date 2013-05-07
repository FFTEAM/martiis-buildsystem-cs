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
	if a == 0 then return off end
	return on
end

function onoff2num(a)
	if a == on then return 1 end
	return 0
end

-- fixme
autostart=0

function set_autostart(a)
	-- fixme
	autostart=onoff2num(a)
end

function set_fbip(a) C["FRITZBOXIP"]=a end
function set_fbport(a) C["FRITZBOXPORT"]=a end
function set_debug(a) C["debug"]=onoff2num(a) end
function set_Phone_1(a) C["Phone_1"]=a end
function set_Phone_1_name(a) C["Phone_1"]=a end
function set_Phone_2(a) C["Phone_2"]=a end
function set_Phone_2_name(a) C["Phone_2"]=a end
function set_Phone_3(a) C["Phone_3"]=a end
function set_Phone_3_name(a) C["Phone_3"]=a end
function set_All(a) C["All"]=onoff2num(a) end
function set_monRing(a) C["monRing"]=onoff2num(a) end
function set_monDisconnect(a) C["monDisconnect"]=onoff2num(a) end
function set_muteRing(a) C["muteRing"]=onoff2num(a) end
function set_popup(a) C["popup"]=onoff2num(a) end
function set_invers(a) C["invers"]=onoff2num(a) end

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
m:addItem{type="forwarder", name="Speichern", action="save", icon="rot", directkey=RC["red"]}
m:addItem{type="separator"}
m:addItem{type="chooser", name="Autostart", value=autostart, action="set_autostart", options={ on, off }}
m:addItem{type="stringinput", name="FritzBox IP/Name", value=C["FRITZBOXIP"], action="set_fbip", sms=1}
m:addItem{type="stringinput", name="FritzBox Port", value=C["FRITZBOXPORT"], action="set_fbport", enabled=1, valid_chars="0123456789"}
m:addItem{type="chooser", name="Debug (nur in Telnet)", value=num2onoff(C["debug"]), action="set_debug", options={ off, on }}
m:addItem{type="separator"}
m:addItem{type="stringinput", name="Rufnummer 1", value=C["Phone_1"], action="set_Phone_1", valid_chars="0123456789"}
m:addItem{type="stringinput", name="Rufnummer 1 Name", value=C["Phone_1_name"], action="set_Phone_1_name"}
m:addItem{type="stringinput", name="Rufnummer 2", value=C["Phone_2"], action="set_Phone_2", valid_chars="0123456789"}
m:addItem{type="stringinput", name="Rufnummer 2 Name", value=C["Phone_2_name"], action="set_Phone_2_name"}
m:addItem{type="stringinput", name="Rufnummer 3", value=C["Phone_3"], action="set_Phone_3", valid_chars="0123456789"}
m:addItem{type="stringinput", name="Rufnummer 3 Name", value=C["Phone_3_name"], action="set_Phone_3_name"}
m:addItem{type="separator"}
m:addItem{type="chooser", name="Alle Rufnummern überwachen", valeu=num2onoff(C["All"]), action="set_All", options={ on, off }, directkey=RC["1"]}
m:addItem{type="chooser", name="Eingehende Anrufe anzeigen", value=num2onoff(C["monRing"]), action="set_monRing", options={ on, off }, directkey=RC["2"]}
m:addItem{type="chooser", name="Dauer und Ende des Anrufs anzeigen", value=num2onoff(C["monDisconnect"]), action="set_monDisconnect", options={ on, off }, directkey=RC["3"]}
m:addItem{type="chooser", name="Ton aus bei Anruf", value=num2onoff(C["muteRing"]), action="set_muteRing", options={ on, off }, directkey=RC["4"]}
m:addItem{type="chooser", name="Popup statt normaler Meldung", value=num2onoff(C["popup"]), action="set_popup", options={ on, off }, directkey=RC["5"]}
m:addItem{type="chooser", name="Inverssuche (GoYellow)", value=num2onoff(C["invers"]), action="set_invers", options={ on, off }, directkey=RC["6"]}
m:exec()

