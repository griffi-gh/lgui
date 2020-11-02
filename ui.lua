assert(love,'no love :(')

local ui = {}

local function parts(i,s)
  return string.gmatch(i..s,'(.-)'..s)
end
local function texth(f,t)
  local h=f:getHeight()
  local _,r=t:gsub('\n','')
  return h*(r+1)
end
local function textw(f,t)
  t = t:gsub('\n\r','\n')
  local m = 0
  for p in parts(t,'\n') do
    local s = f:getWidth(p)
    m = math.max(m,s)
  end
  return m
end

local function align(v,w,h,cw,ch)
  local x,y
  --align x
  if v[1]=='center' then 
    x = math.floor((w-cw)/2)
  elseif v[1]=='left' then
    x = 0
  elseif v[1]=='right' then
    x = w-cw
  else
    error('Invalid align type')
  end
  --align y
  if v[2]=='center' then
    y = math.floor((h-ch)/2)
  elseif v[2]=='top' then
    y = 0
  elseif v[2]=='bottom' then
    y = h-ch
  else
    error('Invalid align type')
  end
  --
  return x,y
end
local function defaultAlign() return {'center','center'} end

function ui.widget(c,t)
  local w = {
    position = 'relative',
    x = 0,
    y = 0,
    w = w or 'matchParent',
    margin = 2,
  }
  if type(c)=='table' then
    for i,v in pairs(c) do
      w[i]=v
    end
  end
  function w:copy(p)
    local c={}
    for i,v in pairs(self) do
      c[i]=v
    end
    for i,v in pairs(p) do
      c[i]=v
    end
    return c
  end
  w.type = t or 'widget'
  return w
end

function ui.container(p)
  local w = ui.widget(p,'container')
  
  w._bkt = {}
  w.children = {}
  w.layout = w.layout or 'vertical'
  if w.scissor==nil then w.scissor=true end
  
  --function w:getContentSize()  --TODO!
  --  
  --end
  
  function w:add(v)
    local i = #self.children+1
    self.children[i] = v
    self._bkt[v] = i
    return self
  end
  function w:remove(v)
    local i = self._bkt[v]
    self._bkt[v] = nil
    table.remove(self.children,i)
    return self
  end
  function w:removeAll()
    self.children={}
    self._bkt={}
    return self
  end
  
  return w
end

function ui.text(p)
  w = ui.widget(p,'text')
  w.text = w.text or 'Text'
  w.font = w.font or love.graphics.newFont(14)
  w.textColor = w.textColor or {1,1,1}
  w.align = w.align or defaultAlign()
  w.h = w.h or 'wrapContent'
  --
  function w:getContentSize()
    return textw(self.font,self.text),texth(self.font,self.text)
  end
  function w:draw(w,h)
    local g = love.graphics
    local pf = g.getFont()
    g.setFont(self.font)
    g.setColor(self.textColor)
    
    local i = 0
    for p in parts(self.text,'\n') do
      i = i+1
      local x,y = align(self.align, w, h, textw(self.font,p), texth(self.font,self.text))
      g.print(p,x,y+(i-1)*self.font:getHeight())
    end
    
    g.setFont(pf)
  end
  --
  return w
end

do
  local function background(v,x,y,w,h)
    if v.background then
      local g=love.graphics
      g.push()
      g.setColor(v.background)
      g.rectangle('fill',x,y,w,h)
      g.pop()
    end
  end

  local function border(v,x,y,w,h)
    if v.border then
      local g=love.graphics
      g.push()
      g.setColor(v.border.color)
      g.setLineWidth(v.border.width or 1)
      g.rectangle('line',x-.5,y-.5,w+1,h+1)
      g.pop()
    end
  end

  function ui.draw(c,k,pcx,pcy,pcw,pch)
    assert(c.type=='container','Not a container!')
    assert(k==nil or k.type=='container','Parent is not a container!')
    
    local g = love.graphics
    
    local ccx = c.x+(pcx or 0)
    local ccy = c.y+(pcy or 0)
    local ccw = pcw or c.w
    local cch = pch or c.h
    
    local wscis
    
    --local bigw,bigh=0,0
    
    g.push()
      
      if c.scissor then
        wscis={g.getScissor()}
        g.setScissor(ccx,ccy,ccw,cch)
      else
        g.setScissor()
      end
      
      background(c,ccx,ccy,ccw,cch)
      border(c,ccx,ccy,ccw,cch)
      
      local p
      local ux,uy = 0,0
      
      for i,v in ipairs(c.children) do
          local x,y = 0,0
          local w,h = v.w,v.h
          
          local ml,mr = (v.marginLeft or v.margin or 0),(v.marginRight or v.margin or 0)
          local mt,mb = (v.marginTop or v.margin or 0),(v.marginBottom or v.margin or 0)
          
          --TODO (padding)
          --local pl,pr = (v.paddingLeft or v.padding or 0),(v.paddingRight or v.padding or 0)
          --local pt,pb = (v.paddingTop or v.padding or 0),(v.paddingBottom or v.padding or 0)
           
          local cnw,cnh
          if v.getContentSize then cnw,cnh=v:getContentSize() end
          
          if w=='matchParent' then 
            w = ccw-ml-mr
          elseif h=='wrapContent' then
            w = cnw-ml-mr
          end
          
          if h=='matchParent' then 
            h = cch-mt-mb
          elseif h=='wrapContent' then
            h = cnh-mt-mb
          end
          
          if v.position=='relative' then
            x = v.x+ccx+ux+ml
            y = v.y+ccy+uy+mt
            if c.layout=='vertical' then
              uy = uy+h+mb+mt
            elseif c.layout=='horizontal' then
              ux = ux+w+mr+ml
            else
              error('Invalid layout type')
            end
          elseif v.position=='absolute' then
            x = v.x+ccx
            y = v.y+ccy
          elseif v.position=='fixed' then
            x = v.x
            y = v.y
          else
            error('Invalid position type')
          end
          if v.type=='container' then
            ui.draw(v,c,x,y,w,h)
          else
            background(v,x,y,w,h)
            border(v,x,y,w,h)
            if type(v.draw)=='function' then
              g.push()
                g.translate(x,y)
                v:draw(w,h)
              g.pop()
            end
          end
          --bigw = math.max(bigw,w+ml+mr)
          --bigh = math.max(bigh,h+mt+mb)
          p=v
      end
      if c.scissor then 
        g.setScissor(unpack(wscis))
      end
    g.pop()
    --c._cs={bigw,bigh}
  end
end

return ui