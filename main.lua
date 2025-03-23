--[[

https://github.com/EngineerSmith

This code isn't pretty, it was written in 2 hours.
The story took another 4 hours to clean up, and add all the audio.

I wasn't going to join LoveJam2025, but I had some spare time at the end of my day and came up with this
wacky ride. It's my first time creating a game in love that has no graphics par text. It was quite the ride,
I wanted to make it more engaging trying to use what sounds I had. I hope you liked it.

All audio is from various resources I've paid for in the past.
Thus you have no license to reuse to them, or distribute them, nor can I give you one.

The font is taken from Love12;
Noto-Sans is licensed under the SIL Open Font License, Version 1.1; https://openfontlicense.org/open-font-license-official-text/
https://fonts.google.com/noto/specimen/Noto+Sans

]]--

love.setDeprecationOutput(false)
local lg = love.graphics

local Text = require("slog-text")

Audio = { }

Audio.text = { }
Audio.text.typing = love.audio.newSource("typing_keystroke_single_soft_01.wav", "static")

Audio.sfx = { }
Audio.sfx.moo = love.audio.newSource("cow_2_moo_03.wav", "static")
Audio.sfx.moo:setVolume(0.7)
Audio.sfx.grass1 = love.audio.newSource("footstep_grass_walk_01.wav", "static")
Audio.sfx.grass1:setVolume(0.4)
Audio.sfx.grass2 = love.audio.newSource("footstep_grass_walk_02.wav", "static")
Audio.sfx.grass2:setVolume(0.4)
Audio.sfx.grass3 = love.audio.newSource("footstep_grass_walk_03.wav", "static")
Audio.sfx.grass3:setVolume(0.4)
Audio.sfx.emptyBag = love.audio.newSource("foley_sports_bag_movements_06.wav", "static")
Audio.sfx.emptyBag:setVolume(0.3)
Audio.sfx.pullout = love.audio.newSource("foley_jump_movement_throw_02.wav", "static")
Audio.sfx.pullout:setVolume(0.4)
Audio.sfx.pickup = love.audio.newSource("foley_object_grab_pickup_rough_04.wav", "static")
Audio.sfx.pickup:setVolume(0.4)
Audio.sfx.pop = love.audio.newSource("bubble_effect_04.wav", "static")
Audio.sfx.pop:setVolume(0.4)
Audio.sfx.fizz = love.audio.newSource("alarm_beep_clock_timer_01.wav", "static")
Audio.sfx.fizz:setVolume(0.4)
Audio.sfx.eat = love.audio.newSource("comedy_bite_creature_eating_04.wav", "static")
Audio.sfx.eat:setVolume(0.4)
Audio.sfx.grass = love.audio.newSource("bird_crows_many_call_squawk_distant_close_01.wav", "static")
Audio.sfx.grass:setVolume(0.5)
Audio.sfx.endChime = love.audio.newSource("points_ticker_bonus_score_reward_jingle_01.wav", "static")
Audio.sfx.endChime:setVolume(0.6)
Audio.sfx.wakeup = love.audio.newSource("clock_cuckoo_clock_bird_call_01.wav", "static")
Audio.sfx.wakeup:setVolume(0.3)
Audio.sfx.paint = love.audio.newSource("pencil_sketch_draw_write_squibble_02_med_03.wav", "static")
Audio.sfx.paint:setVolume(0.2)

Audio.ui = { }
Audio.ui.hover = { }
Audio.ui.hover[1] = love.audio.newSource("door_A_creak_03.wav", "static")
Audio.ui.hover[1]:setVolume(0.1)
Audio.ui.hover[2] = love.audio.newSource("door_A_creak_05.wav", "static")
Audio.ui.hover[2]:setVolume(0.1)

Audio.looping = { }
Audio.looping.wind = love.audio.newSource("wind_general_soft_low_loop_05.wav", "static")
Audio.looping.wind:setVolume(0.3)

for _, source in pairs(Audio.looping) do
  source:setLooping(true)
end

Text.configure.audio_table("Audio")
Text.configure.add_text_sound(Audio.text.typing, 0.2)

lg.setFont(lg.newFont("NotoSans-Regular.ttf", 25))

local textbox = Text.new("center", {
  font = lg.getFont(),
  color = {1,1,1,1},
  character_sound = true,
  warble = 3,
})
Text = nil

local text = require("text")

local text_index, choice = 0, nil
local timer, wait = 0, false
local inventory = { }

