-- fritzcall demo script

config="/lib/tuxbox/plugins/fritzcall/fb.conf"
fritzcall="/lib/tuxbox/plugins/fritzcall/fb.sh"
initscript="/etc/init.d/S98fritzcall"

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

changed=0
changed_startup=0
autostart=0


function set_auto(k, v)
	autostart=onoff2num(v)
	changed_startup=1
end

function set_string(k, v) C[k]=v changed=1 end
function set_bool(k, v) C[k]=onoff2num(v) changed=1 end

function load()
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
	f = io.open(initscript, "r");
	if f ~= nil then
		f:close()
		autostart=1
	end
end

function save()
	local h = hintbox.new{caption="Einstellungen werden gespeichert", text="Bitte warten ..."}
	h:paint()
	if (changed) then
		local f = io.open(config, "w")
		if f then
			local key, val
			for key, val in pairs(C) do
				f:write(key .. "=" .. val .. "\n")
			end
			f:close()
		end
		changed = 0
	end
	if (changed_startup) then
		if (autostart == 0) then
			os.execute(initscript .. " stop >/dev/null 2>&1")
			os.remove(initscript)
		else
			local f = io.open(initscript, "w")
			if f then
				f:write(
[[#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH
case "$1" in
	restart)
		(]] .. fritzcall .. [[ stop ; ]] .. fritzcall .. [[ start ) >/dev/null 2>&1 &
		;;
	start|stop)
		]] .. fritzcall .. [[ $1 >/dev/null 2>&1 &
		;;
esac
]]
				)
				f:close()
				os.execute("chmod 755 ".. initscript .. ";" .. initscript .. " start >/dev/null 2>&1")
			end
		end
		changed_startup = 0
	else
		if (autostart == 1) then
			os.execute(initscript .. " restart >/dev/null 2>&1")
		end
	end
	h:hide()
end

function handle_key(a)
	if (changed == 0) then return MENU_RETURN["EXIT"] end
	local res = messagebox.exec{title="Änderungen verwerfen?", text="Sollen die Änderungen verworfen werden?", buttons={ "yes", "no" } }
	if (res == "yes") then return MENU_RETURN["EXIT"] end
	return MENU_RETURN["REPAINT"]
end

load()

local m = menu.new{name="FritzBox CallMonitor", icon="settings"}
m:addKey{directkey=RC["home"], id="home", action="handle_key"}
m:addItem{type="back"}
m:addItem{type="separator"}
m:addItem{type="forwarder", name="Speichern", action="save", icon="rot", directkey=RC["red"]}
m:addItem{type="separator"}
m:addItem{type="chooser",     action="set_auto", options={ on, off }, id="dummy", value=num2onoff(autostart), name="Autostart", icon="gruen", directkey=RC["green"]}
m:addItem{type="stringinput", action="set_string", id="FRITZBOXIP",   value=C["FRITZBOXIP"],   sms=1,                    name="FritzBox IP/Name"}
m:addItem{type="stringinput", action="set_string", id="FRITZBOXPORT", value=C["FRITZBOXPORT"], valid_chars="0123456789", name="FritzBox Port"}
m:addItem{type="chooser",     action="set_bool", options={ on, off }, id="debug", value=num2onoff(C["debug"]), name="Debug (nur in Telnet)"}

pcall(
	function()
		local client = require 'soap.client'
		local ns = 'urn:schemas-upnp-org:service:WANIPConnection:1'
		local meth = 'GetExternalIPAddress'
		ns, meth, ent = client.call {
		url = 'http://' .. C['FRITZBOXIP'] ..':49000/upnp/control/WANIPConn1',
			soapaction = ns .. '#' .. meth, method=meth, namespace=ns, entries = { }
		}
		if (type(ent[1]) == 'table' and ent[1]['tag'] == 'NewExternalIPAddress') then
			m:addItem{type="stringinput", value=ent[1][1], active=0, name="Aktuelle WAN-IP"}
		end
	end
)

m:addItem{type="separator"}
m:addItem{type="stringinput", action="set_string", id="Phone_1",      name="Rufnummer 1",      value=C["Phone_1"],      valid_chars="0123456789"}
m:addItem{type="stringinput", action="set_string", id="Phone_1_name", name="Rufnummer 1 Name", value=C["Phone_1_name"], sms=1}
m:addItem{type="stringinput", action="set_string", id="Phone_2",      name="Rufnummer 2",      value=C["Phone_2"],      valid_chars="0123456789"}
m:addItem{type="stringinput", action="set_string", id="Phone_2_name", name="Rufnummer 2 Name", value=C["Phone_2_name"], sms=1}
m:addItem{type="stringinput", action="set_string", id="Phone_3",      name="Rufnummer 3",      value=C["Phone_3"],      valid_chars="0123456789"}
m:addItem{type="stringinput", action="set_string", id="Phone_3_name", name="Rufnummer 3 Name", value=C["Phone_3_name"], sms=1}
m:addItem{type="separator"}
m:addItem{type="chooser", action="set_bool", options={ on, off }, id="All",           value=num2onoff(C["All"]),           directkey=RC["1"], name="Alle Rufnummern überwachen"}
m:addItem{type="chooser", action="set_bool", options={ on, off }, id="monRing",       value=num2onoff(C["monRing"]),       directkey=RC["2"], name="Eingehende Anrufe anzeigen"}
m:addItem{type="chooser", action="set_bool", options={ on, off }, id="monDisconnect", value=num2onoff(C["monDisconnect"]), directkey=RC["3"], name="Dauer und Ende des Anrufs anzeigen"}
m:addItem{type="chooser", action="set_bool", options={ on, off }, id="muteRing",      value=num2onoff(C["muteRing"]),      directkey=RC["4"], name="Ton aus bei Anruf"}
m:addItem{type="chooser", action="set_bool", options={ on, off }, id="popup",         value=num2onoff(C["popup"]),         directkey=RC["5"], name="Popup statt normaler Meldung"}
m:addItem{type="chooser", action="set_bool", options={ on, off }, id="invers",        value=num2onoff(C["invers"]),        directkey=RC["6"], name="Inverssuche (GoYellow)"}
m:exec()

