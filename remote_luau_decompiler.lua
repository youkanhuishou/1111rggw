--!nocheck
-- ddd
local bit32_band = bit32.band
local bit32_rshift = bit32.rshift

local LBC_VERSION_MIN = 3
local LBC_VERSION_MAX = 9

local LBC_CONSTANT_NIL = 0
local LBC_CONSTANT_BOOLEAN = 1
local LBC_CONSTANT_NUMBER = 2
local LBC_CONSTANT_STRING = 3
local LBC_CONSTANT_IMPORT = 4
local LBC_CONSTANT_TABLE = 5
local LBC_CONSTANT_CLOSURE = 6
local LBC_CONSTANT_VECTOR = 7
local LBC_CONSTANT_TABLE_WITH_CONSTANTS = 8
local LBC_CONSTANT_INTEGER = 9

local ROBLOX_OPCODES = {
	[4] = "POWK",
	[9] = "MUL",
	[13] = "JUMPXLEKN",
	[14] = "JUMPIFNOT",
	[18] = "CAPTURE",
	[19] = "GETTABLEN",
	[23] = "FORGPREP",
	[28] = "LENGTH",
	[33] = "MODK",
	[38] = "SUB",
	[42] = "JUMPXEQKB",
	[43] = "JUMPIF",
	[48] = "SETTABLEKS",
	[52] = "FASTCALL3",
	[57] = "MINUS",
	[62] = "DIVK",
	[67] = "ADD",
	[71] = "JUMPXEQKNIL",
	[76] = "FASTCALL1",
	[77] = "GETTABLEKS",
	[81] = "FORGPREP_NEXT",
	[82] = "MOVE",
	[86] = "NOT",
	[91] = "MULK",
	[96] = "JUMPIFNOTLT",
	[100] = "FORGPREP_INEXT",
	[101] = "JUMP",
	[106] = "SETTABLE",
	[110] = "FORGLOOP",
	[111] = "LOADK",
	[115] = "CONCAT",
	[120] = "SUBK",
	[125] = "JUMPIFNOTLE",
	[129] = "FASTCALL2K",
	[130] = "RETURN",
	[135] = "GETTABLE",
	[139] = "FORNLOOP",
	[140] = "LOADN",
	[144] = "ORK",
	[149] = "ADDK",
	[154] = "JUMPIFEQ",
	[158] = "FASTCALL2K",
	[159] = "CALL",
	[163] = "PREPVARARGS",
	[164] = "GETIMPORT",
	[168] = "FORNPREP",
	[169] = "LOADB",
	[183] = "JUMPIFLT",
	[187] = "FASTCALL1",
	[188] = "NAMECALL",
	[192] = "DUPCLOSURE",
	[193] = "CLOSEUPVALS",
	[197] = "SETLIST",
	[198] = "LOADNIL",
	[202] = "MOVE",
	[207] = "MOD",
	[216] = "DIVRK",
	[217] = "NEWCLOSURE",
	[222] = "SETUPVAL",
	[226] = "DUPTABLE",
	[231] = "AND",
	[236] = "DIV",
	[240] = "JUMPXEQKS",
	[241] = "JUMPIFEQ",
	[245] = "SUBRK",
	[251] = "GETUPVAL",
	[255] = "NEWTABLE",
}

local OPCODES = {}
for i = 0, 255 do
	OPCODES[i] = ROBLOX_OPCODES[i] or ("ROBLOX_OP_" .. tostring(i))
end

local OPS_WITH_AUX_BYTES = {
	[13] = true,
	[16] = true,
	[26] = true,
	[42] = true,
	[48] = true,
	[52] = true,
	[71] = true,
	[77] = true,
	[96] = true,
	[110] = true,
	[125] = true,
	[129] = true,
	[154] = true,
	[158] = true,
	[164] = true,
	[183] = true,
	[188] = true,
	[197] = true,
	[240] = true,
	[241] = true,
	[255] = true,
}

local OPS_WITH_AUX = {}
for opcode, _ in pairs(OPS_WITH_AUX_BYTES) do
	OPS_WITH_AUX[OPCODES[opcode]] = true
end

local CAPTURE_KINDS = {
	[0] = "VAL",
	[1] = "REF",
	[2] = "UPVAL",
	[3] = "UPREF",
}

local LUA_KEYWORDS = {
	["and"] = true,
	["break"] = true,
	["do"] = true,
	["else"] = true,
	["elseif"] = true,
	["end"] = true,
	["false"] = true,
	["for"] = true,
	["function"] = true,
	["goto"] = true,
	["if"] = true,
	["in"] = true,
	["local"] = true,
	["nil"] = true,
	["not"] = true,
	["or"] = true,
	["repeat"] = true,
	["return"] = true,
	["then"] = true,
	["true"] = true,
	["until"] = true,
	["while"] = true,
}

