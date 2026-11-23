local SceneManager = require("src.scenes.SceneManager")
local ProgressionSystem = require("src.systems.ProgressionSystem")

local ProgressionScene = {}

function ProgressionScene:setup(gameState, eventBus)
    self.gameState = gameState
    self.eventBus = eventBus

    self.gameState.feedback.message = "¿Que deseas hacer hoy?"

end

function ProgressionScene:update(dt)
end

function ProgressionScene:perform_action(action)
    local success, message =
        ProgressionSystem.perform_action(self.gameState, action)

    self.message = message

    if success then
        self.eventBus:emit("action_performed", {
            action = action,
            message = message
        })

        print(message)
    end
end

function ProgressionScene:render()
    local stats = self.gameState.stats

    love.graphics.clear(0.12, 0.16, 0.20)

    love.graphics.setColor(1, 1, 1)

    love.graphics.printf(
        "ENTRENAMIENTO",
        0, 40, 800, "center"
    )

    love.graphics.printf(
        "Dia: " .. self.gameState.day,
        0, 100, 800, "center"
    )

    love.graphics.printf(
        "Acciones restantes: " .. self.gameState.actionsRemaining,
        0, 130, 800, "center"
    )

    love.graphics.printf(
        "Encanto: " .. stats.charm,
        100, 220, 600, "center"
    )

    love.graphics.printf(
        "Confianza: " .. stats.confidence,
        100, 250, 600, "center"
    )

    love.graphics.printf(
        "Energia: " .. stats.energy,
        100, 280, 600, "center"
    )

    love.graphics.printf(
        "1 - Practicar cumplidos (+2 Encanto, -1 Energia)",
        50, 370, 700, "center"
    )

    love.graphics.printf(
        "2 - Pasear por el jardin (+2 Confianza, -1 Energia)",
        50, 400, 700, "center"
    )

    love.graphics.printf(
        "3 - Descansar (+2 Energia)",
        50, 430, 700, "center"
    )

    love.graphics.printf(
        self.gameState.feedback.message,
        50, 490, 700, "center"
    )

    if ProgressionSystem.can_advance(self.gameState) then
        love.graphics.printf(
            "ENTER - Continuar a la adquisicion de cartas",
            50, 540, 700, "center"
        )
    end

    love.graphics.setColor(1, 1, 1)
end

function ProgressionScene:keypressed(key)
    if key == "1" then
        self:perform_action("compliments")

    elseif key == "2" then
        self:perform_action("garden")

    elseif key == "3" then
        self:perform_action("rest")

    elseif key == "return" then
        if ProgressionSystem.can_advance(self.gameState) then
            local CardAcquisitionScene =
                require("src.scenes.CardAcquisitionScene")

            SceneManager.change(CardAcquisitionScene)
        end

    elseif key == "escape" then
        local MapScene = require("src.scenes.MapScene")
        SceneManager.change(MapScene)
    end
end

return ProgressionScene