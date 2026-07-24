local squassets = {}
function squassets.getFluid(eyeHeight)
  local fluid
  local B = world.getBlockState(player:getPos() + vec(0, eyeHeight or 1.5, 0))
  local submerged = B.id == "minecraft:water" or B.id == "minecraft:lava"
  if player:isInWater() then
    fluid = "WATER"
  elseif player:isInLava() then
    fluid = "LAVA"
  end
  return fluid, submerged
end
function squassets.isOnGround()
  return world.getBlockState(player:getPos():add(0, -0.1, 0)):isSolidBlock()
end
function squassets.forwardVel()
  return player:getVelocity():dot((player:getLookDir().x_z):normalize())
end
function squassets.verticalVel()
  return player:getVelocity()[2]
end
function squassets.sideVel()
  return (player:getVelocity() * matrices.rotation3(0, player:getRot().y, 0)).x
end
function squassets.getHeadRot()
  return (vanilla_model.HEAD:getOriginRot() + 180) % 360 - 180
end
function squassets.PTOC(r, theta)
  return r * math.cos(theta), r * math.sin(theta)
end
function squassets.CTOP(x, y)
  return squassets.pyth(x, y), math.atan(y / x)
end
function squassets.PTOC3(R, theta, phi)
  local r, y = squassets.PTOC(R, phi)
  local x, z = squassets.PTOC(r, theta)
  return vec(x, y, z)
end
function squassets.CTOP3(x, y, z)
  local v
  if type(x) == "Vector3" then
    v = x
  else
    v = vec(x, y, z)
  end
  local R = v:length()
  return R, math.atan2(v.z, v.x), math.asin(v.y / R)
end
function squassets.pyth(a, b)
  return math.sqrt(a ^ 2 + b ^ 2)
end
function squassets.pointInBox(point, corner1, corner2)
  if not (point and corner1 and corner2) then return false end
  return
      point.x >= corner1.x and point.x <= corner2.x and
      point.y >= corner1.y and point.y <= corner2.y and
      point.z >= corner1.z and point.z <= corner2.z
end
function squassets.inRange(lower, num, upper)
  return lower <= num and num <= upper
end
function squassets.lineargraph(x1, y1, x2, y2, t)
  local slope = (y2 - y1) / (x2 - x1)
  local inter = y2 - slope * x2
  return slope * t + inter
end
function squassets.parabolagraph(x1, y1, x2, y2, x3, y3, t)
  local denom = (x1 - x2) * (x1 - x3) * (x2 - x3)
  local a = (x3 * (y2 - y1) + x2 * (y1 - y3) + x1 * (y3 - y2)) / denom
  local b = (x3 ^ 2 * (y1 - y2) + x2 ^ 2 * (y3 - y1) + x1 ^ 2 * (y2 - y3)) / denom
  local c = (x2 * x3 * (x2 - x3) * y1 + x3 * x1 * (x3 - x1) * y2 + x1 * x2 * (x1 - x2) * y3) / denom
  return a * t ^ 2 + b * t + c
end
function squassets.sign(num)
  if num < 0 then
    return -1
  end
  return 1
end
function squassets.Vec3Dir(v)
  return vec(squassets.sign(v.x), squassets.sign(v.y), squassets.sign(v.z))
end
function squassets.Vec3Pow(v, power)
  power = power or 2
  return vec(math.pow(v.x, power), math.pow(v.y, power), math.pow(v.z, power))
end
function squassets.bbox(corner1, corner2, color)
  local dx = corner2[1] - corner1[1]
  local dy = corner2[2] - corner1[2]
  local dz = corner2[3] - corner1[3]
  squassets.pointMarker(corner1, color)
  squassets.pointMarker(corner2, color)
  squassets.pointMarker(corner1 + vec(dx, 0, 0), color)
  squassets.pointMarker(corner1 + vec(dx, dy, 0), color)
  squassets.pointMarker(corner1 + vec(dx, 0, dz), color)
  squassets.pointMarker(corner1 + vec(0, dy, 0), color)
  squassets.pointMarker(corner1 + vec(0, dy, dz), color)
  squassets.pointMarker(corner1 + vec(0, 0, dz), color)
end
function squassets.sphereMarker(pos, radius, color, colorCenter, quality)
  pos = pos or vec(0, 0, 0)
  local r = radius or 1
  quality = (quality or 1) * 10
  colorCenter = colorCenter or color
  squassets.pointMarker(pos, colorCenter)
  for i = 1, quality do
    for j = 1, quality do
      local theta = (i / quality) * 2 * math.pi
      local phi = (j / quality) * math.pi
      local x = pos.x + r * math.sin(phi) * math.cos(theta)
      local y = pos.y + r * math.sin(phi) * math.sin(theta)
      local z = pos.z + r * math.cos(phi)
      squassets.pointMarker(vec(x, y, z), color)
    end
  end
end
function squassets.line(corner1, corner2, color, density)
  local l = (corner2 - corner1):length()            
  local direction = (corner2 - corner1):normalize() 
  density = density or 10
  for i = 0, l, 1 / density do
    local pos = corner1 + direction * i 
    squassets.pointMarker(pos, color)   
  end
