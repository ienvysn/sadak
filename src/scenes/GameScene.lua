local sti = require("src.lib.sti.sti")
local Car = require("src.entities.Car")
local camera = require("src.camera")
local DamageSystem = require("src.systems.DamageSystem")

local GameScene = {}

function GameScene.load()
    GameScene.map = sti("maps/test_map.lua")
    GameScene.car = Car.new(320, 240, "bajaj_100cc")
    GameScene.shakeTime = 0
end

function GameScene.update(dt)
    GameScene.car:update(dt)
    
    GameScene.checkCollisions()
    
    local mapW = GameScene.map.width * GameScene.map.tilewidth
    local mapH = GameScene.map.height * GameScene.map.tileheight
    camera.set(GameScene.car.x, GameScene.car.y, mapW, mapH)
    
    if GameScene.shakeTime > 0 then
        GameScene.shakeTime = GameScene.shakeTime - dt
        camera.offsetX = math.random(-4, 4)
        camera.offsetY = math.random(-4, 4)
    else
        camera.offsetX = 0
        camera.offsetY = 0
    end
    
    GameScene.map:update(dt)
end

function GameScene.checkCollisions()
    local carBounds = GameScene.car:getAABB()
    
    local corners = {
        {x = carBounds.left, y = carBounds.top},
        {x = carBounds.right, y = carBounds.top},
        {x = carBounds.left, y = carBounds.bottom},
        {x = carBounds.right, y = carBounds.bottom}
    }
    
    for _, corner in ipairs(corners) do
        local tx = math.floor(corner.x / 32) + 1
        local ty = math.floor(corner.y / 32) + 1
        
        if GameScene.map.layers["Buildings"] and GameScene.map.layers["Buildings"].data[ty] and GameScene.map.layers["Buildings"].data[ty][tx] then
            local tile = GameScene.map.layers["Buildings"].data[ty][tx]
            if tile and tile.properties and tile.properties.collides then
                GameScene.car.velocity = 0
                
                GameScene.car.x = GameScene.car.x - math.cos(GameScene.car.angle) * 5
                GameScene.car.y = GameScene.car.y - math.sin(GameScene.car.angle) * 5
                
                DamageSystem.applyDamage(20)
                GameScene.shakeTime = 0.2
                break
            end
        end
    end
end

function GameScene.draw()
    local sw, sh = love.graphics.getDimensions()
    local tx = math.floor(-camera.x * camera.scale + sw * 0.5 + camera.offsetX)
    local ty = math.floor(-camera.y * camera.scale + sh * 0.4 + camera.offsetY)
    
    love.graphics.setColor(1, 1, 1)
    GameScene.map:draw(tx, ty, camera.scale, camera.scale)
    
    camera.apply()
    GameScene.car:draw()
    camera.clear()
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Speed: " .. math.floor(math.abs(GameScene.car.velocity)), 10, 10)
    love.graphics.print("Condition: " .. DamageSystem.getCondition(), 10, 30)
end

return GameScene
