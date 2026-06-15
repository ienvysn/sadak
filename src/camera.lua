local camera = {
    x = 0,
    y = 0,
    scale = 0.5,
    offsetX = 0,
    offsetY = 0
}

function camera.set(x, y, mapW, mapH)
    camera.x = x
    camera.y = y
end

function camera.apply()
    love.graphics.push()
    local sw, sh = love.graphics.getDimensions()
    love.graphics.translate(sw * 0.5, sh * 0.4)
    love.graphics.translate(camera.offsetX, camera.offsetY)
    love.graphics.scale(camera.scale)
    love.graphics.translate(-camera.x, -camera.y)
end

function camera.clear()
    love.graphics.pop()
end

return camera
