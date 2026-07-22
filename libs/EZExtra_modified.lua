-- + Made by Jimmy Hellp
-- + Simplified JimmyExtras (only "land") by @chmonyasik
-- + V2 for 0.1.0 and above
-- + for JimmyAnims V7 and above
-- + Thank you GrandpaScout for helping with the library stuff!
-- + Automatically compatible with GSAnimBlend for automatic smooth animation blending
-- + Also includes Manuel's Run Later script (?)

------------------------------------

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

-- If you're choosing to edit this script, don't put anything beneath the return line

return setmetatable({
    animsList = animsList
}, animMT)

