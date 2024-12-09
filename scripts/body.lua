function start()
    range = math.min(math.max(es.GetFloat("range", 1), 1), 15)
    speed = math.min(math.max(es.GetFloat("speed", 15), 1), 10)
    
    mb = es.MultiBlock.Blocks[1]
    lever = nil
    shaft = nil
    extended = false
    currentExtension = 0
    
    sp = "speed: "
    rng = string.char(10).."range: "
end

function update()
    local sign = findBlockOfType("Sign")
    if sign then
        updateSignValues(sign)
    end
    
    if not lever then
        initializePiston()
    end
    
    if lever and shaft then
        updatePistonExtension()
    end
end

function updateSignValues(sign)
    local txt = sign.Sign.Text
    if string.find(txt, sp) and string.find(txt, rng) then
        local edg = string.find(txt, rng)
        speed = math.min(math.max(tonumber(string.sub(txt, #sp, edg)) or speed, 1), 10)
        range = math.min(math.max(tonumber(string.sub(txt, edg + #rng)) or range, 1), 15)
    end
    sign.Sign.Text = sp..speed..rng..range
    es.SetFloat("range", range)
    es.SetFloat("speed", speed)
end

function initializePiston()
    if mb.UpBlock and mb.UpBlock.MultiBlock.Blocks[1].UpBlock then
        local upBlock = mb.UpBlock.MultiBlock.Blocks[1].UpBlock
        if upBlock.MultiBlock.Type == "SimpleModBlock" then
            lever = upBlock
            shaft = mb.UpBlock.MultiBlock.Blocks[1]
            shaft.Root.Rigidbody.IsKinematic = true
        end
    end
end

function updatePistonExtension()
    if canExtend and not extended then
        currentExtension = math.min(currentExtension + (0.01 * speed), range)
        extended = currentExtension >= range
    elseif not canExtend and extended then
        currentExtension = math.max(currentExtension - (0.01 * speed), 0)
        extended = currentExtension > 0
    end

    local basePos = es.MultiBlock.Transform.Position
    local upVector = es.MultiBlock.Transform.Up
    
    shaft.Root.Rigidbody.Position = {
        basePos[1] + upVector[1] * (0.25 + currentExtension/2),
        basePos[2] + upVector[2] * (0.25 + currentExtension/2),
        basePos[3] + upVector[3] * (0.25 + currentExtension/2)
    }
    
    lever.Root.Rigidbody.Position = {
        basePos[1] + upVector[1] * (0.5 + currentExtension),
        basePos[2] + upVector[2] * (0.5 + currentExtension),
        basePos[3] + upVector[3] * (0.5 + currentExtension)
    }
    
    shaft.Root.Rigidbody.Velocity = {0,0,0}
    lever.Root.Rigidbody.Velocity = {0,0,0}
end

function canConnect(itemType, thisConnectionIndex, otherConnectionIndex)
    local validTypes = {
        "PushButton", "Sensor", "Switch", "LogicAnd", "LogicOr", "LogicXor",
        "LogicNand", "LogicNor", "LogicNxor", "Timer"
    }
    return thisConnectionIndex == 1 and otherConnectionIndex == 1 and 
           table.concat(validTypes, " "):find(itemType)
end

function onSignalReceived(value) canExtend = value end
function onInputRemoved() canExtend = false end

function findBlockOfType(itemtype) 
    local Block = es.MultiBlock.Blocks[1]
    for _, block in ipairs({Block.BackBlock, Block.ForwardBlock, Block.UpBlock, 
                           Block.DownBlock, Block.RightBlock, Block.LeftBlock}) do
        if block and block.Type == itemtype then
            return block.MultiBlock
        end
    end
end
