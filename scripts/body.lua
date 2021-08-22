function onPlace()
    es.SetSoundVolume(5)
end

function start()
    piston_in = "audio/piston_in.wav"
    piston_out = "audio/piston_out.wav"
    sound = false
    --[[
    Useless Code
    piston_in = true --If false then no sounds
    piston_out = true --If false then no sounds
    --]]
    range = es.GetFloat("range", 1)
    speed = es.GetFloat("speed", 15)
    
    maxRange = 15
    minRange = 1
    
    maxSpeed = 10
    minSpeed = 1
    
    friction = 50
    
    newLine = string.char(10)
	sp = "speed: "
	rng = newLine.."range: "
    
    mb = es.MultiBlock.Blocks[1]
    leveruuid = "50434033-e5e9-4fc4-b9b8-0e96d5d3778f9"
    extenderuuid = "4275a186-278e-4aff-9f3e-bcde2b9d59d2"
    lever = nil
    rd = false
    leeever = nil
    tm = os.time()
    rang = 0
    canActivate = false
    count = 2
    rd = false
end

function update()
    --print("Text : ", txt)
    sign = findBlockOfType("Sign")
	if sign != nil then
		
		txt = sign.Sign.Text
		if string.find(txt, sp) != nil and string.find(txt, rng) != nil then
			edg = string.find(txt, rng)
			speed = tonumber(string.sub(txt, #sp, edg))
			range = tonumber(string.sub(txt, edg + #rng))
			if range > maxRange then
				range = maxRange
				txt = sp..speed..rng..range
				sign.Sign.Text = txt
			end
			if range < minRange then
				range = minRange
				txt = sp..speed..rng..range
				sign.Sign.Text = txt
			end
			if speed > maxSpeed then
				speed = maxSpeed
				txt = sp..speed..rng..range
				sign.Sign.Text = txt
			end
			if speed < minSpeed then
				speed = minSpeed
				txt = sp..speed..rng..range
				sign.Sign.Text = txt
			end
		else
			txt = sp..speed..rng..range
			sign.Sign.Text = txt
		end
		es.SetFloat("range", range)
		es.SetFloat("speed", speed)
	end
	print("Lever : ", lever)
    
    	-- Check Lever
    if lever == nil then
		if mb.UpBlock != nil and mb.UpBlock.MultiBlock.Blocks[1].UpBlock != nil and mb.UpBlock.MultiBlock.Blocks[1].UpBlock.MultiBlock.Type == "SimpleModBlock" then
			lever = mb.UpBlock.MultiBlock.Blocks[1].UpBlock
			mb.UpBlock.MultiBlock.Destroy()
			timeQuery = os.time()
			rd = true
			tm = os.time()
		end
	end
	
	if rd == true and tm - tm > speed then
		if leeever == nil then
			leeever = lever.Root.Rigidbody
		else
			leeever.IsKinematic = false
			leeever.IsKinematic = true
			rd = false
			ready = true
		end
	end
	
    if rd == true and os.time() - tm > speed then
		if leeever == nil then
			leeever = lever.Root.Rigidbody
		else
			leeever.IsKinematic = false		
			leeever.IsKinematic = true
			ready = true
			rd = false
		end
	end
	if ready == true then
		leeever.IsKinematic = true
		local pos = AddVectors(es.MultiBlock.Transform.Position, ScaleVector(es.MultiBlock.Transform.Up, 0.5 + rang))
		local diff = SubstructVectors(pos, leeever.Transform.Position)
		leeever.Position = AddVectors(rigid.Position, diff)
		leeever.Velocity ={ 0,0,0 }
		
	end
    if canExtend == true then
        if rang < count / 2 then
				if extend == true then
					leeever = lever.Root.Rigidbody
					extend = false
				end
			lever.IsKinematic = true
			rang = rang  + (0.01 * speed)
        end
    end
end

function fixedUpdate()
    
end

function canConnect(itemType, thisConnectionIndex, otherConnectionIndex, reverse)

    if (itemType == "PushButton" or 
        itemType == "Sensor" or
        itemType == "Switch" or
        itemType == "LogicAnd" or
        itemType == "LogicOr" or
        itemType == "LogicXor" or
        itemType == "LogicNand" or
        itemType == "LogicNor" or
        itemType == "LogicNxor" or
        itemType == "Timer"


        ) and thisConnectionIndex == 1 and otherConnectionIndex == 1 then
        
        return true
        
    end

    return false
    
end

function onSignalReceived(value, fromGuid, toConnectionIndex)
    canExtend = value
end

function onInputRemoved(fromGuid, toConnectionIndex)
    canExtend = false
end

function findBlockOfType(itemtype) 
 
	local Block = es.MultiBlock.Blocks[1] 
	local U = Block.UpBlock 
	local D = Block.DownBlock 
	local L = Block.LeftBlock 
	local R = Block.RightBlock 
	local F = Block.ForwardBlock 
	local B = Block.BackBlock 
  
	if B and B.Type == itemtype then 
		return B.MultiBlock 
  
	elseif F and F.Type == itemtype then 
		return F.MultiBlock 
  
	elseif U and U.Type == itemtype then 
		return U.MultiBlock 
  
	elseif D and D.Type == itemtype then 
		return D.MultiBlock 
  
	elseif R and R.Type == itemtype then 
		return R.MultiBlock 
  
	elseif L and L.Type == itemtype then 
		return L.MultiBlock 
  
	else 
		return nil 
	end 
end

function AddVectors(a,b) 
	return {
		a[1]+b[1],
		a[2]+b[2],
		a[3]+b[3]
	}
end


function SubstructVectors(a,b)
	return {
		a[1]-b[1],
		a[2]-b[2],
		a[3]-b[3]
	}
end



function ScaleVector(a,s)
	return {
		a[1]*s,
		a[2]*s,
		a[3]*s
	}
end
