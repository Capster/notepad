local META = {}

META.__index = META
META.Type = "Buffer Object"

function META:__len()
	return #self:GetBuffer()
end

function META:__add(newBuffer)
	return table.Add(self:GetBuffer(), newBuffer)
end

function META:GetBuffer()
	if not self.Buffer then
		self.Buffer = {}
	end
	return self.Buffer
end

function META:SetBuffer(tblBuffer)
	self.Buffer = tblBuffer
end

function META:AddElement(objNewElement)
	table.insert(self:GetBuffer(), objNewElement)
end

function META:RemoveElement(numID)
	table.remove(self:GetBuffer(), numID)
end

function META:GetSize()
	return GPad.VFS.Protocol.GetTableSize(self:GetBuffer())
end

-- Push

function META:PushString(strString)
	self:AddElement(strString)
end

function META:PushNumber(numNumber)
	self:AddElement(numNumber)
end

function META:PushTable(tblTable)
	self:AddElement(tblTable)
end

function META:PushBool(boolBool)
	self:AddElement(boolBool)
end

-- Pull

function META:PullNextByType(strType)
	for curIndex, curElement in pairs(self:GetBuffer()) do
		if type(curElement) == strType then
			table.remove(self:GetBuffer(), curIndex)
			return curElement
		end
	end
end

function META:PullString()
	return self:PullNextByType("string")
end

function META:PullNumber()
	return self:PullNextByType("number")
end

function META:PullTable()
	return self:PullNextByType("table")
end

function META:PullBool()
	return self:PullNextByType("boolean")
end

function GPad.VFS.Protocol.GetTableSize(tblTable)	
	local size = 0
	
	for k,v in pairs(tblTable) do
		if type(v) == "table" then
			size = size + GPad.VFS.Protocol.GetTableSize(v)
		elseif type(v) == "string" then
			size = size + v:byte()
		elseif type(v) == "number" then
			size = size + math.ceil(v / 0x8)
		elseif type(v) == "boolean" then
			size = size + 1
		end
	end
	return size
end

function GPad.VFS.Protocol.MakeBuffer(tblBuffer)
	local inBuffer = setmetatable({}, META)
	inBuffer.Buffer = {}
	
	inBuffer:SetBuffer(tblBuffer)
	
	return inBuffer
end