GPad.VFS.Protocol.Channels = {}

function GPad.VFS.Protocol:RegisterChannel(strName)
	if SERVER then
		GPad.VFS.Debug("Protocol:RegisterChannel() -> "..strName)
		util.AddNetworkString(strName)
		GPad.VFS.Protocol.Channels[strName] = true
	else
		GPad.VFS.Error("Unhandled channel register!")
	end
end

function GPad.VFS.Protocol:UnregisterChannel(strName)
	if SERVER then
		GPad.VFS.Protocol.Channels[strName] = false
	else
		GPad.VFS.Error("Unhandled channel unregister!")
	end
end

function GPad.VFS.Protocol:Send(strName, entPlayer, ...)
	if SERVER and not GPad.VFS.Protocol.Channels[strName] then
		GPad.VFS.Error("Unpooled channel name: "..strName)
		return false
	end
	net.Start(strName)
	
	inBuffer = self.MakeBuffer(...)
	-- <-- Some shit goes here...
	net.WriteTable(inBuffer)
	
	if CLIENT then
		return net.SendToServer()
	else
		if entPlayer then
			return IsValid(entPlayer) and net.Send(entPlayer)
		else
			return net.Broadcast()
		end
	end
	
end

function GPad.VFS.Protocol:Recieve(strName, funcCallback)
	net.Recieve(strName, function(numLength, entPlayer)
		funcCallback(inBuffer, numLength, entPlayer)
	end)	
end