local function push(list, value)
	list[#list + 1] = value
end

local function basename(path)
	local match = string.match(path or "bytecode", "[^/\\]+$")
	return match or path or "bytecode"
end

local function isInteger(x)
	return x == math.floor(x)
end

local function numToString(x)
	if x ~= x or x == math.huge or x == -math.huge then
		return tostring(x)
	end
	if isInteger(x) and math.abs(x) < 1e16 then
		return string.format("%.0f", x)
	end
	return string.format("%.17g", x)
end

local function luaString(s)
	local out = { '"' }
	for i = 1, #s do
		local ch = string.sub(s, i, i)
		local byte = string.byte(s, i)
		if ch == "\\" then
			push(out, "\\\\")
		elseif ch == '"' then
			push(out, '\\"')
		elseif ch == "\n" then
			push(out, "\\n")
		elseif ch == "\r" then
			push(out, "\\r")
		elseif ch == "\t" then
			push(out, "\\t")
		elseif byte < 0x20 or byte == 0x7F then
			push(out, "\\" .. tostring(byte))
		else
			push(out, ch)
		end
	end
	push(out, '"')
	return table.concat(out)
end

local function isValidIdent(s)
	return type(s) == "string"
		and s:match("^[A-Za-z_][A-Za-z0-9_]*$") ~= nil
		and not LUA_KEYWORDS[s]
end

local function cleanIdent(s)
	if type(s) ~= "string" or s == "" then
		return nil
	end
	local cleaned = s:gsub("[^A-Za-z0-9_]", "_")
	if cleaned == "" then
		return nil
	end
	if cleaned:match("^%d") then
		cleaned = "_" .. cleaned
	end
	if LUA_KEYWORDS[cleaned] then
		cleaned = "_" .. cleaned
	end
	return cleaned
end

local function luaIndexSuffix(key)
	if type(key) == "string" then
		if isValidIdent(key) then
			return "." .. key
		end
		return "[" .. luaString(key) .. "]"
	end
	return "[" .. tostring(key) .. "]"
end

local function decodeFloat32(bits)
	local sign = bit32_band(bits, 0x80000000) ~= 0 and -1 or 1
	local exponent = bit32_rshift(bit32_band(bits, 0x7F800000), 23)
	local mantissa = bit32_band(bits, 0x007FFFFF)
	if exponent == 0xFF then
		if mantissa == 0 then
			return sign * math.huge
		end
		return 0 / 0
	end
	if exponent == 0 then
		if mantissa == 0 then
			return sign * 0
		end
		return sign * ((mantissa / 8388608) * (2 ^ -126))
	end
	return sign * ((1 + mantissa / 8388608) * (2 ^ (exponent - 127)))
end

local function decodeFloat64(low, high)
	local sign = high >= 0x80000000 and -1 or 1
	local exponent = bit32_rshift(bit32_band(high, 0x7FF00000), 20)
	local mantissaHigh = bit32_band(high, 0x000FFFFF)
	local mantissa = mantissaHigh * 4294967296 + low
	if exponent == 0x7FF then
		if mantissa == 0 then
			return sign * math.huge
		end
		return 0 / 0
	end
	if exponent == 0 then
		if mantissa == 0 then
			return sign * 0
		end
		return sign * ((mantissa / 4503599627370496) * (2 ^ -1022))
	end
	return sign * ((1 + mantissa / 4503599627370496) * (2 ^ (exponent - 1023)))
end

local Reader = {}
Reader.__index = Reader

function Reader.new(data)
	return setmetatable({
		data = data,
		pos = 1,
		len = #data,
	}, Reader)
end

function Reader:remaining()
	return self.len - self.pos + 1
end

function Reader:u8()
	local value = string.byte(self.data, self.pos, self.pos)
	if value == nil then
		error("Unexpected end of bytecode")
	end
	self.pos = self.pos + 1
	return value
end

function Reader:bytes(n)
	local value = string.sub(self.data, self.pos, self.pos + n - 1)
	if #value ~= n then
		error("Unexpected end of bytecode")
	end
	self.pos = self.pos + n
	return value
end

function Reader:u32()
	if string.unpack then
		local value
		value, self.pos = string.unpack("<I4", self.data, self.pos)
		return value
	end
	local b1, b2, b3, b4 = string.byte(self.data, self.pos, self.pos + 3)
	if b4 == nil then
		error("Unexpected end of bytecode")
	end
	self.pos = self.pos + 4
	return b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
end

function Reader:i32()
	local value = self:u32()
	if value >= 2147483648 then
		value = value - 4294967296
	end
	return value
end

function Reader:f32()
	if string.unpack then
		local value
		value, self.pos = string.unpack("<f", self.data, self.pos)
		return value
	end
	return decodeFloat32(self:u32())
end

function Reader:f64()
	if string.unpack then
		local value
		value, self.pos = string.unpack("<d", self.data, self.pos)
		return value
	end
	local low = self:u32()
	local high = self:u32()
	return decodeFloat64(low, high)
end

function Reader:varint()
	local result = 0
	local shift = 0
	while true do
		local b = self:u8()
		result = result + bit32.lshift(bit32_band(b, 0x7F), shift)
		if bit32_band(b, 0x80) == 0 then
			break
		end
		shift = shift + 7
	end
	return result
end

function Reader:varint64()
	local result = 0
	local shift = 0
	while true do
		local b = self:u8()
		result = result + (bit32_band(b, 0x7F) * (2 ^ shift))
		if bit32_band(b, 0x80) == 0 then
			break
		end
		shift = shift + 7
	end
	return result
end

function Reader:stringRef(strings)
	local idx = self:varint()
	if idx == 0 then
		return ""
	end
	return strings[idx] or ""
end

local function newConstant(kind, value)
	return {
		kind = kind,
		value = value,
	}
end

local function newLocVar(name, startpc, endpc, reg)
	return {
		name = name,
		startpc = startpc,
		endpc = endpc,
		reg = reg,
	}
end

local function newProto()
	return {
		maxstacksize = 0,
		numparams = 0,
		nups = 0,
		is_vararg = false,
		flags = 0,
		code = {},
		constants = {},
		child_proto_ids = {},
		linedefined = 0,
		debugname = "",
		lineinfo = {},
		abslineinfo = {},
		linegaplog2 = 0,
		locvars = {},
		upvalues = {},
	}
end

local function newBytecode(raw)
	return {
		version = 0,
		typesversion = 0,
		strings = {},
		protos = {},
		main_id = 0,
		raw = raw,
	}
end

local function codeWordAt(p, pc)
	return p.code[pc + 1]
end

local function constantAt(p, idx)
	return p.constants[idx + 1]
end

local function childProtoIdAt(p, idx)
	return p.child_proto_ids[idx + 1]
end

local function protoAt(bc, idx)
	return bc.protos[idx + 1]
end

local function decodeSignedD(insn)
	local d = bit32_band(bit32_rshift(insn, 16), 0xFFFF)
	if d >= 0x8000 then
		d = d - 0x10000
	end
	return d
end

local function decodeSignedE(insn)
	local e = bit32_band(bit32_rshift(insn, 8), 0xFFFFFF)
	if e >= 0x800000 then
		e = e - 0x1000000
	end
	return e
end

local function getOpLength(opName)
	return OPS_WITH_AUX[opName] and 2 or 1
end

local function parseProto(r, bc)
	local p = newProto()
	p.maxstacksize = r:u8()
	p.numparams = r:u8()
	p.nups = r:u8()
	p.is_vararg = r:u8() ~= 0

	if bc.version >= 4 then
		p.flags = r:u8()
		if bc.typesversion == 1 or bc.typesversion == 2 or bc.typesversion == 3 then
			local typesize = r:varint()
			if typesize ~= 0 then
				r:bytes(typesize)
			end
		end
	end

	local sizecode = r:varint()
	for _ = 1, sizecode do
		push(p.code, r:u32())
	end

	local sizek = r:varint()
	for _ = 1, sizek do
		local ktype = r:u8()
		if ktype == LBC_CONSTANT_NIL then
			push(p.constants, newConstant("nil", nil))
		elseif ktype == LBC_CONSTANT_BOOLEAN then
			push(p.constants, newConstant("bool", r:u8() ~= 0))
		elseif ktype == LBC_CONSTANT_NUMBER then
			push(p.constants, newConstant("number", r:f64()))
		elseif ktype == LBC_CONSTANT_STRING then
			local sidx = r:varint()
			push(p.constants, newConstant("string", sidx > 0 and (bc.strings[sidx] or "") or ""))
		elseif ktype == LBC_CONSTANT_IMPORT then
			push(p.constants, newConstant("import", r:u32()))
		elseif ktype == LBC_CONSTANT_TABLE then
			local keys = r:varint()
			local values = {}
			for _k = 1, keys do
				push(values, r:varint())
			end
			push(p.constants, newConstant("table", values))
		elseif ktype == LBC_CONSTANT_CLOSURE then
			push(p.constants, newConstant("closure", r:varint()))
		elseif ktype == LBC_CONSTANT_VECTOR then
			push(p.constants, newConstant("vector", { r:f32(), r:f32(), r:f32(), r:f32() }))
		elseif ktype == LBC_CONSTANT_TABLE_WITH_CONSTANTS then
			local keys = r:varint()
			local pairs = {}
			for _k = 1, keys do
				push(pairs, {
					k_idx = r:varint(),
					v_idx = r:i32(),
				})
			end
			push(p.constants, newConstant("table_kv", pairs))
		elseif ktype == LBC_CONSTANT_INTEGER then
			local neg = r:u8()
			local magnitude = r:varint64()
			push(p.constants, newConstant("integer", neg ~= 0 and -magnitude or magnitude))
		else
			error("Unknown constant kind: " .. tostring(ktype))
		end
	end

	local sizep = r:varint()
	for _ = 1, sizep do
		push(p.child_proto_ids, r:varint())
	end

	p.linedefined = r:varint()
	p.debugname = r:stringRef(bc.strings)

	if r:u8() ~= 0 then
		p.linegaplog2 = r:u8()
		local intervals = sizecode > 0 and (bit32_rshift(sizecode - 1, p.linegaplog2) + 1) or 0
		local last = 0
		for _ = 1, sizecode do
			last = (last + r:u8()) % 256
			push(p.lineinfo, last)
		end
		local lastLine = 0
		for _ = 1, intervals do
			lastLine = lastLine + r:i32()
			push(p.abslineinfo, lastLine)
		end
	end

	if r:u8() ~= 0 then
		local sizelocvars = r:varint()
		for _ = 1, sizelocvars do
			push(p.locvars, newLocVar(
				r:stringRef(bc.strings),
				r:varint(),
				r:varint(),
				r:u8()
			))
		end
		local sizeupvalues = r:varint()
		for _ = 1, sizeupvalues do
			push(p.upvalues, r:stringRef(bc.strings))
		end
	end

	return p
end

local function parseBytecode(data)
	local r = Reader.new(data)
	local bc = newBytecode(data)

	bc.version = r:u8()
	if bc.version == 0 then
		local msg = string.sub(data, r.pos)
		error("Bytecode contains compiler error: " .. msg)
	end
	if bc.version < LBC_VERSION_MIN or bc.version > LBC_VERSION_MAX then
		error(
			"Unsupported bytecode version "
				.. tostring(bc.version)
				.. " (expected "
				.. tostring(LBC_VERSION_MIN)
				.. ".."
				.. tostring(LBC_VERSION_MAX)
				.. ")"
		)
	end

	if bc.version >= 4 then
		bc.typesversion = r:u8()
	end

	local stringCount = r:varint()
	for _ = 1, stringCount do
		local length = r:varint()
		push(bc.strings, r:bytes(length))
	end

	if bc.typesversion == 3 then
		local idx = r:u8()
		while idx ~= 0 do
			r:stringRef(bc.strings)
			idx = r:u8()
		end
	end

	local protoCount = r:varint()
	for _ = 1, protoCount do
		push(bc.protos, parseProto(r, bc))
	end

	bc.main_id = r:varint()
	return bc
end

local function decodeImportId(iid, p)
	local count = bit32_band(bit32_rshift(iid, 30), 0x3)
	local rawIdx = {}
	if count >= 1 then
		push(rawIdx, bit32_band(bit32_rshift(iid, 20), 0x3FF))
	end
	if count >= 2 then
		push(rawIdx, bit32_band(bit32_rshift(iid, 10), 0x3FF))
	end
	if count >= 3 then
		push(rawIdx, bit32_band(iid, 0x3FF))
	end

	local parts = {}
	for _, ki in ipairs(rawIdx) do
		local c = constantAt(p, ki)
		if c and c.kind == "string" then
			push(parts, c.value)
		else
			push(parts, "k[" .. tostring(ki) .. "]")
		end
	end
	return parts, rawIdx
end

local function formatConstant(c, p)
	if c.kind == "nil" then
		return "nil"
	end
	if c.kind == "bool" then
		return c.value and "true" or "false"
	end
	if c.kind == "number" then
		return numToString(c.value)
	end
	if c.kind == "integer" then
		return tostring(c.value)
	end
	if c.kind == "string" then
		return luaString(c.value)
	end
	if c.kind == "vector" then
		local x, y, z, w = c.value[1], c.value[2], c.value[3], c.value[4]
		local text = "Vector3.new(" .. numToString(x) .. ", " .. numToString(y) .. ", " .. numToString(z) .. ")"
		if w and w ~= 0 then
			text = text .. " --[[w=" .. numToString(w) .. "]]"
		end
		return text
	end
	if c.kind == "import" then
		local parts = decodeImportId(c.value, p)
		local resolved = parts
		if #resolved > 0 then
			return table.concat(resolved, ".")
		end
		return "import(" .. string.format("0x%08x", c.value) .. ")"
	end
	if c.kind == "table" then
		return "{}"
	end
	if c.kind == "table_kv" then
		local parts = {}
		for _, pair in ipairs(c.value) do
			local keyConst = constantAt(p, pair.k_idx)
			local keyString
			if keyConst and keyConst.kind == "string" and isValidIdent(keyConst.value) then
				keyString = keyConst.value
			else
				keyString = "[" .. (keyConst and formatConstant(keyConst, p) or ("K[" .. tostring(pair.k_idx) .. "]")) .. "]"
			end
			local valueConst = constantAt(p, pair.v_idx)
			local valueString = valueConst and formatConstant(valueConst, p) or "nil"
			push(parts, keyString .. " = " .. valueString)
		end
		if #parts == 0 then
			return "{}"
		end
		return "{ " .. table.concat(parts, ", ") .. " }"
	end
	if c.kind == "closure" then
		return "<closure proto[" .. tostring(c.value) .. "]>"
	end
	return "<" .. tostring(c.kind) .. ">"
end

local function kvalLua(p, idx)
	local c = constantAt(p, idx)
	if not c then
		return "K[" .. tostring(idx) .. "]"
	end
	return formatConstant(c, p)
end

local function locvarAt(p, reg, pc)
	local best = nil
	for _, lv in ipairs(p.locvars) do
		if lv.reg == reg and isValidIdent(lv.name) and lv.startpc <= pc and pc <= lv.endpc then
			if best == nil or lv.startpc >= best.startpc then
				best = lv
			end
		end
	end
	return best
end

local function localAt(p, reg, pc)
	local lv = locvarAt(p, reg, pc)
	return lv and lv.name or nil
end

local function regRepr(regs, p, reg, pc)
	local lv = locvarAt(p, reg, pc)
	if lv then
		local tracked = regs[reg]
		if lv.startpc ~= pc
			and lv.name:match("^_r%d+_?%d*$")
			and tracked
			and tracked ~= lv.name
			and not tracked:match("^R%d+$")
			and not tracked:match("^%-?%d+%.?%d*$")
			and not tracked:match("^%-?%.%d+$")
			and tracked ~= "true"
			and tracked ~= "false"
			and tracked ~= "nil"
			and tracked:sub(1, 1) ~= '"'
			and tracked:sub(1, 1) ~= "'"
		then
			return tracked
		end
		if lv.startpc ~= pc then
			return lv.name
		end
	end
	return regs[reg] or ("R" .. tostring(reg))
end

local function assignTarget(p, reg, pc)
	local name = localAt(p, reg, pc)
	if name then
		return "local " .. name
	end
	return "local _r" .. tostring(reg)
end

local function formatHex32(value)
	return string.format("0x%08X", value)
end

local function formatDisasm(pc, opName, a, b, c, d, e, aux, p)
	local function kfmt(idx)
		return kvalLua(p, idx)
	end

	if opName == "LOADK" or opName == "LOADKC" or opName == "LOADKX" then
		local idx = opName == "LOADKC" and c or (opName == "LOADK" and d or aux)
		return opName .. " R" .. tostring(a) .. ", " .. kfmt(idx)
	end
	if opName == "GETIMPORT" then
		local parts = decodeImportId(aux or 0, p)
		local resolved = parts
		return opName .. " R" .. tostring(a) .. ", " .. (#resolved > 0 and table.concat(resolved, ".") or ("import(" .. tostring(d) .. ")"))
	end
	if opName == "GETUPVAL" then
		local name = p.upvalues[b + 1] or ("U" .. tostring(b))
		return opName .. " R" .. tostring(a) .. ", " .. name
	end
	if opName == "SETUPVAL" then
		local name = p.upvalues[b + 1] or ("U" .. tostring(b))
		return opName .. " " .. name .. ", R" .. tostring(a)
	end
	if opName == "GETTABLEKS" or opName == "SETTABLEKS" then
		local idx = aux ~= nil and aux or d
		local keyConst = constantAt(p, idx)
		local key = keyConst and keyConst.kind == "string" and keyConst.value or ("K[" .. tostring(idx) .. "]")
		return opName .. " A=" .. tostring(a) .. " B=" .. tostring(b) .. " KEY=" .. tostring(key)
	end
	if opName == "CALL" then
		return opName .. " A=" .. tostring(a) .. " args=" .. tostring(b) .. " rets=" .. tostring(c)
	end
	if opName == "RETURN" then
		return opName .. " A=" .. tostring(a) .. " count=" .. tostring(b)
	end
	if opName == "JUMP" or opName == "JUMPBACK" then
		return opName .. " -> pc" .. tostring(pc + d + 1)
	end
	if opName == "JUMPIF" or opName == "JUMPIFNOT" then
		return opName .. " R" .. tostring(a) .. " -> pc" .. tostring(pc + b + 1)
	end
	if opName == "NEWCLOSURE" then
		local childId = childProtoIdAt(p, d)
		return opName .. " R" .. tostring(a) .. ", proto[" .. tostring(childId or "?") .. "]"
	end
	if opName == "DUPCLOSURE" then
		return opName .. " R" .. tostring(a) .. ", K[" .. tostring(d) .. "]"
	end

	local parts = {
		"A=" .. tostring(a),
		"B=" .. tostring(b),
		"C=" .. tostring(c),
		"D=" .. tostring(d),
		"E=" .. tostring(e),
	}
	if aux ~= nil then
		push(parts, "AUX=" .. formatHex32(aux))
	end
	local dConst = constantAt(p, d)
	if dConst then
		push(parts, "K[D]=" .. formatConstant(dConst, p))
	end
	return opName .. " " .. table.concat(parts, " ")
end

local function disassembleProto(p, bc, protoIdx)
	local out = {}
	local name = p.debugname ~= "" and p.debugname or ("<anon#" .. tostring(protoIdx) .. ">")
	local tags = {}
	if protoIdx == bc.main_id then
		push(tags, "MAIN")
	end
	if p.is_vararg then
		push(tags, "vararg")
	end
	local tagString = #tags > 0 and (" [" .. table.concat(tags, ", ") .. "]") or ""
	push(out, "-- proto[" .. tostring(protoIdx) .. "] " .. name .. tagString .. " (params=" .. tostring(p.numparams) .. ", upvalues=" .. tostring(p.nups) .. ", maxstack=" .. tostring(p.maxstacksize) .. ", line=" .. tostring(p.linedefined) .. ")")

	if #p.upvalues > 0 then
		push(out, "-- upvalues:")
		for i, u in ipairs(p.upvalues) do
			push(out, "--   U" .. tostring(i - 1) .. " = " .. u)
		end
	end

	if #p.locvars > 0 then
		push(out, "-- local variables:")
		for _, lv in ipairs(p.locvars) do
			push(out, "--   R" .. tostring(lv.reg) .. " " .. lv.name .. " (pc " .. tostring(lv.startpc) .. ".." .. tostring(lv.endpc) .. ")")
		end
	end

	if #p.constants > 0 then
		push(out, "-- constants:")
		for i, c in ipairs(p.constants) do
			push(out, "--   K" .. tostring(i - 1) .. " = " .. formatConstant(c, p))
		end
	end

	if #p.child_proto_ids > 0 then
		local ids = {}
		for _, childId in ipairs(p.child_proto_ids) do
			push(ids, tostring(childId))
		end
		push(out, "-- child protos: {" .. table.concat(ids, ", ") .. "}")
	end

	push(out, "-- code:")
	local pc = 0
	local codeLen = #p.code
	while pc < codeLen do
		local insn = codeWordAt(p, pc)
		local op = bit32_band(insn, 0xFF)
		local opName = OPCODES[op] or ("ROBLOX_OP_" .. tostring(op))
		local a = bit32_band(bit32_rshift(insn, 8), 0xFF)
		local b = bit32_band(bit32_rshift(insn, 16), 0xFF)
		local c = bit32_band(bit32_rshift(insn, 24), 0xFF)
		local d = decodeSignedD(insn)
		local e = decodeSignedE(insn)
		local aux = nil
		if OPS_WITH_AUX[opName] and pc + 1 < codeLen then
			aux = codeWordAt(p, pc + 1)
		end
		local line = formatDisasm(pc, opName, a, b, c, d, e, aux, p)
		local endMarker = pc + getOpLength(opName) == codeLen and "  <-- end of proto" or ""
		push(out, string.format("  [%04d] %s  %s%s", pc, formatHex32(insn), line, endMarker))
		pc = pc + getOpLength(opName)
	end

	return table.concat(out, "\n")
end

local function scanJumpTargets(p)
	local targets = {}
	local pc = 0
	local codeLen = #p.code
	while pc < codeLen do
		local insn = codeWordAt(p, pc)
		local op = bit32_band(insn, 0xFF)
		local opName = OPCODES[op] or ""
		if opName == "JUMPIF" or opName == "JUMPIFNOT" then
			targets[pc + bit32_band(bit32_rshift(insn, 16), 0xFF) + 1] = true
		elseif opName == "JUMP"
			or opName == "JUMPBACK"
			or opName == "JUMPIFEQ"
			or opName == "JUMPIFLE"
			or opName == "JUMPIFLT"
			or opName == "JUMPIFNOTEQ"
			or opName == "JUMPIFNOTLE"
			or opName == "JUMPIFNOTLT"
			or opName == "JUMPXLEKN"
			or opName == "JUMPXEQKNIL"
			or opName == "JUMPXEQKB"
			or opName == "JUMPXEQKN"
			or opName == "JUMPXEQKS"
			or opName == "FORNPREP"
			or opName == "FORNLOOP"
			or opName == "FORGPREP"
			or opName == "FORGPREP_INEXT"
			or opName == "FORGPREP_NEXT"
			or opName == "FORGLOOP"
		then
			targets[pc + decodeSignedD(insn) + 1] = true
		elseif opName == "JUMPX" then
			targets[pc + decodeSignedE(insn) + 1] = true
		elseif opName == "LOADB" then
			local skip = bit32_band(bit32_rshift(insn, 24), 0xFF)
			if skip ~= 0 then
				targets[pc + skip + 1] = true
			end
		elseif opName == "FASTCALL"
			or opName == "FASTCALL1"
			or opName == "FASTCALL2"
			or opName == "FASTCALL2K"
			or opName == "FASTCALL3"
		then
			local jump = bit32_band(bit32_rshift(insn, 24), 0xFF)
			if jump ~= 0 then
				targets[pc + jump + 1] = true
			end
		end
		pc = pc + (opName ~= "" and getOpLength(opName) or 1)
	end
	return targets
end

local function emitDecompileLine(pc, opName, a, b, c, d, e, aux, p, bc, regs, indent)
	local function rname(reg)
		return regRepr(regs, p, reg, pc)
	end

	local function assignLocalOrExisting(reg, value)
		local lv = locvarAt(p, reg, pc)
		if lv then
			local prefix = lv.startpc == pc and "local " or ""
			regs[reg] = lv.name
			return indent .. prefix .. lv.name .. " = " .. value
		end
		return nil
	end

	if opName == "LOADNIL" then
		regs[a] = "nil"
		local assigned = assignLocalOrExisting(a, "nil")
		return assigned, 0
	end

	if opName == "LOADB" then
		local value = b ~= 0 and "true" or "false"
		regs[a] = value
		local suffix = c ~= 0 and ("  -- skip " .. tostring(c)) or ""
		local assigned = assignLocalOrExisting(a, value .. suffix)
		if assigned then
			return assigned, 0
		end
		return suffix ~= "" and (indent .. "-- LOADB R" .. tostring(a) .. " = " .. value .. suffix) or nil, 0
	end

	if opName == "LOADN" then
		regs[a] = tostring(d)
		return assignLocalOrExisting(a, tostring(d)), 0
	end

	if opName == "LOADK" or opName == "LOADKC" or opName == "LOADKX" then
		local idx = opName == "LOADKC" and c or (opName == "LOADK" and d or aux)
		regs[a] = kvalLua(p, idx)
		return assignLocalOrExisting(a, regs[a]), 0
	end

	if opName == "MOVE" then
		local src = rname(b)
		local targetLocal = localAt(p, a, pc)
		if targetLocal then
			regs[a] = targetLocal
			return indent .. targetLocal .. " = " .. src, 0
		end
		if a < p.numparams then
			local paramName = localAt(p, a, 0) or ("arg" .. tostring(a))
			if regs[a] == paramName and src ~= paramName then
				return indent .. paramName .. " = " .. src, 0
			end
		end
		regs[a] = src
		return nil, 0
	end

	if opName == "GETIMPORT" then
		local parts = decodeImportId(aux or 0, p)
		local resolved = parts
		local path = #resolved > 0 and table.concat(resolved, ".") or ("import(" .. tostring(d) .. ")")
		local targetLocal = localAt(p, a, pc)
		if targetLocal then
			regs[a] = targetLocal
			return indent .. "local " .. targetLocal .. " = " .. path, 0
		end
		regs[a] = path
		return nil, 0
	end

	if opName == "GETUPVAL" then
		local upvalueName = p.upvalues[b + 1] or ("U" .. tostring(b))
		local targetLocal = localAt(p, a, pc)
		if targetLocal then
			regs[a] = targetLocal
			return indent .. "local " .. targetLocal .. " = " .. upvalueName, 0
		end
		regs[a] = upvalueName
		return nil, 0
	end

	if opName == "SETUPVAL" then
		local upvalueName = p.upvalues[b + 1] or ("U" .. tostring(b))
		return indent .. upvalueName .. " = " .. rname(a), 0
	end

	if opName == "CLOSEUPVALS" then
		return nil, 0
	end

	if opName == "GETGLOBAL" then
		local keyConst = aux ~= nil and constantAt(p, aux) or nil
		local key = keyConst and keyConst.value or ("K[" .. tostring(aux) .. "]")
		regs[a] = key
		local targetLocal = localAt(p, a, pc)
		if targetLocal then
			return indent .. "local " .. targetLocal .. " = " .. tostring(key), 0
		end
		return nil, 0
	end

	if opName == "SETGLOBAL" then
		local keyConst = aux ~= nil and constantAt(p, aux) or nil
		local key = keyConst and keyConst.value or ("K[" .. tostring(aux) .. "]")
		return indent .. tostring(key) .. " = " .. rname(a), 0
	end

	if opName == "GETTABLE" then
		local expr = rname(b) .. "[" .. rname(c) .. "]"
		local targetLocal = localAt(p, a, pc)
		if targetLocal then
			regs[a] = targetLocal
			return indent .. "local " .. targetLocal .. " = " .. expr, 0
		end
		regs[a] = expr
		return nil, 0
	end

	if opName == "SETTABLE" then
		return indent .. rname(b) .. "[" .. rname(c) .. "] = " .. rname(a), 0
	end

	if opName == "GETTABLEKS" then
		local idx = aux ~= nil and aux or d
		local keyConst = constantAt(p, idx)
		local key = keyConst and keyConst.kind == "string" and keyConst.value or ("K[" .. tostring(idx) .. "]")
		local expr = rname(b) .. luaIndexSuffix(key)
		local targetLocal = localAt(p, a, pc)
		if targetLocal then
			regs[a] = targetLocal
			return indent .. "local " .. targetLocal .. " = " .. expr, 0
		end
		regs[a] = expr
		return nil, 0
	end

	if opName == "SETTABLEKS" then
		local idx = aux ~= nil and aux or d
		local keyConst = constantAt(p, idx)
		local key = keyConst and keyConst.kind == "string" and keyConst.value or ("K[" .. tostring(idx) .. "]")
		return indent .. rname(b) .. luaIndexSuffix(key) .. " = " .. rname(a), 0
	end

	if opName == "GETTABLEN" then
		regs[a] = rname(b) .. "[" .. tostring(c + 1) .. "]"
		return nil, 0
	end

	if opName == "SETTABLEN" then
		return indent .. rname(b) .. "[" .. tostring(c + 1) .. "] = " .. rname(a), 0
	end

	if opName == "NAMECALL" then
		local keyConst = aux ~= nil and constantAt(p, aux) or nil
		local key = keyConst and keyConst.value or ("K[" .. tostring(aux) .. "]")
		regs[a] = rname(b) .. ":" .. tostring(key)
		regs[a + 1] = rname(b)
		return nil, 0
	end

	if opName == "CALL" then
		local callee = regs[a] or ("R" .. tostring(a))
		local isNamecall = string.find(callee:match("[^.]+$") or callee, ":", 1, true) ~= nil
		local args
		if b == 0 then
			local prev = regs[a + 1]
			args = prev and prev ~= ("R" .. tostring(a + 1)) and prev or "..."
		else
			local argParts = {}
			for reg = a + 1, a + b - 1 do
				push(argParts, rname(reg))
			end
			if isNamecall and #argParts > 0 then
				table.remove(argParts, 1)
			end
			args = table.concat(argParts, ", ")
		end
		local callExpr = callee .. "(" .. args .. ")"
		if c == 1 then
			return indent .. callExpr, 0
		end
		if c == 0 then
			regs[a] = callExpr
			return nil, 0
		end
		local names = {}
		for k = 0, c - 2 do
			local name = localAt(p, a + k, pc + 1) or ("_r" .. tostring(a + k))
			push(names, name)
			regs[a + k] = name
		end
		return indent .. "local " .. table.concat(names, ", ") .. " = " .. callExpr, 0
	end

	if opName == "RETURN" then
		if b == 0 then
			return indent .. "return " .. rname(a), 0
		end
		if b == 1 then
			return indent .. "return", 0
		end
		local values = {}
		for i = 0, b - 2 do
			push(values, rname(a + i))
		end
		return indent .. "return " .. table.concat(values, ", "), 0
	end

	if opName == "NEWCLOSURE" then
		local childId = childProtoIdAt(p, d)
		regs[a] = "<closure proto[" .. tostring(childId or "?") .. "]>"
		return nil, 0
	end

	if opName == "DUPCLOSURE" then
		regs[a] = "<closure K" .. tostring(d) .. ">"
		return nil, 0
	end

	if opName == "NEWTABLE" then
		regs[a] = localAt(p, a, pc) or ("_r" .. tostring(a))
		return indent .. assignTarget(p, a, pc) .. " = {}", 0
	end

	if opName == "DUPTABLE" then
		regs[a] = localAt(p, a, pc) or ("_r" .. tostring(a))
		return indent .. assignTarget(p, a, pc) .. " = " .. kvalLua(p, d), 0
	end

	if opName == "SETLIST" then
		local startIndex = aux ~= nil and aux or 1
		local count = c - 1
		if count <= 0 then
			return nil, 0
		end
		local tableExpr = rname(a)
		local lhs = {}
		local rhs = {}
		for i = 0, count - 1 do
			push(lhs, tableExpr .. "[" .. tostring(startIndex + i) .. "]")
			push(rhs, rname(b + i))
		end
		return indent .. table.concat(lhs, ", ") .. " = " .. table.concat(rhs, ", "), 0
	end

	if opName == "CONCAT" then
		local parts = {}
		for reg = b, c do
			push(parts, rname(reg))
		end
		regs[a] = table.concat(parts, " .. ")
		return nil, 0
	end

	if opName == "ADD" or opName == "SUB" or opName == "MUL" or opName == "DIV" or opName == "MOD" or opName == "POW" or opName == "IDIV" then
		local symbols = {
			ADD = "+",
			SUB = "-",
			MUL = "*",
			DIV = "/",
			MOD = "%",
			POW = "^",
			IDIV = "//",
		}
		regs[a] = "(" .. rname(b) .. " " .. symbols[opName] .. " " .. rname(c) .. ")"
		return nil, 0
	end

	if opName == "ADDK" or opName == "SUBK" or opName == "MULK" or opName == "DIVK" or opName == "MODK" or opName == "POWK" or opName == "IDIVK" then
		local symbols = {
			ADDK = "+",
			SUBK = "-",
			MULK = "*",
			DIVK = "/",
			MODK = "%",
			POWK = "^",
			IDIVK = "//",
		}
		regs[a] = "(" .. rname(b) .. " " .. symbols[opName] .. " " .. kvalLua(p, c) .. ")"
		return nil, 0
	end

	if opName == "SUBRK" or opName == "DIVRK" then
		local symbol = opName == "SUBRK" and "-" or "/"
		regs[a] = "(" .. kvalLua(p, b) .. " " .. symbol .. " " .. rname(c) .. ")"
		return nil, 0
	end

	if opName == "AND" or opName == "OR" then
		local symbol = opName == "AND" and "and" or "or"
		regs[a] = "(" .. rname(b) .. " " .. symbol .. " " .. rname(c) .. ")"
		return nil, 0
	end

	if opName == "ANDK" or opName == "ORK" then
		local symbol = opName == "ANDK" and "and" or "or"
		regs[a] = "(" .. rname(b) .. " " .. symbol .. " " .. kvalLua(p, c) .. ")"
		return nil, 0
	end

	if opName == "NOT" then
		regs[a] = "(not " .. rname(b) .. ")"
		return nil, 0
	end

	if opName == "MINUS" then
		regs[a] = "(-" .. rname(b) .. ")"
		return nil, 0
	end

	if opName == "LENGTH" then
		regs[a] = "(#" .. rname(b) .. ")"
		return nil, 0
	end

	if opName == "JUMP" or opName == "JUMPBACK" then
		return indent .. "goto pc" .. tostring(pc + d + 1), 0
	end

	if opName == "JUMPIF" or opName == "JUMPIFNOT" then
		local cond = opName == "JUMPIF" and rname(a) or ("not " .. rname(a))
		return indent .. "if " .. cond .. " then goto pc" .. tostring(pc + b + 1) .. " end", 0
	end

	if opName == "JUMPIFEQ" or opName == "JUMPIFLE" or opName == "JUMPIFLT" or opName == "JUMPIFNOTEQ" or opName == "JUMPIFNOTLE" or opName == "JUMPIFNOTLT" then
		local notFlag = bit32_band(bit32_rshift(aux or 0, 31), 1)
		local rb = bit32_band(aux or 0, 0x7FFFFFFF)
		local baseSymbols = {
			JUMPIFEQ = "==",
			JUMPIFLE = "<=",
			JUMPIFLT = "<",
			JUMPIFNOTEQ = "~=",
			JUMPIFNOTLE = ">",
			JUMPIFNOTLT = ">=",
		}
		local negate = {
			["=="] = "~=",
			["~="] = "==",
			["<="] = ">",
			[">"] = "<=",
			["<"] = ">=",
			[">="] = "<",
		}
		local symbol = baseSymbols[opName]
		if notFlag ~= 0 then
			symbol = negate[symbol]
		end
		return indent .. "if " .. rname(a) .. " " .. symbol .. " " .. rname(rb) .. " then goto pc" .. tostring(pc + d + 1) .. " end", 0
	end

	if opName == "JUMPXLEKN" then
		local notFlag = bit32_band(bit32_rshift(aux or 0, 31), 1)
		local kidx = bit32_band(aux or 0, 0x7FFFFFFF)
		local symbol = notFlag ~= 0 and ">" or "<="
		return indent .. "if " .. rname(a) .. " " .. symbol .. " " .. kvalLua(p, kidx) .. " then goto pc" .. tostring(pc + d + 1) .. " end", 0
	end

	if opName == "JUMPX" then
		return indent .. "goto pc" .. tostring(pc + e + 1), 0
	end

	if opName == "JUMPXEQKNIL" or opName == "JUMPXEQKB" or opName == "JUMPXEQKN" or opName == "JUMPXEQKS" then
		local notFlag = bit32_rshift(aux or 0, 31)
		local cmpOp = notFlag ~= 0 and "~=" or "=="
		local rhs
		if opName == "JUMPXEQKNIL" then
			rhs = "nil"
		elseif opName == "JUMPXEQKB" then
			rhs = bit32_band(aux or 0, 1) ~= 0 and "true" or "false"
		else
			local kidx = bit32_band(aux or 0, 0xFFFFFF)
			rhs = kvalLua(p, kidx)
		end
		return indent .. "if " .. rname(a) .. " " .. cmpOp .. " " .. rhs .. " then goto pc" .. tostring(pc + d + 1) .. " end", 0
	end

	if opName == "GETVARARGS" then
		regs[a] = "..."
		return nil, 0
	end

	if opName == "PREPVARARGS" then
		return nil, 0
	end

	if opName == "FORNPREP" then
		local init = regs[a + 2] or ("R" .. tostring(a + 2))
		local limit = regs[a] or ("R" .. tostring(a))
		local step = regs[a + 1] or ("R" .. tostring(a + 1))
		return indent .. "-- FORNPREP R" .. tostring(a) .. " init=" .. init .. " limit=" .. limit .. " step=" .. step .. " -> pc" .. tostring(pc + d + 1), 0
	end

	if opName == "FORNLOOP" then
		return indent .. "-- FORNLOOP R" .. tostring(a) .. " -> pc" .. tostring(pc + d + 1), 0
	end

	if opName == "FORGPREP" or opName == "FORGPREP_INEXT" or opName == "FORGPREP_NEXT" then
		local iterNote = ""
		if opName == "FORGPREP_INEXT" then
			local iterExpr = regs[a] or ("R" .. tostring(a))
			iterNote = " iter=ipairs(" .. iterExpr .. ")"
		end
		regs[a + 3] = "R" .. tostring(a + 3)
		regs[a + 4] = "R" .. tostring(a + 4)
		regs[a + 5] = "R" .. tostring(a + 5)
		return indent .. "-- " .. opName .. " R" .. tostring(a) .. iterNote .. " -> pc" .. tostring(pc + d + 1), 0
	end

	if opName == "FORGLOOP" then
		local nvars = bit32_band(aux or 0, 0xFF)
		return indent .. "-- generic-for loop R" .. tostring(a) .. ".. (vars=" .. tostring(nvars) .. ") -> pc" .. tostring(pc + d + 1), 0
	end

	if opName == "CAPTURE" or opName == "COVERAGE" or opName == "BREAK" or opName == "NOP" or opName == "NATIVECALL" then
		return nil, 0
	end

	if opName == "FASTCALL" or opName == "FASTCALL1" or opName == "FASTCALL2" or opName == "FASTCALL2K" or opName == "FASTCALL3" then
		return nil, 0
	end

	local hints = {}
	local dConst = constantAt(p, d)
	if dConst then
		push(hints, "K[D]=" .. formatConstant(dConst, p))
	end
	local childId = childProtoIdAt(p, d)
	if childId ~= nil then
		push(hints, "child#" .. tostring(d) .. "=proto[" .. tostring(childId) .. "]")
	end
	local bConst = constantAt(p, b)
	if bConst and opName ~= "LOADN" and opName ~= "MOVE" then
		push(hints, "K[B]=" .. formatConstant(bConst, p))
	end
	local cConst = constantAt(p, c)
	if cConst then
		push(hints, "K[C]=" .. formatConstant(cConst, p))
	end
	if aux ~= nil then
		local auxConst = constantAt(p, aux)
		if auxConst then
			push(hints, "AUX=" .. formatConstant(auxConst, p))
		else
			push(hints, "AUX=" .. formatHex32(aux))
		end
	end
	local hintText = #hints > 0 and ("  -- " .. table.concat(hints, ", ")) or ""
	return indent .. "-- " .. opName .. " A=" .. tostring(a) .. " B=" .. tostring(b) .. " C=" .. tostring(c) .. " D=" .. tostring(d) .. hintText, 0
end

-- ===========================================================================
-- BEAUTIFICATION / CONTROL-FLOW LIFTING (goto-free Luau implementation)
-- ===========================================================================

-- Lua pattern magic-char escape (equivalent to Python re.escape)
local function luaPE(s)
	return (s:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1"))
end

-- Check if string s matches label pattern  ^(\s*)::(pc\d+)::\s*$
local function matchLbl(s)
	return s:match("^(%s*)::([Pp][Cc]%d+)::%s*$")
end

-- Check if string s matches if-goto pattern ^(\s*)if (.+) then goto (pc\d+) end\s*$
local function matchIfGoto(s)
	return s:match("^(%s*)if%s+(.+)%s+then%s+goto%s+(pc%d+)%s+end%s*$")
end

-- Check if string s matches goto pattern ^(\s*)goto (pc\d+)\s*$
local function matchGoto(s)
	return s:match("^(%s*)goto%s+(pc%d+)%s*$")
end

-- Check if string s matches if-open pattern ^(\s*)if (.+) then\s*$
local function matchIfOpen(s)
	return s:match("^(%s*)if%s+(.+)%s+then%s*$")
end

-- Check if string s matches end line ^(\s*)end\s*$
local function matchEnd(s)
	return s:match("^(%s*)end%s*$")
end

-- Check if string s matches return line ^(\s*)(return...)\s*$
local function matchReturn(s)
	return s:match("^(%s*)(return%s*.*)%s*$")
end

-- Check if string s matches for-open ^(\s*)for\b.*\bdo\s*$
local function matchForOpen(s)
	return s:match("^(%s*)for%s.+%sdo%s*$")
end

-- Check if string s matches loop-open (for/while/repeat)
local function matchLoopOpen(s)
	local ind = s:match("^(%s*)for%s.+%sdo%s*$")
	if ind then return ind end
	ind = s:match("^(%s*)while%s.+%sdo%s*$")
	if ind then return ind end
	ind = s:match("^(%s*)repeat%s*$")
	if ind then return ind end
	return nil
end

-- Collect all indices in lines where `goto TARGET` appears
local function labelRefs(lines, target)
	local pat = "%f[%a_]goto%s+" .. luaPE(target) .. "%f[^%a_%d]"
	local result = {}
	for i, ln in ipairs(lines) do
		if ln:find(pat) then
			result[#result+1] = i
		end
	end
	return result
end

-- Negate a Lua condition string
local function negateCond(cond)
	cond = cond:match("^%s*(.-)%s*$")
	-- strip balanced outer parens
	while cond:sub(1,1) == "(" and cond:sub(-1) == ")" do
		local depth = 0
		local balanced = true
		for i = 1, #cond - 1 do
			local ch = cond:sub(i,i)
			if ch == "(" then depth = depth + 1
			elseif ch == ")" then
				depth = depth - 1
				if depth == 0 then balanced = false; break end
			end
		end
		if not balanced then break end
		cond = cond:sub(2, -2):match("^%s*(.-)%s*$")
	end
	if cond:sub(1,4) == "not " then
		return cond:sub(5):match("^%s*(.-)%s*$")
	end
	local ops = {
		{" == ", " ~= "}, {" ~= ", " == "},
		{" <= ", " > "}, {" >= ", " < "},
		{" < ", " >= "}, {" > ", " <= "},
	}
	for _, pair in ipairs(ops) do
		local op, neg = pair[1], pair[2]
		local idx = cond:find(luaPE(op), 1, true)
		if idx then
			-- ensure only one occurrence
			if not cond:find(luaPE(op), idx + 1, true) then
				return cond:sub(1, idx-1) .. neg .. cond:sub(idx + #op)
			end
		end
	end
	if cond == "true" then return "false" end
	if cond == "false" then return "true" end
	return "not (" .. cond .. ")"
end

-- Wrap condition for use in `and` chain
local function wrapForAnd(s)
	s = s:match("^%s*(.-)%s*$")
	if s:sub(1,1) == "(" and s:sub(-1) == ")" then
		local depth = 0
		local balanced = true
		for i = 1, #s - 1 do
			local ch = s:sub(i,i)
			if ch == "(" then depth = depth + 1
			elseif ch == ")" then
				depth = depth - 1
				if depth == 0 then balanced = false; break end
			end
		end
		if balanced and depth == 1 then return s end
	end
	if s:match("^%s*not%s+[%a_][%a_%d%.]*%s*$") then return s end
	if s:match("^[%a_][%a_%d%.]*%s*$") then return s end
	return "(" .. s .. ")"
end

-- Collapse multi-line `if X then\n  goto pcN\nend` -> single line
local function collapseTrivialIf(lines)
	local out = {}
	local j = 1
	while j <= #lines do
		local collapsed = false
		if j + 2 <= #lines then
			local ind, cond = matchIfOpen(lines[j])
			local _, tgt = matchGoto(lines[j+1])
			local mend = matchEnd(lines[j+2])
			if ind and tgt and mend then
				out[#out+1] = ind .. "if " .. cond .. " then goto " .. tgt .. " end"
				j = j + 3
				collapsed = true
			end
		end
		if not collapsed then
			out[#out+1] = lines[j]
			j = j + 1
		end
	end
	return out
end

-- Drop orphan labels (not referenced by any goto)
local function dropOrphanLabels(lines)
	local used = {}
	for _, ln in ipairs(lines) do
		for tgt in ln:gmatch("%f[%a_]goto%s+(pc%d+)%f[^%a_%d]") do
			used[tgt] = true
		end
	end
	local out = {}
	for _, ln in ipairs(lines) do
		local _, lbl = matchLbl(ln)
		if lbl and not used[lbl] then
			-- skip
		else
			out[#out+1] = ln
		end
	end
	return out
end

-- Normalize `(X + -N)` -> `(X - N)`
local function normalizeNegativeAddk(lines)
	local out = {}
	for _, line in ipairs(lines) do
		local prev = nil
		local cur = line
		while cur ~= prev do
			prev = cur
			cur = cur:gsub("(%([^()]-) %+ %-(%d+%.?%d*)", "%1 - %2")
		end
		out[#out+1] = cur
	end
	return out
end

-- Lift numeric for: FORNPREP/FORNLOOP comments -> `for i = init, limit, step do`
local function liftNumericFor(lines, indentUnit)
	local FORNPREP_PAT = "^(%s*)%-%- FORNPREP R(%d+) init=(.+) limit=(.+) step=(.+) %-> pc(%d+)%s*$"
	local FORNLOOP_PAT = "^(%s*)%-%- FORNLOOP R(%d+) %-> pc(%d+)%s*$"
	local out = {}
	local i = 1
	while i <= #lines do
		local ind, base, initE, limitE, stepE, _tgt = lines[i]:match(FORNPREP_PAT)
		if ind then
			base = tonumber(base)
			-- find matching FORNLOOP
			local loopIdx = nil
			for k = i + 1, #lines do
				local _, lb = lines[k]:match(FORNLOOP_PAT)
				if lb and tonumber(lb) == base then
					loopIdx = k
					break
				end
			end
			if loopIdx then
				local body = {}
				for k = i + 1, loopIdx - 1 do body[#body+1] = lines[k] end
				local loopVar = "_i"
				local bodyText = table.concat(body, "\n")
				local best, bestCount = "_i", 0
				for nm in bodyText:gmatch("(_i[_%d]*)") do
					local cnt = 0
					for _ in bodyText:gmatch("%f[%a_]" .. luaPE(nm) .. "%f[^%a_%d]") do cnt = cnt + 1 end
					if cnt > bestCount then
						best = nm
						bestCount = cnt
					end
				end
				if bestCount > 0 then loopVar = best end
				local renamed = {}
				for _, bl in ipairs(body) do
					renamed[#renamed+1] = bl:gsub("%f[%a_R]R" .. tostring(base+2) .. "%f[^%a_%d]", loopVar)
				end
				if stepE:match("^%s*1%s*$") then
					out[#out+1] = ind .. "for " .. loopVar .. " = " .. initE .. ", " .. limitE .. " do"
				else
					out[#out+1] = ind .. "for " .. loopVar .. " = " .. initE .. ", " .. limitE .. ", " .. stepE .. " do"
				end
				for _, bl in ipairs(renamed) do
					if bl:match("%S") then out[#out+1] = indentUnit .. bl
					else out[#out+1] = bl end
				end
				out[#out+1] = ind .. "end"
				i = loopIdx + 1
			else
				out[#out+1] = lines[i]
				i = i + 1
			end
		else
			out[#out+1] = lines[i]
			i = i + 1
		end
	end
	return out
end

-- Lift generic for: FORGPREP/FORGLOOP comments -> `for k, v in iter do`
local function liftGenericFor(lines, indentUnit)
	local function matchForgPrep(ln)
		local ind, base, tgt = ln:match("^(%s*)%-%-%s*FORGPREP[_A-Z]*%s+R(%d+)%s+%->%s+pc(%d+)%s*$")
		if ind then return ind, tonumber(base), tgt end
		-- with iter= annotation
		ind, base, tgt = ln:match("^(%s*)%-%-%s*FORGPREP[_A-Z]*%s+R(%d+)%s+iter=.-%s+%->%s+pc(%d+)%s*$")
		if ind then return ind, tonumber(base), tgt end
		return nil
	end
	local function matchForgLoop(ln)
		local ind, base, nvars, tgt = ln:match("^(%s*)%-%-%s*generic%-for loop R(%d+)%.%.%s+%(vars=(%d+)[^)]*%)%s+%->%s+pc(%d+)%s*$")
		if ind then return ind, tonumber(base), tonumber(nvars), tgt end
		return nil
	end
	local out = {}
	local i = 1
	while i <= #lines do
		local ind, base, loopTgt = matchForgPrep(lines[i])
		if ind then
			local labelPat = "^%s*::pc" .. loopTgt .. "::%s*$"
			local loopIdx = nil
			for k = i + 1, #lines do
				if lines[k]:match(labelPat) then
					loopIdx = k
					break
				end
			end
			local loopCmtIdx = nil
			local nvars = 2
			if loopIdx then
				for k = loopIdx + 1, math.min(#lines, loopIdx + 3) do
					local _, lb, nv = matchForgLoop(lines[k])
					if lb and lb == base then
						loopCmtIdx = k
						nvars = nv or 2
						break
					end
				end
			end
			if not loopCmtIdx then
				for k = i + 1, #lines do
					local _, lb, nv = matchForgLoop(lines[k])
					if lb and lb == base then
						loopCmtIdx = k
						loopIdx = k
						nvars = nv or 2
						break
					end
				end
			end
			if loopCmtIdx then
				local iterExpr = nil
				for k = #out, math.max(1, #out - 12), -1 do
					local _, rn, rhs = out[k]:match("^(%s*)local%s+_r(%d+)%s*=%s*(.*)$")
					if rn and tonumber(rn) == base then
						iterExpr = rhs:match("^(.-)%s*$")
						table.remove(out, k)
						break
					end
					local _ind2, names, rhs2 = out[k]:match("^(%s*)local%s+([%a_][%a_%d%s,]-)%s*=%s*(.*)$")
					if names and rhs2 then
						local firstName = names:match("^([%a_][%a_%d]*)")
						if firstName == "_r" .. tostring(base) or rhs2:match("pairs%s*%(") or rhs2:match("ipairs%s*%(") then
							iterExpr = rhs2:match("^(.-)%s*$")
							table.remove(out, k)
							break
						end
					end
				end
				local body = {}
				for k = i + 1, (loopIdx or loopCmtIdx) - 1 do body[#body+1] = lines[k] end
				local names
				if nvars == 2 then names = {"_k", "_v"}
				elseif nvars == 1 then names = {"_v"}
				else names = {}; for n = 1, nvars do names[n] = "_v" .. n end end
				local renamed = {}
				for _, bl in ipairs(body) do
					for ni, nm in ipairs(names) do
						bl = bl:gsub("%f[%a_R]R" .. tostring(base + 2 + ni) .. "%f[^%a_%d]", nm)
					end
					renamed[#renamed+1] = bl
				end
				local iterStr = iterExpr or ("-- iter R" .. tostring(base))
				out[#out+1] = ind .. "for " .. table.concat(names, ", ") .. " in " .. iterStr .. " do"
				for _, bl in ipairs(renamed) do
					if bl:match("%S") then out[#out+1] = indentUnit .. bl
					else out[#out+1] = bl end
				end
				out[#out+1] = ind .. "end"
				i = loopCmtIdx + 1
			else
				out[#out+1] = lines[i]
				i = i + 1
			end
		else
			out[#out+1] = lines[i]
			i = i + 1
		end
	end
	return out
end

-- Remove unreachable code after return/continue
local function removeUnreachableAfterReturn(lines)
	local out = {}
	local skipIndent = nil
	for _, ln in ipairs(lines) do
		if skipIndent ~= nil then
			local stripped = ln:match("^%s*(.-)%s*$")
			if stripped and stripped ~= "" then
				local lead = ln:match("^(%s*)") or ""
				local ind = #lead
				local isTerminator = (
					ind <= skipIndent and (
						ind < skipIndent
						or stripped == "end" or stripped == "else" or stripped == "until"
						or stripped:sub(1,7) == "elseif " or stripped:sub(1,6) == "else "
					)
				)
				if isTerminator or matchLbl(ln) then
					skipIndent = nil
					out[#out+1] = ln
				end
			end
		else
			local ind, rest = matchReturn(ln)
			if ind and rest then
				skipIndent = #ind
			elseif ln:match("^%s*continue%s*$") then
				skipIndent = #(ln:match("^(%s*)") or "")
			end
			out[#out+1] = ln
		end
	end
	return out
end

-- Drop redundant trailing `return` before closing `end`
local function dropTrailingReturn(lines)
	if #lines == 0 then return lines end
	local last = #lines
	while last >= 1 and not lines[last]:match("%S") do last = last - 1 end
	if last < 1 then return lines end
	if not matchEnd(lines[last]) then return lines end
	local endIndent = lines[last]:match("^(%s*)")
	local prev = last - 1
	while prev >= 1 and not lines[prev]:match("%S") do prev = prev - 1 end
	if prev < 1 then return lines end
	local ri, rtext = matchReturn(lines[prev])
	if not ri or not rtext then return lines end
	if rtext:match("^%s*$") then return lines end  -- non-bare return
	if rtext:match("^return%s+.") then return lines end  -- has value
	local retIndent = ri
	if #retIndent <= #endIndent then return lines end
	-- verify nothing shallower between prev and last
	for k = prev + 1, last - 1 do
		if lines[k]:match("%S") then
			local ki = lines[k]:match("^(%s*)")
			if #ki <= #endIndent then return lines end
		end
	end
	local out = {}
	for k = 1, #lines do
		if k ~= prev then out[#out+1] = lines[k] end
	end
	return out
end

-- `else { if X then BODY end }` -> `elseif X then BODY`
local function liftElseifPatterns(lines)
	local out = {}
	for _, ln in ipairs(lines) do out[#out+1] = ln end
	local i = 1
	while i <= #out do
		local transformed = false
		local outerInd = out[i]:match("^(%s*)else%s*$")
		if outerInd and i + 1 <= #out then
			local innerExtra, cond = out[i+1]:match("^" .. luaPE(outerInd) .. "(%s+)if%s+(.-)%s+then%s*$")
			if innerExtra and cond then
				local innerInd = outerInd .. innerExtra
				local depth = 1
				local j = i + 2
				local hasElseAtInner = false
				while j <= #out and depth > 0 do
					local s = out[j]:match("^%s*(.-)%s*$")
					local li = out[j]:match("^(%s*)")
					if #li == #innerInd then
						if s == "else" or s:sub(1,7) == "elseif " then hasElseAtInner = true end
						if s:sub(1,3) == "if " or s:sub(1,4) == "for " or s:sub(1,6) == "while " or s == "repeat" or s == "do" then
							depth = depth + 1
						elseif s == "end" or s:sub(1,6) == "until " then
							depth = depth - 1
						end
					end
					j = j + 1
				end
				j = j - 1
				if depth == 0 and j + 1 <= #out and not hasElseAtInner and matchEnd(out[j+1]) then
					local outerEndInd = out[j+1]:match("^(%s*)")
					if outerEndInd == outerInd then
						local newBlock = {outerInd .. "elseif " .. cond .. " then"}
						for k = i + 2, j - 1 do
							local ln2 = out[k]
							if ln2:sub(1, #innerExtra) == innerExtra then newBlock[#newBlock+1] = ln2:sub(#innerExtra+1)
							else newBlock[#newBlock+1] = ln2 end
						end
						for k = 1, #newBlock do out[i + k - 1] = newBlock[k] end
						for _ = #newBlock + i, j + 1 do table.remove(out, #newBlock + i) end
						transformed = true
					end
				end
			end
		end
		if not transformed then
			i = i + 1
		end
	end
	return out
end

-- `if A then if B then BODY end end` -> `if A and B then BODY end`
local function collapseSingleIfChain(lines)
	local changed = true
	while changed do
		changed = false
		local out = {}
		for _, ln in ipairs(lines) do out[#out+1] = ln end
		local i = 1
		while i <= #out do
			local transformed = false
			local outerInd, outerCond = matchIfOpen(out[i])
			if outerInd and i + 1 <= #out then
				local innerInd2, innerCond = matchIfOpen(out[i+1])
				if innerInd2 and innerInd2 == outerInd .. "\t" then
					local depth = 1
					local j = i + 2
					local innerHasBranch = false
					while j <= #out and depth > 0 do
						local s = out[j]:match("^%s*(.-)%s*$")
						local li = out[j]:match("^(%s*)")
						if #li == #innerInd2 then
							if s == "else" or s:sub(1,7) == "elseif " then innerHasBranch = true end
							if s:sub(1,3) == "if " or s:sub(1,4) == "for " or s:sub(1,6) == "while " or s == "repeat" or s == "do" then
								depth = depth + 1
							elseif s == "end" or s:sub(1,6) == "until " then
								depth = depth - 1
							end
						end
						j = j + 1
					end
					j = j - 1
					if depth == 0 and j + 1 <= #out and not innerHasBranch and matchEnd(out[j+1]) and out[j+1]:match("^(%s*)") == outerInd then
						local outerHasBranch = false
						for k = i + 1, j + 1 do
							local s2 = out[k]:match("^%s*(.-)%s*$")
							local li2 = out[k]:match("^(%s*)")
							if #li2 == #outerInd and (s2 == "else" or s2:sub(1,7) == "elseif ") then
								outerHasBranch = true
								break
							end
						end
						if not outerHasBranch then
							local combined = wrapForAnd(outerCond) .. " and " .. wrapForAnd(innerCond)
							local newBlock = {outerInd .. "if " .. combined .. " then"}
							for k = i + 2, j - 1 do
								local bl = out[k]
								if bl:sub(1,1) == "\t" then newBlock[#newBlock+1] = bl:sub(2)
								else newBlock[#newBlock+1] = bl end
							end
							newBlock[#newBlock+1] = outerInd .. "end"
							for k = 0, #newBlock - 1 do out[i + k] = newBlock[k + 1] end
							for _ = i + #newBlock, j + 1 do table.remove(out, i + #newBlock) end
							lines = out
							changed = true
							transformed = true
						end
					end
				end
				if transformed then
					break
				end
			end
			if not transformed then
				i = i + 1
			end
		end
	end
	return lines
end

-- Drop empty `if cond then end` blocks
local function dropEmptyIfBlocks(lines)
	local changed = true
	local out = {}
	for _, ln in ipairs(lines) do out[#out+1] = ln end
	while changed do
		changed = false
		local new = {}
		local i = 1
		while i <= #out do
			local removed = false
			if i + 2 <= #out then
				local iind = matchIfOpen(out[i])
				local eind1 = out[i+1]:match("^(%s*)else%s*$")
				local eind2 = matchEnd(out[i+2])
				if iind and eind1 and eind2 and iind == eind1 and iind == eind2 then
					i = i + 3
					changed = true
					removed = true
				end
			end
			if not removed and i + 1 <= #out then
				local iind = matchIfOpen(out[i])
				local eind = matchEnd(out[i+1])
				if iind and eind and iind == eind then
					i = i + 2
					changed = true
					removed = true
				end
			end
			if not removed then
				new[#new+1] = out[i]
				i = i + 1
			end
		end
		out = new
	end
	return out
end

local function recoverEmptyFieldGuards(lines)
	local remove = {}
	local replace = {}
	local function trim(s)
		return s:match("^%s*(.-)%s*$")
	end
	local function matchBaseIf(ln)
		local ind = ln:match("^(%s*)") or ""
		local text = trim(ln)
		local base = text:match("^if%s+([%a_][%w_]*)%s+then$")
		if not base then base = text:match("^if%s+%(([%a_][%w_]*)%)%s+then$") end
		if base then return ind, base end
		return nil, nil
	end
	local function matchFieldIf(ln)
		local ind = ln:match("^(%s*)") or ""
		local text = trim(ln)
		local field = text:match("^if%s+([%a_][%w_]*(%.[%a_][%w_]*)+)%s+then$")
		if not field then field = text:match("^if%s+%(([%a_][%w_]*(%.[%a_][%w_]*)+)%)%s+then$") end
		if field then return ind, field end
		return nil, nil
	end
	local function matchGuardInline(ln)
		local ind = ln:match("^(%s*)") or ""
		local text = trim(ln)
		local field, _, ret = text:match("^if%s+not%s+([%a_][%w_]*(%.[%a_][%w_]*)+)%s+then%s+return(.-)%s+end$")
		if not field then field, _, ret = text:match("^if%s+not%s+%(([%a_][%w_]*(%.[%a_][%w_]*)+)%)%s+then%s+return(.-)%s+end$") end
		if field then return ind, field, ret or "" end
		return nil, nil, nil
	end
	local function matchGuardOpen(ln)
		local ind = ln:match("^(%s*)") or ""
		local text = trim(ln)
		local field = text:match("^if%s+not%s+([%a_][%w_]*(%.[%a_][%w_]*)+)%s+then$")
		if not field then field = text:match("^if%s+not%s+%(([%a_][%w_]*(%.[%a_][%w_]*)+)%)%s+then$") end
		if field then return ind, field end
		return nil, nil
	end
	for i, line in ipairs(lines) do
		local guardIndent, fieldExpr, retSuffix = matchGuardInline(line)
		local guardEnd = i
		if not guardIndent then
			local gi, gf = matchGuardOpen(line)
			if gi and i + 2 <= #lines then
				local ret = trim(lines[i + 1]):match("^return(.*)$")
				local endInd = matchEnd(lines[i + 2])
				if ret and endInd == gi then
					guardIndent, fieldExpr, retSuffix = gi, gf, ret
					guardEnd = i + 2
				end
			end
		end
		if guardIndent and fieldExpr then
			local base = fieldExpr:match("^([%a_][%w_]*)%.")
			local emptyStart, emptyEnd = nil, nil
			for k = math.max(1, i - 24), i - 1 do
				local baseInd, baseName = matchBaseIf(lines[k])
				if baseName == base and k + 3 < i then
					local _, fieldName = matchFieldIf(lines[k + 1])
					if fieldName == fieldExpr then
						local end2 = matchEnd(lines[k + 2])
						local end3 = matchEnd(lines[k + 3])
						if end2 and end3 == baseInd then
							emptyStart, emptyEnd = k, k + 3
							break
						end
						local elseInd = lines[k + 2]:match("^(%s*)else%s*$")
						local end4 = k + 4 < i and matchEnd(lines[k + 4]) or nil
						if elseInd and end3 and end4 == baseInd then
							emptyStart, emptyEnd = k, k + 4
							break
						end
					end
				end
			end
			if emptyStart and emptyEnd then
				local clear = true
				for mid = emptyEnd + 1, i - 1 do
					if trim(lines[mid]) ~= "" and not matchEnd(lines[mid]) then clear = false break end
				end
				if clear then
					for idx = emptyStart, emptyEnd do remove[idx] = true end
					replace[i] = {
						endIdx = guardEnd,
						lines = {
							guardIndent .. "if not " .. base .. " then return" .. retSuffix .. " end",
							guardIndent .. "if not " .. fieldExpr .. " then return" .. retSuffix .. " end",
						},
					}
				end
			end
		end
	end
	local out = {}
	local i = 1
	while i <= #lines do
		if replace[i] then
			for _, ln in ipairs(replace[i].lines) do out[#out+1] = ln end
			i = replace[i].endIdx + 1
		else
			if not remove[i] then out[#out+1] = lines[i] end
			i = i + 1
		end
	end
	return out
end

local function fixInvertedIsaGuard(lines)
	local out = {}
	local i = 1
	while i <= #lines do
		if i + 4 > #lines then
			out[#out+1] = lines[i]
			i = i + 1
		else
			local findInd, name = lines[i]:match("^(%s*)local%s+([%a_][%w_]*)%s*=%s*.+:FindFirstChild%(.+%)%s*$")
			local ifInd, ifName = lines[i + 1]:match("^(%s*)if%s+([%a_][%w_]*)%s+then%s*$")
			local isaInd, checkName, isaName, isaArg = lines[i + 2]:match("^(%s*)local%s+([%a_][%w_]*)%s*=%s*([%a_][%w_]*):IsA%((.+)%)%s*$")
			if not (findInd and ifInd and isaInd and name and ifName and checkName and isaName and isaArg)
				or ifInd ~= findInd
				or ifName ~= name
				or isaName ~= name
				or isaInd:sub(1, #findInd) ~= findInd
				or isaInd == findInd
			then
				out[#out+1] = lines[i]
				i = i + 1
			else
				local endIdx = nil
				local maxJ = math.min(#lines, i + 11)
				for j = i + 3, maxJ do
					local endInd = matchEnd(lines[j])
					if endInd == findInd then
						endIdx = j
						break
					end
				end
				if not endIdx then
					out[#out+1] = lines[i]
					i = i + 1
				else
					local hasReturn = false
					for j = i + 3, endIdx - 1 do
						local text = lines[j]:match("^%s*(.-)%s*$")
						if text == "return" or text:sub(1, 7) == "return " then
							hasReturn = true
							break
						end
					end
					if not hasReturn then
						out[#out+1] = lines[i]
						i = i + 1
					else
						out[#out+1] = lines[i]
						out[#out+1] = findInd .. "if not " .. name .. " then"
						for j = i + 3, endIdx - 1 do out[#out+1] = lines[j] end
						out[#out+1] = findInd .. "end"
						out[#out+1] = findInd .. "local " .. checkName .. " = " .. name .. ":IsA(" .. isaArg .. ")"
						out[#out+1] = findInd .. "if not " .. checkName .. " then"
						for j = i + 3, endIdx - 1 do out[#out+1] = lines[j] end
						out[#out+1] = findInd .. "end"
						i = endIdx + 1
					end
				end
			end
		end
	end
	return out
end

-- Rewrite goto -> return when label points at a return
local function rewriteGotoToReturn(lines)
	local labelToReturn = {}
	for i, ln in ipairs(lines) do
		local _, lbl = matchLbl(ln)
		if lbl then
			local j = i + 1
			while j <= #lines and (not lines[j]:match("%S") or matchLbl(lines[j])) do j = j + 1 end
			if j <= #lines then
				local ri, rtext = matchReturn(lines[j])
				if ri and rtext then
					labelToReturn[lbl] = rtext:match("^%s*(.-)%s*$")
				end
			end
		end
	end
	if not next(labelToReturn) then return lines end
	local out = {}
	for _, ln in ipairs(lines) do
		local gi, gtgt = matchGoto(ln)
		if gi and labelToReturn[gtgt] then
			out[#out+1] = gi .. labelToReturn[gtgt]
		else
			local ii, icond, itgt = matchIfGoto(ln)
			if ii and labelToReturn[itgt] then
				out[#out+1] = ii .. "if " .. icond .. " then " .. labelToReturn[itgt] .. " end"
			else
				out[#out+1] = ln
			end
		end
	end
	return out
end

-- Fold constant condition blocks: `if false then...end` -> drop, `if true then...end` -> unwrap
local function foldConstantConditionBlocks(lines, indentUnit)
	for _ = 1, 16 do
		local prev = lines
		local folded = {}
		local skipUntilEndAt = nil
		local unwrapUntilEndAt = nil
		local unwrapStep = ""
		local unwrapSeenElse = false
		for _, ln in ipairs(lines) do
			local stripped = ln:match("^%s*(.-)%s*$")
			local handled = false
			if skipUntilEndAt ~= nil then
				local curInd = ln:match("^(%s*)") or ""
				if curInd == skipUntilEndAt and stripped == "end" then skipUntilEndAt = nil end
				handled = true
			end
			if not handled and unwrapUntilEndAt ~= nil then
				local curInd = ln:match("^(%s*)") or ""
				if curInd == unwrapUntilEndAt then
					if (stripped == "else" or stripped:sub(1,7) == "elseif ") and not unwrapSeenElse then
						unwrapSeenElse = true
						handled = true
					end
					if not handled and stripped == "end" then
						unwrapUntilEndAt = nil
						unwrapStep = ""
						unwrapSeenElse = false
						handled = true
					end
				end
				if not handled and unwrapSeenElse then
					handled = true
				end
				if not handled and unwrapStep == "" and stripped ~= "" then
					if #curInd > #unwrapUntilEndAt then
						unwrapStep = curInd:sub(#unwrapUntilEndAt + 1)
					end
					if unwrapStep == "" then unwrapStep = indentUnit end
				end
				if not handled then
					local childPfx = unwrapUntilEndAt .. unwrapStep
					if unwrapStep ~= "" and ln:sub(1, #childPfx) == childPfx then
						folded[#folded+1] = unwrapUntilEndAt .. ln:sub(#childPfx + 1)
					elseif unwrapStep ~= "" and ln:sub(1, #unwrapStep) == unwrapStep then
						folded[#folded+1] = ln:sub(#unwrapStep + 1)
					else
						folded[#folded+1] = ln
					end
					handled = true
				end
			end
			if not handled then
				local inlineInd, inlineCond, inlineBody = ln:match("^(%s*)if%s+(.+)%s+then%s+(.+)%s+end%s*$")
				if inlineInd then
					local cn = inlineCond:match("^%s*(.-)%s*$")
					while cn:sub(1,1) == "(" and cn:sub(-1) == ")" do
						local d2, bal = 0, true
						for ci = 1, #cn-1 do
							local ch = cn:sub(ci,ci)
							if ch == "(" then d2 = d2+1 elseif ch == ")" then d2 = d2-1; if d2==0 then bal=false; break end end
						end
						if not bal then break end
						cn = cn:sub(2,-2):match("^%s*(.-)%s*$")
					end
					if cn == "false" or cn == "not true" or cn == "not (true)" then
						handled = true
					elseif cn == "true" or cn == "not false" or cn == "not (false)" then
						folded[#folded+1] = inlineInd .. inlineBody
						handled = true
					end
				end
			end
			if not handled then
				local mii, cond = matchIfOpen(ln)
				if mii then
					local cn = cond:match("^%s*(.-)%s*$")
					while cn:sub(1,1) == "(" and cn:sub(-1) == ")" do
						local d2, bal = 0, true
						for ci = 1, #cn-1 do
							local ch = cn:sub(ci,ci)
							if ch == "(" then d2 = d2+1 elseif ch == ")" then d2 = d2-1; if d2==0 then bal=false; break end end
						end
						if not bal then break end
						cn = cn:sub(2,-2):match("^%s*(.-)%s*$")
					end
					if cn == "false" or cn == "not true" or cn == "not (true)" then
						skipUntilEndAt = mii
						handled = true
					end
					if not handled and (cn == "true" or cn == "not false" or cn == "not (false)") then
						unwrapUntilEndAt = mii
						unwrapStep = ""
						unwrapSeenElse = false
						handled = true
					end
				end
				if not handled then
					folded[#folded+1] = ln
				end
			end
		end
		lines = folded
		local same = #lines == #prev
		if same then
			for k = 1, #lines do
				if lines[k] ~= prev[k] then same = false; break end
			end
		end
		if same then break end
	end
	return lines
end

-- Normalize indentation by level tracking
local function normalizeLuaIndentation(lines, indentUnit)
	local out = {}
	local level = 0
	for _, ln in ipairs(lines) do
		local stripped = ln:match("^%s*(.-)%s*$")
		if not stripped or stripped == "" then
			out[#out+1] = ""
		else
			local lower = stripped
			local dedentFirst = (
				lower == "end" or lower == "else"
				or lower:sub(1,7) == "elseif " or lower:sub(1,6) == "until "
			)
			if dedentFirst then level = math.max(0, level - 1) end
			if stripped:sub(1,2) == "::" and stripped:sub(-2) == "::" then
				out[#out+1] = indentUnit:rep(math.max(0, level)) .. stripped
			else
				out[#out+1] = indentUnit:rep(level) .. stripped
			end
			local opensBlock = false
			if lower == "else" or lower:sub(1,7) == "elseif " then opensBlock = true
			elseif lower == "repeat" then opensBlock = true
			elseif lower:sub(-5) == " then" then opensBlock = true
			elseif lower:sub(-3) == " do" then opensBlock = true
			elseif lower:match("^local%s+function%f[%W]") or lower:match("^function%f[%W]") then
				if not lower:match("end%s*$") then opensBlock = true end
			end
			if opensBlock and lower:sub(1,6) ~= "until " then level = level + 1 end
		end
	end
	return out
end

-- Fix bare method references: `obj:Method` (no parens) -> `obj.Method`
local function fixBareMethodReferences(lines)
	local out = {}
	for _, line in ipairs(lines) do
		local code2, comment = line, ""
		-- split off trailing comment
		local ci = 1
		local inQ = nil
		while ci <= #line do
			local ch = line:sub(ci,ci)
			if inQ then
				if ch == "\\" then
					ci = ci + 2
				else
					if ch == inQ then inQ = nil end
					ci = ci + 1
				end
			else
				if ch == '"' or ch == "'" then inQ = ch
				elseif ch == "-" and line:sub(ci+1,ci+1) == "-" then
					code2 = line:sub(1, ci-1); comment = line:sub(ci); break
				end
				ci = ci + 1
			end
		end
		-- replace bare `:Method` with `.Method` when not followed by `(`
		local res = {}
		local qi = 1
		inQ = nil
		while qi <= #code2 do
			local ch = code2:sub(qi,qi)
			if inQ then
				res[#res+1] = ch
				if ch == "\\" and qi < #code2 then
					res[#res+1] = code2:sub(qi+1,qi+1)
					qi = qi + 2
				else
					if ch == inQ then inQ = nil end
					qi = qi + 1
				end
			elseif ch == '"' or ch == "'" then
				inQ = ch
				res[#res+1] = ch
				qi = qi + 1
			elseif ch == ":" and qi + 1 <= #code2 and code2:sub(qi+1,qi+1):match("[%a_]") then
				local j2 = qi + 2
				while j2 <= #code2 and code2:sub(j2,j2):match("[%a_%d]") do j2 = j2 + 1 end
				local k2 = j2
				while k2 <= #code2 and code2:sub(k2,k2):match("%s") do k2 = k2 + 1 end
				if k2 <= #code2 and code2:sub(k2,k2) == "(" then
					res[#res+1] = ":"
				else
					res[#res+1] = "."
				end
				qi = qi + 1
			else
				res[#res+1] = ch
				qi = qi + 1
			end
		end
		out[#out+1] = table.concat(res) .. comment
	end
	return out
end

-- Balance Lua blocks by indent (insert missing `end` lines)
local function balanceLuaBlocksByIndent(lines)
	local out = {}
	local stack = {}  -- {kind, indent}
	local function flushAbove(indLevel)
		while #stack > 0 and #stack[#stack][2] >= indLevel do
			out[#out+1] = stack[#stack][2] .. "end"
			table.remove(stack)
		end
	end
	for _, line in ipairs(lines) do
		local text = line:match("^%s*(.-)%s*$")
		local indent = line:match("^(%s*)") or ""
		if text ~= "" and text ~= "end" and text ~= "else" and text:sub(1,7) ~= "elseif " and text:sub(1,6) ~= "until " then
			flushAbove(#indent + 1)
		end
		if text == "end" then
			while #stack > 0 and #stack[#stack][2] > #indent do
				out[#out+1] = stack[#stack][2] .. "end"; table.remove(stack)
			end
			if #stack > 0 and stack[#stack][2] == indent then table.remove(stack) end
			out[#out+1] = line
		elseif text == "else" or text:sub(1,7) == "elseif " then
			while #stack > 0 and #stack[#stack][2] > #indent do
				out[#out+1] = stack[#stack][2] .. "end"; table.remove(stack)
			end
			out[#out+1] = line
		elseif text:sub(1,6) == "until " then
			while #stack > 0 and #stack[#stack][2] > #indent do
				out[#out+1] = stack[#stack][2] .. "end"; table.remove(stack)
			end
			if #stack > 0 and stack[#stack][1] == "repeat" and stack[#stack][2] == indent then table.remove(stack) end
			out[#out+1] = line
		else
			out[#out+1] = line
			if text:match("^if%s") then
				if not text:match("%f[%a]end%s*$") then stack[#stack+1] = {"if", indent} end
			elseif text == "repeat" then stack[#stack+1] = {"repeat", indent}
			elseif text:match("^for%s.+%sdo$") or text:match("^while%s.+%sdo$") or text == "do"
				or text:match("^local%s+function%f[%W]") or text:match("^function%f[%W]") then
				if not text:match("end%s*$") then stack[#stack+1] = {"block", indent} end
			end
		end
	end
	while #stack > 0 do
		out[#out+1] = stack[#stack][2] .. "end"; table.remove(stack)
	end
	return out
end

-- Drop unmatched `end` lines
local function dropUnmatchedEndLines(lines)
	local out = {}
	local stack = {}
	for _, line in ipairs(lines) do
		local text = line:match("^%s*(.-)%s*$")
		if text:match("^if%s") then
			if not text:match("%f[%a]end%s*$") then stack[#stack+1] = "if" end
			out[#out+1] = line
		elseif text == "repeat" then
			stack[#stack+1] = "repeat"; out[#out+1] = line
		elseif text:match("^for%s.+%sdo$") or text:match("^while%s.+%sdo$") or text == "do"
			or text:match("^local%s+function%f[%W]") or text:match("^function%f[%W]") then
			if not text:match("end%s*$") then stack[#stack+1] = "block" end
			out[#out+1] = line
		elseif text:sub(1,6) == "until " then
			if #stack > 0 and stack[#stack] == "repeat" then table.remove(stack) end
			out[#out+1] = line
		elseif text == "end" then
			if #stack > 0 then table.remove(stack); out[#out+1] = line end
		else
			out[#out+1] = line
		end
	end
	return out
end

-- Simple AST re-render (replaces _render_lua_ast_lines)
local function renderLuaAstLines(lines, indentUnit)
	-- We just use normalizeLuaIndentation as it achieves the same goal
	return normalizeLuaIndentation(lines, indentUnit)
end

-- Split register lifetimes for _rN names with multiple declarations
local function splitRegisterLifetimes(lines)
	if #lines == 0 then return lines end
	local bodyStart = 1
	for i, ln in ipairs(lines) do
		if ln:match("%S") then
			if ln:match("^%s*local%s+function%f[%W]") or ln:match("^%s*function%f[%W]") then
				bodyStart = i + 1
			else
				bodyStart = i
			end
			break
		end
	end
	local bodyEnd = #lines
	while bodyEnd > bodyStart do
		local t = lines[bodyEnd]:match("^%s*(.-)%s*$")
		if not t or t == "" then bodyEnd = bodyEnd - 1
		elseif t == "end" then bodyEnd = bodyEnd - 1; break
		else break end
	end
	if bodyEnd <= bodyStart then return lines end

	-- group declarations of _rN by name
	local declsByName = {}
	for i = bodyStart, bodyEnd do
		local ind, nm, rhs = lines[i]:match("^(%s*)local%s+(_r%d+)%s*=%s*(.+)%s*$")
		if nm and nm:match("^_r%d+$") then
			if not declsByName[nm] then declsByName[nm] = {} end
			declsByName[nm][#declsByName[nm]+1] = i
		end
	end

	local newLines = {}
	for _, ln in ipairs(lines) do newLines[#newLines+1] = ln end

	for name, idxs in pairs(declsByName) do
		if #idxs >= 2 then
			for k = 2, #idxs do
				local newName = name .. "_" .. tostring(k)
				local startI = idxs[k]
				local endI = k + 1 <= #idxs and idxs[k+1] - 1 or bodyEnd
				local pat = "%f[%a_]" .. luaPE(name) .. "%f[^%a_%d]"
				for j = startI, endI do
					if j == startI then
						local di, dn, drhs = newLines[j]:match("^(%s*)local%s+(_r%d+)%s*=%s*(.+)%s*$")
						if dn == name then
							local prevName = k == 2 and name or (name .. "_" .. tostring(k-1))
							local newRhs = drhs:gsub(pat, prevName)
							newLines[j] = di .. "local " .. newName .. " = " .. newRhs
						end
					else
						newLines[j] = newLines[j]:gsub(pat, newName)
					end
				end
			end
		end
	end
	return newLines
end

-- Inline `local _rN = E; return _rN` -> `return E`
local function inlineTrivialReturnLocals(lines)
	local out = {}
	local i = 1
	while i <= #lines do
		local inlined = false
		if i + 1 <= #lines then
			local li, ln2, lrhs = lines[i]:match("^(%s*)local%s+(_r%d+[_%d]*)%s*=%s*(.+)%s*$")
			local ri, rn2 = lines[i+1]:match("^(%s*)return%s+(_r%d+[_%d]*)%s*$")
			if li and ri and li == ri and ln2 == rn2 then
				out[#out+1] = ri .. "return " .. lrhs
				i = i + 2
				inlined = true
			end
		end
		if not inlined then
			out[#out+1] = lines[i]
			i = i + 1
		end
	end
	return out
end

-- Inline `local _rN = E; if [(not)] _rN then ... end` -> `if [(not)] E then ... end`
local function inlineTrivialConditionLocals(lines)
	local out = {}
	local i = 1
	while i <= #lines do
		local inlined = false
		if i + 1 <= #lines then
			local li, ln2, lrhs = lines[i]:match("^(%s*)local%s+(_r%d+[_%d]*)%s*=%s*(.+)%s*$")
			local ii, neg, in2
			-- Lua patterns do not support `?` after capture groups, so try
			-- each prefix variant explicitly.
			local ifPats = {
				{"^(%s*)if%s+(_r%d+[_%d]*)%s+then%s*$",               ""},
				{"^(%s*)if%s+not%s+(_r%d+[_%d]*)%s+then%s*$",         "not "},
				{"^(%s*)if%s+%(%s*(_r%d+[_%d]*)%s*%)%s+then%s*$",     ""},
				{"^(%s*)if%s+not%s+%(%s*(_r%d+[_%d]*)%s*%)%s+then%s*$", "not "},
			}
			for _, pair in ipairs(ifPats) do
				local a1, a2 = lines[i+1]:match(pair[1])
				if a1 then
					ii, in2, neg = a1, a2, pair[2]
					break
				end
			end
			if li and ii and li == ii and ln2 == in2 then
				-- check name not used inside the block
				local endPat = "^" .. luaPE(ii) .. "end%s*$"
				local endIdx = nil
				for j = i + 2, #lines do
					if lines[j]:match(endPat) then endIdx = j; break end
				end
				if endIdx then
					local usePat = "%f[%a_]" .. luaPE(ln2) .. "%f[^%a_%d]"
					local usedInside = false
					for j = i + 2, endIdx - 1 do
						if lines[j]:find(usePat) then usedInside = true; break end
					end
					if not usedInside then
						local negStr = neg or ""
						out[#out+1] = ii .. "if " .. negStr .. lrhs .. " then"
						i = i + 2
						inlined = true
					end
				end
			end
		end
		if not inlined then
			out[#out+1] = lines[i]
			i = i + 1
		end
	end
	return out
end

local function inlineTrivialCompareGuardLocals(lines)
	local out = {}
	local i = 1
	local ops = {"~=", "<=", ">=", "==", "<", ">"}
	while i <= #lines do
		local inlined = false
		if i + 1 <= #lines then
			local li, name, rhs = lines[i]:match("^(%s*)local%s+(_r%d+[_%d]*)%s*=%s*(.+)%s*$")
			if li and name and rhs then
				for _, op in ipairs(ops) do
					local ii, in2, cmp, ret = lines[i + 1]:match("^(%s*)if%s+(_r%d+[_%d]*)%s*" .. luaPE(op) .. "%s*(.-)%s+then%s+return(.-)%s+end%s*$")
					if ii and li == ii and name == in2 then
						local usePat = "%f[%a_]" .. luaPE(name) .. "%f[^%a_%d]"
						local usedLater = false
						for j = i + 2, #lines do
							if lines[j]:find(usePat) then usedLater = true break end
						end
						if not usedLater then
							out[#out+1] = ii .. "if " .. rhs .. " " .. op .. " " .. cmp .. " then return" .. (ret or "") .. " end"
							i = i + 2
							inlined = true
						end
						break
					end
				end
			end
		end
		if not inlined then
			out[#out+1] = lines[i]
			i = i + 1
		end
	end
	return out
end

local function fixOrDefaultAssignments(lines)
	local work = {}
	for _, ln in ipairs(lines) do work[#work+1] = ln end
	local function trim(s)
		return s:match("^%s*(.-)%s*$")
	end
	local function startsWith(s, prefix)
		return s:sub(1, #prefix) == prefix
	end
	local function matchDeclEmpty(ln)
		return ln:match("^(%s*)local%s+(_r%d+[_%d]*)%s*$")
	end
	local function matchIfNot(ln)
		local ind = ln:match("^(%s*)") or ""
		local text = trim(ln)
		local cond = text:match("^if%s+not%s+%((.-)%)%s+then$")
		if not cond then cond = text:match("^if%s+not%s+(.+)%s+then$") end
		if cond then return ind, cond end
		return nil, nil
	end
	local function matchAssignTmp(ln)
		return ln:match("^(%s*)(_r%d+[_%d]*)%s*=%s*(.+)%s*$")
	end
	local function matchAssignTarget(ln)
		local ind, target, tmp = ln:match("^(%s*)([%a_][%w_]*%b[])%s*=%s*(_r%d+[_%d]*)%s*$")
		if ind then return ind, target, tmp end
		ind, target, tmp = ln:match("^(%s*)([%a_][%w_]*)%s*=%s*(_r%d+[_%d]*)%s*$")
		if ind then return ind, target, tmp end
		return nil, nil, nil
	end
	local function matchLocalValue(ln)
		return ln:match("^(%s*)local%s+(_r%d+[_%d]*)%s*=%s*(.+)%s*$")
	end
	for i = 1, #work - 3 do
		local ifInd, cond = matchIfNot(work[i])
		local tmpInd, tmp, rhs = matchAssignTmp(work[i + 1])
		local endInd = matchEnd(work[i + 2])
		local targetInd, target, targetTmp = matchAssignTarget(work[i + 3])
		if ifInd and tmpInd and tmp and rhs and endInd and targetInd and target and targetTmp
			and endInd == ifInd
			and targetInd == ifInd
			and startsWith(tmpInd, ifInd)
			and targetTmp == tmp
		then
			local declIdx = nil
			for j = i - 1, 1, -1 do
				local text = trim(work[j])
				local jind = work[j]:match("^(%s*)") or ""
				if (text:sub(1, 15) == "local function " or text:sub(1, 9) == "function ") and #jind <= #ifInd then
					break
				end
				local declInd, declTmp = matchDeclEmpty(work[j])
				if declInd == ifInd and declTmp == tmp then
					declIdx = j
					break
				end
			end
			if declIdx then
				local usePat = "%f[%a_]" .. luaPE(tmp) .. "%f[^%a_%d]"
				local usedBefore = false
				for j = declIdx + 1, i - 1 do
					if work[j]:find(usePat) then usedBefore = true break end
				end
				if not usedBefore then
					work[declIdx] = ""
					work[i] = ifInd .. target .. " = (" .. cond .. " or " .. rhs .. ")"
					work[i + 1] = ""
					work[i + 2] = ""
					work[i + 3] = ""
				end
			end
		end
	end
	local out = {}
	local i = 1
	while i <= #work do
		if work[i] == "" then
			i = i + 1
		else
			local handled = false
			if i + 4 <= #work then
				local declInd, declTmp = matchDeclEmpty(work[i])
				local ifInd, cond = matchIfNot(work[i + 1])
				local tmpInd, tmp, rhs = matchAssignTmp(work[i + 2])
				local endInd = matchEnd(work[i + 3])
				local targetInd, target, targetTmp = matchAssignTarget(work[i + 4])
				if declInd and ifInd and tmpInd and tmp and rhs and endInd and targetInd and target and targetTmp
					and declInd == ifInd and ifInd == endInd and endInd == targetInd
					and startsWith(tmpInd, declInd)
					and declTmp == tmp and tmp == targetTmp
				then
					out[#out+1] = targetInd .. target .. " = (" .. cond .. " or " .. rhs .. ")"
					i = i + 5
					handled = true
				end
			end
			if not handled and i + 1 <= #work then
				local localInd, localTmp, value = matchLocalValue(work[i])
				local targetInd, target, targetTmp = matchAssignTarget(work[i + 1])
				if localInd and localTmp and value and targetInd and target and targetTmp
					and localInd == targetInd
					and localTmp == targetTmp
				then
					out[#out+1] = targetInd .. target .. " = " .. value
					i = i + 2
					handled = true
				end
			end
			if not handled then
				out[#out+1] = work[i]
				i = i + 1
			end
		end
	end
	return out
end

local function renameTempFindFirstChildDynamic(lines)
	local out = {}
	for _, ln in ipairs(lines) do out[#out+1] = ln end
	local existing = {}
	for _, ln in ipairs(out) do
		local name = ln:match("%f[%a_]local%s+([%a_][%w_]*)%f[^%a_%d]")
		if name then existing[name] = true end
	end
	for i, line in ipairs(lines) do
		local old, arg = line:match("^%s*local%s+(_r%d+[_%d]*)%s*=%s*.+:FindFirstChild%((.+)%)%s*$")
		if old and arg then
			arg = arg:match("^%s*(.-)%s*$")
			local hint = arg:match("%.([%a_][%w_]*)$")
			if not hint and isValidIdent(arg) then hint = arg end
			hint = hint and cleanIdent(hint) or nil
			if hint and isValidIdent(hint) then
				local newName = hint
				if existing[newName] and newName ~= old then
					local suffix = 2
					while existing[newName .. "_" .. tostring(suffix)] do suffix = suffix + 1 end
					newName = newName .. "_" .. tostring(suffix)
				end
				existing[newName] = true
				local usePat = "%f[%a_]" .. luaPE(old) .. "%f[^%a_%d]"
				local endIdx = math.min(#out, i + 11)
				for j = i, endIdx do
					if j > i and out[j]:find("%f[%a_]local%s+" .. luaPE(old) .. "%f[^%a_%d]") then break end
					if out[j]:find(usePat) then
						out[j] = out[j]:gsub(usePat, newName)
					end
				end
			end
		end
	end
	return out
end

local function renameTempByCommonAssignedField(lines)
	local out = {}
	for _, ln in ipairs(lines) do out[#out+1] = ln end
	local preferred = {
		Visible = "visible",
		Enabled = "enabled",
		Transparency = "transparency",
		Size = "size",
		Position = "position",
		CFrame = "cframe",
		Color = "color",
		Text = "text",
	}
	local existing = {}
	for _, ln in ipairs(lines) do
		local name = ln:match("%f[%a_]local%s+([%a_][%w_]*)%f[^%a_%d]")
		if name then existing[name] = true end
	end
	for i, line in ipairs(lines) do
		local old = line:match("^%s*local%s+(_r%d+[_%d]*)%s*=%s*.+%s*$")
		if old then
			local fields = {}
			local lastUse = i
			local valid = true
			for j = i + 1, math.min(#lines, i + 7) do
				if lines[j]:find("%f[%a_]local%s+" .. luaPE(old) .. "%f[^%a_%d]") then break end
				local usePat = "%f[%a_]" .. luaPE(old) .. "%f[^%a_%d]"
				if lines[j]:find(usePat) then
					local field, rhs = lines[j]:match("^%s*[%a_][%w_%.:%[%]\"']*%.([%a_][%w_]*)%s*=%s*(_r%d+[_%d]*)%s*$")
					if not field or rhs ~= old then
						valid = false
						break
					end
					fields[#fields+1] = field
					lastUse = j
				elseif #fields > 0 then
					break
				end
			end
			if valid and #fields > 0 then
				local same = true
				for j = 2, #fields do
					if fields[j] ~= fields[1] then same = false break end
				end
				if same then
					local newName = preferred[fields[1]] or cleanIdent(fields[1])
					if newName and isValidIdent(newName) then
						if existing[newName] and newName ~= old then
							local suffix = 2
							while existing[newName .. "_" .. tostring(suffix)] do suffix = suffix + 1 end
							newName = newName .. "_" .. tostring(suffix)
						end
						existing[newName] = true
						local usePat = "%f[%a_]" .. luaPE(old) .. "%f[^%a_%d]"
						for j = i, lastUse do
							out[j] = out[j]:gsub(usePat, newName)
						end
					end
				end
			end
		end
	end
	return out
end

local function renameLocalTableByAssignment(lines)
	local out = {}
	for _, ln in ipairs(lines) do out[#out+1] = ln end
	local existing = {}
	for _, ln in ipairs(lines) do
		local name = ln:match("%f[%a_]local%s+([%a_][%w_]*)%f[^%a_%d]")
		if name then existing[name] = true end
	end
	for i, line in ipairs(lines) do
		local ind, old, tableExpr = line:match("^(%s*)local%s+(_r%d+[_%d]*)%s*=%s*(%{.+%})%s*$")
		local hasSignalField = false
		if tableExpr then
			for _, field in ipairs({"Weld", "OriginalC0", "SpinRate", "IsFiring", "CurrentPosition", "TargetPosition", "Model", "Animator"}) do
				if tableExpr:find("%f[%a_]" .. field .. "%f[^%a_%d]%s*=") then
					hasSignalField = true
					break
				end
			end
		end
		if ind and old and tableExpr and hasSignalField then
			local assignIdx = nil
			for j = i + 1, math.min(#lines, i + 11) do
				local rhs = lines[j]:match("^%s*[%a_][%w_]*%b[]%s*=%s*(_r%d+[_%d]*)%s*$")
				if rhs == old then
					assignIdx = j
					break
				end
				local rhs2 = lines[j]:match("^%s*[%a_][%w_]*%s*=%s*(_r%d+[_%d]*)%s*$")
				if rhs2 == old then
					assignIdx = j
					break
				end
			end
			if assignIdx then
				local newName = "data"
				if existing[newName] then
					local suffix = 2
					while existing[newName .. "_" .. tostring(suffix)] do suffix = suffix + 1 end
					newName = newName .. "_" .. tostring(suffix)
				end
				existing[newName] = true
				local usePat = "%f[%a_]" .. luaPE(old) .. "%f[^%a_%d]"
				for j = i, assignIdx do
					out[j] = out[j]:gsub(usePat, newName)
				end
			end
		end
	end
	return out
end

-- Fold table array initializers: `local t = {}; t[1],t[2]=a,b` -> `local t = {a,b}`
local function foldTableArrayInitializers(lines)
	local out = {}
	local i = 1
	while i <= #lines do
		local folded = false
		local ind, nm = lines[i]:match("^(%s*)local%s+([%a_][%a_%d]*)%s*=%s*%{%}%s*$")
		if nm and i + 1 <= #lines then
			-- next line: t[1], t[2], ... = v1, v2, ...
			local lhsStr, rhsStr = lines[i+1]:match("^" .. luaPE(ind) .. "(.+)%s*=%s*(.+)%s*$")
			if lhsStr and rhsStr then
				-- split by comma at depth 0
				local function splitTopCommas(s)
					local parts = {}
					local buf = {}
					local depth2 = 0
					local inq = nil
					for ci = 1, #s do
						local ch = s:sub(ci,ci)
						if inq then
							buf[#buf+1] = ch
							if ch == inq then inq = nil end
						elseif ch == '"' or ch == "'" then inq = ch; buf[#buf+1] = ch
						elseif ch == "(" or ch == "[" or ch == "{" then depth2 = depth2+1; buf[#buf+1] = ch
						elseif ch == ")" or ch == "]" or ch == "}" then depth2 = depth2-1; buf[#buf+1] = ch
						elseif ch == "," and depth2 == 0 then
							parts[#parts+1] = table.concat(buf):match("^%s*(.-)%s*$"); buf = {}
						else buf[#buf+1] = ch end
					end
					parts[#parts+1] = table.concat(buf):match("^%s*(.-)%s*$")
					return parts
				end
				local lhsParts = splitTopCommas(lhsStr)
				local rhsParts = splitTopCommas(rhsStr)
				local ok = #lhsParts == #rhsParts
				local indexes = {}
				for _, part in ipairs(lhsParts) do
					local idx = part:match("^" .. luaPE(nm) .. "%[(%d+)%]$")
					if not idx then ok = false; break end
					indexes[#indexes+1] = tonumber(idx)
				end
				if ok and #indexes > 0 then
					local seq = true
					for k = 1, #indexes do
						if indexes[k] ~= k then seq = false; break end
					end
					if seq then
						out[#out+1] = ind .. "local " .. nm .. " = {" .. table.concat(rhsParts, ", ") .. "}"
						i = i + 2
						folded = true
					end
				end
			end
		end
		if not folded then
			out[#out+1] = lines[i]
			i = i + 1
		end
	end
	return out
end

local function fixBareMethodReferences(lines)
	local out = {}
	for _, line in ipairs(lines) do
		if matchLbl(line) then
			out[#out+1] = line
			continue
		end
		local res = {}
		local quote = nil
		local i = 1
		while i <= #line do
			local ch = line:sub(i, i)
			if quote then
				res[#res+1] = ch
				if ch == "\\" and i + 1 <= #line then
					res[#res+1] = line:sub(i + 1, i + 1)
					i = i + 2
				else
					if ch == quote then quote = nil end
					i = i + 1
				end
			elseif ch == '"' or ch == "'" then
				quote = ch
				res[#res+1] = ch
				i = i + 1
			elseif ch == "-" and line:sub(i + 1, i + 1) == "-" then
				res[#res+1] = line:sub(i)
				break
			elseif ch == ":" and line:sub(i - 1, i - 1) ~= ":" and line:sub(i + 1, i + 1):match("[%a_]") then
				local j = i + 2
				while j <= #line and line:sub(j, j):match("[%a_%d]") do
					j = j + 1
				end
				local k = j
				while k <= #line and line:sub(k, k):match("%s") do
					k = k + 1
				end
				if k <= #line and line:sub(k, k) == "(" then
					res[#res+1] = ":"
				else
					res[#res+1] = "."
				end
				i = i + 1
			else
				res[#res+1] = ch
				i = i + 1
			end
		end
		out[#out+1] = table.concat(res)
	end
	return out
end

local function fixLiteralMethodReceivers(lines)
	local out = {}
	for _, line in ipairs(lines) do
		local ln = line
		ln = ln:gsub("([^%w_])nil:([%a_][%a_%d]*%s*%()", "%1(nil):%2")
		ln = ln:gsub("([^%w_])true:([%a_][%a_%d]*%s*%()", "%1(true):%2")
		ln = ln:gsub("([^%w_])false:([%a_][%a_%d]*%s*%()", "%1(false):%2")
		ln = ln:gsub("^nil:([%a_][%a_%d]*%s*%()", "(nil):%1")
		ln = ln:gsub("^true:([%a_][%a_%d]*%s*%()", "(true):%1")
		ln = ln:gsub("^false:([%a_][%a_%d]*%s*%()", "(false):%1")
		out[#out+1] = ln
	end
	return out
end

local function fixLiteralFieldReceivers(lines)
	local out = {}
	for _, line in ipairs(lines) do
		local res = {}
		local quote = nil
		local i = 1
		while i <= #line do
			local ch = line:sub(i, i)
			if quote then
				res[#res+1] = ch
				if ch == "\\" and i + 1 <= #line then
					res[#res+1] = line:sub(i + 1, i + 1)
					i = i + 2
				else
					if ch == quote then quote = nil end
					i = i + 1
				end
			elseif ch == '"' or ch == "'" then
				quote = ch
				res[#res+1] = ch
				i = i + 1
			elseif ch == "-" and line:sub(i + 1, i + 1) == "-" then
				res[#res+1] = line:sub(i)
				break
			else
				local replaced = false
				for _, lit in ipairs({"false", "true", "nil"}) do
					local before = i > 1 and line:sub(i - 1, i - 1) or ""
					local after = line:sub(i + #lit, i + #lit)
					if line:sub(i, i + #lit - 1) == lit
						and after == "."
						and not before:match("[%w_]")
					then
						res[#res+1] = "(" .. lit .. ")"
						i = i + #lit
						replaced = true
						break
					end
				end
				if not replaced then
					res[#res+1] = ch
					i = i + 1
				end
			end
		end
		out[#out+1] = table.concat(res)
	end
	return out
end

local function astIfOpenText(text)
	return text:match("^if%s+(.+)%s+then$")
end

local function astBlockOpenText(text)
	if text:match("^local%s+function%f[%W]") or text:match("^function%f[%W]") then return true end
	if text:match("^for%s.+%sdo$") or text:match("^while%s.+%sdo$") or text == "do" then return true end
	return false
end

local function repairInvalidElseClauses(lines)
	local out = {}
	local stack = {}
	for _, line in ipairs(lines) do
		local text = line:match("^%s*(.-)%s*$")
		local indent = line:match("^(%s*)") or ""
		while #stack > 0 and stack[#stack].indent > #indent do
			table.remove(stack)
		end
		if text:sub(1, 7) == "elseif " then
			if #stack > 0 and stack[#stack].kind == "if" and stack[#stack].indent == #indent and not stack[#stack].seen_else then
				out[#out+1] = line
			else
				local newLine = indent .. "if " .. text:sub(8)
				out[#out+1] = newLine
				stack[#stack+1] = {kind = "if", indent = #indent, seen_else = false}
			end
		elseif text == "else" then
			if #stack > 0 and stack[#stack].kind == "if" and stack[#stack].indent == #indent and not stack[#stack].seen_else then
				stack[#stack].seen_else = true
				out[#out+1] = line
			else
				local newLine = indent .. "if true then"
				out[#out+1] = newLine
				stack[#stack+1] = {kind = "if", indent = #indent, seen_else = false}
			end
		elseif text == "end" then
			if #stack > 0 and stack[#stack].indent == #indent then
				table.remove(stack)
			end
			out[#out+1] = line
		else
			out[#out+1] = line
			if astIfOpenText(text) then
				stack[#stack+1] = {kind = "if", indent = #indent, seen_else = false}
			elseif text == "repeat" then
				stack[#stack+1] = {kind = "repeat", indent = #indent}
			elseif astBlockOpenText(text) then
				stack[#stack+1] = {kind = "block", indent = #indent}
			end
		end
	end
	return out
end

local function dropGotoToImmediatePostIfLabel(lines)
	local i = 1
	while i <= #lines do
		local gi, target = matchGoto(lines[i])
		if not gi then
			i = i + 1
		else
			local labelIdx = nil
			for k = i + 1, #lines do
				local _, lbl = matchLbl(lines[k])
				if lbl == target then
					labelIdx = k
					break
				end
			end
			local li = labelIdx and (lines[labelIdx]:match("^(%s*)") or "") or nil
			local nextIdx = i + 1
			while nextIdx <= #lines and not lines[nextIdx]:match("%S") do nextIdx = nextIdx + 1 end
			local nextText = nextIdx <= #lines and (lines[nextIdx]:match("^%s*(.-)%s*$") or "") or ""
			local nextInd = nextIdx <= #lines and (lines[nextIdx]:match("^(%s*)") or "") or ""
			local prevEnd = labelIdx and matchEnd(lines[labelIdx - 1] or "") or nil
			local branchTail = (
				labelIdx
				and li
				and prevEnd == li
				and #nextInd < #gi
				and (nextText == "else" or nextText == "end" or nextText:sub(1, 7) == "elseif ")
			)
			if branchTail then
				local result = {}
				for k = 1, i - 1 do result[#result+1] = lines[k] end
				for k = i + 1, labelIdx - 1 do result[#result+1] = lines[k] end
				for k = labelIdx + 1, #lines do result[#result+1] = lines[k] end
				return result, true
			end
			local j = i + 1
			local ok = true
			while j <= #lines do
				local text = lines[j]:match("^%s*(.-)%s*$")
				local ind = lines[j]:match("^(%s*)") or ""
				if text == "" then
					j = j + 1
				elseif #ind < #gi then
					ok = false
					break
				elseif #ind == #gi and (text == "else" or text:sub(1, 7) == "elseif " or text == "end") then
					j = j + 1
				else
					break
				end
			end
			local li2, lbl = j <= #lines and matchLbl(lines[j]) or nil
			if ok and lbl == target and li2 and #li2 <= #gi then
				local result = {}
				for k = 1, i - 1 do result[#result+1] = lines[k] end
				for k = i + 1, j - 1 do result[#result+1] = lines[k] end
				for k = j + 1, #lines do result[#result+1] = lines[k] end
				return result, true
			end
			i = i + 1
		end
	end
	return lines, false
end

local function wrapOrphanIfGotosAsGuards(lines, indentUnit)
	local labels = {}
	for _, ln in ipairs(lines) do
		local _, lbl = matchLbl(ln)
		if lbl then labels[lbl] = true end
	end
	local i = 1
	while i <= #lines do
		local ind, cond, target = matchIfGoto(lines[i])
		if ind and not labels[target] then
			local j = i + 1
			while j <= #lines do
				local text = lines[j]:match("^%s*(.-)%s*$")
				local curInd = lines[j]:match("^(%s*)") or ""
				if text == "" then
					j = j + 1
				elseif #curInd < #ind then
					break
				elseif #curInd == #ind and (text == "end" or text == "else" or text:sub(1, 7) == "elseif ") then
					break
				else
					j = j + 1
				end
			end
			if j > i + 1 then
				local result = {}
				for k = 1, i - 1 do result[#result+1] = lines[k] end
				result[#result+1] = ind .. "if " .. negateCond(cond) .. " then"
				for k = i + 1, j - 1 do
					local bl = lines[k]
					if bl:match("%S") then result[#result+1] = indentUnit .. bl else result[#result+1] = bl end
				end
				result[#result+1] = ind .. "end"
				for k = j, #lines do result[#result+1] = lines[k] end
				return result, true
			end
		end
		i = i + 1
	end
	return lines, false
end

local function dropInvalidTopLevelReturns(lines)
	local out = {}
	for i, ln in ipairs(lines) do
		local ind = ln:match("^(%s*)") or ""
		local text = ln:match("^%s*(.-)%s*$")
		local drop = false
		if ind == "" and (text == "return" or text:sub(1, 7) == "return ") then
			local j = i + 1
			while j <= #lines and not lines[j]:match("%S") do j = j + 1 end
			local nextText = j <= #lines and (lines[j]:match("^%s*(.-)%s*$") or "") or ""
			if nextText:sub(1, 15) == "local function " or nextText:sub(1, 9) == "function " then
				drop = true
			end
		end
		if not drop then out[#out+1] = ln end
	end
	return out
end

local function fixInvalidGenericForHeaders(lines)
	local out = {}
	for _, ln in ipairs(lines) do
		local ind, vars, reg = ln:match("^(%s*)for%s+(.+)%s+in%s+%-%-%s*iter%s+(R%d+)%s+do%s*$")
		if ind then
			out[#out+1] = ind .. "for " .. vars .. " in " .. reg .. " do"
		else
			out[#out+1] = ln
		end
	end
	return out
end

-- Find label index in lines starting from `startI` (1-based)
local function findLabelIndex(lines, target, startI)
	local pat = "^%s*::" .. luaPE(target) .. "::%s*$"
	for i = startI, #lines do
		if lines[i]:match(pat) then return i end
	end
	return nil
end

-- Last non-blank index
local function lastNonblankIndex(lines)
	for i = #lines, 1, -1 do
		if lines[i]:match("%S") then return i end
	end
	return nil
end

local function inlineLocalIntoIfGoto(lines, indentUnit)
	local out = {}
	for _, ln in ipairs(lines) do out[#out+1] = ln end

	local function trim(s)
		return (s or ""):match("^%s*(.-)%s*$")
	end

	local function stripOuterParens(s)
		s = trim(s)
		while s:sub(1, 1) == "(" and s:sub(-1) == ")" do
			local depth = 0
			local balanced = true
			for i = 1, #s do
				local ch = s:sub(i, i)
				if ch == "(" then
					depth = depth + 1
				elseif ch == ")" then
					depth = depth - 1
					if depth == 0 and i < #s then
						balanced = false
						break
					end
				end
			end
			if not balanced then break end
			s = trim(s:sub(2, -2))
		end
		return s
	end

	local function matchDecl(line)
		local ind, var, rhs = line:match("^(%s*)local%s+([%a_][%a_%d]*)%s*=%s*(.+)%s*$")
		if var then return ind, true, var, rhs end
		ind, var, rhs = line:match("^(%s*)([%a_][%a_%d]*)%s*=%s*(.+)%s*$")
		if var then return ind, false, var, rhs end
		return nil
	end

	local function validFieldSuffix(s)
		if s == "" then return true end
		local consumed = 0
		for seg in s:gmatch("%.([%a_][%a_%d]*)") do
			consumed = consumed + #seg + 1
		end
		return consumed == #s and consumed > 0
	end

	local function simpleIdentChain(s)
		local first, nextPos = s:match("^([%a_][%a_%d]*)()")
		if not first then return false end
		while nextPos <= #s do
			if s:sub(nextPos, nextPos) ~= "." then return false end
			local seg, afterSeg = s:match("^%.([%a_][%a_%d]*)()", nextPos)
			if not seg then return false end
			nextPos = afterSeg
		end
		return true
	end

	local function parseTest(line, var)
		local ind, cond, target = matchIfGoto(line)
		if not ind then return nil end
		local neg = ""
		cond = trim(cond)
		if cond:sub(1, 4) == "not " then
			neg = "not "
			cond = trim(cond:sub(5))
		end
		cond = stripOuterParens(cond)
		if cond == var then
			return ind, neg, "", target
		end
		if cond:sub(1, #var) == var then
			local suffix = cond:sub(#var + 1)
			if validFieldSuffix(suffix) then
				return ind, neg, suffix, target
			end
		end
		return nil
	end

	local function usesVar(line, var)
		return line:find("%f[%a_]" .. luaPE(var) .. "%f[^%a_%d]") ~= nil
	end

	local changed = false
	local i = 1
	while i + 1 <= #out do
		local ind, isLocal, var, rhs = matchDecl(out[i])
		if not ind then
			i = i + 1
		else
			local testInd, neg, suffix, target = parseTest(out[i + 1], var)
			if not testInd or testInd ~= ind then
				i = i + 1
			else
				local targetIdx = findLabelIndex(out, target, i + 2)
				if not targetIdx then
					i = i + 1
				else
					local unsafe = false
					for j = i + 2, targetIdx - 1 do
						if usesVar(out[j], var) then
							local ai, arhs = out[j]:match("^(%s*)local%s+" .. luaPE(var) .. "%s*=%s*(.+)%s*$")
							if not ai then
								ai, arhs = out[j]:match("^(%s*)" .. luaPE(var) .. "%s*=%s*(.+)%s*$")
							end
							if ai and not usesVar(arhs, var) then
								break
							end
							unsafe = true
							break
						end
					end
					if unsafe then
						i = i + 1
					else
						if not isLocal then
							local tailUsed = false
							for j = targetIdx, #out do
								if usesVar(out[j], var) then tailUsed = true break end
							end
							if tailUsed then
								i = i + 1
							else
								local expr = trim(rhs)
								local needsParens = expr:find(" or ", 1, true) ~= nil or expr:find(" and ", 1, true) ~= nil or (suffix ~= "" and not simpleIdentChain(expr))
								if needsParens then expr = "(" .. expr .. ")" end
								out[i] = ind .. "if " .. neg .. expr .. suffix .. " then goto " .. target .. " end"
								table.remove(out, i + 1)
								changed = true
								i = i + 1
							end
						else
							local expr = trim(rhs)
							local needsParens = expr:find(" or ", 1, true) ~= nil or expr:find(" and ", 1, true) ~= nil or (suffix ~= "" and not simpleIdentChain(expr))
							if needsParens then expr = "(" .. expr .. ")" end
							out[i] = ind .. "if " .. neg .. expr .. suffix .. " then goto " .. target .. " end"
							table.remove(out, i + 1)
							changed = true
							i = i + 1
						end
					end
				end
			end
		end
	end
	return out, changed
end

-- Lift `if g1 goto T end; if g2 goto T end; THEN_BODY; goto J; ::T:: ELSE_BODY; ::J::` -> `if not g1 and not g2 then...else...end`
local function liftGuardChainElse(lines, indentUnit)
	local i = 1
	while i <= #lines do
		local transformed = false
		local ii, cond1, tgt1 = matchIfGoto(lines[i])
		if ii then
			local guards = {cond1}
			local cur = i + 1
			while cur <= #lines do
				local ii2, c2, t2 = matchIfGoto(lines[cur])
				if not ii2 or ii2 ~= ii or t2 ~= tgt1 then break end
				guards[#guards+1] = c2
				cur = cur + 1
			end
			local elseIdx = findLabelIndex(lines, tgt1, cur)
			if elseIdx then
				local thenBody = {}
				for k = cur, elseIdx - 1 do thenBody[#thenBody+1] = lines[k] end
				local lastI = lastNonblankIndex(thenBody)
				if lastI then
					local ji, joinTgt = matchGoto(thenBody[lastI])
					if ji then
						local joinIdx = findLabelIndex(lines, joinTgt, elseIdx + 1)
						if joinIdx then
							local elseBody = {}
							for k = elseIdx + 1, joinIdx - 1 do elseBody[#elseBody+1] = lines[k] end
							local hasInnerLabel = false
							for k = 1, lastI - 1 do if matchLbl(thenBody[k]) then hasInnerLabel = true break end end
							if not hasInnerLabel then
								for _, bl in ipairs(elseBody) do if matchLbl(bl) then hasInnerLabel = true break end end
							end
							local innerGoto = false
							if not hasInnerLabel then
								for k = 1, lastI - 1 do if thenBody[k]:match("%f[%a_]goto%s+pc%d+") then innerGoto = true break end end
								if not innerGoto then
									for _, bl in ipairs(elseBody) do if bl:match("%f[%a_]goto%s+pc%d+") then innerGoto = true break end end
								end
							end
							local outsideRefs = false
							if not hasInnerLabel and not innerGoto then
								for _, r in ipairs(labelRefs(lines, tgt1)) do
									if r < i or r > elseIdx then outsideRefs = true break end
								end
							end
							if not hasInnerLabel and not innerGoto and not outsideRefs then
								local condParts = {}
								for _, g in ipairs(guards) do condParts[#condParts+1] = wrapForAnd(negateCond(g)) end
								local cond = table.concat(condParts, " and ")
								local newBlock = {ii .. "if " .. cond .. " then"}
								for k = 1, lastI - 1 do
									local bl = thenBody[k]
									newBlock[#newBlock+1] = bl:match("%S") and (indentUnit .. bl) or bl
								end
								local hasElseBody = false
								for _, bl in ipairs(elseBody) do if bl:match("%S") then hasElseBody = true break end end
								if hasElseBody then
									newBlock[#newBlock+1] = ii .. "else"
									for _, bl in ipairs(elseBody) do newBlock[#newBlock+1] = bl:match("%S") and (indentUnit .. bl) or bl end
								end
								newBlock[#newBlock+1] = ii .. "end"
								local otherJoinRefs = {}
								for _, r in ipairs(labelRefs(lines, joinTgt)) do
									if not (i <= r and r <= joinIdx) then otherJoinRefs[#otherJoinRefs+1] = r end
								end
								if #otherJoinRefs > 0 then newBlock[#newBlock+1] = lines[joinIdx] end
								local result = {}
								for k = 1, i - 1 do result[#result+1] = lines[k] end
								for _, bl in ipairs(newBlock) do result[#result+1] = bl end
								for k = joinIdx + 1, #lines do result[#result+1] = lines[k] end
								return result, true
							end
						end
					end
				end
			end
		end
		if not transformed then
			i = i + 1
		end
	end
	return lines, false
end

-- Lift `if COND then goto T end; BODY; ::T::` -> `if not COND then BODY end`
-- where T is only referenced by this one goto, BODY has no labels and no ref to T
local function liftGuardToSkipLabel(lines, indentUnit)
	local changed = false
	local i = 1
	while i <= #lines do
		local rebuilt = false
		local ind, cond, tgt = matchIfGoto(lines[i])
		if ind then
			local labelIdx = nil
			local labelInd = nil
			for j = i + 1, #lines do
				local li, lbl = matchLbl(lines[j])
				if lbl == tgt then
					labelIdx = j
					labelInd = li
					break
				end
			end
			if labelIdx and labelInd == ind and labelIdx > i + 1 then
				-- the label must be referenced only once (by our goto) so we
				-- can safely drop it after re-structuring.
				local refs = labelRefs(lines, tgt)
				if #refs == 1 and refs[1] == i then
					local bodyOk = true
					-- disallow inner labels and disallow nested blocks that
					-- span past the label.
					local depth = 0
					for k = i + 1, labelIdx - 1 do
						local _, innerLbl = matchLbl(lines[k])
						if innerLbl then bodyOk = false; break end
						local ki = lines[k]:match("^(%s*)") or ""
						if #ki < #ind then bodyOk = false; break end
						if matchLoopOpen(lines[k]) or matchIfOpen(lines[k]) then
							depth = depth + 1
						elseif matchEnd(lines[k]) then
							if depth == 0 then bodyOk = false; break end
							depth = depth - 1
						end
					end
					if bodyOk and depth == 0 then
						local body = {}
						for k = i + 1, labelIdx - 1 do body[#body+1] = lines[k] end
						local negCond = negateCond(cond)
						local newBlock = {ind .. "if " .. negCond .. " then"}
						for _, bl in ipairs(body) do
							if bl:match("%S") then
								newBlock[#newBlock+1] = indentUnit .. bl
							else
								newBlock[#newBlock+1] = bl
							end
						end
						newBlock[#newBlock+1] = ind .. "end"
						local result = {}
						for k = 1, i - 1 do result[#result+1] = lines[k] end
						for _, bl in ipairs(newBlock) do result[#result+1] = bl end
						for k = labelIdx + 1, #lines do result[#result+1] = lines[k] end
						lines = result
						changed = true
						rebuilt = true
					end
				end
			end
		end
		if not rebuilt then i = i + 1 end
	end
	return lines, changed
end

local function liftIfGotoBody(lines, indentUnit)
	local i = 1
	while i <= #lines do
		local ind, cond, target = matchIfGoto(lines[i])
		if not ind then
			i = i + 1
		else
			local labelIdx = findLabelIndex(lines, target, i + 1)
			if not labelIdx then
				i = i + 1
			else
				local body = {}
				for k = i + 1, labelIdx - 1 do body[#body+1] = lines[k] end
				local bodyHasGoto = false
				for _, bl in ipairs(body) do
					if bl:find("%f[%a_]goto%s+" .. luaPE(target) .. "%f[^%a_%d]") then
						bodyHasGoto = true
						break
					end
				end
				local outsideRefs = {}
				for _, r in ipairs(labelRefs(lines, target)) do
					if r < i or r > labelIdx then outsideRefs[#outsideRefs+1] = r end
				end

				local elseBlock = nil
				local elseTarget = nil
				local elseLabelIdx = nil
				local lastIdx = lastNonblankIndex(body)
				if lastIdx and not bodyHasGoto then
					local _, candTarget = matchGoto(body[lastIdx])
					if candTarget then
						local candLabelIdx = findLabelIndex(lines, candTarget, labelIdx + 1)
						if candLabelIdx then
							local between = {}
							for k = labelIdx + 1, candLabelIdx - 1 do between[#between+1] = lines[k] end
							local bodyInner = {}
							for k = 1, lastIdx - 1 do bodyInner[#bodyInner+1] = body[k] end
							local escapes = false
							for _, bl in ipairs(bodyInner) do
								if bl:find("%f[%a_]goto%s+" .. luaPE(target) .. "%f[^%a_%d]")
									or bl:find("%f[%a_]goto%s+" .. luaPE(candTarget) .. "%f[^%a_%d]")
								then
									escapes = true
									break
								end
							end
							if not escapes then
								for _, bl in ipairs(between) do
									if bl:find("%f[%a_]goto%s+" .. luaPE(target) .. "%f[^%a_%d]")
										or bl:find("%f[%a_]goto%s+" .. luaPE(candTarget) .. "%f[^%a_%d]")
									then
										escapes = true
										break
									end
								end
							end
							if not escapes then
								elseBlock = between
								elseTarget = candTarget
								elseLabelIdx = candLabelIdx
								body = bodyInner
							end
						end
					end
				end

				local newBlock = {ind .. "if " .. negateCond(cond) .. " then"}
				for _, bl in ipairs(body) do
					if bl:match("%S") then
						newBlock[#newBlock+1] = indentUnit .. bl
					else
						newBlock[#newBlock+1] = bl
					end
				end
				if elseBlock then
					newBlock[#newBlock+1] = ind .. "else"
					for _, bl in ipairs(elseBlock) do
						if bl:match("%S") then
							newBlock[#newBlock+1] = indentUnit .. bl
						else
							newBlock[#newBlock+1] = bl
						end
					end
				end
				newBlock[#newBlock+1] = ind .. "end"

				local result = {}
				for k = 1, i - 1 do result[#result+1] = lines[k] end
				for _, bl in ipairs(newBlock) do result[#result+1] = bl end
				if elseBlock then
					if #outsideRefs > 0 or bodyHasGoto then result[#result+1] = lines[labelIdx] end
					local otherElseRefs = false
					for _, r in ipairs(labelRefs(lines, elseTarget)) do
						if r < i or r > elseLabelIdx then
							otherElseRefs = true
							break
						end
					end
					if otherElseRefs then result[#result+1] = lines[elseLabelIdx] end
					for k = elseLabelIdx + 1, #lines do result[#result+1] = lines[k] end
				else
					if #outsideRefs > 0 or bodyHasGoto then result[#result+1] = lines[labelIdx] end
					for k = labelIdx + 1, #lines do result[#result+1] = lines[k] end
				end
				return result, true
			end
		end
	end
	return lines, false
end

local function liftSimpleGuardChains(lines, indentUnit)
	local i = 1
	while i <= #lines do
		local ind, cond, target = matchIfGoto(lines[i])
		if not ind then
			i = i + 1
		else
			local guards = {}
			local cur = i
			while cur <= #lines do
				local gi, gc, gt = matchIfGoto(lines[cur])
				if not gi or gi ~= ind or gt ~= target then break end
				guards[#guards+1] = gc
				cur = cur + 1
			end
			local labelIdx = findLabelIndex(lines, target, cur)
			if labelIdx and #guards > 0 then
				local refsOk = true
				for _, r in ipairs(labelRefs(lines, target)) do
					if r < i or r >= cur then refsOk = false break end
				end
				local bodyOk = refsOk and labelIdx > cur
				if bodyOk then
					for k = cur, labelIdx - 1 do
						local bi = lines[k]:match("^(%s*)") or ""
						local _, lbl = matchLbl(lines[k])
						if (lines[k]:match("%S") and #bi < #ind) or lbl or matchGoto(lines[k]) or matchIfGoto(lines[k]) then bodyOk = false break end
					end
				end
				if bodyOk then
					local conds = {}
					for _, g in ipairs(guards) do conds[#conds+1] = negateCond(g) end
					local newBlock = {ind .. "if " .. table.concat(conds, " and ") .. " then"}
					for k = cur, labelIdx - 1 do
						local bl = lines[k]
						if bl:match("%S") then newBlock[#newBlock+1] = indentUnit .. bl else newBlock[#newBlock+1] = bl end
					end
					newBlock[#newBlock+1] = ind .. "end"
					local result = {}
					for k = 1, i - 1 do result[#result+1] = lines[k] end
					for _, bl in ipairs(newBlock) do result[#result+1] = bl end
					for k = labelIdx + 1, #lines do result[#result+1] = lines[k] end
					return result, true
				end
			end
			i = i + 1
		end
	end
	return lines, false
end

local function liftParentClosingGuards(lines, indentUnit)
	local i = 1
	while i <= #lines do
		local ind, cond, target = matchIfGoto(lines[i])
		if not ind then
			i = i + 1
		else
			local labelIdx = findLabelIndex(lines, target, i + 1)
			if labelIdx and labelIdx > i + 2 then
				local labelInd = lines[labelIdx]:match("^(%s*)") or ""
				local endIdx = labelIdx - 1
				local endInd = matchEnd(lines[endIdx])
				if endInd and #endInd == #labelInd and #labelInd < #ind then
					local refs = labelRefs(lines, target)
					local bodyOk = #refs == 1 and refs[1] == i
					if bodyOk then
						for k = i + 1, endIdx - 1 do
							local bi = lines[k]:match("^(%s*)") or ""
							local _, lbl = matchLbl(lines[k])
							if #bi < #ind or lbl or matchGoto(lines[k]) or matchIfGoto(lines[k]) then bodyOk = false break end
						end
					end
					if bodyOk then
						local newBlock = {ind .. "if " .. negateCond(cond) .. " then"}
						for k = i + 1, endIdx - 1 do
							local bl = lines[k]
							if bl:match("%S") then newBlock[#newBlock+1] = indentUnit .. bl else newBlock[#newBlock+1] = bl end
						end
						newBlock[#newBlock+1] = ind .. "end"
						local result = {}
						for k = 1, i - 1 do result[#result+1] = lines[k] end
						for _, bl in ipairs(newBlock) do result[#result+1] = bl end
						result[#result+1] = lines[endIdx]
						for k = labelIdx + 1, #lines do result[#result+1] = lines[k] end
						return result, true
					end
				end
			end
			i = i + 1
		end
	end
	return lines, false
end

-- Lift multiline `if X then BODY goto T end ELSE_BODY ::T::` -> `if X then BODY else ELSE_BODY end`
local function liftMultilineIfGotoElse(lines, indentUnit)
	local i = 1
	while i <= #lines do
		local mii, cond = matchIfOpen(lines[i])
		if mii then
			local endPat = "^" .. luaPE(mii) .. "end%s*$"
			local depth = 0
			local endIdx = nil
			for j = i + 1, #lines do
				local ii2 = matchIfOpen(lines[j])
				if ii2 and ii2 == mii then
					depth = depth + 1
				elseif lines[j]:match(endPat) then
					if depth == 0 then
						endIdx = j
						break
					end
					depth = depth - 1
				end
			end
			if endIdx then
				local k = endIdx - 1
				while k > i and not lines[k]:match("%S") do k = k - 1 end
				if k > i then
					local gi, gTgt = matchGoto(lines[k])
					if gi and #gi > #mii then
						local labelIdx = nil
						for j = endIdx + 1, #lines do
							local lind, lbl = matchLbl(lines[j])
							if lbl == gTgt then
								if #lind <= #mii then labelIdx = j end
								break
							end
						end
						if labelIdx then
							local outsideRefs = false
							for _, r in ipairs(labelRefs(lines, gTgt)) do
								if r < i or r > labelIdx then outsideRefs = true break end
							end
							local bodyInner = {}
							for j = i + 1, k - 1 do bodyInner[#bodyInner+1] = lines[j] end
							local elseBody = {}
							for j = endIdx + 1, labelIdx - 1 do elseBody[#elseBody+1] = lines[j] end
							local bodyHasGoto = false
							local tgtPat = "%f[%a_]goto%s+" .. luaPE(gTgt) .. "%f[^%a_%d]"
							for _, bl in ipairs(bodyInner) do if bl:find(tgtPat) then bodyHasGoto = true break end end
							local elseHasGoto = false
							for _, bl in ipairs(elseBody) do if bl:find(tgtPat) then elseHasGoto = true break end end
							local newBlock = {mii .. "if " .. cond .. " then"}
							for _, bl in ipairs(bodyInner) do newBlock[#newBlock+1] = bl end
							local hasElse = false
							for _, bl in ipairs(elseBody) do if bl:match("%S") then hasElse = true break end end
							if hasElse then
								newBlock[#newBlock+1] = mii .. "else"
								local minInd = nil
								for _, bl in ipairs(elseBody) do
									if bl:match("%S") then
										local li2 = #(bl:match("^(%s*)") or "")
										if not minInd or li2 < minInd then minInd = li2 end
									end
								end
								minInd = minInd or #mii
								for _, bl in ipairs(elseBody) do
									if not bl:match("%S") then newBlock[#newBlock+1] = bl
									else newBlock[#newBlock+1] = gi .. bl:sub(minInd + 1) end
								end
							end
							newBlock[#newBlock+1] = mii .. "end"
							local keepLabel = bodyHasGoto or elseHasGoto or outsideRefs
							local result = {}
							for j = 1, i - 1 do result[#result+1] = lines[j] end
							for _, bl in ipairs(newBlock) do result[#result+1] = bl end
							if keepLabel then result[#result+1] = lines[labelIdx] end
							for j = labelIdx + 1, #lines do result[#result+1] = lines[j] end
							return result, true
						end
					end
				end
			end
		end
		i = i + 1
	end
	return lines, false
end

-- Find enclosing loop (returns openIdx, closeIdx, loopIndent) using fresh copy of lines
local function enclosingLoop(lines, gotoLineIdx)
	local candidates = {}
	for k = gotoLineIdx - 1, 1, -1 do
		local li = matchLoopOpen(lines[k])
		if li then candidates[#candidates+1] = {k, li} end
	end
	for _, cand in ipairs(candidates) do
		local openIdx, loopInd = cand[1], cand[2]
		local endPat = "^" .. luaPE(loopInd) .. "end%s*$"
		local depth = 0
		for j = openIdx + 1, #lines do
			local li2 = matchLoopOpen(lines[j])
			if li2 and li2 == loopInd then depth = depth + 1
			elseif lines[j]:match(endPat) then
				if depth == 0 then
					if openIdx <= gotoLineIdx and gotoLineIdx <= j then
						return openIdx, j, loopInd
					end
					break
				end
				depth = depth - 1
			end
		end
	end
	return nil
end

-- Convert goto pcN inside loops to `continue` keyword
local function gotosToContinue(lines)
	if #lines == 0 then return lines end
	local labelIdx = {}
	for i, ln in ipairs(lines) do
		local _, lbl = matchLbl(ln)
		if lbl then
			if not labelIdx[lbl] then labelIdx[lbl] = {} end
			labelIdx[lbl][#labelIdx[lbl]+1] = i
		end
	end
	local newLines = {}
	for _, ln in ipairs(lines) do newLines[#newLines+1] = ln end
	local labelsToDrop = {}
	for i, ln in ipairs(newLines) do
		local gind, gtgt = matchGoto(ln)
		local inlineInd, inlineCond, inlineTarget = matchIfGoto(ln)
		if gind or inlineInd then
			local indent2 = gind or inlineInd
			local target = gtgt or inlineTarget
			local openIdx, closeIdx, _ = enclosingLoop(newLines, i)
			if openIdx then
				local tgtIdxs = labelIdx[target] or {}
				local convert = false
				if #tgtIdxs == 0 then
					convert = true
				else
					for _, li in ipairs(tgtIdxs) do
						if openIdx < li and li < closeIdx then
							local tailBlank = true
							for k = li + 1, closeIdx - 1 do
								if newLines[k]:match("%S") then tailBlank = false break end
							end
							if tailBlank then
								convert = true
								labelsToDrop[li] = true
								break
							end
						end
					end
				end
				if convert then
					if inlineInd then
						newLines[i] = indent2 .. "if " .. inlineCond .. " then continue end"
					else
						newLines[i] = indent2 .. "continue"
					end
				end
			end
		end
	end
	if next(labelsToDrop) then
		local filtered = {}
		for k, ln in ipairs(newLines) do
			if not labelsToDrop[k] then filtered[#filtered+1] = ln end
		end
		newLines = filtered
	end
	return newLines
end

-- Convert goto pcN after loops to `break`
local function gotosToBreak(lines)
	if #lines == 0 then return lines end
	local labelIdx = {}
	for i, ln in ipairs(lines) do
		local _, lbl = matchLbl(ln)
		if lbl then
			if not labelIdx[lbl] then labelIdx[lbl] = {} end
			labelIdx[lbl][#labelIdx[lbl]+1] = i
		end
	end
	local newLines = {}
	for _, ln in ipairs(lines) do newLines[#newLines+1] = ln end
	local convertedTargets = {}
	for i, ln in ipairs(newLines) do
		local gind, gtgt = matchGoto(ln)
		local inlineInd, inlineCond, inlineTarget = matchIfGoto(ln)
		if gind or inlineInd then
			local indent2 = gind or inlineInd
			local target = gtgt or inlineTarget
			local converted = false
			local openIdx, closeIdx, _ = enclosingLoop(newLines, i)
			if openIdx then
				local j = closeIdx + 1
				while j <= #newLines and not newLines[j]:match("%S") do j = j + 1 end
				local tgtIdxs = labelIdx[target] or {}
				local found = false
				for _, li in ipairs(tgtIdxs) do if li == j then found = true break end end
				if found then
					newLines[i] = inlineInd and (indent2 .. "if " .. inlineCond .. " then break end") or (indent2 .. "break")
					convertedTargets[target] = true
					converted = true
				end
			end
			if not converted then
				local j = i + 1
				while j <= #newLines and not newLines[j]:match("%S") do j = j + 1 end
				local closeInd = j <= #newLines and matchEnd(newLines[j]) or nil
				if closeInd and #closeInd < #indent2 then
					local k = j + 1
					while k <= #newLines and not newLines[k]:match("%S") do k = k + 1 end
					local lbl = nil
					if k <= #newLines then
						local _li
						_li, lbl = matchLbl(newLines[k])
					end
					if lbl == target then
						newLines[i] = inlineInd and (indent2 .. "if " .. inlineCond .. " then break end") or (indent2 .. "break")
						convertedTargets[target] = true
					end
				end
			end
		end
	end
	if next(convertedTargets) then
		local stillUsed = {}
		for _, ln in ipairs(newLines) do
			local _, gtgt = matchGoto(ln)
			if gtgt then stillUsed[gtgt] = true end
			local _, _, inlineTarget = matchIfGoto(ln)
			if inlineTarget then stillUsed[inlineTarget] = true end
		end
		local filtered = {}
		for _, ln in ipairs(newLines) do
			local _, lbl = matchLbl(ln)
			if lbl and convertedTargets[lbl] and not stillUsed[lbl] then
				-- skip
			else
				filtered[#filtered+1] = ln
			end
		end
		newLines = filtered
	end
	return newLines
end

-- Drop empty for-loops whose body is just `goto LBL` then `::LBL::`
local function dropEmptyGotoForLoops(lines)
	local newLines = {}
	for _, ln in ipairs(lines) do newLines[#newLines+1] = ln end
	local i = 1
	while i <= #newLines - 3 do
		local forInd = newLines[i]:match("^(%s*)for%s.+%sdo%s*$")
		if forInd then
			local endPat = "^" .. luaPE(forInd) .. "end%s*$"
			local j = i + 1
			local bodyLines = {}
			while j <= #newLines do
				if newLines[j]:match("%S") then
					if newLines[j]:match(endPat) then break end
					bodyLines[#bodyLines+1] = j
				end
				j = j + 1
			end
			local removed = false
			if j <= #newLines and #bodyLines == 1 then
				local gi, gTgt = matchGoto(newLines[bodyLines[1]])
				if gi then
					local k = j + 1
					while k <= #newLines and not newLines[k]:match("%S") do k = k + 1 end
					if k <= #newLines then
						local _, lbl = matchLbl(newLines[k])
						if lbl == gTgt then
							for _ = i, k do table.remove(newLines, i) end
							removed = true
						end
					end
				end
			end
			if not removed then
				i = i + 1
			end
		else
			i = i + 1
		end
	end
	return newLines
end

-- Convert `::pcN:: BODY goto pcN` -> `while true do BODY end`
local function liftWhileTrueFromJumpback(lines, loopHeaderPcs)
	local headerSet = {}
	if loopHeaderPcs then
		for _, pc in ipairs(loopHeaderPcs) do headerSet[pc] = true end
	end
	local i = 1
	while i <= #lines do
		local transformed = false
		local lind, lbl = matchLbl(lines[i])
		if lbl and (not loopHeaderPcs or headerSet[lbl]) then
			local lastJ = nil
			for j = i + 1, #lines do
				local gi, gTgt = matchGoto(lines[j])
				if gi and gTgt == lbl then
					if #gi <= #lind then break end
					lastJ = j
					break
				end
			end
			if lastJ then
				local depth = 0
				for j = i + 1, lastJ - 1 do
					local s = lines[j]:match("^%s*(.-)%s*$")
					if matchLoopOpen(lines[j]) then depth = depth + 1
					elseif s == "end" and depth > 0 then depth = depth - 1 end
				end
				if depth == 0 then
					local extraRefs = false
					for _, r in ipairs(labelRefs(lines, lbl)) do
						if r ~= lastJ then extraRefs = true break end
					end
					if not extraRefs then
						local whileInd = lind
						local bodyLines = {}
						for j = i + 1, lastJ - 1 do bodyLines[#bodyLines+1] = lines[j] end
						local lastB = #bodyLines
						while lastB > 0 and not bodyLines[lastB]:match("%S") do lastB = lastB - 1 end
						while #bodyLines > lastB do table.remove(bodyLines) end
						local newBlock = {whileInd .. "while true do"}
						for _, bl in ipairs(bodyLines) do newBlock[#newBlock+1] = bl end
						newBlock[#newBlock+1] = whileInd .. "end"
						local result = {}
						for k = 1, i - 1 do result[#result+1] = lines[k] end
						for _, bl in ipairs(newBlock) do result[#result+1] = bl end
						for k = lastJ + 1, #lines do result[#result+1] = lines[k] end
						lines = result
						transformed = true
					end
				end
			end
		end
		if not transformed then
			i = i + 1
		end
	end
	return lines
end

-- helper: get assignation info from a line: returns indent, varname, expr or nil
local function assignLineVar(line)
	local ind, nm, rhs = line:match("^(%s*)local%s+([%a_][%a_%d%.]*)%s*=%s*(.+)%s*$")
	if nm then return ind, nm, rhs end
	ind, nm, rhs = line:match("^(%s*)([%a_][%a_%d%.:%[%]]*)%s*=%s*(.+)%s*$")
	if nm then return ind, nm, rhs end
	return nil
end

-- Lift `if COND then return EXPR1 else return EXPR2 end` -> `return COND and EXPR1 or EXPR2`
-- (or simpler ternary pattern)
local function liftConditionalFallback(lines, indentUnit)
	local changed = false
	local out = {}
	local i = 1
	while i <= #lines do
		local folded = false
		-- pattern: `if COND then return E1 else return E2 end`
		if i + 4 <= #lines then
			local mi, cond = matchIfOpen(lines[i])
			if mi then
				local ei1, r1 = matchReturn(lines[i+1])
				local el2 = lines[i+2]:match("^" .. luaPE(mi) .. "else%s*$")
				local ei3, r2 = matchReturn(lines[i+3])
				local eend = matchEnd(lines[i+4])
				if ei1 and el2 and ei3 and eend and ei1 == mi .. indentUnit and ei3 == mi .. indentUnit and eend == mi then
					local v1 = r1:match("^return%s+(.+)$")
					local v2 = r2:match("^return%s+(.+)$")
					if v1 and v2 then
						local nc = negateCond(cond)
						out[#out+1] = mi .. "return " .. wrapForAnd(nc) .. " or (" .. wrapForAnd(v1) .. " or " .. wrapForAnd(v2) .. ")"
						i = i + 5
						changed = true
						folded = true
					end
				end
			end
		end
		if not folded then
			out[#out+1] = lines[i]
			i = i + 1
		end
	end
	return out, changed
end

-- Lift mixed guard-or pair: `if not COND then X = DEFAULT end; BODY using X`
local function liftMixedGuardOrPair(lines, indentUnit)
	local out = {}
	local i = 1
	local changed = false
	while i <= #lines do
		local folded = false
		if i + 4 <= #lines then
			local gi, negCond = lines[i]:match("^(%s*)if%s+not%s+(.+)%s+then%s*$")
			if gi then
				local ai, dv = lines[i+1]:match("^(" .. luaPE(gi .. indentUnit) .. ")(.+)$")
				local ei = matchEnd(lines[i+2])
				if ai and ei and ei == gi then
					local varPat, rhs = dv:match("^([%a_][%a_%d%.]*)%s*=%s*(.+)$")
					if varPat and rhs then
						out[#out+1] = gi .. varPat .. " = " .. negCond .. " and " .. varPat .. " or " .. rhs
						i = i + 3
						changed = true
						folded = true
					end
				end
			end
		end
		if not folded then
			out[#out+1] = lines[i]
			i = i + 1
		end
	end
	return out, changed
end

-- Lift case chain: `if _rN == V1 then goto J1 end; if _rN == V2 then goto J2 end...`
-- We try to reconstruct an elseif chain from goto-based case dispatch
local function liftIfGotoCaseChains(lines, indentUnit)
	local changed = false
	local i = 1
	while i <= #lines do
		local ii, c0, t0 = matchIfGoto(lines[i])
		local rebuilt = false
		if ii then
			local selector = c0:match("^(.-)%s*==%s*.+$")
			if selector then
				local cases = {{c0, t0}}
				local j = i + 1
				while j <= #lines do
					local ii2, c2, t2 = matchIfGoto(lines[j])
					if not ii2 or ii2 ~= ii then break end
					if not c2:match("^" .. luaPE(selector) .. "%s*==%s*") then break end
					cases[#cases+1] = {c2, t2}
					j = j + 1
				end
				if #cases >= 2 then
					local newBlock = {}
					for k, cas in ipairs(cases) do
						local cond, tgt = cas[1], cas[2]
						if k == 1 then
							newBlock[#newBlock+1] = ii .. "if " .. cond .. " then"
						else
							newBlock[#newBlock+1] = ii .. "elseif " .. cond .. " then"
						end
						newBlock[#newBlock+1] = ii .. indentUnit .. "goto " .. tgt
					end
					newBlock[#newBlock+1] = ii .. "end"
					local result = {}
					for k = 1, i - 1 do result[#result+1] = lines[k] end
					for _, bl in ipairs(newBlock) do result[#result+1] = bl end
					for k = j, #lines do result[#result+1] = lines[k] end
					lines = result
					changed = true
					rebuilt = true
				end
			end
		end
		if not rebuilt then
			i = i + 1
		end
	end
	return lines, changed
end

-- MAIN CONTROL FLOW LIFTER
local function liftControlFlow(lines, indentUnit, loopHeaderPcs)
	if type(lines) == "string" then
		local tmp = {}
		for ln in (lines .. "\n"):gmatch("([^\n]*)\n") do tmp[#tmp+1] = ln end
		lines = tmp
	end
	indentUnit = indentUnit or "\t"

	local function sameLines(a, b)
		if #a ~= #b then return false end
		for i = 1, #a do
			if a[i] ~= b[i] then return false end
		end
		return true
	end

	-- Pass 1: basic single-line structural passes
	lines = rewriteGotoToReturn(lines)
	lines = collapseTrivialIf(lines)
	lines = rewriteGotoToReturn(lines)
	lines = normalizeNegativeAddk(lines)
	lines = removeUnreachableAfterReturn(lines)
	lines = dropOrphanLabels(lines)

	for _ = 1, 400 do
		local changed = false
		lines = collapseTrivialIf(lines)
		local newLines, changedGuard = liftGuardChainElse(lines, indentUnit)
		if changedGuard then
			lines = newLines
			changed = true
		else
			local changedFallback = false
			newLines, changedFallback = liftConditionalFallback(lines, indentUnit)
			if changedFallback then
				lines = newLines
				changed = true
			else
				local changedInline = false
				newLines, changedInline = inlineLocalIntoIfGoto(lines, indentUnit)
				if changedInline then
					lines = newLines
					changed = true
				else
					local changedMixed = false
					newLines, changedMixed = liftMixedGuardOrPair(lines, indentUnit)
					if changedMixed then
						lines = newLines
						changed = true
					else
						local changedCase = false
						newLines, changedCase = liftIfGotoCaseChains(lines, indentUnit)
						if changedCase then
							lines = newLines
							changed = true
						else
							local changedMlif = false
							newLines, changedMlif = liftMultilineIfGotoElse(lines, indentUnit)
							if changedMlif then
								lines = newLines
								changed = true
							end
						end
					end
				end
			end
		end
		if not changed then break end
	end

	-- Pass 2: for loop reconstruction
	for _ = 1, 8 do
		local prev = lines
		lines = liftNumericFor(lines, indentUnit)
		lines = liftGenericFor(lines, indentUnit)
		if sameLines(lines, prev) then break end
	end

	-- Pass 3: while-true reconstruction
	lines = liftWhileTrueFromJumpback(lines, loopHeaderPcs)

	-- Pass 4: goto -> break/continue
	lines = gotosToContinue(lines)
	lines = gotosToBreak(lines)

	-- Pass 5: if/else reconstruction (multi-pass)
	for _ = 1, 128 do
		local prev = lines
		lines = collapseTrivialIf(lines)
		lines = rewriteGotoToReturn(lines)
		local changedInline = false
		lines, changedInline = inlineLocalIntoIfGoto(lines, indentUnit)
		local changed1 = false
		lines, changed1 = liftGuardChainElse(lines, indentUnit)
		local changed2 = false
		lines, changed2 = liftMultilineIfGotoElse(lines, indentUnit)
		lines = liftElseifPatterns(lines)
		lines = collapseSingleIfChain(lines)
		lines = recoverEmptyFieldGuards(lines)
		lines = dropEmptyIfBlocks(lines)
		local changed3 = false
		lines, changed3 = liftIfGotoCaseChains(lines, indentUnit)
		local changed5 = false
		lines, changed5 = liftSimpleGuardChains(lines, indentUnit)
		local changed6 = false
		lines, changed6 = dropGotoToImmediatePostIfLabel(lines)
		local changed4 = false
		lines, changed4 = liftIfGotoBody(lines, indentUnit)
		local changed0 = false
		lines, changed0 = liftGuardToSkipLabel(lines, indentUnit)
		local same = (not changedInline) and (not changed0) and (not changed1) and (not changed2) and (not changed3) and (not changed4) and (not changed5) and (not changed6)
		if same then
			local eq = #lines == #prev
			if eq then for k = 1, #lines do if lines[k] ~= prev[k] then eq = false; break end end end
			if eq then break end
		end
	end

	-- Pass 6: fallback/guard idioms
	for _ = 1, 8 do
		local changed1, changed2
		lines, changed1 = liftConditionalFallback(lines, indentUnit)
		lines, changed2 = liftMixedGuardOrPair(lines, indentUnit)
		if not changed1 and not changed2 then break end
	end

	-- Pass 7: return/local inlining
	lines = inlineTrivialReturnLocals(lines)
	lines = inlineTrivialConditionLocals(lines)
	lines = inlineTrivialCompareGuardLocals(lines)
	lines = fixOrDefaultAssignments(lines)
	lines = rewriteGotoToReturn(lines)
	lines = foldConstantConditionBlocks(lines, indentUnit)

	-- Pass 8: structural cleanup
	for _ = 1, 8 do
		local prev = lines
		lines = liftNumericFor(lines, indentUnit)
		lines = liftGenericFor(lines, indentUnit)
		if sameLines(lines, prev) then break end
	end
	lines = gotosToContinue(lines)
	lines = gotosToBreak(lines)
	lines = dropEmptyGotoForLoops(lines)
	lines = liftElseifPatterns(lines)
	lines = collapseSingleIfChain(lines)
	lines = recoverEmptyFieldGuards(lines)
	lines = dropEmptyIfBlocks(lines)

	-- Pass 9: register temp cleanup
	lines = splitRegisterLifetimes(lines)
	lines = inlineTrivialReturnLocals(lines)

	-- Pass 10: trailing cleanup
	lines = removeUnreachableAfterReturn(lines)
	lines = dropTrailingReturn(lines)
	lines = gotosToContinue(lines)
	lines = gotosToBreak(lines)
	lines = dropOrphanLabels(lines)
	lines = foldTableArrayInitializers(lines)
	lines = fixInvertedIsaGuard(lines)
	lines = fixBareMethodReferences(lines)
	lines = fixLiteralMethodReceivers(lines)
	lines = fixLiteralFieldReceivers(lines)
	lines = repairInvalidElseClauses(lines)
	lines = foldConstantConditionBlocks(lines, indentUnit)
	lines = removeUnreachableAfterReturn(lines)

	-- Pass 11: indentation normalization
	lines = normalizeLuaIndentation(lines, indentUnit)
	lines = fixInvertedIsaGuard(lines)
	lines = inlineTrivialConditionLocals(lines)
	lines = inlineTrivialCompareGuardLocals(lines)
	lines = renameTempByCommonAssignedField(lines)
	lines = renameTempFindFirstChildDynamic(lines)
	lines = renameLocalTableByAssignment(lines)
	lines = fixOrDefaultAssignments(lines)
	lines = gotosToContinue(lines)
	lines = gotosToBreak(lines)
	lines = dropOrphanLabels(lines)
	lines = fixBareMethodReferences(lines)
	lines = fixLiteralMethodReceivers(lines)
	lines = fixLiteralFieldReceivers(lines)
	lines = repairInvalidElseClauses(lines)
	lines = foldConstantConditionBlocks(lines, indentUnit)
	lines = removeUnreachableAfterReturn(lines)
	lines = balanceLuaBlocksByIndent(lines)
	lines = dropUnmatchedEndLines(lines)
	lines = normalizeLuaIndentation(lines, indentUnit)
	for _ = 1, 16 do
		local changed
		lines, changed = wrapOrphanIfGotosAsGuards(lines, indentUnit)
		if not changed then break end
	end
	lines = dropInvalidTopLevelReturns(lines)
	lines = fixInvalidGenericForHeaders(lines)
	lines = normalizeLuaIndentation(lines, indentUnit)
	lines = dropInvalidTopLevelReturns(lines)

	return table.concat(lines, "\n")
end

local function decompileProto(p, bc, protoIdx)
	local isMain = protoIdx == bc.main_id
	local baseIndent = isMain and "" or "\t"
	local out = {}

	local name = p.debugname ~= "" and cleanIdent(p.debugname) or ("anon" .. tostring(protoIdx))
	local params = {}
	for i = 0, p.numparams - 1 do
		push(params, localAt(p, i, 0) or ("arg" .. tostring(i)))
	end
	if p.is_vararg then
		push(params, "...")
	end

	if isMain then
		push(out, "-- main chunk (proto[" .. tostring(protoIdx) .. "], line " .. tostring(p.linedefined) .. ")")
	else
		local upvalues = #p.upvalues > 0 and ("  -- upvalues: " .. table.concat(p.upvalues, ", ")) or ""
		push(out, "local function " .. name .. "(" .. table.concat(params, ", ") .. ") -- proto[" .. tostring(protoIdx) .. "], line " .. tostring(p.linedefined) .. upvalues)
	end

	local bodyIndent = baseIndent .. (isMain and "" or "\t")
	local regs = {}
	for i, paramName in ipairs(params) do
		if paramName ~= "..." then
			regs[i - 1] = paramName
		end
	end

	local targets = scanJumpTargets(p)
	local pendingClosureTarget = nil
	local pendingClosureProtoId = nil
	local pendingClosureCaps = {}
	local pc = 0
	local codeLen = #p.code

	local function flushPendingClosure()
		if pendingClosureTarget == nil then
			return
		end
		local childProto = pendingClosureProtoId ~= nil and protoAt(bc, pendingClosureProtoId) or nil
		local closureName = childProto and cleanIdent(childProto.debugname) or nil
		if not closureName or closureName == "" then
			closureName = pendingClosureProtoId ~= nil and ("anon" .. tostring(pendingClosureProtoId)) or "anon_unknown"
		end
		regs[pendingClosureTarget] = closureName
		if #pendingClosureCaps > 0 then
			local capDescs = {}
			for _, cap in ipairs(pendingClosureCaps) do
				push(capDescs, cap.expr)
			end
			push(out, bodyIndent .. "-- " .. closureName .. " captures: " .. table.concat(capDescs, ", "))
		end
		pendingClosureTarget = nil
		pendingClosureProtoId = nil
		pendingClosureCaps = {}
	end

	while pc < codeLen do
		if targets[pc] then
			push(out, bodyIndent .. "::pc" .. tostring(pc) .. "::")
		end

		local insn = codeWordAt(p, pc)
		local op = bit32_band(insn, 0xFF)
		local opName = OPCODES[op] or ("ROBLOX_OP_" .. tostring(op))
		local a = bit32_band(bit32_rshift(insn, 8), 0xFF)
		local b = bit32_band(bit32_rshift(insn, 16), 0xFF)
		local c = bit32_band(bit32_rshift(insn, 24), 0xFF)
		local d = decodeSignedD(insn)
		local e = decodeSignedE(insn)
		local aux = nil
		if OPS_WITH_AUX[opName] and pc + 1 < codeLen then
			aux = codeWordAt(p, pc + 1)
		end

		local handledCapture = false
		if opName == "CAPTURE" and pendingClosureTarget ~= nil then
			local kind = CAPTURE_KINDS[a] or ("?" .. tostring(a))
			if kind == "VAL" or kind == "REF" then
				push(pendingClosureCaps, {
					kind = kind,
					expr = regRepr(regs, p, b, pc),
				})
			else
				push(pendingClosureCaps, {
					kind = kind,
					expr = p.upvalues[b + 1] or ("U" .. tostring(b)),
				})
			end
			pc = pc + 1
			handledCapture = true
		elseif pendingClosureTarget ~= nil then
			flushPendingClosure()
		end

		if not handledCapture then
			local line, advanceExtra = emitDecompileLine(pc, opName, a, b, c, d, e, aux, p, bc, regs, bodyIndent)
			if opName == "NEWCLOSURE" then
				pendingClosureTarget = a
				pendingClosureProtoId = childProtoIdAt(p, d)
				pendingClosureCaps = {}
			elseif opName == "DUPCLOSURE" then
				pendingClosureTarget = a
				local closureConst = constantAt(p, d)
				pendingClosureProtoId = closureConst and closureConst.kind == "closure" and closureConst.value or nil
				pendingClosureCaps = {}
			end
			if line then
				push(out, line)
			end
			pc = pc + getOpLength(opName) + advanceExtra
		end
	end

	flushPendingClosure()

	if not isMain then
		push(out, "end")
	end

	local decompIndent = isMain and "\t" or (baseIndent .. "\t")
	return liftControlFlow(out, decompIndent, nil)
end

local function renderDisassembly(bc)
	local out = { "-- ============== DISASSEMBLY ==============" }
	for protoIdx = 0, #bc.protos - 1 do
		push(out, disassembleProto(protoAt(bc, protoIdx), bc, protoIdx))
		push(out, "")
	end
	return table.concat(out, "\n")
end

local function renderSource(bc)
	local out = { "-- ============== SOURCE ==============" }
	for protoIdx = 0, #bc.protos - 1 do
		if protoIdx ~= bc.main_id then
			push(out, decompileProto(protoAt(bc, protoIdx), bc, protoIdx))
			push(out, "")
		end
	end
	if bc.main_id >= 0 and bc.main_id < #bc.protos then
		push(out, decompileProto(protoAt(bc, bc.main_id), bc, bc.main_id))
		push(out, "")
	end
	local source = table.concat(out, "\n")
	local lines = {}
	for line in (source .. "\n"):gmatch("(.-)\n") do
		lines[#lines+1] = line
	end
	lines = dropInvalidTopLevelReturns(lines)
	return table.concat(lines, "\n")
end

local function normalizeOptions(options)
	if type(options) == "string" then
		return {
			mode = string.lower(options),
			filename = "bytecode",
		}
	end
	if type(options) ~= "table" then
		return {
			mode = "source",
			filename = "bytecode",
		}
	end
	local mode = type(options.mode) == "string" and string.lower(options.mode) or "source"
	local filename = type(options.filename) == "string" and options.filename or "bytecode"
	return {
		mode = mode,
		filename = filename,
	}
end

local function renderBytecode(filename, data, mode)
	local bc = parseBytecode(data)
	local out = {}
	push(out, "-- " .. basename(filename))
	push(out, "-- Original size: " .. tostring(#data) .. " bytes")
	push(out, "-- Bytecode version: " .. tostring(bc.version) .. ", types version: " .. tostring(bc.typesversion))
	push(out, "-- Strings: " .. tostring(#bc.strings) .. ", Protos: " .. tostring(#bc.protos) .. ", Main proto: " .. tostring(bc.main_id))
	push(out, "")

	if mode == "asm" or mode == "both" then
		push(out, renderDisassembly(bc))
	end
	if mode == "source" or mode == "both" then
		if mode == "both" then
			push(out, "")
		end
		push(out, renderSource(bc))
	end
	return table.concat(out, "\n")
end

local Module = {}

function Module.parseBytecode(data)
	assert(type(data) == "string", "parseBytecode expects raw bytecode string")
	return parseBytecode(data)
end

function Module.render(data, options)
	assert(type(data) == "string", "render expects raw bytecode string")
	local normalized = normalizeOptions(options)
	if normalized.mode ~= "source" and normalized.mode ~= "asm" and normalized.mode ~= "both" then
		error("Invalid mode: " .. tostring(normalized.mode) .. " (expected source|asm|both)")
	end
	return renderBytecode(normalized.filename, data, normalized.mode)
end

function Module.decompile(data, options)
	return Module.render(data, options)
end

function Module.tryDecompile(data, options)
	return pcall(Module.decompile, data, options)
end

Module.Decompile = Module.decompile
Module.default = Module.decompile

return Module