end
function squassets.pointMarker(pos, color)
  if type(color) == "string" then
    if color == "R" then
      color = vec(1, 0, 0)
    elseif color == "G" then
      color = vec(0, 1, 0)
    elseif color == "B" then
      color = vec(0, 0, 1)
    elseif color == "yellow" then
      color = vec(1, 1, 0)
    elseif color == "purple" then
      color = vec(1, 0, 1)
    elseif color == "cyan" then
      color = vec(0, 1, 1)
    elseif color == "black" then
      color = vec(0, 0, 0)
    else
      color = vec(1, 1, 1)
    end
  else
    color = color or vec(1, 1, 1)
  end
  particles:newParticle("minecraft:wax_on", pos):setScale(0.5):setLifetime(0):setColor(color)
end
squassets.vanillaElement = {}
squassets.vanillaElement.__index = squassets.vanillaElement
function squassets.vanillaElement:new(element, strength, keepPosition)
  local self = setmetatable({}, squassets.vanillaElement)
    self.keepPosition = keepPosition 
	if keepPosition == nil then self.keepPosition = true end
	self.element = element
	self.element:setParentType("NONE")
    self.strength = strength or 1
	self.rot = vec(0,0,0)
	self.pos = vec(0,0,0)
	self.enabled = true
  function self:disable()
    self.enabled = false
  end
  function self:enable()
    self.enabled = true
  end
	function self:toggle()
		self.enabled = not self.enabled
	end
	self.frozen = false
	function self:freeze()
		self.frozen = true
	end
	function self:unfreeze()
		self.frozen = false
	end
  function self:zero()
    self.element:setOffsetRot(0, 0, 0)
		self.element:setPos(0, 0, 0)
  end
	function self:getPos()
		return self.pos
	end
	function self:getRot()
		return self.rot
	end
  function self:render(dt, _)
    if not self.frozen then
			if self.enabled then
				local rot, pos = self:getVanilla()
				self.element:setOffsetRot(rot*self.strength)
				if self.keepPosition then
					self.element:setPos(pos)
				end
			else
				self.element:setOffsetRot(math.lerp(
					self.element:getOffsetRot(), 0, dt	
				))
				self.rot = math.lerp(self.rot, 0, dt)
				self.pos = math.lerp(self.pos, 0, dt)
			end
    end
  end
  return self
end
squassets.BERP3D = {}
squassets.BERP3D.__index = squassets.BERP3D
function squassets.BERP3D:new(stiff, bounce, lowerLimit, upperLimit, initialPos, initialVel)
  local self = setmetatable({}, squassets.BERP3D)
  self.stiff = stiff or 0.1
  self.bounce = bounce or 0.1
  self.pos = initialPos or vec(0, 0, 0)
  self.vel = initialVel or vec(0, 0, 0)
  self.acc = vec(0, 0, 0)
  self.lower = lowerLimit or { nil, nil, nil }
  self.upper = upperLimit or { nil, nil, nil }
  function self:berp(target, dt, _stiff, _bounce)
    target = target or vec(0, 0, 0)
    dt = dt or 1
    for i = 1, 3 do
      local dif = (target[i]) - self.pos[i]
      self.acc[i] = ((dif * math.min(_stiff or self.stiff, 1)) * dt) 
      self.vel[i] = self.vel[i] + self.acc[i]
      self.pos[i] = self.pos[i] + (dif * (1 - math.min(_bounce or self.bounce, 1)) + self.vel[i]) * dt
      if self.upper[i] and self.pos[i] > self.upper[i] then
        self.pos[i] = self.upper[i]
        self.vel[i] = 0
      elseif self.lower[i] and self.pos[i] < self.lower[i] then
        self.pos[i] = self.lower
        self.vel[i] = 0
      end
    end
    return self.pos
  end
  return self
end
squassets.BERP = {}
squassets.BERP.__index = squassets.BERP
function squassets.BERP:new(stiff, bounce, lowerLimit, upperLimit, initialPos, initialVel)
  local self = setmetatable({}, squassets.BERP)
  self.stiff = stiff or 0.1
  self.bounce = bounce or 0.1
  self.pos = initialPos or 0
  self.vel = initialVel or 0
  self.acc = 0
  self.lower = lowerLimit or nil
  self.upper = upperLimit or nil
  function self:berp(target, dt, _stiff, _bounce)
    dt = dt or 1
    local dif = (target or 10) - self.pos
    self.acc = ((dif * math.min(_stiff or self.stiff, 1)) * dt) 
    self.vel = self.vel + self.acc
    self.pos = self.pos + (dif * (1 - math.min(_bounce or self.bounce, 1)) + self.vel) * dt
    if self.upper and self.pos > self.upper then
      self.pos = self.upper
      self.vel = 0
    elseif self.lower and self.pos < self.lower then
      self.pos = self.lower
      self.vel = 0
    end
    return self.pos
  end
  return self
end
local _mp_getName = models.getName
local _str_lower = string.lower
local _str_find = string.find
function squassets.caseInsensitiveFind(str, pattern)
  return _str_find(_str_lower(_mp_getName(str)), pattern)
end
return squassets
