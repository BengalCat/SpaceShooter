-- Space Shooter
-- art and code by Jakub Kuleszewicz

-- Player
player = {
	x = 26,
	y = 110,
	speed = 75,
	img = {
		straight = nil,
		left = nil,
		right = nil },
	position = 'straight',
	imgDeath = {},
	deathTimerMax = 0.15,
	deathTimer = 0,
	deathFrame = 11,
	isAlive = false,
	hitbox = {
		x = 9.5,
		y = 6,
		r = 6 },
	shootSound = nil
	}
score = 0
-- Player death animation

-- Speed up of resize
gameScaleNew = gameScale

-- Background
backgroundImg = nil

-- Splash screen
splashImg = nil

-- Timers for bullets
canShoot = false
canSchootTimerMax = 0.5
canSchootTimer = canSchootTimerMax

-- Timers for enemies
createEnemyTimerMax = 1
createEnemyTimer = createEnemyTimerMax

-- Bullets
bulletImg = nil
bullets = {}

-- Enemies
enemyImg = {}
enemies = {}
enemyDeath = {}

-- Score font
scoreFont = {}

-- Colision detection with rectangle hitboxes
function CheckColision(x1, y1, w1, h1,  x2, y2, w2, h2)
	return x1 < x2 + w2 and
		   x2 < x1 + w1 and
		   y1 < y2 + h2 and
		   y2 < y1 + h1
end

-- Colision detection with circle hitboxes
function CheckColisionAlt(x1, y1, r1,  x2, y2, r2)
	return ((x1 - x2) ^ 2) + ((y1 - y2) ^ 2) <= (r1 + r2) ^ 2
end

-- Drawing score
function DrawScore(score)
	margin = 5
	letterSpacing = 1
	position = 1
	while score > 0 do
		love.graphics.draw(scoreFont[score - math.floor(score / 10) * 10], 64 - ((3 + letterSpacing) * position) - margin, margin)
		score = math.floor(score / 10)
		position = position + 1
	end
end

function love.load(arg)
	love.graphics.setDefaultFilter('nearest', 'nearest')

	player.img.straight = love.graphics.newImage('assets/Ship.png')
	player.img.left = love.graphics.newImage('assets/ShipLeft.png')
	player.img.right = love.graphics.newImage('assets/ShipRight.png')
	backgroundImg = love.graphics.newImage('assets/Background.png')
	splashImg = love.graphics.newImage('assets/Splash.png')
	bulletImg = love.graphics.newImage('assets/Bullet.png')
	enemyImg[1] = love.graphics.newImage('assets/Enemy1.png')
	enemyImg[2] = love.graphics.newImage('assets/Enemy2.png')

	-- Load font for score
	for i = 0, 9 do
		scoreFont[i] = love.graphics.newImage('assets/ScoreFont/'..i..'.png')
	end

	-- Load player death animation
	for i = 1, 9 do
		player.imgDeath[i] = love.graphics.newImage('assets/ShipDeath/ShipDeath'..i..'.png')
	end

	-- Load enemy death animation
	for i = 1, 11 do
		enemyDeath[i] = love.graphics.newImage('assets/EnemyDeath/EnemyDeath'..i..'.png')
	end

	-- Load sounds
	player.shootSound = love.sound.newSoundData('assets/Sound/Shoot.wav')
end

