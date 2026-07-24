local animsList = {
    land = "landing from a great height",
}
local bbmodels = {}
local landvel = -1
local vel = 0
local oldvel = 0
function events.entity_init()
    vel = player:getVelocity().y
    oldvel = vel
end
local function tick()
    oldvel = vel
    vel = player:getVelocity().y
    if vel > landvel and oldvel < landvel and player:isOnGround() and not player:isInWater() then
        for _, path in pairs(bbmodels) do
            if path.land then path.land:play() end
        end
    end
end
local init = false
local animMT = {
    __call = function(self, ...)
        local paths = {...}
        if self.landvel ~= nil then landvel = self.landvel end
        for _, v in ipairs(paths) do
            bbmodels[#bbmodels + 1] = v
        end
        if not init then
            events.TICK:register(tick)
            init = true
        end
    end
}
return setmetatable({
    animsList = animsList
}, animMT)
