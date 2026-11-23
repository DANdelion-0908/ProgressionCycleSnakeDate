local SceneManager = require("src.scenes.SceneManager")

local MapData = require("src.scenes.MapData")
local MapRenderer = require("src.systems.MapRenderer")

local World = require("src.ecs.World")
local Factory = require("src.entities.Factory")

local InputSystem = require("src.systems.InputSystem")
local MovementSystem = require("src.systems.MovementSystem")
local RenderSystem = require("src.systems.RenderSystem")

local MapScene = {}

local function get_distance_to_rectangle(x, y, rectangle)
    local closestX = math.max(
        rectangle.x,
        math.min(x, rectangle.x + rectangle.width)
    )

    local closestY = math.max(
        rectangle.y,
        math.min(y, rectangle.y + rectangle.height)
    )

    local dx = x - closestX
    local dy = y - closestY

    return math.sqrt(dx * dx + dy * dy)
end

function MapScene:setup(gameState, eventBus)
    self.gameState = gameState
    self.eventBus = eventBus
    self.map = MapData
    self.world = World.new()

    self.nearbyPoint = nil

    Factory.create_player(
        self.world,
        400,
        300
    )

    print("Dia actual:", self.gameState.day)
    print("Acciones disponibles:", self.gameState.actionsRemaining)
    print("Energia:", self.gameState.stats.energy)
    print("Estado compartido:", self.gameState ~= nil)
end

function MapScene:update(dt)
    dt = math.min(dt, 1 / 30)

    InputSystem.update(self.world)

    MovementSystem.update(
        self.world,
        dt,
        self.map.width,
        self.map.height,
        self.map
    )

    self.nearbyPoint = nil

    local players = self.world:query(
        "Player",
        "Transform"
    )

    for _, entity in ipairs(players) do
        local transform = self.world:get_component(
            entity,
            "Transform"
        )

        for _, point in ipairs(self.map.pointsOfInterest) do
            local distance = get_distance_to_rectangle(
                transform.x,
                transform.y,
                point
            )

            if distance <= 45 then
                self.nearbyPoint = point
                break
            end
        end
    end
end

function MapScene:render()
    MapRenderer.draw(self.map)

    RenderSystem.draw(self.world)

    love.graphics.setColor(1, 1, 1)

    love.graphics.print(
        "WASD / Flechas: Moverse",
        15,
        15
    )

    love.graphics.print(
        "ESC: Regresar al menu",
        15,
        35
    )

    love.graphics.print("C - Ver coleccion", 20, 80)

    love.graphics.print("P - Entrenamiento", 20, 60)

    if self.nearbyPoint then
        local message = "Viajando a: " .. self.nearbyPoint.name

        love.graphics.setColor(0, 0, 0, 0.75)

        love.graphics.rectangle(
            "fill",
            220,
            535,
            360,
            40,
            8,
            8
        )

        love.graphics.setColor(1, 1, 1)

        love.graphics.printf(
            message,
            220,
            547,
            360,
            "center"
        )
    end
end

function MapScene:keypressed(key)
    if key == "escape" then
        local MenuScene = require("src.scenes.MenuScene")
        SceneManager.change(MenuScene)
    
    elseif key == "p" then
        local ProgressionScene =
        require("src.scenes.ProgressionScene")

        SceneManager.change(ProgressionScene)
    
    elseif key == "c" then
        local CollectionScene =
        require("src.scenes.CollectionScene")

        SceneManager.change(CollectionScene)
    
    end

end

return MapScene