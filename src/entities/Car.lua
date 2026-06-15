local Car = {}
Car.__index = Car

local vehicles = require("src.data.vehicles")

function Car.new(x, y, vehicleType)
    local self = setmetatable({}, Car)
    self.x = x
    self.y = y
    self.angle = -math.pi / 2
    self.velocity = 0
    self.vehicleInfo = vehicles[vehicleType] or vehicles.bajaj_100cc
    self.max_speed = self.vehicleInfo.max_speed
    self.acceleration = self.vehicleInfo.acceleration
    self.friction = self.vehicleInfo.friction
    self.width = self.vehicleInfo.width
    self.height = self.vehicleInfo.height
    self.color = self.vehicleInfo.color
    self.condition = 100
    
    return self
end

function Car:update(dt)
    local accel = 0
    if love.keyboard.isDown("w") then
        accel = self.acceleration
    elseif love.keyboard.isDown("s") then
        accel = -self.acceleration * 0.5
    end
    
    self.velocity = self.velocity + accel * dt
    self.velocity = self.velocity * self.friction
    
    if self.velocity > self.max_speed then
        self.velocity = self.max_speed
    elseif self.velocity < -self.max_speed * 0.5 then
        self.velocity = -self.max_speed * 0.5
    end
    
    if math.abs(self.velocity) > 5 then
        local turnRate = self.vehicleInfo.turn_speed * dt
        local speedFactor = math.abs(self.velocity) / self.max_speed
        turnRate = turnRate * (0.5 + 0.5 * speedFactor)
        
        local dir = self.velocity > 0 and 1 or -1
        
        if love.keyboard.isDown("a") then
            self.angle = self.angle - turnRate * dir
        elseif love.keyboard.isDown("d") then
            self.angle = self.angle + turnRate * dir
        end
    end
    
    self.x = self.x + math.cos(self.angle) * self.velocity * dt
    self.y = self.y + math.sin(self.angle) * self.velocity * dt
end

function Car:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.angle)
    
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", -self.width/2, -self.height/2, self.width, self.height)
    
    love.graphics.setColor(1, 1, 0)
    love.graphics.rectangle("fill", self.width/2 - 2, -self.height/2, 4, self.height)
    
    love.graphics.pop()
end

function Car:getAABB()
    -- Calculate oriented bounds (approximate for now)
    local maxRadius = math.max(self.width, self.height) / 2
    return {
        left = self.x - maxRadius,
        right = self.x + maxRadius,
        top = self.y - maxRadius,
        bottom = self.y + maxRadius
    }
end

return Car
