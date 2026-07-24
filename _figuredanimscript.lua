-- V0.1
-- Created with the help of the Figura Discord community (FiguraMC)
-- Brought to life by @chmonyasik (ElenaNya in Minecraft)
-- Special thanks to @jimmyhelp, @mirsirsquishy, @grandpa_scout and @piratesee

-- saved

 --better combat thing [[modeltorso.RightArm1.RightArm:setParentType("RightArm")]]

-- required

local squapi = require("libs.SquAPI")
local batterUp = require("libs.EZSwing")
local anims = require("libs.EZAnims_modified")
anims:setOneJump(true)
--anims:disableAutoSearch()

local figuredanim = animations.model
local modelpath = models.model
local modeltorso = modelpath.Player.root.Torso

local example = anims:addBBModel(figuredanim)
--example:setBlendTimes()

--[[local list = {
    idling = {figuredanim.idling},
    walking = {figuredanim.walking, figuredanim.arm_R_walking, figuredanim.arm_L_walking},
    walkingback = nil,
    jumpingup = {figuredanim.jumpingup},
    jumpingdown = {figuredanim.jumpingdown},
    falling = {figuredanim.falling},
    sprinting = {figuredanim.sprinting, figuredanim.arm_R_sprinting, figuredanim.arm_L_sprinting},
    sprintjumpup = nil,
    sprintjumpdown = nil,
    crouching = {figuredanim.crouching},
    crouchwalk = nil,
    crouchwalkback = nil,
    crouchjumpup = nil,
    crouchjumpdown = nil,
    elytra = nil,
    elytradown = nil,
    trident = nil,
    sleeping = {figuredanim.sleeping},
    swimming = {figuredanim.swimming},
    sitting = nil,
    sitmove = nil,
    sitmoveback = nil,
    sitjumpup = nil,
    sitjumpdown = nil,
    sitpass = nil,
    crawling = {figuredanim.crawling},
    crawlstill = nil,
    flying = {figuredanim.flying},
    flywalk = {figuredanim.flywalk},
    flywalkback = {figuredanim.flywalkback},
    flysprint = {figuredanim.flysprint},
    flyup = {figuredanim.flyup},
    flydown = {figuredanim.flydown},
    climbing = {figuredanim.climbing},
    climbstill = nil,
    climbdown = nil,
    climbcrouch = nil,
    climbcrouchwalking = nil,

    water = nil,
    waterwalk = nil,
    waterwalkback = nil,
    waterup = nil,
    waterdown = nil,
    watercrouch = nil,
    watercrouchwalk = nil,
    watercrouchwalkback = nil,
    watercrouchup = nil,
    watercrouchdown = nil,

    hurt = nil,
    death = nil,

    holdR = nil,
    holdL = nil,
    eatR = {figuredanim.eatR},
    eatL = {figuredanim.eatL},
    drinkR = {figuredanim.drinkR},
    drinkL = {figuredanim.drinkL},
    blockR = {figuredanim.blockR},
    blockL = {figuredanim.blockL},
    bowR = {figuredanim.bowR},
    bowL = {figuredanim.bowL},
    loadR = {figuredanim.loadR},
    loadL = nil,
    crossR = {figuredanim.crossR},
    crossL = nil,
    spearR = {figuredanim.spearR},
    spearL = {figuredanim.spearL},
    spyglassR = {figuredanim.spyglassR},
    spyglassL = nil,
    hornR = {figuredanim.hornR},
    hornL = nil,
    brushR = {figuredanim.brushR},
    brushL = {figuredanim.brushL},
}

example:setAnims(list, true)]]

local getAnimState = function(stateName)
    return example:getAnimationStates(stateName)
end

local extras = require("libs.EZExtra_modified")
extras.landvel = -0.3
extras(figuredanim)
--extras.jimmyCompat = true
require("libs.GSAnimBlend")

-- First-person Model mod compat

function events.render(_,context)
    modeltorso.Head:visible(not (renderer:isFirstPerson() and context == "OTHER"))
end

-- second layers compat

