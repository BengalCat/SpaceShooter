-- Configuration

function love.conf(t)
	t.title = "Space Shooter"
	t.version = "0.10.1"
	gameScale = 3
	t.window.width = 64 * gameScale
	t.window.height = 128 * gameScale
end