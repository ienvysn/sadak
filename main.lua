local GameScene = require("src.scenes.GameScene")

function love.load()
    love.graphics.setBackgroundColor(0.3, 0.5, 0.3)
    love.mouse.setVisible(false)
    love.graphics.setNewFont(16)
    GameScene.load()
end

function love.update(dt)
    GameScene.update(dt)
end

function love.draw()
    GameScene.draw()
end
