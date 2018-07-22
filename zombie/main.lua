function love.load(arg)
  sprites = {}
  sprites.player = love.graphics.newImage('sprites/player.png')
  sprites.zombie = love.graphics.newImage('sprites/zombie.png')
  sprites.bullet = love.graphics.newImage('sprites/bullet.png')
  sprites.background = love.graphics.newImage('sprites/background.png')

  player = {}
  player.x = love.graphics.getWidth()/2
  player.y = love.graphics.getHeight()/2
  player.speed = 180

  zombies = {}
  bullets = {}

  gameState = 0
  maxTime = 2
  timer = maxTime
  myFont = love.graphics.newFont(40)
  score = 0
end

function love.update(dt)
  if gameState == 1 then
    if love.keyboard.isDown("s") and player.y < love.graphics.getHeight() then
      player.y = player.y + player.speed * dt
    end

    if love.keyboard.isDown("w") and player.y > 0 then
      player.y = player.y - player.speed * dt
    end

    if love.keyboard.isDown("a") and player.x > 0 then
      player.x = player.x - player.speed * dt
    end

    if love.keyboard.isDown("d") and player.x < love.graphics.getWidth() then
      player.x = player.x + player.speed * dt
    end
  end



  for i,z in ipairs(zombies) do
    z.x = z.x + math.cos(zombie_mouse_angle(z)) * z.speed * dt
    z.y = z.y + math.sin(zombie_mouse_angle(z)) * z.speed * dt

    if distanceBetween(z.x, z.y, player.x, player.y) < 30 then
      for i,z in ipairs(zombies) do
        zombies[i] = nil
        gameState = 0
        player.x = love.graphics.getWidth()/2
        player.y = love.graphics.getHeight()/2
      end
    end
  end

  for i,b in ipairs(bullets) do
    b.x = b.x + math.cos(b.direction) * b.speed * dt
    b.y = b.y + math.sin(b.direction) * b.speed * dt
  end

  for i=#bullets,1,-1 do
    local b = bullets[i]
    if b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then
      table.remove(bullets, i)
    end
  end

  for i,z in ipairs(zombies) do
    for j,b in ipairs(bullets) do
      if distanceBetween(z.x, z.y, b.x, b.y) < 20 then
        z.dead = true
        b.dead = true
        score = score + 1
      end
    end
  end

  for i=#zombies,1,-1 do
    local z = zombies[i]
    if z.dead == true then
      table.remove(zombies, i)
    end
  end

  for i=#bullets,1,-1 do
    local b = bullets[i]
    if b.dead == true then
      table.remove(bullets,i)
    end
  end

  if gameState == 1 then
    timer = timer - dt
    if timer <= 0 then
      spawnZombie()
      maxTime = maxTime * 0.95
      timer = maxTime
    end
  end
end

function love.draw()
  love.graphics.setFont(myFont)
  love.graphics.draw(sprites.background, 0, 0)
  if gameState == 0 then
    love.graphics.printf("Click anywhere to begin!", 0, 50, love.graphics.getWidth(), "center")
  end

  love.graphics.printf("Score: " ..score, 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")
  love.graphics.draw(sprites.player, player.x, player.y, player_mouse_angle(), nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2)

  for i,z in ipairs(zombies) do
    love.graphics.draw(sprites.zombie, z.x, z.y,zombie_mouse_angle(z), nil, nil, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2)
  end

  for i,b in ipairs(bullets) do
    love.graphics.draw(sprites.bullet, b.x, b.y, nil, .5, .5, sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2)
  end
end

function player_mouse_angle()
  return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi
end

function zombie_mouse_angle(enemy)
  return math.atan2(player.y - enemy.y, player.x - enemy.x)
end

function spawnZombie()
  zombie = {}
  zombie.x = 0
  zombie.y = 0
  zombie.speed = 140
  zombie.dead = false
  local side = math.random(1, 4)

  if side == 1 then
    zombie.x = -30
    zombie.y = math.random(0, love.graphics.getHeight())
  elseif side == 2 then
    zombie.x = math.random(0, love.graphics.getWidth())
    zombie.y = -30
  elseif side == 3 then
    zombie.x = love.graphics.getWidth() + 30
    zombie.y = math.random(0, love.graphics.getHeight())
  else
    zombie.x = math.random(0, love.graphics.getWidth())
    zombie.y = love.graphics.getHeight() + 30
  end

  table.insert(zombies, zombie)
end

function spawnBullets()
  bullet = {}
  bullet.x = player.x
  bullet.y = player.y
  bullet.speed = 500
  bullet.direction = player_mouse_angle()
  bullet.dead = false

  table.insert(bullets,bullet)
end




function love.mousepressed(x, y, button, isTouch)
  if button == 1 and gameState == 1 then
    spawnBullets()
  end

  if gameState == 0 then
    gameState = 1
    maxTime = 2
    timer = maxTime
    score = 0
  end
end

function distanceBetween(x1, y1, x2, y2)
  return math.sqrt((x1 - x2)^2 + (y1 - y2)^2)
end
