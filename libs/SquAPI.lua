local squassets
for _, path in ipairs(listFiles("/", true)) do
if string.find(path, "SquAssets") then squassets=require(path) end
end
assert(squassets,
"§4Missing SquAssets file! Make sure to download that from the GitHub too!§c")
local squapi={}
squapi.autoFunctionUpdates=true
squapi.tails={}
squapi.tail={}
squapi.tail.__index=squapi.tail
function squapi.tail:new(tailSegmentList, idleXMovement, idleYMovement, idleXSpeed, idleYSpeed,
bendStrength, velocityPush, initialMovementOffset, offsetBetweenSegments,
stiffness, bounce, flyingOffset, downLimit, upLimit)
local self=setmetatable({}, squapi.tail)
self.tailSegmentList=tailSegmentList
if type(self.tailSegmentList)=="ModelPart" then
self.tailSegmentList={self.tailSegmentList}
end
assert(type(self.tailSegmentList)=="table",
"your tailSegmentList table seems to to be incorrect")
self.berps={}
self.targets={}
self.stiffness=stiffness or.005
self.bounce=bounce or.9
self.downLimit=downLimit or-90
self.upLimit=upLimit or 45
if type(self.tailSegmentList[2])=="number" then
local range=self.tailSegmentList[2]
local str=""
if self.tailSegmentList[3] then
str=self.tailSegmentList[3]
end
self.tailSegmentList[2]=self.tailSegmentList[1][str.."tailseg"]
for i=2, range-2 do
self.tailSegmentList[i+1]=self.tailSegmentList[i][str.."tailseg"..i]
end
self.tailSegmentList[range]=self.tailSegmentList[range-1][str.."tailtip"]
end
for i=1, #self.tailSegmentList do
assert(self.tailSegmentList[i]:getType()=="GROUP",
"§4The tail segment at position "..i.." of the table is not a group.The tail segments need to be groups that are nested inside the previous segment.§c")
self.berps[i]={squassets.BERP:new(self.stiffness, self.bounce), squassets.BERP:new(self.stiffness, self.bounce, self.downLimit, self.upLimit)}
self.targets[i]={0, 0}
end
self.tailSegmentList=tailSegmentList
self.idleXMovement=idleXMovement or 15
self.idleYMovement=idleYMovement or 5
self.idleXSpeed=idleXSpeed or 1.2
self.idleYSpeed=idleYSpeed or 2
self.bendStrength=bendStrength or 2
self.velocityPush=velocityPush or 0
self.initialMovementOffset=initialMovementOffset or 0
self.flyingOffset=flyingOffset or 90
self.offsetBetweenSegments=offsetBetweenSegments or 1
self.enabled=true
function self:toggle()
self.enabled=not self.enabled
end
function self:disable()
self.enabled=false
end
function self:enable()
self.enabled=true
end
function self:zero()
for _, v in pairs(self.tailSegmentList) do
v:setOffsetRot(0, 0, 0)
end
end
self.currentBodyRot=0
self.oldBodyRot=0
self.bodyRotSpeed=0
function self:tick()
if self.enabled then
self.oldBodyRot=self.currentBodyRot
self.currentBodyRot=player:getBodyYaw()
self.bodyRotSpeed=math.max(math.min(self.currentBodyRot-self.oldBodyRot, 20),-20)
local time=world.getTime()
local vel=squassets.forwardVel()
local yvel=squassets.verticalVel()
local svel=squassets.sideVel()
local bendStrength=self.bendStrength/(math.abs((yvel*30))+vel*30+1)
local pose=player:getPose()
for i=1, #self.tailSegmentList do
self.targets[i][1]=math.sin((time*self.idleXSpeed)/10-(i*self.offsetBetweenSegments))*self.idleXMovement
self.targets[i][2]=math.sin((time*self.idleYSpeed)/10-(i*self.offsetBetweenSegments)+self.initialMovementOffset)*self.idleYMovement
self.targets[i][1]=self.targets[i][1]+self.bodyRotSpeed*self.bendStrength+svel*self.bendStrength*40
self.targets[i][2]=self.targets[i][2]+yvel*15*self.bendStrength-vel*self.bendStrength*15*self.velocityPush
if i==1 then
if pose=="FALL_FLYING" or pose=="SWIMMING" or player:riptideSpinning() then
self.targets[i][2]=self.flyingOffset
end
end
end
end
end
function self:render(dt, _)
if self.enabled then
local pose=player:getPose()
if pose ~="SLEEPING" then
for i, tail in ipairs(self.tailSegmentList) do
tail:setOffsetRot(
self.berps[i][2]:berp(self.targets[i][2], dt),
self.berps[i][1]:berp(self.targets[i][1], dt),
0
)
end
end
end
end
table.insert(squapi.tails, self)
return self
end
squapi.ears={}
squapi.ear={}
squapi.ear.__index=squapi.ear
function squapi.ear:new(leftEar, rightEar, rangeMultiplier, horizontalEars, bendStrength, doEarFlick,
earFlickChance, earStiffness, earBounce)
local self=setmetatable({}, squapi.ear)
assert(leftEar,
"§4The first ear's model path is incorrect.§c")
self.leftEar=leftEar
self.rightEar=rightEar
self.horizontalEars=horizontalEars
self.rangeMultiplier=rangeMultiplier or 1
if self.horizontalEars then self.rangeMultiplier=self.rangeMultiplier/2 end
self.bendStrength=bendStrength or 2
earStiffness=earStiffness or 0.1
earBounce=earBounce or 0.8
if doEarFlick==nil then doEarFlick=true end
self.doEarFlick=doEarFlick
self.earFlickChance=earFlickChance or 400
self.enabled=true
function self:toggle()
self.enabled=not self.enabled
end
function self:disable()
self.enabled=false
end
function self:enable()
self.enabled=true
end
function self:setEnabled(bool)
assert(type(bool)=="boolean",
"§4setEnabled must be set to a boolean.§c")
self.enabled=bool
end
self.eary=squassets.BERP:new(earStiffness, earBounce)
self.earx=squassets.BERP:new(earStiffness, earBounce)
self.earz=squassets.BERP:new(earStiffness, earBounce)
self.targets={0, 0, 0}
self.oldpose="STANDING"
function self:tick()
if self.enabled then
local vel=math.min(math.max(-0.75, squassets.forwardVel()), 0.75)
local yvel=math.min(math.max(-1.5, squassets.verticalVel()), 1.5)*5
local svel=math.min(math.max(-0.5, squassets.sideVel()), 0.5)
local headrot=squassets.getHeadRot()
local bend=self.bendStrength
if headrot[1]<-22.5 then bend=-bend end
local pose=player:getPose()
if pose=="CROUCHING" and self.oldpose=="STANDING" then
self.eary.vel=self.eary.vel+5*self.bendStrength
elseif pose=="STANDING" and self.oldpose=="CROUCHING" then
self.eary.vel=self.eary.vel-5*self.bendStrength
end
self.oldpose=pose
if self.horizontalEars then
local rot=10*bend*(yvel+vel*10)+headrot[1]*self.rangeMultiplier
local addrot=headrot[2]*self.rangeMultiplier
self.targets[2]=rot+addrot
self.targets[3]=-rot+addrot
else
self.targets[1]=headrot[1]*self.rangeMultiplier+2*bend*(yvel+vel*15)
self.targets[2]=headrot[2]*self.rangeMultiplier-svel*100*self.bendStrength
self.targets[3]=self.targets[2]
end
if self.doEarFlick then
if math.random(0, self.earFlickChance)==1 then
if math.random(0, 1)==1 then
self.earx.vel=self.earx.vel+50
else
self.earz.vel=self.earz.vel-50
end
end
end
else
leftEar:setOffsetRot(0, 0, 0)
rightEar:setOffsetRot(0, 0, 0)
end
end
function self:render(dt, _)
if self.enabled then
self.eary:berp(self.targets[1], dt)
self.earx:berp(self.targets[2], dt)
self.earz:berp(self.targets[3], dt)
local rot3=self.earx.pos/4
local rot3b=self.earz.pos/4
if self.horizontalEars then
local y=self.eary.pos/4
self.leftEar:setOffsetRot(y, self.earx.pos/3, rot3)
if self.rightEar then
self.rightEar:setOffsetRot(y, self.earz.pos/3, rot3b)
end
else
self.leftEar:setOffsetRot(self.eary.pos, rot3, rot3)
if self.rightEar then
self.rightEar:setOffsetRot(self.eary.pos, rot3b, rot3b)
end
end
end
end
table.insert(squapi.ears, self)
return self
end
function squapi.crouch(crouch, uncrouch, crawl, uncrawl)
local oldstate="STANDING"
function events.render()
local pose=player:getPose()
if pose=="SWIMMING" and not player:isInWater() then pose="CRAWLING" end
if pose=="CROUCHING" then
if uncrouch ~=nil then
uncrouch:stop()
end
crouch:play()
elseif oldstate=="CROUCHING" then
crouch:stop()
if uncrouch ~=nil then
uncrouch:play()
end
elseif crawl ~=nil then
if pose=="CRAWLING" then
if uncrawl ~=nil then
uncrawl:stop()
end
crawl:play()
elseif oldstate=="CRAWLING" then
crawl:stop()
if uncrawl ~=nil then
uncrawl:play()
end
end
end
oldstate=pose
end
end
squapi.bewbs={}
squapi.bewb={}
squapi.bewb.__index=squapi.bewb
function squapi.bewb:new(element, bendability, stiff, bounce, doIdle, idleStrength, idleSpeed,
downLimit, upLimit)
local self=setmetatable({}, squapi.bewb)
assert(element, "§4Your model path for bewb is incorrect.§c")
self.element=element
if doIdle==nil then doIdle=true end
self.doIdle=doIdle
self.bendability=bendability or 2
self.bewby=squassets.BERP:new(stiff or 0.05, bounce or 0.9, downLimit or-10, upLimit or 25)
self.idleStrength=idleStrength or 4
self.idleSpeed=idleSpeed or 1
self.target=0
self.enabled=true
function self:toggle()
self.enabled=not self.enabled
end
function self:disable()
self.enabled=false
end
function self:enable()
self.enabled=true
end
function self:setEnabled(bool)
assert(type(bool)=="boolean",
"§4setEnabled must be set to a boolean.§c")
self.enabled=bool
end
self.oldpose="STANDING"
function self:tick()
if self.enabled then
local vel=squassets.forwardVel()
local yvel=squassets.verticalVel()
local worldtime=world.getTime()
if self.doIdle then
self.target=math.sin(worldtime/8*self.idleSpeed)*self.idleStrength
end
local pose=player:getPose()
if pose=="CROUCHING" and self.oldpose=="STANDING" then
self.bewby.vel=self.bewby.vel+self.bendability
elseif pose=="STANDING" and self.oldpose=="CROUCHING" then
self.bewby.vel=self.bewby.vel-self.bendability
end
self.oldpose=pose
self.bewby.vel=self.bewby.vel-yvel*self.bendability
self.bewby.vel=self.bewby.vel-vel*self.bendability
else
self.target=0
end
end
function self:render(dt, _)
self.element:setOffsetRot(self.bewby:berp(self.target, dt), 0, 0)
end
table.insert(squapi.bewbs, self)
return self
end
squapi.randimations={}
squapi.randimation={}
squapi.randimation.__index=squapi.randimation
function squapi.randimation:new(animation, chanceRange, stopOnSleep)
local self=setmetatable({}, squapi.randimation)
self.stopOnSleep=stopOnSleep
self.animation=animation
self.chanceRange=chanceRange or 200
self.enabled=true
function self:toggle()
self.enabled=not self.enabled
end
function self:disable()
self.enabled=false
end
function self:enable()
self.enabled=true
end
function self:setEnabled(bool)
assert(type(bool)=="boolean",
"§4setEnabled must be set to a boolean.§c")
self.enabled=bool
end
function events.tick()
if self.enabled and (not self.stopOnSleep or player:getPose() ~="SLEEPING") and math.random(0, self.chanceRange)==0 and self.animation:isStopped() then
self.animation:play()
end
end
table.insert(squapi.randimations, self)
return self
end
squapi.eyes={}
squapi.eye={}
squapi.eye.__index=squapi.eye
function squapi.eye:new(element, leftDistance, rightDistance, upDistance, downDistance, switchValues)
local self=setmetatable({}, squapi.eye)
assert(element,
"§4Your eye model path is incorrect.§c")
self.element=element
self.switchValues=switchValues or false
self.left=leftDistance or.25
self.right=rightDistance or 1.25
self.up=upDistance or 0.5
self.down=downDistance or 0.5
self.x=0
self.y=0
self.eyeScale=1
function self:setEyeScale(scale)
self.eyeScale=scale
end
self.enabled=true
function self:toggle()
self.enabled=not self.enabled
end
function self:disable()
self.enabled=false
end
function self:enable()
self.enabled=true
end
function self:setEnabled(bool)
assert(type(bool)=="boolean",
"§4setEnabled must be set to a boolean.§c")
self.enabled=bool
end
function self:zero()
self.x, self.y=0, 0
end
function self:tick()
if self.enabled then
local headrot=squassets.getHeadRot()
headrot[2]=math.max(math.min(50, headrot[2]),-50)
self.x=-squassets.parabolagraph(-50,-self.left, 0, 0, 50, self.right, headrot[2])
self.y=squassets.parabolagraph(-90,-self.down, 0, 0, 90, self.up, headrot[1])
self.x=math.max(math.min(self.left, self.x),-self.right)
self.y=math.max(math.min(self.up, self.y),-self.down)
end
end
function self:render(dt, _)
local c=self.element:getPos()
if self.switchValues then
self.element:setPos(0, math.lerp(c[2], self.y, dt), math.lerp(c[3],-self.x, dt))
else
self.element:setPos(math.lerp(c[1], self.x, dt), math.lerp(c[2], self.y, dt), 0)
end
local scale=math.lerp(self.element:getOffsetScale()[1], self.eyeScale, dt)
self.element:setOffsetScale(scale, scale, scale)
end
table.insert(squapi.eyes, self)
return self
end
squapi.hoverPoints={}
squapi.hoverPoint={}
squapi.hoverPoint.__index=squapi.hoverPoint
function squapi.hoverPoint:new(element, elementOffset, springStrength, mass, resistance, rotationSpeed, rotateWithPlayer, doCollisions)
local self=setmetatable({}, squapi.hoverPoint)
self.element=element
assert(self.element,
"§4The Hover point's model path is incorrect.§c")
self.element:setParentType("WORLD")
elementOffset=elementOffset or vec(0,0,0)
self.elementOffset=elementOffset*16
self.springStrength=springStrength or 0.2
self.mass=mass or 5
self.resistance=resistance or 1
self.rotationSpeed=rotationSpeed or 0.05
self.doCollisions=doCollisions
self.rotateWithPlayer=rotateWithPlayer
if self.rotateWithPlayer==nil then self.rotateWithPlayer=true end
self.enabled=true
function self:toggle()
self.enabled=not self.enabled
end
function self:disable()
self.enabled=false
end
function self:enable()
self.enabled=true
end
function self:setEnabled(bool)
assert(type(bool)=="boolean",
"§4setEnabled must be set to a boolean.§c")
self.enabled=bool
end
function self:reset()
local yaw
if self.rotateWithPlayer then
yaw=math.rad(player:getBodyYaw()+180)
else
yaw=0
end
local sin, cos=math.sin(yaw), math.cos(yaw)
local offset=vec(
cos*self.elementOffset.x-sin*self.elementOffset.z,
self.elementOffset.y,
sin*self.elementOffset.x+cos*self.elementOffset.z
)
self.pos=player:getPos()+offset/16
self.element:setPos(self.pos*16)
self.element:setOffsetRot(0,-player:getBodyYaw()+180,0)
end
self.pos=vec(0,0,0)
self.vel=vec(0,0,0)
self.init=true
self.delay=0
function self:tick()
if self.enabled then
local yaw
if self.rotateWithPlayer then
yaw=math.rad(player:getBodyYaw()+180)
else
yaw=0
end
local sin, cos=math.sin(yaw), math.cos(yaw)
local offset=vec(
cos*self.elementOffset.x-sin*self.elementOffset.z,
self.elementOffset.y,
sin*self.elementOffset.x+cos*self.elementOffset.z
)
if self.init then
self.init=false
self.pos=player:getPos()+offset/16
self.element:setPos(self.pos*16)
self.element:setOffsetRot(0,-player:getBodyYaw()+180,0)
end
local target=player:getPos()+offset/16
local pos=self.element:partToWorldMatrix():apply()
local dif=self.pos-target
local force=vec(0,0,0)
if self.delay==0 then
if self.doCollisions and world.getBlockState(pos):getCollisionShape()[1] then
local block, hitPos, side=raycast:block(pos-self.vel*2, pos)
self.pos=self.pos+(hitPos-pos)
if side=="east" or side=="west" then
self.vel.x=-self.vel.x*0.5
elseif side=="north" or side=="south" then
self.vel.z=-self.vel.z*0.5
else
self.vel.y=-self.vel.y*0.5
end
self.delay=2
else
force=force-dif*self.springStrength
end
else
self.delay=self.delay-1
end
force=force-self.vel*self.resistance
self.vel=self.vel+force/self.mass
self.pos=self.pos+self.vel
end
end
function self:render(dt, _)
self.element:setPos(
math.lerp(self.element:getPos(), self.pos*16, dt/2)
)
self.element:setOffsetRot(0,
math.lerp(self.element:getOffsetRot()[2], 180-player:getBodyYaw(), dt*self.rotationSpeed), 0)
end
table.insert(squapi.hoverPoints, self)
return self
end
squapi.legs={}
squapi.leg={}
squapi.leg.__index=squapi.leg
function squapi.leg:new(element, strength, isRight, keepPosition)
local self=squassets.vanillaElement:new(element, strength, keepPosition)
if isRight==nil then isRight=false end
self.isRight=isRight
function self:getVanilla()
if self.isRight then
self.rot=vanilla_model.RIGHT_LEG:getOriginRot()
self.pos=vanilla_model.RIGHT_LEG:getOriginPos()
else
self.rot=vanilla_model.LEFT_LEG:getOriginRot()
self.pos=vanilla_model.LEFT_LEG:getOriginPos()
end
return self.rot, self.pos
end
table.insert(squapi.legs, self)
return self
end
squapi.arms={}
squapi.arm={}
squapi.arm.__index=squapi.arm
function squapi.arm:new(element, strength, isRight, keepPosition)
local self=squassets.vanillaElement:new(element, strength, keepPosition)
if isRight==nil then isRight=false end
self.isRight=isRight
function self:getVanilla()
if self.isRight then
self.rot=vanilla_model.RIGHT_ARM:getOriginRot()
else
self.rot=vanilla_model.LEFT_ARM:getOriginRot()
end
self.pos=-vanilla_model.LEFT_ARM:getOriginPos()
return self.rot, self.pos
end
table.insert(squapi.arms, self)
return self
end
squapi.smoothHeads={}
squapi.smoothHead={}
squapi.smoothHead.__index=squapi.smoothHead
function squapi.smoothHead:new(element, strength, tilt, speed, keepOriginalHeadPos, fixPortrait)
local self=setmetatable({}, squapi.smoothHead)
if type(element)=="ModelPart" then
assert(element, "§4Your model path for smoothHead is incorrect.§c")
element={element}
end
assert(type(element)=="table", "§4your element table seems to to be incorrect.§c")
for i=1, #element do
assert(element[i]:getType()=="GROUP",
"§4The head element at position "..
i..
" of the table is not a group.The head elements need to be groups that are nested inside one another to function properly.§c")
assert(element[i], "§4The head segment at position "..i.." is incorrect.§c")
element[i]:setParentType("NONE")
end
self.element=element
self.strength=strength or 1
if type(self.strength)=="number" then
local strengthDiv=self.strength/#element
self.strength={}
for i=1, #element do
self.strength[i]=strengthDiv
end
end
self.tilt=tilt or 0.1
if keepOriginalHeadPos==nil then keepOriginalHeadPos=true end
self.keepOriginalHeadPos=keepOriginalHeadPos
self.headRot=vec(0, 0, 0)
self.offset=vec(0, 0, 0)
self.speed=(speed or 1)/2
if fixPortrait==nil then fixPortrait=true end
if fixPortrait then
if type(element)=="table" then
for _, part in ipairs(element) do
if squassets.caseInsensitiveFind(part, "head") then
part:copy("_squapi-portrait"):moveTo(models):setParentType("Portrait")
:setPos(-part:getPivot())
break
end
end
elseif type(element)=="ModelPart" and element:getType()=="GROUP" then
if squassets.caseInsensitiveFind(element, "head") then
element:copy("_squapi-portrait"):moveTo(models):setParentType("Portrait")
:setPos(-element:getPivot())
end
end
end
function self:setOffset(xRot, yRot, zRot)
self.offset=vec(xRot, yRot, zRot)
end
self.enabled=true
function self:toggle()
self.enabled=not self.enabled
end
function self:disable()
self.enabled=false
end
function self:enable()
self.enabled=true
end
function self:setEnabled(bool)
assert(type(bool)=="boolean",
"§4setEnabled must be set to a boolean.§c")
self.enabled=bool
end
function self:zero()
for _, v in ipairs(self.element) do
v:setPos(0, 0, 0)
v:setOffsetRot(0, 0, 0)
self.headRot=vec(0, 0, 0)
end
end
function self:tick()
if self.enabled then
local vanillaHeadRot=squassets.getHeadRot()
self.headRot[1]=self.headRot[1]+(vanillaHeadRot[1]-self.headRot[1])*self.speed
self.headRot[2]=self.headRot[2]+(vanillaHeadRot[2]-self.headRot[2])*self.speed
self.headRot[3]=self.headRot[2]*self.tilt
end
end
function self:render(dt, context)
if self.enabled then
dt=dt/5
for i in ipairs(self.element) do
local c=self.element[i]:getOffsetRot()
local target=(self.headRot*self.strength[i])-self.offset/#self.element
self.element[i]:setOffsetRot(
math.lerp(c[1], target[1], dt),
math.lerp(c[2], target[2], dt),
math.lerp(c[3], target[3], dt)
)
if renderer:isFirstPerson() and context=="RENDER" then
self.element[i]:setVisible(false)
else
self.element[i]:setVisible(true)
end
end
if self.keepOriginalHeadPos then
self.element
[type(self.keepOriginalHeadPos)=="number" and self.keepOriginalHeadPos or #self.element]
:setPos(-vanilla_model.HEAD:getOriginPos())
end
end
end
table.insert(squapi.smoothHeads, self)
return self
end
squapi.bounceWalks={}
squapi.bounceWalk={}
squapi.bounceWalk.__index=squapi.bounceWalk
function squapi.bounceWalk:new(model, bounceMultiplier)
local self=setmetatable({}, squapi.bounceWalk)
assert(model, "Your model path is incorrect for bounceWalk")
self.bounceMultiplier=bounceMultiplier or 1
self.target=0
self.enabled=true
function self:toggle()
self.enabled=not self.enabled
end
function self:disable()
self.enabled=false
end
function self:enable()
self.enabled=true
end
function self:setEnabled(bool)
assert(type(bool)=="boolean",
"§4setEnabled must be set to a boolean.§c")
self.enabled=bool
end
function self:render(dt, _)
local pose=player:getPose()
if self.enabled and (pose=="STANDING" or pose=="CROUCHING") then
local leftlegrot=vanilla_model.LEFT_LEG:getOriginRot()[1]
local bounce=self.bounceMultiplier
if pose=="CROUCHING" then
bounce=bounce/2
end
self.target=math.abs(leftlegrot)/40*bounce
else
self.target=0
end
model:setPos(0, math.lerp(model:getPos()[2], self.target, dt), 0)
end
table.insert(squapi.bounceWalks, self)
return self
end
squapi.taurs={}
squapi.taur={}
squapi.taur.__index=squapi.taur
function squapi.taur:new(taurBody, frontLegs, backLegs)
local self=setmetatable({}, squapi.taur)
assert(taurBody, "§4Your model path for the body in taurPhysics is incorrect.§c")
self.taurBody=taurBody
self.frontLegs=frontLegs
self.backLegs=backLegs
self.taur=squassets.BERP:new(0.01, 0.5)
self.target=0
self.enabled=true
function self:toggle()
self.enabled=not self.enabled
end
function self:disable()
self.enabled=false
end
function self:enable()
self.enabled=true
end
function self:setEnabled(bool)
assert(type(bool)=="boolean",
"§4setEnabled must be set to a boolean.§c")
self.enabled=bool
end
function self:tick()
if self.enabled then
self.target=math.min(math.max(-30, squassets.verticalVel()*40), 45)
end
end
function self:render(dt, _)
if self.enabled then
self.taur:berp(self.target, dt/2)
local pose=player:getPose()
if pose=="FALL_FLYING" or pose=="SWIMMING" or (player:isClimbing() and not player:isOnGround()) or player:riptideSpinning() then
self.taurBody:setRot(80, 0, 0)
if self.backLegs then
self.backLegs:setRot(-50, 0, 0)
end
if self.frontLegs then
self.frontLegs:setRot(-50, 0, 0)
end
else
self.taurBody:setRot(self.taur.pos, 0, 0)
if self.backLegs then
self.backLegs:setRot(self.taur.pos*3, 0, 0)
end
if self.frontLegs then
self.frontLegs:setRot(-self.taur.pos*3, 0, 0)
end
end
end
end
table.insert(squapi.taurs, self)
return self
end
squapi.FPHands={}
squapi.FPHand={}
squapi.FPHand.__index=squapi.FPHand
function squapi.FPHand:new(element, x, y, z, scale, onlyVisibleInFP)
local self=setmetatable(self, squapi.FPHand)
assert(element, "Your First Person Hand path is incorrect")
element:setParentType("RightArm")
self.element=element
self.x=x or 0
self.y=y or 0
self.z=z or 0
self.scale=scale or 1
self.onlyVisibleInFP=onlyVisibleInFP
function self:updatePos(_x, _y, _z)
self.x=_x
self.y=_y
self.z=_z
end
function self:render(_, context)
if context=="FIRST_PERSON" then
if self.onlyVisibleInFP then
self.element:setVisible(true)
end
self.element:setPos(self.x, self.y, self.z)
self.element:setScale(self.scale, self.scale, self.scale)
else
if self.onlyVisibleInFP then
self.element:setVisible(false)
end
self.element:setPos(0, 0, 0)
end
end
table.insert(squapi.FPHands, self)
return self
end
function squapi.animateTexture(element, numberOfFrames, framePercent, slowFactor, vertical)
assert(element,
"§4Your model path for animateTexture is incorrect.§c")
vertical=vertical or false
slowFactor=slowFactor or 1
function events.tick()
local time=world.getTime()
local frameshift=math.floor(time/slowFactor) % numberOfFrames*framePercent
if vertical then element:setUV(0, frameshift) else element:setUV(frameshift, 0) end
end
end
if squapi.autoFunctionUpdates then
function events.tick()
for _, v in ipairs(squapi.smoothHeads) do v:tick() end
for _, v in ipairs(squapi.eyes) do v:tick() end
for _, v in ipairs(squapi.bewbs) do v:tick() end
for _, v in ipairs(squapi.hoverPoints) do v:tick() end
for _, v in ipairs(squapi.ears) do v:tick() end
for _, v in ipairs(squapi.tails) do v:tick() end
for _, v in ipairs(squapi.taurs) do v:tick() end
end
function events.render(dt, context)
for _, v in ipairs(squapi.smoothHeads) do v:render(dt, context) end
for _, v in ipairs(squapi.FPHands) do v:render(dt, context) end
for _, v in ipairs(squapi.bounceWalks) do v:render(dt, context) end
for _, v in ipairs(squapi.eyes) do v:render(dt, context) end
for _, v in ipairs(squapi.bewbs) do v:render(dt, context) end
for _, v in ipairs(squapi.hoverPoints) do v:render(dt, context) end
for _, v in ipairs(squapi.ears) do v:render(dt, context) end
for _, v in ipairs(squapi.tails) do v:render(dt, context) end
for _, v in ipairs(squapi.taurs) do v:render(dt, context) end
for _, v in ipairs(squapi.legs) do v:render(dt, context) end
for _, v in ipairs(squapi.arms) do v:render(dt, context) end
end
end
return squapi