function events.entity_init()
if not player then return end
modeltorso.Body.Cape:visible(player:isSkinLayerVisible("CAPE"))
modeltorso.Head.Hat:visible(player:isSkinLayerVisible("HAT"))
modeltorso.Body.Jacket:visible(player:isSkinLayerVisible("JACKET"))
modeltorso.LeftArm1.LeftArm.LeftSleeve:visible(player:isSkinLayerVisible("LEFT_SLEEVE"))
modeltorso.RightArm1.RightArm.RightSleeve:visible(player:isSkinLayerVisible("RIGHT_SLEEVE"))
modelpath.Player.LeftLeg1.LeftLeg.LeftPants:visible(player:isSkinLayerVisible("LEFT_PANTS"))
modelpath.Player.RightLeg1.RightLeg.RightPants:visible(player:isSkinLayerVisible("RIGHT_PANTS"))
end

-- aeugh

local idling = figuredanim.idling
idling:offset(3):length(7)

local walking = figuredanim.walking
walking:offset(1.3):length(2.3):blendTime(1,4)
local arm_R_walking = figuredanim.arm_R_walking
arm_R_walking:offset(1.3):length(2.3):blendTime(1,4)
local arm_L_walking = figuredanim.arm_L_walking
arm_L_walking:offset(1.3):length(2.3):blendTime(1,4)

local swimming = figuredanim.swimming
swimming:offset(1.4):length(3):blendTime(4)

local flying = figuredanim.flying
flying:offset(3):length(7)--:blendTime(4)
local flywalk = figuredanim.flywalk
flywalk:offset(3):length(7):blendTime(10)
local flywalkback = figuredanim.flywalkback
flywalkback:blendTime(10)
local flysprint = figuredanim.flysprint
flysprint:offset(3):length(7):blendTime(10)
local flyup = figuredanim.flyup
flyup:blendTime(1,10)
local flydown = figuredanim.flydown
flydown:blendTime(1,10)

local sprinting = figuredanim.sprinting
sprinting:offset(1.3):length(2.8):blendTime(1,4)
local arm_R_sprinting = figuredanim.arm_R_sprinting
arm_R_sprinting:offset(1.3):length(2.8):blendTime(1,4)
local arm_L_sprinting = figuredanim.arm_L_sprinting
arm_L_sprinting:offset(1.3):length(2.8):blendTime(1,4)

--local sleeping = figuredanim.sleeping

local climbing = figuredanim.climbing
climbing:offset(1):length(3):blendTime(1,4)

local crawling = figuredanim.crawling
crawling:offset(1):length(3)--:blendTime(1,4)

local drinkR = figuredanim.drinkR
drinkR:offset(2):length(3.6):blendTime(4)
local drinkL = figuredanim.drinkL
drinkL:offset(2):length(3.6):blendTime(4)

local eatR = figuredanim.eatR
eatR:offset(2):length(3.6):blendTime(4)
local eatL = figuredanim.eatL
eatL:offset(2):length(3.6):blendTime(4)

local land = figuredanim.land
land:offset(0.25):length(0.95):blendTime(1,4)

local jumpingup = figuredanim.jumpingup
jumpingup:offset(0.5):length(1):blendTime(0.1,4)
local jumpingdown = figuredanim.jumpingdown
jumpingdown:blendTime(4)

local falling = figuredanim.falling
falling:blendTime(10,4)
local shake_falling = figuredanim.shake_falling
shake_falling:blendTime(10,4)

local mineR = figuredanim.mineR
mineR:offset(1.4):length(1.9):blendTime(1,4):speed(1.5)
local mineL = figuredanim.mineL
mineL:offset(1.4):length(1.9):blendTime(1,4):speed(1.5)

batterUp:addSingleSwing(mineR, "right", "pickaxe", "mine", false) --later set nil for everything
batterUp:addSingleSwing(mineL, "left", "pickaxe", "mine", false) --later set nil for everything

local axe_mineR = figuredanim.axe_mineR
axe_mineR:offset(1.4):length(1.9):blendTime(1,4):speed(1.5)
batterUp:addSingleSwing(axe_mineR, "right", "_axe", "mine", false)
local axe_mineL = figuredanim.axe_mineL
axe_mineL:offset(1.4):length(1.9):blendTime(1,4):speed(1.5)
batterUp:addSingleSwing(axe_mineL, "left", "_axe", "mine", false)

