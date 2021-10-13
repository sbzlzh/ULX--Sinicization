
--[[
Copyright (C) 2016-2018 DBot


-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

]]

local C = ULib.cmds

local ENT = {}

ENT.Type = 'anim'
ENT.PrintName = 'Trainfuck'
ENT.Author = 'DBot'

function ENT:Initialize()
	self.time = CurTimeL() + 4
	self:SetModel("models/props_combine/CombineTrain01a.mdl")
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)

	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:Wake()
			phys:EnableGravity(false)
			self.phys = phys
		end
	end
end

function ENT:SetPlayer(ply)
	self.Player = ply

	local pos = ply:GetPos()
	pos.x = pos.x + math.random(-1000,1000)
	pos.y = pos.y + math.random(-1000,1000)
	pos.z = pos.z + 20

	self:SetPos(pos)
end

function ENT:PhysicsCollide(tab)
	if tab.HitEntity ~= self.Player then return end
	self.Player:GodDisable()
	self.Player:TakeDamage(2 ^ 31 - 1, self, self)
end

function ENT:Think()
	if CLIENT then return end

	if self.time < CurTimeL() then
		SafeRemoveEntity(self)
		return
	end

	if not IsValid(self.Player) then return end
	local ply = self.Player

	ply:ExitVehicle()
	local pos = ply:GetPos()
	local newpos = self:GetPos()

	local normal = pos - newpos

	local ang = (normal):Angle()
	ang.y = ang.y + 180

	self:SetAngles(ang)

	if self.phys then
		self.phys:ApplyForceCenter(normal:GetNormalized() * 10^10) --heh c:
	end

	if not ply:GetNWBool("Spectator") and ply:GetMoveType() ~= MOVETYPE_WALK then
		ply:SetMoveType(MOVETYPE_WALK)
	end
end

scripted_ents.Register(ENT, 'dbot_admin_train')

ULXPP.Funcs = {}
--Functions not called clientside
if SERVER then
	include('autorun/ulxpp/sv_commands.lua')
end

