local GUI = {}

function GUI.logo_screen(w, h)
   love.graphics.rectangle("line", w/2-195, h/2-57, 381, 115)
   love.graphics.rectangle("line", w/2-195, h/2-57, 381, 115)
   love.graphics.setColor(0,0,0)
   love.graphics.rectangle("fill", w/2-195, h/2-57, 381, 115)
   love.graphics.setColor(255,255,255)
   love.graphics.rectangle("line", w/2-160, h/2+50, 314, 40)
   love.graphics.rectangle("line", w/2-160, h/2+50, 314, 40)
   love.graphics.setColor(0,0,0)
   love.graphics.rectangle("fill", w/2-160, h/2+50, 314, 40)
   love.graphics.setColor(255,255,255)
   love.graphics.setFont(love.graphics.newFont(100))
   love.graphics.print("SNAKE", w/2-171, h/2-55)
   love.graphics.setFont(love.graphics.newFont(20))
   love.graphics.print("Press Space to Start", w/2-108, h/2+59)
end

function GUI.draw_field(w, h, field, sqr_size)
   for i=1, w/sqr_size do
      for j=1, h/sqr_size do
         if field[i][j] then
            love.graphics.rectangle("fill", i*sqr_size-sqr_size, j*sqr_size-sqr_size, sqr_size, sqr_size)
         end
      end
   end
end

function GUI.death_screen(w, h, score)
   love.graphics.rectangle("line", w/2-305, h/2-57, 620, 115)
   love.graphics.rectangle("line", w/2-305, h/2-57, 620, 115)
   love.graphics.setColor(0,0,0)
   love.graphics.rectangle("fill", w/2-305, h/2-57, 620, 115)
   love.graphics.setColor(255,255,255)
   love.graphics.rectangle("line", w/2-100, h/2+50, 200, 40)
   love.graphics.rectangle("line", w/2-100, h/2+50, 200, 40)
   love.graphics.setColor(0,0,0)
   love.graphics.rectangle("fill", w/2-100, h/2+50, 200, 40)
   love.graphics.setColor(255,255,255)
   love.graphics.setFont(love.graphics.newFont(100))
   love.graphics.print("Game Over", w/2-280, h/2-55)
   love.graphics.setFont(love.graphics.newFont(20))
   love.graphics.print("Score: "..score, w/2-48, h/2+59)
end

function GUI.pause_screen(w, h)
   love.graphics.rectangle("line", w/2-195, h/2-57, 381, 115)
   love.graphics.rectangle("line", w/2-195, h/2-57, 381, 115)
   love.graphics.setColor(0,0,0)
   love.graphics.rectangle("fill", w/2-195, h/2-57, 381, 115)
   love.graphics.setColor(255,255,255)
   love.graphics.rectangle("line", w/2-160, h/2+50, 314, 40)
   love.graphics.rectangle("line", w/2-160, h/2+50, 314, 40)
   love.graphics.setColor(0,0,0)
   love.graphics.rectangle("fill", w/2-160, h/2+50, 314, 40)
   love.graphics.setColor(255,255,255)
   love.graphics.setFont(love.graphics.newFont(100))
   love.graphics.print("PAUSE", w/2-170, h/2-55)
   love.graphics.setFont(love.graphics.newFont(20))
   love.graphics.print("Press Space to Resume", w/2-120, h/2+59)
end

return GUI