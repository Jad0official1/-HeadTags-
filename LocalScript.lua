local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TextService")
local GS = game:GetService("GuiService")
local cam = workspace.CurrentCamera
local Events = RS:WaitForChild("Events")
local event = Events:WaitForChild("SendDeviceEvent")

print:("👑 Runing Head Tags v5.0.6 by @Jad_official1)
local function glyph(cp)
    local inv = TS:GetTextSize(utf8.char(0xFFFF), 16, Enum.Font.SourceSans, Vector2.new(1000, 1000))
    local char = TS:GetTextSize(utf8.char(cp), 16, Enum.Font.SourceSans, Vector2.new(1000, 1000))
    return char ~= inv
end

local function get()
    local v = version()
    local mobile = v:find("^2%.") ~= nil
    local pc = v:find("^0%.") ~= nil
    local console = GS:IsTenFootInterface() or v:find("^1%.") ~= nil
    
    if console then
        local img = UIS:GetImageForKeyCode(Enum.KeyCode.ButtonSelect):lower()
        if img:find("xbox") then return "🎮 (Xbox)" end
        if img:find("ps") then return "🎮 (PlayStation)" end
        return "🎮 (Console)"
    end

    if mobile then
        if not UIS.TouchEnabled then return "🐧 (Linux)" end
        if glyph(0xF8FF) then return "📱 (iOS)" end
        local size = cam.ViewportSize
        if math.min(size.X, size.Y) >= 600 then
            return "📠 (Android Tablet)"
        else
            return "📱 (Android)"
        end
    end

    if pc then
        if GS.IsWindows then return "💻 (Windows)" end
        return "💻 (MacOS)"
    end

    return "❓ (Unknown)"
end

local function send()
    event:FireServer(get())
end

game.Players.LocalPlayer.CharacterAdded:Connect(send)
send()

