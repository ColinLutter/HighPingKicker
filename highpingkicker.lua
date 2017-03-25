local version = "0.02 - 26. März 2017"

local rgb = Color

--CONFIG
local PingGrenze = 200
local ToleranzGrenze = 100
local CheckIntervall = 25 -- In Sekunden
local MaxWarns = 4
--CONFIG ENDE!

if (SERVER) then

  util.AddNetworkString("hk_WarnChatText")

  hook.Add("Initialize", "init_hpKicker", function()
    MsgC(rgb(22, 160, 133), "[HPKicker] Initalisiert!\n")
  end)

  local pM = FindMetaTable("Player")

    function pM:GetPingWarns()
      if !self.pingWarns then
        self.pingWarns = 0;
        self.totalWarns = 0;
      end;

      return self.pingWarns, self.totalWarns
    end;

    function pM:GivePingWarn()
      local curPing = self:Ping()
    
      if !self.pingWarns then
        self.pingWarns = 0;
        self.totalWarns = 0;
      end;

      self.totalWarns = self.totalWarns + 1
      self.pingWarns = self.pingWarns + 1

      net.Start("hk_WarnChatText")
        net.WriteBool(false)
        net.WriteInt(self.pingWarns, 3)
        net.WriteString(curPing)
      net.Send(self)
    end;

    function pM:SetPingWarn( s )
      if !s then s = 0 end
    
      if !self.pingWarns then
        self.pingWarns = 0;
        self.totalWarns = 0;
      end;

      self.pingWarns = s
    end;

    function pM:TakePingWarn()
      if !self.pingWarns then
        self.pingWarns = 0;
      end;

      if (self.pingWarns > 0) then
        self.pingWarns = self.pingWarns - 1
        net.Start("hk_WarnChatText")
          net.WriteBool(true)
          net.WriteInt(self.pingWarns, 3)
        net.Send(self)
      else
        self.pingWarns = 0;
      end;
    end;

  timer.Create("hpKicker_checkIntervall", CheckIntervall, 0, function()
    for k, v in pairs(player.GetAll()) do
      local ping = v:Ping()

      if (v:GetPingWarns() > (MaxWarns - 1)) then
        v:Kick( "High Ping Kick (PING: "..ping..")" )
      end;

      if (ping > PingGrenze) then
        v:GivePingWarn()
          print(v:Nick().." Warns + 1")
          --t[v:Nick()] = v:GetPingWarns();
      elseif (ping < ToleranzGrenze ) then
        v:TakePingWarn()
      end
    end;
  end)

  concommand.Add("hpkicker_totalwarns", function(pl, cmd, args)
    if !(#args > 0) then
      return print("Es wurde kein Spieler angegeben.")
    end;
    local target;
    for k, v in pairs(player.GetAll()) do
      if ( string.lower(v:Nick()) == string.lower(args[1]) ) then
        target = v;
      end;
    end;

    if !target then return print("Es wurde kein VALIDER Spieler angegeben") end
    if !target.totalWarns then target.totalWarns = 0; end

    print("Warns:", target.pingWarns)
    print("Total:", target.totalWarns)
  end)

  concommand.Add("hpkicker_setwarns", function(pl, cmd, args)
    if !(#args > 0) then
      return print("hpkicker_setwarns [Spieler] [Anzahl]")
    end;

    local target;
    for k, v in pairs(player.GetAll()) do
      if ( string.lower(v:Nick()) == string.lower(args[1]) ) then
        target = v;
      end;
    end;

    local amount = tonumber(args[2])

    if !target then return print("Es wurde kein VALIDER Spieler angegeben.") end
    if !amount then return print("Es wurde keine VALIDE Zahl angegeben.") end

    target:SetPingWarn( amount )
  end)
else
  net.Receive("hk_WarnChatText", function(len)
    local bool = net.ReadBool()
    local warns = net.ReadInt(3)
    local pingZumZeitpunktDesWarns = net.ReadString() or "FEHLER"
      
    if !bool then
      chat.AddText(rgb(231, 76, 60), "Dein Ping ist zu Hoch! Du hast nun "..warns.." Ping-Warn(s). (Ping: "..pingZumZeitpunktDesWarns..")")
      --print("Dein Ping ist zu Hoch! Du hast nun "..int.." Ping-Warns. (Ping: "..tostring(LocalPlayer():Ping())..")")
    else
      chat.AddText(rgb(230, 126, 34), "Da dein Ping wieder im grünen Bereich ist, wird dir ein Warn erlassen! Du hast noch "..int.." weitere(n) Ping-Warns. (Ping: "..pingZumZeitpunktDesWarns..")")
      --print("Da dein Ping wieder im grünen Bereich ist, wird dir ein Warn erlassen! Du hast noch "..int.." weitere(n) Ping-Warns. (Ping: "..tostring(LocalPlayer():Ping())..")")
    end;
  end)
end;
84
      if (ping > PingGrenze) then
85
        v:GivePingWarn()
86
          print(v:Nick().." Warns + 1")
87
          --t[v:Nick()] = v:GetPingWarns();
88
      elseif (ping < ToleranzGrenze ) then
89
        v:TakePingWarn()
90
      end
91
    end;
92
  end)
93
​
94
  concommand.Add("hpkicker_totalwarns", function(pl, cmd, args)
95
    if !(#args > 0) then
96
      return print("Es wurde kein Spieler angegeben.")
97
    end;
98
    local target;
99
    for k, v in pairs(player.GetAll()) do
100
      if ( string.lower(v:Nick()) == string.lower(args[1]) ) then
101
        target = v;
102
      end;
103
    end;
104
​
105
    if !target then return print("Es wurde kein VALIDER Spieler angegeben") end
106
    if !target.totalWarns then target.totalWarns = 0; end
107
​
108
    print("Warns:", target.pingWarns)
109
    print("Total:", target.totalWarns)
110
  end)
111
​
112
  concommand.Add("hpkicker_setwarns", function(pl, cmd, args)
113
    if !(#args > 0) then
114
      return print("hpkicker_setwarns [Spieler] [Anzahl]")
115
    end;
116
​
117
    local target;
118
    for k, v in pairs(player.GetAll()) do
119
      if ( string.lower(v:Nick()) == string.lower(args[1]) ) then
120
        target = v;
121
      end;
122
    end;
123
​
124
    local amount = tonumber(args[2])
125
​
126
    if !target then return print("Es wurde kein VALIDER Spieler angegeben.") end
127
    if !amount then return print("Es wurde keine VALIDE Zahl angegeben.") end
128
​
129
    target:SetPingWarn( amount )
130
  end)
131
else
132
  net.Receive("hk_WarnChatText", function(len)
133
    local bool = net.ReadBool()
134
    local warns = net.ReadInt(3)
135
    local pingZumZeitpunktDesWarns = net.ReadString() or "FEHLER" 
136
      
137
    if !bool then
138
      chat.AddText(rgb(231, 76, 60), "Dein Ping ist zu Hoch! Du hast nun "..tostring(warns).." Ping-Warn(s). (Ping: "..pingZumZeitpunktDesWarns..")")
139
      --print("Dein Ping ist zu Hoch! Du hast nun "..int.." Ping-Warns. (Ping: "..tostring(LocalPlayer():Ping())..")")
140
    else
141
      chat.AddText(rgb(230, 126, 34), "Da dein Ping wieder im grünen Bereich ist, wird dir ein Warn erlassen! Du hast noch "..tostring(warns).." weitere(n) Ping-Warn(s). (Ping: "..pingZumZeitpunktDesWarns..")")
142
      --print("Da dein Ping wieder im grünen Bereich ist, wird dir ein Warn erlassen! Du hast noch "..int.." weitere(n) Ping-Warns. (Ping: "..tostring(LocalPlayer():Ping())..")")
143
    end;
144
  end)
145
end;
146
​
@ColinLutter

Commit changes
