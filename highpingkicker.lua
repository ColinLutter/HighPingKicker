local version = "V1.0 - 30. März 2017"

--CONFIG
local PingGrenze = 4
local ToleranzGrenze = 0
local CheckIntervall = 5 -- In Sekunden
local MaxWarns = 4
--CONFIG ENDE!

local meta = FindMetaTable("Player")

function meta:GetPingWarns()
  return self.sloth_pingWarns or 0
end


if (SERVER) then

  util.AddNetworkString("hpk_sendChange_give")
  util.AddNetworkString("hpk_sendChange_take")

  hook.Add("Initialize", "init_hpKicker", function()
    MsgC(Color(22, 160, 133), "[HPKicker] Initalisiert! (" .. version .. ")\n")
  end)

  local function checkIfKick(pl)
    if IsValid(pl) and pl:IsPlayer() then

      if pl:GetPingWarns() > MaxWarns then
        pl:Kick( "High Ping Kick (Ping: "..ping..")" )
      end

    end
  end

  function meta:GivePingWarn()
    checkIfKick(self)

    self.sloth_pingWarns = self:GetPingWarns() + 1



    net.Start("hpk_sendChange_give")
      net.WriteInt(self:Ping(), 32)
      net.WriteInt(self:GetPingWarns(), 32)
    net.Send(self)
  end

  function meta:TakePingWarn()

    if (self:GetPingWarns() == 0) then
      return
    end

    if (self:GetPingWarns() < 0) then
      self.sloth_pingWarns = 0
      return
    end

    self.sloth_pingWarns = self:GetPingWarns() - 1
    self.sloth_totalWarns = self:GetPingWarns() - 1

    net.Start("hpk_sendChange_take")
      net.WriteInt(self:Ping(), 32)
      net.WriteInt(self:GetPingWarns(), 32)
    net.Send(self)
  end

  timer.Create("sloth_highpingkicker", CheckIntervall, 0, function()
    for k, v in pairs(player.GetAll()) do
      local ping = v:Ping()

      checkIfKick(v)

      if ping > PingGrenze then
        print("[HPKicker] " .. v:Nick() .. " wurde verwarnt. (Ping: " .. tostring(ping) .. ", Warns: " .. tostring(v:GetPingWarns() or 0) .. ")" )
        v:GivePingWarn()
        continue
      end

      if ping < ToleranzGrenze then
        print("[HPKicker] " .. v:Nick() .. " wurde ein Warn erlassen. (Ping: " .. tostring(ping) .. ", Warns: " .. tostring(v:GetPingWarns()) .. ")" )
        v:TakePingWarn()
      end
    end
  end)

else

  net.Receive("hpk_sendChange_give", function()
    local ping = net.ReadInt(32)
    local val = net.ReadInt(32)

    LocalPlayer().sloth_pingWarns = val
    chat.AddText(Color(231, 76, 60), "Dein Ping ist zu Hoch! Du hast nun "..tostring(val).." Ping-Warn(s). (Ping: "..tostring(ping)..")")
  end)

  net.Receive("hpk_sendChange_take", function()
    local ping = net.ReadInt(32)
    local val = net.ReadInt(32)

    LocalPlayer().sloth_pingWarns = val
    chat.AddText(Color(230, 126, 34), "Da dein Ping wieder im grünen Bereich ist, wird dir ein Warn erlassen! Du hast noch "..tostring(val).." weitere(n) Ping-Warns. (Ping: "..tostring(ping)..")")
  end)

end
