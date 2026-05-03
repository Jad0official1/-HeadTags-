-- [[ 👑 Config-الاعدادات 👑 ]] --
local Config = {
    OwnerID = 0,
    BrothersIDs = {0, 0},
    GamepassID = 0,
    
    -- [[ ✨ Ranks-الرتب ✨ ]] --
    OwnerRank = "👑Owner👑",
    BrotherRank = "👬Brother👬",
    FriendRank = "👥️Friend👥️",
    VIPRank = "👑VIP👑",
    MemberRank = "👤Member👤"
}

-- -------------------------------------------------------------------------------------------------------------------- --

local Players = game:GetService("Players")
local Market = game:GetService("MarketplaceService")
local Localize = game:GetService("LocalizationService")
local Run = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")

local Events = RS:FindFirstChild("Events") or Instance.new("Folder", RS)
Events.Name = "Events"
local event = Events:FindFirstChild("SendDeviceEvent") or Instance.new("RemoteEvent", Events)
event.Name = "SendDeviceEvent"

local flagOffset = 0x1F1E6
local asciiOffset = 0x41

local function GetFlag(country)
    if country == "IL" then country = "PS" end
    if not country or #country < 2 then return "❓" end
    local a = utf8.codepoint(country, 1) - asciiOffset + flagOffset
    local b = utf8.codepoint(country, 2) - asciiOffset + flagOffset
    return utf8.char(a) .. utf8.char(b)
end

local function IsBrother(p)
    for _, id in pairs(Config.BrothersIDs) do
        if p.UserId == id then return true end
    end
    return false
end

local function Darker(c)
    return Color3.fromRGB(math.max(math.floor(c.R*255)-60,0), math.max(math.floor(c.G*255)-60,0), math.max(math.floor(c.B*255)-60,0))
end

local function Create(h)
    local g = Instance.new("BillboardGui", h)
    g.Name = "HeadTags"
    g.Adornee = h
    g.Size = UDim2.new(4,0,2.7,0)
    g.StudsOffset = Vector3.new(0, 3, 0)
    g.AlwaysOnTop = true
    
    local r = Instance.new("TextLabel", g)
    r.Size = UDim2.new(1,0,0.45,0)
    r.BackgroundTransparency = 1
    r.TextScaled = true
    r.Font = Enum.Font.GothamBold
    r.TextStrokeTransparency = 0
    r.Name = "Rank"
    
    local i = Instance.new("TextLabel", g)
    i.Position = UDim2.new(0,0,0.45,0)
    i.Size = UDim2.new(1,0,0.3,0)
    i.BackgroundTransparency = 1
    i.TextScaled = true
    i.Font = Enum.Font.Gotham
    i.RichText = true
    i.Name = "Info"
    i.TextColor3 = Color3.new(1,1,1)
    
    local u = Instance.new("TextLabel", g)
    u.Position = UDim2.new(0,0,0.78,0)
    u.Size = UDim2.new(1,0,0.25,0)
    u.BackgroundTransparency = 1
    u.TextScaled = true
    u.Font = Enum.Font.GothamMedium
    u.TextStrokeTransparency = 0
    u.Name = "Username"
    
    return r, i, u
end

local function Apply(p, char, dev)
    local h = char:WaitForChild("Head", 5)
    local hum = char:WaitForChild("Humanoid", 5)
    if not h or not hum then return end
    
    hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    if h:FindFirstChild("HeadTags") then h.HeadTags:Destroy() end
    
    local rL, iL, uL = Create(h)
    local txt = Config.MemberRank
    local clr = Color3.fromRGB(150,150,150)
    
    if p.UserId == Config.OwnerID then
        txt = Config.OwnerRank
    elseif IsBrother(p) then
        txt = Config.BrotherRank
        clr = Color3.fromRGB(0,255,0)
    elseif p:IsFriendsWith(Config.OwnerID) then
        txt = Config.FriendRank
        clr = Color3.fromRGB(0,120,255)
    else
        local s, res = pcall(function() return Market:UserOwnsGamePassAsync(p.UserId, Config.GamepassID) end)
        if s and res then txt = Config.VIPRank clr = Color3.fromRGB(255,255,0) end
    end
    
    rL.Text = txt
    if p.UserId == Config.OwnerID then
        local c; c = Run.Heartbeat:Connect(function()
            if not rL.Parent then c:Disconnect() return end
            local cl = Color3.fromHSV((tick()*0.12)%1, 1, 1)
            rL.TextColor3 = cl
            rL.TextStrokeColor3 = Darker(cl)
        end)
    else
        rL.TextColor3 = clr
        rL.TextStrokeColor3 = Darker(clr)
    end
    
    local s, country = pcall(function() return Localize:GetCountryRegionForPlayerAsync(p) end)
    local f = GetFlag(s and country or nil)
    
    iL.Text = dev .. " | " .. f
    uL.Text = "@" .. p.Name
    uL.TextColor3 = Color3.fromRGB(200,200,255)
    uL.TextStrokeColor3 = Color3.fromRGB(120,120,180)
end

event.OnServerEvent:Connect(function(p, dev)
    if p.Character then Apply(p, p.Character, dev) end
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c) Apply(p, c, "⏳ Checking...") end)
end)

