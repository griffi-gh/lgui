local ui = require'ui'

local testwidget = ui.widget{
  position = 'relative',
  w = 'matchParent',
  h = 50,
  background = {0.5,0.5,0.5},
  border = { color={1,0,0}, width=1 },
  margin = 4
}

local testwidget2 = ui.widget{
  margin = 0,
  position = 'absolute',
  x = 50,
  y = 40,
  w = 30,
  h = 40,
  background = {0,0.85,0},
  border = { color={0,0.75,0}, width=2 }
}
local testwidget3 = testwidget2:copy{w=70,x=80,y=180}

local testwidget4 = ui.text{
  w='wrapContent',
  h='wrapContent',
  text='Hiii',
  textColor={1,0,0}
}
local testwidget5 = testwidget4:copy{text='Hooo',textColor={0,1,0}}

local textw = ui.text{
  w='matchParent',
  font = love.graphics.newFont(25),
  text = 'Testing!\n66\naaaaaa',
  background={0,0,0}
}

local window = ui.container{
  background={.25,.25,.25},
  x = 10,
  y = 10,
  w = 400,
  h = 340,
}

local window2 = ui.container{
  background={0.1,0.1,0.1},
  margin = 5,
  marginTop=10,
  w = 'matchParent',
  h = 150,
  layout = 'horizontal'
}

window:add(testwidget):add(window2):add(textw) --chaining :3
window2:add(testwidget2):add(testwidget3):add(testwidget4):add(testwidget5)

function love.draw()
  local g = love.graphics
  
  g.setBackgroundColor(0.5,0.7,0.7)
  
  if love.mouse.isDown(1) then
    window.x,window.y = love.mouse.getPosition()
  end
  
  ui.draw(window)
  g.print( string.format('%sFPS (%s)',love.timer.getFPS(),math.floor(1/love.timer.getDelta())))
end