function love.update(dt)
	-- Input
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end

	-- Player
	if love.keyboard.isDown('left', 'a') then
		if player.x > 0 then
			player.x = player.x - (player.speed * dt)
			player.position = 'left'
		end
	elseif love.keyboard.isDown('right', 'd') then
		if player.x < (love.graphics.getWidth() / gameScale - player.img[player.position]:getWidth()) then
			player.x = player.x + (player.speed * dt)
			player.position = 'right'
		end
	else
		player.position = 'straight'
	end

	if love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl') and canShoot then
		newBullet = {
			x = player.x + (player.img[player.position]:getWidth() / 2) - 0.5,
			y = player.y,
			speed = 50,
			hitbox = {
				x = 0.5,
				y = 1,
				r = 1 }
		}
		table.insert(bullets, newBullet)
		canShoot = false
		canSchootTimer = canSchootTimerMax
	end
	
	-- Change in scale of graphics
	if love.keyboard.isDown('1')  then
		gameScaleNew = 1
	elseif love.keyboard.isDown('2') then
		gameScaleNew = 2
	elseif love.keyboard.isDown('3') then
		gameScaleNew = 3
	elseif love.keyboard.isDown('4') then
		gameScaleNew = 4
	elseif love.keyboard.isDown('5') then
		gameScaleNew = 5
	end
	-- Update changed resolution
	if gameScaleNew ~= gameScale then
		gameScale = gameScaleNew
		love.window.setMode(64 * gameScale, 128 * gameScale)
	end

	-- Reset game state
	if not player.isAlive and love.keyboard.isDown('return') then
		-- Reset bullets and enemies
		bullets = {}
		enemies = {}

		-- Reset timers
		canSchootTimer = canSchootTimerMax
		createEnemyTimer = createEnemyTimerMax

		-- Reset player
		player.x = 26
		player.y = 110
		player.isAlive = true
		score = 0
		player.deathFrame = 1
	end

	-- Shooting timer
	canSchootTimer = canSchootTimer - (1 * dt)
	if canSchootTimer < 0 and player.isAlive then
		canShoot = true
	end

	-- Update bullets position
	for i, bullet in ipairs(bullets) do
		bullet.y = bullet.y - (bullet.speed * dt)

		if bullet.y < 0 then
			table.remove(bullets, i)
		end
	end

	-- Creating enemies timer
	createEnemyTimer = createEnemyTimer - (1 * dt)
	if createEnemyTimer < 0 and player.isAlive then
		createEnemyTimer = createEnemyTimerMax

		randomPosition = math.random(2, love.graphics.getWidth() / gameScale - 10 - (enemyImg[1]:getWidth() / 2))
		randomSpeed = math.random(5, 50)
		newEnemy = {
			x = randomPosition,
			y = -10,
			speed = randomSpeed,
			position = 1,
			animTimerMax = 0.15,
			animTimer = 0,
			isAlive = true,
			hitbox = {
				x = 3.5,
				y = 10,
				r = 3
			}
		}
		table.insert(enemies, newEnemy)
	end

	-- Update enemy position, animation and check for colision
	for i, enemy in ipairs(enemies) do
		-- Animation
		enemy.animTimer = enemy.animTimer - (1 * dt)
		if enemy.animTimer <= 0 then
			enemy.animTimer = enemy.animTimerMax
			if not enemy.isAlive then
				if enemy.position < 11 then
					enemy.position = enemy.position + 1
				else
					table.remove(enemies, i)
				end
			else
				if enemy.position == 1 then
					enemy.position = 2
				else
					enemy.position = 1
				end

			end
		end
		-- Position
		enemy.y = enemy.y + (enemy.speed * dt)
		if enemy.y > 150 then
			table.remove(enemies, i)
		end
		-- Colision with bullet
		for j, bullet in ipairs(bullets) do
			if CheckColisionAlt(enemy.x + enemy.hitbox.x, enemy.y + enemy.hitbox.y, enemy.hitbox.r,  bullet.x + bullet.hitbox.x, bullet.y + bullet.hitbox.y, bullet.hitbox.r) and enemy.isAlive then
				enemy.isAlive = false
				enemy.position = 1
				enemy.speed = 0
				table.remove(bullets, j)
				score = score + 1
			end
		end

		-- Enemy with player
		if CheckColisionAlt(enemy.x + enemy.hitbox.x, enemy.y + enemy.hitbox.y, enemy.hitbox.r,  player.x + player.hitbox.x, player.y + player.hitbox.y, player.hitbox.r) 
		and player.isAlive and enemy.isAlive then
			enemy.isAlive = false
			player.isAlive = false
		end
	end

	-- Player death animation
	if not player.isAlive and player.deathFrame < 11 then
		player.deathTimer = player.deathTimer + (1 * dt)
		if player.deathTimer > player.deathTimerMax then
			player.deathFrame = player.deathFrame + 1
			player.deathTimer = 0
		end
	end
end

function love.draw(dt)
	love.graphics.scale(gameScale, gameScale)
	love.graphics.draw(backgroundImg)
	for i, bullet in ipairs(bullets) do
		love.graphics.draw(bulletImg, bullet.x, bullet.y)
	end
	for i, enemy in ipairs(enemies) do
		if enemy.isAlive then
			love.graphics.draw(enemyImg[enemy.position], enemy.x, enemy.y)
		else
			love.graphics.draw(enemyDeath[enemy.position], enemy.x - 2, enemy.y - 2)
		end
	end
	DrawScore(score)

	if player.isAlive then
		love.graphics.draw(player.img[player.position], player.x, player.y)
	else
		if player.deathFrame < 10 then
			love.graphics.draw(player.imgDeath[player.deathFrame], player.x - 4, player.y)
		end
		love.graphics.draw(splashImg, (64 - 44) / 2, (128 - 12) / 2)
	end
end
