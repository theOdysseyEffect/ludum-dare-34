local class = require 'lib.class'
local cell = require 'src.hex.cell'

function math.round(x) return
	math.floor(x + 0.5)
end

local hex = class:subclass()

local teams = {"neutral", "virus", "immune"}

function hex:init(radius, cell_size, default_hp)
	default_dmg = 1
	default_regen = 1
	default_def = 0

	self.cells = {}
	self.radius = radius
	self.cell_size = 0
  self.tcell_size = cell_size
	for x = -radius, radius do
		self.cells[x] = {}
		for z = -radius, radius do
			if hexagonal(x, -x-z, z, radius) then
				local team = "neutral"
				if x+z/2 > 7 then team = "immune" end
				if x+z/2 < -7 then team = "virus" end
				self.cells[x][z] = cell:new(self, x, -x-z, z, self.cell_size, default_hp, default_dmg, default_regen, default_def, team)
			end
		end
	end
end

function hex:draw()
	for x = -self.radius, self.radius do
		for z = -self.radius, self.radius do
			if self.cells[x][z] then
				self.cells[x][z]:draw("fill")
			end
		end
	end
end

function hex:getCell(x, y, z)
	if self.cells[x] then
		return self.cells[x][z] or {}
	else return {} end
end

function hex:hexToPixel(x, y, z)
	local xP = self.cell_size * math.sqrt(3) * (x + z/2)
	local yP = self.cell_size * 3/2 * z
	return xP, yP
end

function hex:pixelToHex(x, y)
	local q = (x * math.sqrt(3)/3 - y / 3) / self.cell_size
	local r = y * 2/3 / self.cell_size
	return self:round(q, -q-r, r)
end

function hex:inRange(x, y, z, range)
	local results = {}
	for dx = -range, range do
    	for dy = math.max(-range, -dx-range), math.min(range, -dx+range) do
        	local dz = -dx-dy
        	table.insert(results, {x=x+dx, y=y+dy, z=z+dz})
    	end
	end
	return results
end

function hex:round(x, y, z)
	local rx = math.round(x)
	local ry = math.round(y)
	local rz = math.round(z)

	local x_diff = math.abs(rx - x)
	local y_diff = math.abs(ry - y)
	local z_diff = math.abs(rz - z)

	if x_diff > y_diff and x_diff > z_diff then
		rx = -ry-rz
	elseif y_diff > z_diff then
		ry = -rx-rz
	else
		rz = -rx-ry
	end

	return rx, ry, rz
end

function hexagonal(x, y, z, r)	-- transforms numbers from -120 -> 120 to 0 -> 240
	return (math.abs(x) + math.abs(y) + math.abs(z))/2 <= r
end

function hex:update(dt)
  self.cell_size = self.cell_size + 1*dt*10
  if self.cell_size > self.tcell_size then
    self.cell_size = self.cell_size-1*dt*10
  end
end

return hex