local shovel_mineR = figuredanim.shovel_mineR
shovel_mineR:offset(1.4):length(1.9):blendTime(1,4):speed(1.5)
batterUp:addSingleSwing(shovel_mineR, "right", "shovel", "mine", false)
local shovel_mineL = figuredanim.shovel_mineL
shovel_mineL:offset(1.4):length(1.9):blendTime(1,4):speed(1.5)
batterUp:addSingleSwing(shovel_mineL, "left", "shovel", "mine", false)

local hoe_mineR = figuredanim.hoe_mineR
hoe_mineR:offset(1.4):length(1.9):speed(1):blendTime(1,4)
batterUp:addSingleSwing(hoe_mineR, "right", "_hoe", "mine", false)
local hoe_mineL = figuredanim.hoe_mineL
hoe_mineL:offset(1.4):length(1.9):speed(1):blendTime(1,4)
batterUp:addSingleSwing(hoe_mineL, "left", "_hoe", "mine", false)

local attackR = figuredanim.attackR
attackR:offset(1):length(1.5):speed(1.5):blendTime(1,4)
local attackL = figuredanim.attackL
attackL:offset(1):length(1.5):speed(1.5):blendTime(1,4)
--batterUp:addSingleSwing(attackR, "right", nil, "attack", false)

batterUp:addNegativeSwing(attackR, "right", {"sword"}, "attack", false)
batterUp:addNegativeSwing(attackR, "right", {"pickaxe", "shovel", "_axe", "_hoe"}, "mine", false)
batterUp:addNegativeSwing(attackL, "left", {"sword"}, "attack", false)
batterUp:addNegativeSwing(attackL, "left", {"pickaxe", "shovel", "_axe", "_hoe"}, "mine", false)

local chainR1 = figuredanim.chainR1
chainR1:offset(1):length(1.6):blendTime(1,4)
local chainR2 = figuredanim.chainR2
chainR2:offset(1):length(1.6):blendTime(1,4)
local chainR3 = figuredanim.chainR3
chainR3:offset(1):length(1.6):blendTime(1,2)

local chainedswordR = {
	chainR1,
	chainR2,
	chainR3,
}

batterUp:addChainedSwings(chainedswordR, "right", "sword", "attack", false, 20)

local chainL1 = figuredanim.chainL1
chainR1:offset(1):length(1.6):blendTime(1,4)
local chainL2 = figuredanim.chainL2
chainR2:offset(1):length(1.6):blendTime(1,4)
local chainL3 = figuredanim.chainL3
chainR3:offset(1):length(1.6):blendTime(1,2)

local chainedswordL = {
	chainL1,
	chainL2,
	chainL3,
}

batterUp:addChainedSwings(chainedswordL, "left", "sword", "attack", false, 20)

local blockR = figuredanim.blockR
blockR:offset(0.5):length(0.9)
local blockR_out = figuredanim.blockR_out
blockR_out:offset(0.5):length(0.9):blendTime(0.001,4)

local blockL = figuredanim.blockL
blockL:offset(0.5):length(0.9)
local blockL_out = figuredanim.blockL_out
blockL_out:offset(0.5):length(0.9):blendTime(0.001,4)

local bowR = figuredanim.bowR
bowR:offset(1):length(2.5):blendTime(1)
local bowR_out = figuredanim.bowR_out
bowR_out:offset(1):length(2):blendTime(1,4)

local bowL = figuredanim.bowL
bowL:offset(1):length(2.5):blendTime(1)
local bowL_out = figuredanim.bowL_out
bowL_out:offset(1):length(2):blendTime(1,4)

local loadR = figuredanim.loadR
loadR:offset(1):length(2.2):blendTime(1)

local loadL = figuredanim.loadL
loadL:offset(1):length(2.2):blendTime(1)

local crossR = figuredanim.crossR
crossR:blendTime(1,0.01)
local crossR_out = figuredanim.crossR_out
crossR_out:offset(1):length(2):blendTime(0.01,4)

local crossL = figuredanim.crossL
crossL:blendTime(1,0.01)
local crossL_out = figuredanim.crossL_out
crossL_out:offset(1):length(2):blendTime(0.01,4)