local finCounter = 0
local nextText
nextText = function()
  text_index = text_index + 1
  if text_index == -1 then
    text_index = #text+1
  end
  if text_index > #text then
    finCounter = finCounter + 1
    textbox:send("Fin"..string.rep(".", finCounter))
    return
  end
  local v = text[text_index]
  if type(v) == "string" then
    textbox:send(text[text_index])
  elseif type(v) == "table" then
    if v[1] == "goto" then
      text_index = v[2] - 1
      return nextText()
    elseif v[1] == "choice" then
      choice = v
      return true
    elseif v[1] == "inventory" then
      inventory[v[2]] = v[3]
      return nextText()
    elseif v[1] == "function" then
      v[2](unpack(v, 3))
      return nextText()
    elseif v[1] == "restart" then
      text_index = 0
      love.graphics.setBackgroundColor(0,0,0,1)
      return nextText()
    elseif v[1] == "has" then
      if inventory[v[2]] then
        text_index = v[3] - 1
      else
        text_index = v[4] - 1
      end
      return nextText()
    end
  end
end

local highlightedChoiceIndex = nil

local aabb = function(x, y, box)
  return box and x >= box[1] and x <= box[2] and y >= box[3] and y <= box[4]
end

local mousePressed = false
love.mousepressed = function(x, y, button)
  mousePressed = true
  if wait and choice and button == 1 then
    for i = 2, #choice do
      if aabb(x, y, choice[i].boundingBox) then
        local nextIndex = choice[i][2]
        text_index = nextIndex - 1
        choice[i][3] = true
        choice = nil
        highlightedChoiceIndex = nil
        love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
        wait = nextText()
        break
      end
    end
  end
end

love.keypressed = function(_, scancode)
  if wait and choice then
    local choiceNumber = tonumber(scancode)
    if choiceNumber and choiceNumber >= 1 and choiceNumber <= #choice - 1 then
      local nextIndex = choice[choiceNumber+1][2]
      text_index = nextIndex - 1
      choice[choiceNumber+1][3] = true
      choice = nil
      highlightedChoiceIndex = nil
      love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
      wait = nextText()
    end
  end
end

local input = function()
  local b = love.keyboard.isScancodeDown("space") or mousePressed
  mousePressed = false
  return b
end

love.update = function(dt)
  timer = timer + dt
  if text_index == 0 then
    if timer >= 2 then
      Audio.looping.wind:play()
      wait = nextText()
    end
  else
    if not wait and textbox:is_finished() then
      love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
      if input() then
        love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
        wait = nextText()
      end
    elseif not wait then
      textbox:update(dt)
    end
    mousePressed = nil
  end
end

love.draw = function()
  local ww, wh = lg.getDimensions()
  ww, wh = ww/2, wh/2
  if text_index == 0 then
    lg.setLineWidth(5)
    lg.translate(ww, wh)
    local str = "Downloading 5.216 Terabytes..."
    lg.print(str, -lg.getFont():getWidth(str)/2, 70)
    lg.translate(10,10)
    lg.rotate(2-timer)
    lg.arc('line', 'open', 0, 0, 30, 0, 4-timer)
  else
    local width, height = textbox.get.width, textbox.get.height
    local x, y = math.floor(ww-width/2), math.floor(wh-height/2)
    lg.push()
    if wait then
      lg.translate(0, -50)
    end
    textbox:draw(x, y)
    lg.pop()
    if not wait and textbox:is_finished() then
      -- draw bouncing triangle
      lg.translate(ww, wh+100+math.sin(timer*5)*5)
      lg.rotate(math.rad(90))
      lg.circle("fill", 0, 0, 10, 3)
    end
    if wait and choice then
      local choiceY = wh
      local choiceSpacing = 15 + lg.getFont():getHeight()
      for i = 2, #choice do
        local choiceText = choice[i][1]
        local choiceNumber = i - 1
        local fullText = ("[%d] %s"):format(choiceNumber, choiceText)
        local textWidth = lg.getFont():getWidth(fullText)
        local textX = math.floor(ww - textWidth/2)

        local isHighlighted = highlightedChoiceIndex == choiceNumber

        if isHighlighted then
          lg.setColor(.2,.8,.8, 1)
        elseif choice[i][3] then
          lg.setColor(.5,.5,.5, 1)
        else
          lg.setColor(1,1,1,1)
        end

        lg.print(fullText, textX, choiceY)

        choice[i].boundingBox = { textX, textX + textWidth, choiceY, choiceY + lg.getFont():getHeight() }

        choiceY = choiceY + choiceSpacing
        lg.setColor(1,1,1,1)
      end
    end
  end
end

love.mousemoved = function(x, y)
  local isnil = highlightedChoiceIndex == nil
  highlightedChoiceIndex = nil
  if wait and choice then
    for i = 2, #choice do
      if aabb(x, y, choice[i].boundingBox) then
        highlightedChoiceIndex = i - 1
        if isnil then
          Audio.ui.hover[love.math.random(1,#Audio.ui.hover)]:play()
        end
        break
      end
    end
  end
  if highlightedChoiceIndex then
    love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
  else
    love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
  end
end

-- dumb ideas
-- 1. A slider that does nothing
-- 2. A button that plays a very short, sound effect
-- 3. An endless loading bar
-- 4. A loading screen displaying a 4TB download
