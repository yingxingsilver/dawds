local ID="GSAnimBlend-Tiny"
local VER="1.9.10+tiny"
local FIG={"0.1.0-rc.14", "0.1.4"}
local getmetatable=getmetatable
local setmetatable=setmetatable
local error=error
local next=next
local ipairs=ipairs
local pairs=pairs
local tostring=tostring
local m_max=math.max
local animations=animations
local figuraMetatables=figuraMetatables
local events=events
local _ENV=_ENV
local this={
curve=function(x) return x end
}
local thismt={
__type=ID,
__metatable=false,
__index={
_ID=ID,
_VERSION=VER
}
}
if not getmetatable(_ENV) then setmetatable(_ENV, {}) end
local _ENVMT=getmetatable(_ENV)
local animData={}
local blending={}
this.animData=animData
this.blending=blending
local ticker=0
local last_delta=0
local allowed_contexts={
RENDER=true,
FIRST_PERSON=true,
OTHER=true
}
local tPass=0.037504655
local blendCommand=[[getmetatable(_ENV).GSLib_triggerBlend(%q)]]
_ENVMT.GSLib_triggerBlend=setmetatable({}, {
__call=function(self, id) self[id]() end
})
local animNum=0
for _, anim in ipairs(animations:getAnimations()) do
local blend=anim:getBlend()
local len=anim:getLength()
len=len> tPass and len or false
local tID="blendAnim_"..animNum
animData[anim]={
blendTimeIn=0,
blendTimeOut=0,
blend=blend,
length=len,
triggerId=tID
}
_ENVMT.GSLib_triggerBlend[tID]=function() if anim:getLoop()=="ONCE" then anim:stop() end end
if len then anim:newCode(len-tPass, blendCommand:format(tID)) end
animNum=animNum+1
end
local animation_mt=figuraMetatables.Animation
local animationapi_mt=figuraMetatables.AnimationAPI
local ext_Animation=next(animData)
if not ext_Animation then
error(
"No animations have been found!\n"..
"This library cannot build its functions without an animation to use.\n"..
"Create an animation or stop this library from running to fix the error."
)
end
if ext_Animation.blendTime then
local path=tostring(ext_Animation.blendTime):match("^function:(.-):%d+%-%d+$")
error(
"Conflicting script ["..path.."] found!\n"..
"Remove the other script or this script to fix the error."
)
end
local _animationIndex=animation_mt.__index
local _animationapiIndex=animationapi_mt.__index
local animPlay=ext_Animation.play
local animStop=ext_Animation.stop
local animPause=ext_Animation.pause
local animRestart=ext_Animation.restart
local animBlend=ext_Animation.blend
local animLength=ext_Animation.length
local animGetPlayState=ext_Animation.getPlayState
local animGetBlend=ext_Animation.getBlend
local animIsPlaying=ext_Animation.isPlaying
local animIsPaused=ext_Animation.isPaused
local animNewCode=ext_Animation.newCode
local animapiGetPlaying=animations.getPlaying
this.oldF={
play=animPlay,
stop=animStop,
pause=animPause,
restart=animRestart,
getBlend=animGetBlend,
getPlayState=animGetPlayState,
isPlaying=animIsPlaying,
isPaused=animIsPaused,
setBlend=ext_Animation.setBlend,
setLength=ext_Animation.setLength,
setPlaying=ext_Animation.setPlaying,
blend=animBlend,
length=animLength,
playing=ext_Animation.playing,
api_getPlaying=animapiGetPlaying
}
function this.blend(anim, time, from, to, starting)
local data=animData[anim]
local dataBlend=data.blend
local _from=from or dataBlend
if starting==nil then starting=_from<(to or dataBlend) end
data.state={
time=0,
max=time or (starting and data.blendTimeIn or data.blendTimeOut),
from=from or false,
to=to or false,
paused=false,
starting=starting
}
blending[anim]=true
animBlend(anim, _from or dataBlend)
animPlay(anim)
if starting then anim:setTime(anim:getOffset()) end
animPause(anim)
return blendState
end
events.TICK:register(function() ticker=ticker+1 end, "GSAnimBlendTiny:Tick_TimeTicker")
events.RENDER:register(function(delta, ctx)
if not allowed_contexts[ctx] or (delta==last_delta and ticker==0) then return end
local elapsed_time=ticker+(delta-last_delta)
ticker=0
for anim in pairs(blending) do
local data=animData[anim]
local state=data.state
if not state.paused then
state.time=state.time+elapsed_time
if state.time> state.max or (animGetPlayState(anim)=="STOPPED") then
(state.starting and animPlay or animStop)(anim)
animBlend(anim, state.to or data.blend)
blending[anim]=nil
else
local from=state.from or data.blend
animBlend(anim, from+((state.to or data.blend)-from)*this.curve(state.time/state.max))
end
end
end
last_delta=delta
end, "GSAnimBlendTiny:Render_UpdateBlendStates")
local animationMethods={}
function animationMethods:play()
if blending[self] then
local state=animData[self].state
if state.paused then
state.paused=false
return self
elseif state.starting then
return self
end
animStop(self)
this.blend(self, state.time, animGetBlend(self), nil, true)
return self
elseif animData[self].blendTimeIn==0 or animGetPlayState(self) ~="STOPPED" then
return animPlay(self)
end
this.blend(self, nil, 0, nil, true)
return self
end
function animationMethods:stop()
if blending[self] then
local state=animData[self].state
if not state.starting then return self end
this.blend(self, state.time, animGetBlend(self), 0, false)
return self
elseif animData[self].blendTimeOut==0 or animGetPlayState(self)=="STOPPED" then
return animStop(self)
end
this.blend(self, nil, nil, 0, false)
return self
end
function animationMethods:pause()
if blending[self] then
animData[self].state.paused=true
return self
end
return animPause(self)
end
function animationMethods:restart(blend)
if blend then
animStop(self)
this.blend(self, nil, 0, nil, true)
elseif blending[self] then
animBlend(self, animData[self].blend)
blending[self]=nil
else
animRestart(self)
end
return self
end
function animationMethods:getBlendTime()
local data=animData[self]
return data.blendTimeIn, data.blendTimeOut
end
function animationMethods:isBlending() return not not blending[self] end
function animationMethods:getBlend() return animData[self].blend end
function animationMethods:getPlayState()
return blending[self] and (animData[self].state.paused and "PAUSED" or "PLAYING") or animGetPlayState(self)
end
function animationMethods:isPlaying()
return blending[self] and not animData[self].state.paused or animIsPlaying(self)
end
function animationMethods:isPaused()
return (not blending[self] or animData[self].state.paused) and animIsPaused(self)
end
function animationMethods:setBlendTime(time_in, time_out)
if time_in==nil then time_in=0 end
animData[self].blendTimeIn=m_max(time_in, 0)
animData[self].blendTimeOut=m_max(time_out or time_in, 0)
return self
end
function animationMethods:setBlend(weight)
if weight==nil then weight=0 end
animData[self].blend=weight
return blending[self] and self or animBlend(self, weight)
end
function animationMethods:setLength(len)
if len==nil then len=0 end
local data=animData[self]
if data.length then animNewCode(self, data.length, "") end
data.length=len> tPass and len or false
if data.length then animNewCode(self, data.length-tPass, blendCommand:format(data.triggerId)) end
return animLength(self, len)
end
function animationMethods:setPlaying(state) return state and self:play() or self:stop() end
animationMethods.blendTime=animationMethods.setBlendTime
animationMethods.blend=animationMethods.setBlend
animationMethods.length=animationMethods.setLength
animationMethods.playing=animationMethods.setPlaying
function animation_mt:__index(key)
if animationMethods[key] then
return animationMethods[key]
else
return _animationIndex(self, key)
end
end
if animationapi_mt then
local apiMethods={}
function apiMethods:getPlaying(ignore_blending)
if ignore_blending then return animapiGetPlaying(animations) end
local anims={}
for _, anim in ipairs(animations:getAnimations()) do
if anim:isPlaying() then anims[#anims+1]=anim end
end
return anims
end
function animationapi_mt:__index(key) return apiMethods[key] or _animationapiIndex(self, key) end
end
do return setmetatable(this, thismt) end
local Animation
function Animation:restart(blend) end
function Animation:getBlendTime() end
function Animation:isBlending() end
function Animation:setBlendTime(time_in, time_out) end
function Animation:blendTime(time_in, time_out) end
local AnimationAPI
function AnimationAPI:getPlaying(ignore_blending) end
