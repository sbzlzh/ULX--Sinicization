
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

util.AddNetworkString('ULXPP.sin')
util.AddNetworkString('ULXPP.banish')
util.AddNetworkString('ULXPP.coloredmessage')
util.AddNetworkString('ULXPP.Profile')
util.AddNetworkString('ULXPP.confuse')

DAMAGE_MODE_NONE = 0
DAMAGE_MODE_BUDDHA = 1
DAMAGE_MODE_ENABLED = 2
DAMAGE_MODE_AIM = 3

local C = ULib.cmds
local UP = Vector(0, 0, 10000)

ULXPP.Funcs = {
	mhp = function(ply, targets, hp)
		for k, ply in ipairs(targets) do
			ply:SetMaxHealth(hp)
		end

		ulx.fancyLogAdmin(ply, "#A 设置最大生命值给 #T 到 #i", targets, hp)
	end,

	rocket = function(ply, targets)
		for k, ply in pairs(targets) do
			ply:SetVelocity(UP)
		end

		timer.Simple(1, function()
			for k, ply in ipairs(targets) do
				if not IsValid(ply) then continue end

				local effectdata = EffectData()
				effectdata:SetOrigin(ply:GetPos())

				util.Effect("Explosion", effectdata)
				ply:Kill()
			end
		end)

		ulx.fancyLogAdmin(ply, "#A 火箭 #T", targets)
	end,

	trainfuck = function(ply, targets)
		for k, ply in pairs(targets) do
			local ent = ents.Create('dbot_admin_train')
			ent:Spawn()
			ent:SetPlayer(ply)
			ply:ExitVehicle()
			ent.time = CurTimeL() + 4
		end

		ulx.fancyLogAdmin(ply, "#A 受过训练 #T", targets)
	end,

	roll = function(ply, amount)
		amount = amount or 6
		local r = math.random(1, amount)
		ulx.fancyLogAdmin(ply, "#A 滚 (#i) #i", amount, r)
	end,

	unsin = function(ply, targets)
		for k, ply in pairs(targets) do
			if not ply.ULXPP_SINPOS then
				ULXPP.Error(ply, string.format('%s 没有鼻窦!', ply:Nick()))
				targets[k] = nil
				continue
			end

			local id = tostring(ply) .. '_ulxpp_sin'

			timer.Remove(id)

			hook.Remove('Think', id)
			hook.Remove('Move', id)

			ply.ULXPP_SINPOS = nil

			net.Start('ULXPP.sin')
			net.WriteBool(false)
			net.Send(ply)
		end

		ulx.fancyLogAdmin(ply, "#A 取消鼻窦 #T", targets)
	end,

	sin = function(ply, targets, time)
		for k, ply in pairs(targets) do
			if ply.ULXPP_SINPOS then
				ULXPP.Error(ply, string.format('%s 已经鼻窦炎!', ply:Nick()))
				targets[k] = nil
				continue
			end

			ply:ExitVehicle()
			ply.ULXPP_SINPOS = ply:GetPos() + Vector(0, 0, 50)
			local id = tostring(ply) .. '_ulxpp_sin'

			net.Start('ULXPP.sin')
			net.WriteBool(true)
			net.WriteVector(ply.ULXPP_SINPOS)
			net.Send(ply)

			hook.Add('Think', id, function()
				if not IsValid(ply) then return end
				ply:ExitVehicle()
				ply:SetPos(ply.ULXPP_SINPOS + Vector(0, 0, math.sin(CurTimeL()) * 50))
			end)

			hook.Add('Move', id, function(ply2, mv)
				if ply2 ~= ply then return end
				mv:SetOrigin(ply.ULXPP_SINPOS + Vector(0, 0, math.sin(CurTimeL()) * 50))
				return true
			end)

			timer.Create(id, time, 1, function()
				hook.Remove('Think', id)
				hook.Remove('Move', id)

				if IsValid(ply) then
					ply.ULXPP_SINPOS = nil

					net.Start('ULXPP.sin')
					net.WriteBool(false)
					net.Send(ply)
				end
			end)
		end

		ulx.fancyLogAdmin(ply, "#A 正弦 #T #i 秒", targets, time)
	end,

	unbanish = function(ply, targets)
		for k, ply in pairs(targets) do
			if not ply.ULXPP_BANISHED then
				ULXPP.Error(ply, string.format('%s 没有被放逐!', ply:Nick()))
				targets[k] = nil
				continue
			end

			ply.ULXPP_BANISHED = false

			net.Start('ULXPP.banish')
			net.WriteBool(false)
			net.Send(ply)
			ULXPP.RestorePreviousFuncsState(ply, 'banish')
		end

		ulx.fancyLogAdmin(ply, "#A 取消放逐 #T", targets)
	end,

	banish = function(ply, targets)
		for k, ply in pairs(targets) do
			if ply.ULXPP_BANISHED then
				ULXPP.Error(ply, string.format('%s 已经被放逐!', ply:Nick()))
				targets[k] = nil
				continue
			end

			ply.ULXPP_BANISHED = true

			ULXPP.StorePreviousFuncsState(ply, 'banish', {
				{
					func = 'SetNoDraw',
					gfunc = 'GetNoDraw',
					newval = true,
				},{
					func = 'SetSolid',
					gfunc = 'GetSolid',
					newval = SOLID_NONE,
				},{
					func = 'SetCollisionGroup',
					gfunc = 'GetCollisionGroup',
					newval = COLLISION_GROUP_NONE,
				},{
					func = 'Freeze',
					gfunc = 'IsFrozen',
					newval = true,
				},{
					func = 'SetPos',
					gfunc = 'GetPos',
					newval = Vector(0, 0, -16000),
				},
			})

			net.Start('ULXPP.banish')
			net.WriteBool(true)
			net.Send(ply)
		end

		ulx.fancyLogAdmin(ply, "#A 被放逐 #T", targets)
	end,

	loadout = function(ply, targets)
		for k, ply in pairs(targets) do
			hook.Run('PlayerLoadout', ply)
		end

		ulx.fancyLogAdmin(ply, "#A 已装载 #T", targets)
	end,

	giveammo = function(ply, targets, amount)
		for k, ply in pairs(targets) do
			local wep = ply:GetActiveWeapon()

			if not IsValid(wep) then
				ULXPP.Error(ply, string.format('%s 没有持有有效武器!', ply:Nick()))
				targets[k] = nil
				continue
			end

			ply:GiveAmmo(amount, wep:GetPrimaryAmmoType())
			ply:GiveAmmo(amount, wep:GetSecondaryAmmoType())
		end

		ulx.fancyLogAdmin(ply, "#A 给了弹药 #T #i", targets, amount)
	end,

	giveweapon = function(ply, targets, str)
		for k, ply in pairs(targets) do
			local wep = ply:Give(str)

			if not IsValid(wep) then
				ULXPP.Error(ply, string.format('未能给予武器 %s!', ply:Nick()))
				targets[k] = nil
				continue
			end
		end

		ulx.fancyLogAdmin(ply, "#A 给予武器 #s 到 #T", str, targets)
	end,

	nodraw = function(ply, targets)
		for k, ply in pairs(targets) do
			ply:SetNoDraw(true)
		end

		ulx.fancyLogAdmin(ply, "#A 将 #T 的无平局设置为 true", targets)
	end,

	unnodraw = function(ply, targets)
		for k, ply in pairs(targets) do
			ply:SetNoDraw(false)
		end

		ulx.fancyLogAdmin(ply, "#A 将 #T 的无平局设置为 false", targets)
	end,

	uarmor = function(ply, targets, amount)
		for k, ply in pairs(targets) do
			ply:SetArmor(amount)
		end

		ulx.fancyLogAdmin(ply, "#A 设置了护甲给 #T 为 #i", targets, amount)
	end,

	jumppower = function(ply, targets, amount)
		for k, ply in pairs(targets) do
			ply:SetJumpPower(amount)
		end

		ulx.fancyLogAdmin(ply, "#A 设置跳跃能力 #T 为 #i", targets, amount)
	end,

	walkspeed = function(ply, targets, amount)
		for k, ply in pairs(targets) do
			ply:SetWalkSpeed(amount)
		end

		ulx.fancyLogAdmin(ply, "#A 设置步行速度 #T 为 #i", targets, amount)
	end,

	runspeed = function(ply, targets, amount)
		for k, ply in pairs(targets) do
			ply:SetRunSpeed(amount)
		end

		ulx.fancyLogAdmin(ply, "#A 设置运行速度 #T 为 #i", targets, amount)
	end,

	ctsay = function(ply, color, message)
		net.Start('ULXPP.coloredmessage')
		net.WriteColor(Color(unpack(string.Explode(' ', color))))
		net.WriteString(message)
		net.Broadcast()
	end,

	ip = function(ply, targets)
		local c = ply

		for k, ply in pairs(targets) do
			ULXPP.PText(c, Color(200, 200, 200), '的 IP 地址 ', team.GetColor(ply:Team()), ply:Nick(), Color(200, 200, 200), ' is ', string.Explode(':', ply:IPAddress())[1])
		end
	end,

	uid = function(ply, targets)
		local c = ply

		for k, ply in pairs(targets) do
			ULXPP.PText(c, Color(200, 200, 200), '的唯一 ID ', team.GetColor(ply:Team()), ply:Nick(), Color(200, 200, 200), ' 是 ', ply:UniqueID())
		end
	end,

	steamid64 = function(ply, targets)
		local c = ply

		for k, ply in pairs(targets) do
			ULXPP.PText(c, Color(200, 200, 200), 'SteamID 64 的 ', team.GetColor(ply:Team()), ply:Nick(), Color(200, 200, 200), ' 是 ', ply:SteamID64())
		end
	end,

	steamid = function(ply, targets)
		local c = ply

		for k, ply in pairs(targets) do
			ULXPP.PText(c, Color(200, 200, 200), 'SteamID 的 ', team.GetColor(ply:Team()), ply:Nick(), Color(200, 200, 200), ' 是 ', ply:SteamID())
		end
	end,

	profile = function(ply, targets)
		net.Start('ULXPP.Profile')
		net.WriteTable(targets)
		net.Send(ply)
	end,

	confuse = function(ply, targets)
		for k, ply in pairs(targets) do
			if ply.ULXPP_CONFUSED then
				ULXPP.Error(ply, string.format('%s 已经糊涂了!', ply:Nick()))
				targets[k] = nil
				continue
			end

			ply.ULXPP_CONFUSED = true
			local id = tostring(ply) .. '_ulxpp_confuse'

			net.Start('ULXPP.confuse')
			net.WriteBool(true)
			net.Send(ply)

			hook.Add('Move', id, function(ply2, mv)
				if not IsValid(ply) then
					hook.Remove('Move', id)
					return
				end

				if ply2 ~= ply then return end
				mv:SetSideSpeed(-mv:GetSideSpeed())
			end)
		end

		ulx.fancyLogAdmin(ply, "#A 使困惑 #T", targets)
	end,

	unconfuse = function(ply, targets)
		for k, ply in pairs(targets) do
			if not ply.ULXPP_CONFUSED then
				ULXPP.Error(ply, string.format('%s 不糊涂!', ply:Nick()))
				targets[k] = nil
				continue
			end

			ply.ULXPP_CONFUSED = nil
			local id = tostring(ply) .. '_ulxpp_confuse'

			net.Start('ULXPP.confuse')
			net.WriteBool(false)
			net.Send(ply)

			hook.Remove('Move', id)
		end

		ulx.fancyLogAdmin(ply, "#A 取消了困惑 #T", targets)
	end,

	respawn = function(ply, targets)
		for k, ply in pairs(targets) do
			if ply:Alive() then
				ULXPP.Error(ply, string.format('%s 没有死!', ply:Nick()))
				targets[k] = nil
				continue
			end

			ply:Spawn()
		end

		ulx.fancyLogAdmin(ply, "#A 重生 #T", targets)
	end,

	sendlua = function(ply, targets, str)
		for k, ply in pairs(targets) do
			ply:SendLua(str)
		end
	end,

	frespawn = function(ply, targets)
		for k, ply in pairs(targets) do
			if ply:Alive() then
				ply:Kill()
			end

			--Next frame
			timer.Simple(0, function()
				ply:Spawn()
			end)
		end

		ulx.fancyLogAdmin(ply, "#A 重生 #T", targets)
	end,

	bot = function(ply, num)
		num = num or 1

		for i = 1, num do
			RunConsoleCommand('bot')
		end

		ulx.fancyLogAdmin(ply, "#A 创造 #i 机器人", num)
	end,

	kickbots = function(ply)
		for k, v in pairs(player.GetAll()) do
			if v:IsBot() then
				v:Kick('从服务器踢机器人')
			end
		end

		ulx.fancyLogAdmin(ply, "#A 从服务器踢出所有机器人")
	end,

	silence = function(ply, targets)
		for k, v in pairs(targets) do
			v.ulx_gagged = true
			v.gimp = 2
			v:SetNWBool("ulx_gagged", true)
			v:SetNWBool("ulx_muted", true)
		end

		ulx.fancyLogAdmin(ply, "#A 沉默 #T", targets)
	end,

	unsilence = function(ply, targets)
		for k, v in pairs(targets) do
			v.ulx_gagged = false
			v.gimp = nil
			v:SetNWBool("ulx_gagged", false)
			v:SetNWBool("ulx_muted", false)
		end

		ulx.fancyLogAdmin(ply, "#A 取消沉默 #T", targets)
	end,

	cleanmap = function(ply)
		ulx.fancyLogAdmin(ply, "#A 清理地图")

		game.CleanUpMap()
	end,

	buddha = function(ply, targets)
		for k, v in pairs(targets) do
			v:GodDisable() --Remove godmode flag
			v:SetSaveValue('m_takedamage', DAMAGE_MODE_BUDDHA)
		end

		ulx.fancyLogAdmin(ply, "#A 开启佛陀模式 #T", targets)
	end,

	unbuddha = function(ply, targets)
		for k, v in pairs(targets) do
			v:GodDisable() --Remove godmode flag
			v:SetSaveValue('m_takedamage', DAMAGE_MODE_ENABLED)
		end

		ulx.fancyLogAdmin(ply, "#A 禁用佛陀模式 #T", targets)
	end,
}

hook.Add('PlayerDeath', 'ULX++', function(ply)
	if ply:GetSaveTable().m_takedamage == DAMAGE_MODE_BUDDHA then
		ply:SetSaveValue('m_takedamage', DAMAGE_MODE_ENABLED)
	end
end)