ULXPP.Declared = {
	mhp = {
		help = '设置目标的最大生命值)',
		category = 'ULXPP',
		player = true,
		params = {
			{type = C.NumArg, min = 1, max = 2^31 - 1, hint = 'hp', C.round}
		}
	},

	roll = {
		help = 'Rolls the dice',
		category = 'ULXPP',
		access = ULib.ACCESS_ALL,
		params = {
			{type = C.NumArg, min = 1, max = 256, hint = 'number of faces', C.round, C.optional}
		}
	},

	rocket = {
		help = '火箭目标',
		category = 'ULXPP',
		player = true,
	},

	trainfuck = {
		help = '操练 目标',
		category = 'ULXPP',
		player = true,
	},

	sin = {
		help = '迫使目标漂浮在空中',
		category = 'ULXPP',
		player = true,
		params = {
			{type = C.NumArg, min = 1, max = 20, hint = 'time', C.round}
		}
	},

	unsin = {
		help = '取消浮动目标',
		category = 'ULXPP',
		player = true,
	},

	banish = {
		help = '放逐目标',
		category = 'ULXPP',
		player = true,
	},

	unbanish = {
		help = '取消放逐目标',
		category = 'ULXPP',
		player = true,
	},

	loadout = {
		help = '将他们的装备分配给目标',
		category = 'ULXPP',
		player = true,
	},

	giveammo = {
		help = '为目标提供当前武器的弹药',
		category = 'ULXPP',
		player = true,
		params = {
			{type = C.NumArg, min = 1, max = 9999, hint = 'amount', C.round}
		}
	},

	giveweapon = {
		help = '为目标提供武器',
		category = 'ULXPP',
		player = true,
		params = {
			{type = C.StringArg, default = 'weapon_crowbar'}
		}
	},

	nodraw = {
		help = '设置不绘制目标为相信',
		category = 'ULXPP',
		player = true,
	},

	unnodraw = {
		help = '设置不绘制目标为失败',
		category = 'ULXPP',
		player = true,
	},

	uarmor = {
		help = '与ulx盔甲相同但无限制',
		category = 'ULXPP',
		player = true,
		params = {
			{type = C.NumArg, min = 1, max = 2 ^ 31 - 1, hint = '数量', C.round}
		}
	},

	ctsay = {
		help = '向所有玩家的聊天框打印彩色消息',
		category = 'ULXPP',
		params = {
			{type = C.StringArg, default = '200 200 200', hint = '颜色'},
			{type = C.StringArg, default = '示例文本', hint = '消息'},
		}
	},

	ip = {
		help = '打印目标 IP',
		category = 'ULXPP',
		player = true,
	},

	confuse = {
		help = '混淆目标',
		category = 'ULXPP',
		player = true,
	},

	unconfuse = {
		help = '不混淆目标',
		category = 'ULXPP',
		player = true,
	},

	respawn = {
		help = '如果目标死亡,则重生目标',
		category = 'ULXPP',
		player = true,
	},

	sendlua = {
		help = '用于目标的发送Lua',
		category = 'ULXPP',
		player = true,
		access = ULib.ACCESS_SUPERADMIN,
		params = {
			{type = C.StringArg, default = '', hint = 'lua'},
		}
	},

	frespawn = {
		help = '强制目标重生',
		category = 'ULXPP',
		player = true,
	},

	uid = {
		help = '打印目标唯一 ID',
		category = 'ULXPP',
		player = true,
		access = ULib.ACCESS_ALL,
	},

	steamid64 = {
		help = '打印目标唯一 SteamID64',
		category = 'ULXPP',
		player = true,
		access = ULib.ACCESS_ALL,
	},

	steamid = {
		help = '打印目标唯一 SteamID',
		category = 'ULXPP',
		player = true,
		access = ULib.ACCESS_ALL,
	},

	profile = {
		help = '打开目标的配置文件',
		category = 'ULXPP',
		player = true,
		access = ULib.ACCESS_ALL,
	},

	jumppower = {
		help = '设置目标的跳跃力',
		category = 'ULXPP',
		player = true,
		params = {
			{type = C.NumArg, min = 1, max = 2 ^ 16, hint = '力量', C.round}
		}
	},

	walkspeed = {
		help = '设置目标的步行速度',
		category = 'ULXPP',
		player = true,
		params = {
			{type = C.NumArg, min = 1, max = 2 ^ 16, hint = '力量', C.round}
		}
	},

	runspeed = {
		help = '设置目标的运行速度',
		category = 'ULXPP',
		player = true,
		params = {
			{type = C.NumArg, min = 1, max = 2 ^ 16, hint = '力量', C.round}
		}
	},

	silence = {
		help = '静音和堵嘴目标',
		category = 'ULXPP',
		player = true,
	},

	unsilence = {
		help = '取消静音和堵嘴目标',
		category = 'ULXPP',
		player = true,
	},

	buddha = {
		help = '启用佛陀模式\n与神模式相同,但玩家\n受到击退影响',
		category = 'ULXPP',
		player = true,
	},

	unbuddha = {
		help = '取消佛陀模式',
		category = 'ULXPP',
		player = true,
	},

	bot = {
		help = '创造机器人',
		category = 'ULXPP',
		access = ULib.ACCESS_SUPERADMIN,
		params = {
			{type = C.NumArg, min = 1, max = 32, hint = '数量', C.round, C.optional, default = 1}
		}
	},

	kickbots = {
		help = '踢出全部机器人',
		category = 'ULXPP',
	},

	cleanmap = {
		help = '运行游戏清理地图',
		category = 'ULXPP',
	},
}

for k, v in pairs(ULXPP.Declared) do
	v.callback = ULXPP.Funcs[k]
	local obj = ULXPP.CreateCommand(k, v)
	if v.post then
		v.post(obj)
	end
end