local brushR = figuredanim.brushR
brushR:offset(0.5):length(1):blendTime(1,4)
local brushL = figuredanim.brushL
brushL:offset(0.5):length(1):blendTime(1,4)

local spyglassR = figuredanim.spyglassR
local spyglassR_out = figuredanim.spyglassR_out
spyglassR_out:blendTime(0.01,4)
local spyglassL = figuredanim.spyglassL
local spyglassL_out = figuredanim.spyglassL_out
spyglassL_out:blendTime(0.01,4)

local hornR = figuredanim.hornR
hornR:offset(0.5):length(1.25)
local shake_hornR = figuredanim.shake_hornR
shake_hornR:offset(0.5):length(1)
local hornR_out = figuredanim.hornR_out
hornR_out:offset(0.5):length(1):blendTime(0.01,4)

local hornL = figuredanim.hornL
hornL:offset(0.5):length(1.25)--:blendTime(1,4)
local shake_hornL = figuredanim.shake_hornL
shake_hornL:offset(0.5):length(1)--:blendTime(1,4)
local hornL_out = figuredanim.hornL_out
hornL_out:offset(0.5):length(1):blendTime(0.01,4)

local spearR = figuredanim.spearR
spearR:offset(1):length(1.9):blendTime(0.001,0.1)
local spearR_out = figuredanim.spearR_out
spearR_out:offset(1):length(1.9):blendTime(0.1,4)

local spearL = figuredanim.spearL
spearL:offset(1):length(1.9):blendTime(0.001,0.1)
local spearL_out = figuredanim.spearL_out
spearL_out:offset(1):length(1.9):blendTime(0.1,4)

figuredanim.testorito:offset(1):length(1.30):blendTime(1,4)
figuredanim.testoritoL:offset(1):length(1.30):blendTime(1,4)
figuredanim.crouching:blendTime(1)

-- squapismoothhead

local smoothHead1 = squapi.smoothHead:new(
{
    modeltorso,
    modeltorso.Head,
    modeltorso.RightArm1.RightArm,
    modeltorso.LeftArm1.LeftArm,
    modelpath.Player.RightLeg1.RightLeg,
    modelpath.Player.LeftLeg1.LeftLeg
},
{
    0.3, 0.7, -0.3, -0.3, -0.1, -0.1
},
nil, -- tilt
nil, -- speed
false, -- keepOriginalHeadPos
true -- fixPortrait (change it if something doesn't work (for example, adding a PhysBone requires this to be false))
)

-- locals

local lastPlayingStr = ""

local trackedAnimations = {
    spearR = { allow = false, out = spearR_out },
    spearL = { allow = false, out = spearL_out },
    blockR = { allow = false, out = blockR_out },
    blockL = { allow = false, out = blockL_out },
    bowR   = { allow = false, out = bowR_out },
    bowL   = { allow = false, out = bowL_out },
    crossR = { allow = false, out = crossR_out },
    crossL = { allow = false, out = crossL_out },
    spyglassR = { allow = false, out = spyglassR_out },
    spyglassL = { allow = false, out = spyglassL_out },
    hornR = { allow = false, out = hornR_out },
    hornL = { allow = false, out = hornL_out }
}

local animData = {
    crossR = "B",
    loadR = "B",

    crossL = "B",
    loadL = "B",
    
    bowR = "B",
    bowL = "B",
    
    brushR = "R",
    brushL = "L",
    
    spearR = "B",
    spearL = "B",
    
    blockR = "R",
    blockL = "L",

    attackR = "R",
    attackL = "L",
    
    mineR = "R",
    mineL = "L",

    axe_mineR = "B",
    axe_mineL = "B",

    shovel_mineR = "R",
    shovel_mineL = "L",

    hoe_mineR = "B",
    hoe_mineL = "B",

    eatR = "R",
    eatL = "L",

    drinkR = "R",
    drinkL = "L",

    spyglassR = "R",
    spyglassL = "L",

    hornR = "R",
    hornL = "L",
    --[[chainR1 = "R",
	  chainR2 = "R",
	  chainR3 = "R",
    chainL1 = "L",
	  chainL2 = "L",
	  chainL3 = "L",]]
}

local animRefs = {
    mineR = mineR,
    mineL = mineL,
    axe_mineR = axe_mineR,
    axe_mineL = axe_mineL,
    shovel_mineR = shovel_mineR,
    shovel_mineL = shovel_mineL,
    hoe_mineR = hoe_mineR,
    hoe_mineL = hoe_mineR,
    attackR = attackR,
    attackL = attackL,
    --[[chainR1 = chainR1,
	  chainR2 = chainR2,
	  chainR3 = chainR3,
    chainL1 = chainL1,
	  chainL2 = chainL2,
	  chainL3 = chainL3]]
}

local wasActiveL, wasActiveR = false, false

-- alotoftext

function events.tick()

 local isActiveL, isActiveR = false, false

 if getAnimState("walking") or getAnimState("sprinting") then
    for animName, hand in pairs(animData) do
        local playing = false

        if not animRefs[animName] then
            playing = getAnimState(animName)
        else
            playing = animRefs[animName]:isPlaying()
        end

        if playing then
            if hand == "L" then
                isActiveL = true
            elseif hand == "R" then
                isActiveR = true
            elseif hand == "B" then
                isActiveL = true
                isActiveR = true
            end
        end

        if isActiveL or isActiveR then
            break
        end
    end

    if isActiveL or isActiveR then
        if isActiveR then
            arm_R_walking:stop()
            arm_R_sprinting:stop()
        end
        if isActiveL then
            arm_L_walking:stop()
            arm_L_sprinting:stop()
        end
    elseif (wasActiveL or wasActiveR) and not (isActiveL or isActiveR) then
        if getAnimState("sprinting") then
            arm_R_sprinting:play():time(sprinting:getTime())
            arm_L_sprinting:play():time(sprinting:getTime())
        elseif getAnimState("walking") then
            arm_R_walking:play():time(walking:getTime())
            arm_L_walking:play():time(walking:getTime())
        end
    end

    wasActiveL, wasActiveR = isActiveL, isActiveR
 end


 --[[local spytcher = (getAnimState("spyglassR") or getAnimState("hornR") or getAnimState("bowR") or getAnimState("crossR")) and 0.6 or 0
 local bowcherleft = getAnimState("bowR") and 0.3 or 0
 local crosscherleft = getAnimState("crossR") and 0.6 or 0

 if spytcher ~= 0 and not smoothHead1.element[7] then
    table.insert(smoothHead1.element, modeltorso.RightArm1)
    table.insert(smoothHead1.strength, spytcher)
 elseif smoothHead1.element[7] == modeltorso.RightArm1 then
    smoothHead1.strength[7] = spytcher
 --(arm doesn't get removed at the end — it's not really a problem overall, but I'd prefer to remove it just in case)
 end

 if bowcherleft ~= 0 and not smoothHead1.element[8] then
    table.insert(smoothHead1.element, modeltorso.LeftArm1)
    table.insert(smoothHead1.strength, bowcherleft)
 elseif smoothHead1.element[8] == modeltorso.LeftArm1 then
    smoothHead1.strength[8] = bowcherleft
 end

 if crosscherleft ~= 0 and not smoothHead1.element[9] then
    table.insert(smoothHead1.element, modeltorso.LeftArm1)
    table.insert(smoothHead1.strength, crosscherleft)
 elseif smoothHead1.element[9] == modeltorso.LeftArm1 then
    smoothHead1.strength[9] = crosscherleft
 end
 ]]

 local spytcher = (getAnimState("spyglassR") or getAnimState("hornR") or getAnimState("bowR") or getAnimState("crossR")) and 0.6 or 0
 local spytcherleft = (getAnimState("spyglassL") or getAnimState("hornL") or getAnimState("bowL") or getAnimState("crossL")) and 0.6 or 0
 local bowcherleft = getAnimState("bowR") and 0.3 or 0
 local crosscherleft = getAnimState("crossR") and 0.3 or 0
 local bowcherRightFromLeft = getAnimState("bowL") and 0.3 or 0
 local crosscherRightFromLeft = getAnimState("crossL") and 0.3 or 0

 if spytcher ~= 0 then
    smoothHead1.element[7] = modeltorso.RightArm1
    smoothHead1.strength[7] = spytcher
 elseif bowcherRightFromLeft ~= 0 then
    smoothHead1.element[7] = modeltorso.RightArm1
    smoothHead1.strength[7] = bowcherRightFromLeft
 elseif crosscherRightFromLeft ~= 0 then
    smoothHead1.element[7] = modeltorso.RightArm1
    smoothHead1.strength[7] = crosscherRightFromLeft
 else
    smoothHead1.strength[7] = 0
 end

 if spytcherleft ~= 0 then
    smoothHead1.element[7] = modeltorso.RightArm1
    smoothHead1.element[8] = modeltorso.LeftArm1
    smoothHead1.strength[8] = spytcherleft
 elseif bowcherleft ~= 0 then
    smoothHead1.element[8] = modeltorso.LeftArm1
    smoothHead1.strength[8] = bowcherleft
 elseif crosscherleft ~= 0 then
    smoothHead1.element[8] = modeltorso.LeftArm1
    smoothHead1.strength[8] = crosscherleft
 else
    smoothHead1.strength[8] = 0
 end

    for name, data in pairs(trackedAnimations) do
        if getAnimState(name) then
            data.allow = true
            data.out:stop()
        elseif data.allow then
            data.out:play()
            data.allow = false
        end
    end

 -- piratesee's modified code

    local forwardVel = player:getVelocity():dot((player:getLookDir().x_z):normalize())
    local horizontalVel = player:getVelocity().xz:length()*20 -- convert to m/s
    local verticalVel = math.abs(player:getVelocity().y)*20

 -- ezanims + vertical

    flyup:speed(verticalVel/1 * (player:getVelocity().y > 0 and 4 or -0.2))
    flydown:speed(verticalVel/1 * (player:getVelocity().y > 0 and -0.2 or 4))
    falling:speed(verticalVel/2 * (player:getVelocity().y > 0 and -1.3 or 0.2))
    shake_falling:speed(verticalVel/15 * (player:getVelocity().y > 0 and -0.2 or 0.2))
    climbing:speed(verticalVel/1 * (player:getVelocity().y > 0 and 1.3 or -1.3))

 -- ezanims + piratesee's horizontal

    walking:speed(horizontalVel/3.3 * (forwardVel > 0 and 1 or -1))
    arm_R_walking:speed(horizontalVel/3.3 * (forwardVel > 0 and 1 or -1))
    arm_L_walking:speed(horizontalVel/3.3 * (forwardVel > 0 and 1 or -1))
    crawling:speed(horizontalVel/1 * (forwardVel > 0 and 1 or -1))
    swimming:speed(horizontalVel/3.3 * (forwardVel > 0 and 1 or -1))

 -- sprinting + ezanims + piratesee's

    sprinting:speed(player:getVelocity().xz:length()*7)
    arm_R_sprinting:speed(player:getVelocity().xz:length()*7)
    arm_L_sprinting:speed(player:getVelocity().xz:length()*7)

 -- (needs to be redone)

 local foundHaste = false

 for _, effect in pairs(host:getStatusEffects()) do
    if effect.name == "minecraft:mining_fatigue" then
        animations.model.mineR:speed(2 / (effect.amplifier + 1))
        foundHaste = true
        break
    end
    if effect.name == "minecraft:haste" then
        animations.model.mineR:speed(2 + effect.amplifier)
        foundHaste = true
        break
    end
 end

 if not foundHaste then
    animations.model.mineR:speed(1.5)
 end

 -- logging

    --[[local playing = animations:getPlaying(true)
    local str = ""

    for _, anim in ipairs(playing) do
        str = str .. anim:getName() .. ";"
    end

    if str ~= lastPlayingStr then
        lastPlayingStr = str
        log(str)
    end]]
    
   --log(player:getBodyYaw(%360))
   --print(currentItem)
   --print("SmoothHeads count: "..#squapi.smoothHeads)
   --log(jumpingup:getTime())
   --log(jumpingdown:getTime())
   --log(falling:getSpeed())
   --log(flyup:getSpeed())
   --log(targetStrength)

end
