local maze, mazeList, visibleCells
local screenX,screenY,scaleX,scaleY
local gameStates={["init"]=0,["intro"]=1,["start"]=2,["over"]=3,["play"]=4, ["pit"]=5,["beforeFire"]=6,["afterFire"]=7,["hit"]=8,["miss"]=9,["gameOver"]=10,["displayMap"]=11,["levels"]=12}
local sleeping=false
local sleepTimer
local startTime
local totalTime
local pitTimer
local batShow=false
local logoY=0
local gameState
local redoFlag=false
local arrowDir
local toothY
local arrowFrames={}
local fontObj,fireTextObj
local color,colorInc=0,1
local levelChoice,blindChoice,manCursor
local man_i,man_j,caveman_i,caveman_j
local isCaveManAwake, caveManTimer
local createMazeString="Creating maze, please wait"
local dotString=""
local revcode={["1"]="w",["2"]="p",["3"]="b",["4"]="dr",["5"]="dl",["6"]="ur",["7"]="ul",["8"]="lr",["9"]="ud"}
local imgTable={}
local manImg,batImg,greenImg,brownImg,blackImg,arrowImg,toothUpImg,toothDownImg,eyeImg,logoImg,caveManImg
local rotAngle,scale
local batSound,introSound,arrowSound,winSound,eatenSound,fallingSound,moveSound,loopSound
local batPos
local isTouch, touchX,touchY,isMouse,mouseX,mouseY
local leftImg,rightImg,upImg,downImg,okImg
local dimButtons
local resizeFlag
local caveManDir
colorPathTable={["ud1"]={0,1},["ud3"]={0,-1},["lr2"]={-1,0},["lr4"]={1,0},
  ["ur1"]={1,0},["ur2"]={0,-1},["ul1"]={-1,0},["ul4"]={0,-1},
  ["dr2"]={0,1},["dr3"]={1,0},["dl3"]={-1,0},["dl4"]={0,1}}
local levelsText={{"Practice",256,64},{"Beginner",256,96},{"Amateur",256,128}
  ,{"Soldier",256,160},{"Knight",256,192},{"Hunter",256,224},{"Wizard",256,256}}
local blindText={{"Visible Maze",256,320},{"Blind Maze",256,352},{"Caveman",256,384},{"Classic Visible",256,416},{"Classic Blind",256,448},{"Classic Caveman",256,480}}
local dirs={["up"]=1,["right"]=2,["down"]=3,["left"]=4}
local checkGridArray={ {0,-1}, {1,0}, {0,1},{-1,0} }
local checkGridArrayIn={ {0,1}, {-1,0}, {0,-1},{1,0} }
local trans
local incompat={}
local level=3
local nIterations=0
local wx,wy
local numPit
local px,py={},{}
--[[trans["up"]={"dr","dl","ud"}
  trans["down"]={"ur","ul","ud"}
  trans["left"]={"dr","ur","lr"}
  trans["right"]={"dl","rl","lr"} ]]

incompat["dl"]={}  
incompat["dr"]={}
incompat["ur"]={}  
incompat["ul"]={}  
incompat["lr"]={}  
incompat["ud"]={}
incompat["b"]={}
incompat["w"]=incompat["b"]
incompat["p"]=incompat["b"]

incompat["dr"][1]={"ud","dr","dl","b"}
incompat["dr"][2]={"ud","ur","dr"}
incompat["dr"][3]={"dr","dl","lr"}
incompat["dr"][4]={"lr","ur","dr","b"}

incompat["dl"][1]={"ud","dr","dl","b"}
incompat["dl"][2]={"lr","ul","dl","b"}
incompat["dl"][3]={"lr","dl","dr"}
incompat["dl"][4]={"ud","ul","dl"}

incompat["ur"][1]={"lr","ul","ur"}
incompat["ur"][2]={"ud","ur","dr"}
incompat["ur"][3]={"ud","ur","ul","b"}
incompat["ur"][4]={"lr","ur","dr","b"}

incompat["ul"][1]={"lr","ul","ur"}
incompat["ul"][2]={"lr","ul","dl","b"}
incompat["ul"][3]={"ud","ur","ul","b"}
incompat["ul"][4]={"ud","ul","dl"}

incompat["ud"][1]={"lr","ul","ur"}
incompat["ud"][2]={"lr","ul","dl","b"}
incompat["ud"][3]={"lr","dr","dl"}
incompat["ud"][4]={"lr","ur","dr","b"}

incompat["lr"][1]={"ud","dr","dl","b"}
incompat["lr"][2]={"ud","ur","dr"}
incompat["lr"][3]={"ud","ur","ul","b"}
incompat["lr"][4]={"ud","ul","dl"}

incompat["b"][1]={"lr","ul","ur"}
incompat["b"][2]={"ud","ur","dr"}
incompat["b"][3]={"lr","dr","dl"}
incompat["b"][4]={"ud","ul","dl"}

function initTrans()
  trans={}
  trans["dr"]={}  
  trans["dl"]={}  
  trans["ur"]={}  
  trans["ul"]={}  
  trans["lr"]={}  
  trans["ud"]={}
  trans["r"]={}
  trans["g"]={}
  trans["b"]={}
  trans["w"]=trans["b"]
  trans["p"]=trans["b"]

  trans["dr"][1]=nil
  trans["dr"][2]={"dl","ul","lr","b"}
  trans["dr"][3]={"ul","ur","ud","b"}
  trans["dr"][4]=nil
  trans["dl"][1]=nil
  trans["dl"][2]=nil
  trans["dl"][3]={"ul","ur","ud","b"}
  trans["dl"][4]={"ur","dr","lr","b"}

  trans["ur"][1]={"dr","dl","ud","b"}
  trans["ur"][2]={"ul","dl","lr","b"}
  trans["ur"][3]=nil
  trans["ur"][4]=nil

  trans["ul"][1]={"dr","dl","ud","b"}
  trans["ul"][2]=nil
  trans["ul"][3]=nil
  trans["ul"][4]={"ur","dr","lr","b"}

  trans["lr"][1]=nil
  trans["lr"][2]={"ul","dl","lr","b"}
  trans["lr"][3]=nil
  trans["lr"][4]={"ur","dr","lr","b"}

  trans["ud"][1]={"dr","dl","ud","b"}
  trans["ud"][2]=nil
  trans["ud"][3]={"ur","ul","ud","b"}
  trans["ud"][4]=nil

  trans["b"][1]={"dl","dr","ud","b"}
  trans["b"][2]={"ul","dl","lr","b"}
  trans["b"][3]={"ul","ur","ud","b"}
  trans["b"][4]={"ur","dr","lr","b"}
end

function initTransClassic()
  trans={}
  trans["dr"]={}  
  trans["dl"]={}  
  trans["ur"]={}  
  trans["ul"]={}  
  trans["r"]={}
  trans["g"]={}
  trans["b"]={}
  trans["w"]=trans["b"]
  trans["p"]=trans["b"]

  trans["dr"][1]=nil
  trans["dr"][2]={"dl","ul","b"}
  trans["dr"][3]={"ul","ur","b"}
  trans["dr"][4]=nil
  trans["dl"][1]=nil
  trans["dl"][2]=nil
  trans["dl"][3]={"ul","ur","b"}
  trans["dl"][4]={"ur","dr","b"}

  trans["ur"][1]={"dr","dl","b"}
  trans["ur"][2]={"ul","dl","b"}
  trans["ur"][3]=nil
  trans["ur"][4]=nil

  trans["ul"][1]={"dr","dl","b"}
  trans["ul"][2]=nil
  trans["ul"][3]=nil
  trans["ul"][4]={"ur","dr","b"}

  trans["b"][1]={"dl","dr","b"}
  trans["b"][2]={"ul","dl","b"}
  trans["b"][3]={"ul","ur","b"}
  trans["b"][4]={"ur","dr","b"}
end


function testInsert()
  local t={}
  table.insert(t,1)
  table.insert(t,2)
  table.insert(t,3)
  repeat
    local l=table.remove(t)
    print(l)
  until #t==0
end

function initVisibleCells()
  visibleCells={}
  for i=1,8 do
    visibleCells[i]={"0","0","0","0","0","0","0","0"}
  end
end

function initMaze(rFlag)
  maze={}
  mazeList={}
  for i=1,8 do
    maze[i]={"0","0","0","0","0","0","0","0"} 
  end
  initVisibleCells()
end

function printMaze(m)
  local mz=m or maze
  for y=1,8 do
    for x=1,7 do
      io.write(mz[x][y].."-")
    end
    io.write(mz[8][y].."\n")
  end
end  

function printMazeList()
  print("########################")
  for i=1,#mazeList do
    print(i)
    printMaze(mazeList[i])
  end
  print("########################")
end

function wrapTable(x,y)
  local rx,ry
  rx=(x<1) and 8 or x
  rx=(rx>8) and 1 or rx
  ry=(y<1) and 8 or y
  ry=(ry>8) and 1 or ry
  return rx,ry
end

function checkBorderCell(x,y,c)
  for i=1,4 do
    local newX,newY=wrapTable(x+checkGridArray[i][1],y+checkGridArray[i][2])
    if (maze[newX][newY]=="b") then return true end
  end
  return false
end

function checkEmptyBorderCell(x,y)
  for i=1,4 do
    local newX,newY=wrapTable(x+checkGridArray[i][1],y+checkGridArray[i][2])
    if (maze[newX][newY]=="0") then return true end
  end
  return false
end

function checkAllFullBorderCell(x,y)
  for i=1,4 do
    local newX,newY=wrapTable(x+checkGridArray[i][1],y+checkGridArray[i][2])
    if (maze[newX][newY]=="0") then return false end
  end
  return true
end  

function checkAllEmptyBorderCell(x,y)
  for i=1,4 do
    local newX,newY=wrapTable(x+checkGridArray[i][1],y+checkGridArray[i][2])
    if (maze[newX][newY]~="0") then return false end
  end
  return true
end  


function table.simpleSearch(t, elem)
  local i=1
  if (t==nil) or (type(t)~="table") then return false end
  for k,v in pairs(t) do
    if v==elem then return i end
    i=i+1
  end
  return false
end

function table.simpleCopy(t)
  local newTable={}
  for i=1,#t do
    if (type(t[i])=="table") then
      newTable[i]=table.simpleCopy(t[i])
    else
      newTable[i]=t[i]
    end
  end
  return newTable
end

function table.simpleEqual(t1,t2)
  if (#t1~=#t2) then return false end
  for i=1,#t1 do
    if (type(t1[i])~=type(t2[i])) then return false end
    if (type(t1[i])=="table") then
      if (not table.simpleEqual(t1[i],t2[i])) then return false end 
    else
      if (t1[i]~=t2[i]) then return false end 
    end
  end
  return true
end

function getDir(incrDirTable)
  for i=1,4 do
    if (table.simpleEqual(incrDirTable,checkGridArrayIn[i])) then
      return i
    end
  end
  return nil
end

function getDir2(incrDirTable)
  for i=1,4 do
    if (table.simpleEqual(incrDirTable,checkGridArray[i])) then
      return i
    end
  end
  return nil
end


function checkCompat(newX,newY,newCel)
  for i=1,4 do
    local checkX,checkY=wrapTable(newX+checkGridArray[i][1],newY+checkGridArray[i][2])
    if (incompat[newCel][i]~=nil) then
      if table.simpleSearch(incompat[newCel][i],maze[checkX][checkY]) then return false end
    end
  end
  return true
end

function checkExistCompat()
  local existCompat=false
  for x=1,8 do
    for y=1,8 do
      if (maze[x][y]=="0") then
        for i=3,9 do
          if (checkCompat(x,y,revcode[tostring(i)])) then 
            existCompat=true
            break
          end
        end
      end
    end
  end
  return existCompat
end

function checkMazeFull()
  local fullMaze=true
  for x=1,8 do
    for y=1,8 do
      if maze[x][y]=="0" then return false,x,y end
    end
  end
  return true
end

function findRandomEmptyPosition()
  local x,y
  if checkMazeFull() then return nil,nil end
  repeat 
    x,y=math.random(1,8),math.random(1,8)
  until maze[x][y]=="0"
  return x,y
end

function findRandomFullPosition()
  local x,y
  if checkMazeFull() then return nil,nil end
  repeat 
    x,y=math.random(1,8),math.random(1,8)
  until maze[x][y]~="0"
  return x,y
end

function checkValidDirs()
  -- cerca le direzioni valide, per le quali ci sono transizioni
  local existValidDir=false
  local mazeValidDirs={}
  for i=1,8 do
    mazeValidDirs[i]={nil,nil,nil,nil,nil,nil,nil,nil} 
  end
  for x=1,8 do
    for y=1,8 do
      if (maze[x][y]~="0") then
        local currentCell=maze[x][y]
        local currentTrans=trans[currentCell]
        local validDirs={}
        for i=1,4 do
          local newX,newY=wrapTable(x+checkGridArray[i][1],y+checkGridArray[i][2])
          if (maze[newX][newY]=="0") and (currentTrans[i]~=nil) then 
            table.insert(validDirs,#validDirs+1,{i,newX,newY}) 
            if (not existValidDir) then
              existValidDir=true
            end  
          end
        end
        mazeValidDirs[x][y]=validDirs
      end
    end
  end
  if (existValidDir) then 
    return mazeValidDirs
  else
    return nil
  end  
end

function searchPosition(posList, coorTable)
  for index,v in pairs(posList) do
    if (coorTable[1]==v[1]) and (coorTable[2]==v[2]) then return true, index end
  end
  return false,nil
end

function setBatRandomPosition()
  local batX,batY
  repeat
    batX=math.random(8)
    batY=math.random(8)
  until (maze[batX][batY]~="w") and (maze[batX][batY]~="p") and (not searchPosition(batPos,{batX,batY}))
  return batX,batY
end

function moveCaveman()
  local currentCell,nextCell,new_i,new_j
  if (string.sub(maze[caveman_i][caveman_j],1,1)=="b") then
    currentCell="b"
  else
    currentCell=string.sub(maze[caveman_i][caveman_j],1,2)
  end
  local chooseRandom=false
  local chaseManFlag=false
  repeat
    if (not chooseRandom) then
      if (man_i==caveman_i) then
        if (man_j<caveman_j) then
          caveManDir=1
        else
          caveManDir=3
        end
        chaseManFlag=true
      elseif (man_j==caveman_j) then
        if (man_i<caveman_i) then
          caveManDir=4
        else
          caveManDir=2
        end
        chaseManFlag=true
      else
        chaseManFlag=false
      end
    end
    if ((chooseRandom) or (caveManDir==0) or (math.random(3)==1)) and (chaseManFlag==false) then
      caveManDir=math.random(4)
    end
    new_i,new_j=wrapTable(caveman_i+checkGridArray[caveManDir][1],caveman_j+checkGridArray[caveManDir][2])
    nextCell=maze[new_i][new_j]
    if (nextCell~="w") and (nextCell~="p") and (visibleCells[new_i][new_j]=="1") then
      if (string.sub(nextCell,1,1)=="b") then
        nextCell="b"
      else
        nextCell=string.sub(nextCell,1,2)
      end
      if (table.simpleSearch(trans[currentCell][caveManDir],nextCell)) then
        caveman_i,caveman_j=new_i,new_j
        caveManTimer=love.timer.getTime()
        break
      end
    end
    chooseRandom=true
    chaseManFlag=false
  until false
end

function startCreateMaze()
  local batX,batY
  if (level<=3) then 
    numPit=1
  else
    numPit=2
  end
  repeat
    initMaze()
    wx,wy=findRandomEmptyPosition()
    maze[wx][wy]="w"
    for i=1,numPit do
      repeat
        px[i],py[i]=findRandomEmptyPosition()
      until checkAllEmptyBorderCell(px[i],py[i])
      maze[px[i]][py[i]]="p"
    end
    table.insert(mazeList,table.simpleCopy(maze))
    render()
  until createMaze()
  for i=1,math.floor(level/2+1) do
    batX,batY=setBatRandomPosition()
    batPos[#batPos+1]={batX,batY,0}
  end
end

function createMaze()
  local nBacktrack=1
  ::retry:: repeat
  nIterations=nIterations+1
  local x,y,newX,newY
  local mazeValidDirs=checkValidDirs()
  local existCompat=checkExistCompat()
  if (not mazeValidDirs or not checkExistCompat())  then 
    break
  end
  repeat
    x,y=findRandomFullPosition()
  until (#mazeValidDirs[x][y]>0)
  local curDir
  local validDirs=mazeValidDirs[x][y]
  local currentCell=maze[x][y]
  local currentTrans=trans[currentCell]
  repeat
    local chosenDir=math.random(#validDirs)
    curDir,newX, newY=validDirs[chosenDir][1],validDirs[chosenDir][2],validDirs[chosenDir][3]

  until (maze[newX][newY]=="0") and (currentTrans[curDir]~=nil)
  local cellToCheck={}
  for i=1,#currentTrans[curDir] do
    cellToCheck[i]=currentTrans[curDir][i]
  end
  local noCellFound=false
  repeat
    if table.simpleSearch(cellToCheck,"b") then
      local posCell=table.simpleSearch(cellToCheck,"b")
      if (math.random(6)>=level) or (#cellToCheck==1) then
        nextCel="b"
        if checkCompat(newX,newY,nextCel) then 
          break
        else
          table.remove(cellToCheck,posCell)
        end  
      end  
    end
    if (#cellToCheck>0) then
      try=math.random(#cellToCheck)
      nextCel=cellToCheck[try]
      table.remove(cellToCheck,try)
      if (not checkCompat(newX,newY,nextCel)) and (#cellToCheck==0) then noCellFound=true end
    else
      noCellFound=true
    end
  until checkCompat(newX,newY,nextCel) or (#cellToCheck==0)
  if (noCellFound) then 
    if (#mazeList==1) then
      return false
    else
      break
    end
  else
    maze[newX][newY]=nextCel
    mazeList[#mazeList+1]=table.simpleCopy(maze)
  end  
until false 
if (checkMazeFull()) then 
  return true
else
  for i=1,nBacktrack do
    table.remove(mazeList)
    if (#mazeList==1) then break end
  end
  if (#mazeList==1) then return false end
  maze=table.simpleCopy(mazeList[#mazeList])
  nBacktrack=nBacktrack+1
  goto retry
end  
end  

function followPathAndColor(x,y,dir,color,stop)
  local numB=0
  local incX,incY
  local loopCheck=0
  repeat
    if (maze[x][y]=="w") or (maze[x][y]=="p") then
      break
    elseif (string.sub(maze[x][y],1,1)=="b")  then 
      if not string.find(maze[x][y],color) then maze[x][y]=maze[x][y]..color end
      if (stop==0) then
        local x0,y0=x,y
        for i=1,4 do
          x,y=wrapTable(x0+checkGridArrayIn[i][1],y0+checkGridArrayIn[i][2])
          followPathAndColor(x,y,i,color,1)
        end
        break
      else
        break
      end
    else
      if (colorPathTable[string.sub(maze[x][y],1,2)..tostring(dir)]==nil) then 
        break 
      end
      incX, incY=colorPathTable[string.sub(maze[x][y],1,2)..tostring(dir)][1],colorPathTable[string.sub(maze[x][y],1,2)..tostring(dir)][2]
      if not string.find(maze[x][y],color) then maze[x][y]=maze[x][y]..color end
      x,y=wrapTable(x+incX,y+incY)
      dir=getDir({incX,incY})
    end
    loopCheck=loopCheck+1
    if (loopCheck>=64) then break end 
  until false
end

-- Parte dal wumpus e dalla palude, e colora le celle adiacenti
function colorMaze()
  local sx,sy,cx,cy
  sx,sy=wx,wy
  for i=1,4 do
    cx,cy=wrapTable(sx+checkGridArrayIn[i][1],sy+checkGridArrayIn[i][2])
    followPathAndColor(cx,cy,i,"W",0)
  end
  for k=1,numPit do
    sx,sy=px[k],py[k]
    for i=1,4 do
      cx,cy=wrapTable(sx+checkGridArrayIn[i][1],sy+checkGridArrayIn[i][2])
      followPathAndColor(cx,cy,i,"P",1)
    end
  end
end

function setManBatRandomPosition()
  repeat  
    i=math.random(8)
    j=math.random(8)
  until (not string.match(maze[i][j],"[wp]"))
  return i,j
end

function setManRandomPosition()
  repeat  
    i=math.random(8)
    j=math.random(8)
  until (not string.match(maze[i][j],"[wpWP]"))
  return i,j
end

function drawAllMaze()
  love.graphics.setColor(1,1,1,0.25)
  love.graphics.rectangle( "fill", 60*scaleX, 60*scaleY-8*scaleY, 520*scaleX, 520*scaleY, 8*scaleX, 8*scaleY) 
  love.graphics.setColor(1,1,1,1)
  for i=1,8 do
    for j=1,8 do
      love.graphics.draw(imgTable[maze[i][j]],((i-1)*64+64)*scaleX,((j-1)*64+56)*scaleY,0,4*scaleX,4*scaleY)
      if searchPosition(batPos,{i,j}) then
        love.graphics.draw(batImg,(i*64+16)*scaleX,(j*64-16)*scaleY-8*scaleY,0,2*scaleX,2*scaleY)
      end
      if (caveman_i==i) and (caveman_j==j) and (blindChoice %3 ==0) then 
        love.graphics.draw(caveManImg,(i*64+16)*scaleX,(j*64)*scaleY-8*scaleY,0,2*scaleX,2*scaleY)
      end
    end
  end
end

function drawMaze()
  love.graphics.setColor(1,1,1,0.25)
  love.graphics.rectangle( "fill", 60*scaleX, 60*scaleY-8*scaleY, 520*scaleX, 520*scaleY, 8*scaleX, 8*scaleY) 
  love.graphics.setColor(1,1,1,1)
  for i=1,8 do
    for j=1,8 do
      if (visibleCells[i][j]=="1") and ((blindChoice==1) or (blindChoice % 3 ==0) or (blindChoice==4) or ((man_i==i) and (man_j==j))) then
        love.graphics.draw(imgTable[maze[i][j]],((i-1)*64+64)*scaleX,((j-1)*64+56)*scaleY,0,4*scaleX,4*scaleY)
        if searchPosition(batPos,{i,j}) then
          love.graphics.draw(batImg,(i*64+16)*scaleX,(j*64-16)*scaleY-8*scaleY,0,2*scaleX,2*scaleY)
        end
        if (caveman_i==i) and (caveman_j==j) and (blindChoice % 3==0) then 
          if (isCaveManAwake==false) then
            love.graphics.setColor(math.random(255)/255,math.random(255)/255,math.random(255)/255,1)
          end
          love.graphics.draw(caveManImg,(i*64+16)*scaleX,(j*64)*scaleY-8*scaleY,0,2*scaleX,2*scaleY)
          love.graphics.setColor(1,1,1,1)
        end
      end  
    end
  end
end

function drawTime()
  if (startTime) then
    love.graphics.printf(string.format("Time: %07.2f",love.timer.getTime()-startTime),0,16*scaleY,(screenX/2)/scaleX,"center",0,2*scaleX,2*scaleY)
  end
end
     

function drawMan()
  love.graphics.draw(manImg,(man_i*64+16)*scaleX,(man_j*64+16)*scaleY,0,2*scaleX,2*scaleY)
end

function drawManFalling()
  for j=1,man_j do
    love.graphics.draw(blackImg,man_i,j,0,2*scaleX,2*scaleY)
  end  
  love.graphics.draw(manImg,man_i,man_j,3.14,2*scaleX,2*scaleY,16,16)
end

function drawPit()
  for i=1,10 do
    for j=i,40 do
      love.graphics.draw(brownImg,(i-1)*16*scaleX,(j-1)*16*scaleY,0,scaleX,scaleY)
    end
  end
  for i=40,31,-1 do
    for j=40-i+1,40 do
      love.graphics.draw(brownImg,(i-1)*16*scaleX,(j-1)*16*scaleY,0,scaleX,scaleY)
    end
  end
  for i=11,30 do
    for j=21,40 do
      love.graphics.draw(greenImg,(i-1)*16*scaleX,(j-1)*16*scaleY,0,scaleX,scaleY)
    end
  end
end        

function checkBatPosition()
  local found,pos=searchPosition(batPos,{man_i,man_j})
  if found and (not sleeping) and (batPos[pos][3]==1) then
    if (batShow==true) then
      batShow=false
      batPos[pos][1],batPos[pos][2],batPos[pos][3]=setBatRandomPosition(),1
      man_i,man_j=setManBatRandomPosition()
      visibleCells[man_i][man_j]="1"
    elseif (not batShow) then
      sleeping=true
      sleepTimer=2.0
      love.audio.play(batSound)
      batShow=true
    end
  end
end

function convertCoordIntoButton(x,y)
  local button=nil
  if (y>(screenY-dimButtons*4)) then
    if (x>dimButtons) and (x<dimButtons*5) then
      button="up"
    elseif (x>dimButtons*6) and (x<dimButtons*10) then
      button="down"
    elseif (x>screenX-dimButtons*10) and (x<screenX-dimButtons*6) then
      button="left"
    elseif (x>screenX-dimButtons*5) and (x<(screenX-dimButtons)) then
      button="right"
    elseif (x>(screenX/2-dimButtons*2)) and (x<(screenX/2+dimButtons*2)) then
      button="ok"
    end
  end
  return button
end

function playSound(sound)
   if (love.audio.getActiveSourceCount()>0) then
     love.audio.stop()
   end
   love.audio.play(sound)
end

function love.load()
  math.randomseed(os.time())
  fontObj=love.graphics.newFont(32,"normal")
  fireTextObj=love.graphics.newText(fontObj,"Press one arrow key to fire!")
  for k,v in pairs(revcode) do
    if (v=="p") or (v=="w") then
      imgTable[v]=love.graphics.newImage(v..".png")
    else
      imgTable[v]=love.graphics.newImage(v..".png")
      imgTable[v.."W"]=love.graphics.newImage(v.."W.png")
      imgTable[v.."P"]=love.graphics.newImage(v.."P.png")
      imgTable[v.."WP"]=love.graphics.newImage(v.."WP.png")
    end
  end
  manImg=love.graphics.newImage("man.png")
  caveManImg=love.graphics.newImage("caveman.png")
  batImg=love.graphics.newImage("bat.png")
  greenImg=love.graphics.newImage("green.png")
  brownImg=love.graphics.newImage("brown.png")
  blackImg=love.graphics.newImage("black.png")
  arrowImg=love.graphics.newImage("arrow.png")
  toothUpImg=love.graphics.newImage("tooth_up.png")
  toothDownImg=love.graphics.newImage("tooth_down.png")
  logoImg=love.graphics.newImage("logo_luampus.png")
  eyeImg=love.graphics.newImage("eye.png")
  upImg=love.graphics.newImage("arrow_up.png")
  downImg=love.graphics.newImage("arrow_down.png")
  leftImg=love.graphics.newImage("arrow_left.png")
  rightImg=love.graphics.newImage("arrow_right.png")
  okImg=love.graphics.newImage("ok.png")
  dimButtons=(okImg:getDimensions())
  local arrowQuad1=love.graphics.newQuad(0,0,128,128,arrowImg:getDimensions())
  local arrowQuad2=love.graphics.newQuad(128,0,128,128,arrowImg:getDimensions())
  local arrowQuad3=love.graphics.newQuad(256,0,128,128,arrowImg:getDimensions())
  local arrowQuad4=love.graphics.newQuad(384,0,128,128,arrowImg:getDimensions())
  arrowFrames={ arrowQuad1,arrowQuad2,arrowQuad3,arrowQuad4}
  batSound=love.audio.newSource("batsound.ogg","static")
  introSound=love.audio.newSource("intro.ogg","stream")
  winSound=love.audio.newSource("winsound.ogg","stream")
  arrowSound=love.audio.newSource("arrowsound.ogg","stream")
  eatenSound=love.audio.newSource("eaten.ogg","stream")
  fallingSound=love.audio.newSource("falling.ogg","stream")
  moveSound=love.audio.newSource("move.ogg","static")
  loopSound=love.audio.newSource("loop.ogg","stream")
  logoY=-512
  gameState=gameStates["init"]
end

function manageLevelsInput(code)
  if (code=="up") then
    manCursor=manCursor-1
    love.audio.play(moveSound)
    if (manCursor<1) then manCursor=#levelsText+#blindText end
  elseif (code=="down") then
    manCursor=manCursor+1
    love.audio.play(moveSound)
    if (manCursor>(#levelsText+#blindText)) then manCursor=1 end
  elseif (code=="return") or (code=="ok") then
    love.audio.play(moveSound)
    if (manCursor<=#levelsText) then
      levelChoice=manCursor
    else
        blindChoice=manCursor-#levelsText
    end
  elseif (code=="space") or (code=="right") then
    love.audio.play(moveSound)
    gameState=gameStates["start"]
    level=levelChoice
    if (blindChoice>3) then
      initTransClassic()
    else
      initTrans()
    end
  elseif (code=="left") then
       gameState=gameStates["init"]
       logoY=-512
  end
end

function managePlayInput(code)
local currentCell
    local newCell
    local firstChar=string.sub(maze[man_i][man_j],1,1)
    if (firstChar=="b") then
      currentCell=firstChar
    else
      currentCell=string.sub(maze[man_i][man_j],1,2)
    end
    if (code=="up") then
      new_i,new_j=wrapTable(man_i,man_j-1)
      local newFirstChar=string.sub(maze[new_i][new_j],1,1)
      if (newFirstChar=="b") or (newFirstChar=="w") or (newFirstChar=="p") then
        newCell="b"
      else
        newCell=string.sub(maze[new_i][new_j],1,2)
      end
      if (table.simpleSearch(trans[currentCell][1],newCell)) then
        local found, pos=searchPosition(batPos,{man_i,man_j})
        if (found) then batPos[pos][3]=1 end
        man_i,man_j=new_i,new_j
        visibleCells[man_i][man_j]="1"
        love.audio.play(moveSound)
      end
    elseif (code=="right") then
      new_i,new_j=wrapTable(man_i+1,man_j)
      local newFirstChar=string.sub(maze[new_i][new_j],1,1)
      if (newFirstChar=="b") or (newFirstChar=="w") or (newFirstChar=="p") then
        newCell="b"
      else
        newCell=string.sub(maze[new_i][new_j],1,2)
      end
      if (table.simpleSearch(trans[currentCell][2],newCell)) then
        local found, pos=searchPosition(batPos,{man_i,man_j})
        if (found) then batPos[pos][3]=1 end
        man_i,man_j=new_i,new_j
        visibleCells[man_i][man_j]="1"
        love.audio.play(moveSound)
      end
    elseif (code=="down") then
      new_i,new_j=wrapTable(man_i,man_j+1)
      local newFirstChar=string.sub(maze[new_i][new_j],1,1)
      if (newFirstChar=="b") or (newFirstChar=="w") or (newFirstChar=="p") then
        newCell="b"
      else
        newCell=string.sub(maze[new_i][new_j],1,2)
      end
      if (table.simpleSearch(trans[currentCell][3],newCell)) then
        local found, pos=searchPosition(batPos,{man_i,man_j})
        if (found) then batPos[pos][3]=1 end
        man_i,man_j=new_i,new_j
        visibleCells[man_i][man_j]="1"
        love.audio.play(moveSound)
      end
    elseif (code=="left") then
      new_i,new_j=wrapTable(man_i-1,man_j)
      local newFirstChar=string.sub(maze[new_i][new_j],1,1)
      if (newFirstChar=="b") or (newFirstChar=="w") or (newFirstChar=="p") then
        newCell="b"
      else
        newCell=string.sub(maze[new_i][new_j],1,2)
      end
      if (table.simpleSearch(trans[currentCell][4],newCell)) then
        local found, pos=searchPosition(batPos,{man_i,man_j})
        if (found) then batPos[pos][3]=1 end
        man_i,man_j=new_i,new_j
        visibleCells[man_i][man_j]="1"
        love.audio.play(moveSound)
      end
    elseif (code=="space") or (code=="ok") then
      gameState=gameStates["beforeFire"]
    end
end
  
function manageBeforeFireInput(code)
if (code=="up") or (code=="down") or (code=="left") or (code=="right") then
      gameState=gameStates["firing"]
      playSound(arrowSound)
      arrowDir=dirs[code]
      if (arrowDir==1) then
        arrowX,arrowY=320*scaleX,640*scaleY
      elseif (arrowDir==2) then  
        arrowX,arrowY=0,320*scaleY
      elseif (arrowDir==3) then  
        arrowX,arrowY=320*scaleX,0
      elseif (arrowDir==4) then  
        arrowX,arrowY=640*scaleX,320*scaleY
      end  
    end
  end
  
function manageGameOverInput(code)
  if code~=nil then
    if (string.upper(code)=="M" or code=="down" ) then
        gameState=gameStates["displayMap"]
    elseif (string.upper(code)=="L" or code=="ok") then
        gameState=gameStates["levels"]
    elseif (string.upper(code)=="N" or code=="up") then
        redoFlag=false
        gameState=gameStates["start"]
    elseif (string.upper(code)=="R" or code=="left") then
        redoFlag=true
        gameState=gameStates["start"]
    elseif (string.upper(code)=="Q" or code=="right") then
        love.event.quit()
    end
  end
end

function manageDisplayMapInput(code)
  if (code=="space") or (code=="ok") then
    redoFlag=false
    gameState=gameStates["levels"]
  end
end

function manageIntroInput(code)
  if (logoY==0) then
    if (code=="space") or (code=="click") then
      gameState=gameStates["levels"]
      levelChoice=1
      blindChoice=1
      manCursor=1
    end
  end  
end

function love.resize(w, h)
  resizeFlag=true
  if (w<h) then
    screenX=w
    screenY=h
  else
    screenX=h
    screenY=w
  end  
  scaleX=screenX/640
  scaleY=screenY/640
  love.window.setMode(w,h,{resizable = false,vsync = true})
end

function love.update(dt)
  if (sleeping) then
    sleepTimer=sleepTimer-dt
    if (sleepTimer<=0) then sleeping=false end
  elseif (gameState==gameStates["init"]) then
    resizeFlag=false
    love.window.setMode(640,640,{resizable = false,vsync = true}) 
    if (not resizeFlag) then
      screenX,screenY=love.graphics.getDimensions()
      scaleX=screenX/640
      scaleY=screenY/640
    end
    playSound(eatenSound)
    gameState=gameStates["intro"]
  elseif (gameState==gameStates["intro"]) then  
    if isMouse then manageIntroInput("click") end
  elseif (gameState==gameStates["levels"]) and (isMouse) then
    sleeping=true
    sleepTimer=0.2
    local button=convertCoordIntoButton(mouseX,mouseY)
    manageLevelsInput(button)
  elseif (gameState==gameStates["start"]) then
    love.graphics.setColor(255,255,255,255)
    if (not redoFlag) then
      batPos={}
      startCreateMaze()
      colorMaze()
    else
      for i=1,#batPos do
        batPos[i][3]=0
      end
      initVisibleCells()
    end
    man_i,man_j=setManRandomPosition()
    if (blindChoice % 3 ==0) then
      repeat
        caveman_i,caveman_j=setManRandomPosition()
      until (caveman_i~=man_i) or (caveman_j~=man_j)
      isCaveManAwake=false
      caveManTimer=nil
    end
    caveManDir=0
    visibleCells[man_i][man_j]="1"
    gameState=gameStates["play"]
    startTime=love.timer.getTime()
    playSound(introSound)
  elseif (gameState==gameStates["play"]) then
    if (startTime==nil) then  end
    checkBatPosition()
    if (maze[man_i][man_j]=="p") then
      gameState=gameStates["pit"]
      man_i=(screenX/2)
      man_j=0
      pitTimer=0.5
      playSound(fallingSound)
      return
    elseif (maze[man_i][man_j]=="w") then
      gameState=gameStates["miss"]
      playSound(eatenSound)
      return
    elseif (blindChoice % 3==0) and (man_i==caveman_i) and (man_j==caveman_j) then
      if (caveManTimer==nil) then caveManTimer=love.timer.getTime() end
      if (isCaveManAwake) then
        gameState=gameStates["miss"]
        playSound(eatenSound)
        return
      end
    end
    if (blindChoice % 3==0) then
      if (not isCaveManAwake) and (caveManTimer~=nil) then
        if (love.timer.getTime()-caveManTimer)>3 then isCaveManAwake=true end
      end
      if (isCaveManAwake) and ((love.timer.getTime()-caveManTimer)>1) then moveCaveman() end
    end
    if (isMouse) and (not sleeping) then
      sleeping=true
      sleepTimer=0.2
      local button=convertCoordIntoButton(mouseX,mouseY)
      managePlayInput(button)
    end
  elseif (gameState==gameStates["beforeFire"]) then
    if (love.audio.getActiveSourceCount()==0) then
      playSound(loopSound)
    end
    if (isMouse) then
      sleeping=true
      sleepTimer=0.2
      local button=convertCoordIntoButton(mouseX,mouseY)
      manageBeforeFireInput(button)
    end
  elseif (gameState==gameStates["afterFire"]) then
    local hitX,hitY=wrapTable(man_i+checkGridArray[arrowDir][1],man_j+checkGridArray[arrowDir][2])
    if (maze[hitX][hitY]=="w") then
      gameState=gameStates["hit"]
      rotAngle=0
      scale=2*math.min(scaleX,scaleY)
      totalTime=love.timer.getTime()-startTime
      playSound(winSound)
    else
      gameState=gameStates["miss"]
      playSound(eatenSound)
    end  
  elseif (gameState==gameStates["gameOver"]) then
    if (isMouse) then
      sleeping=true
      sleepTimer=0.2
      local button=convertCoordIntoButton(mouseX,mouseY)
      manageGameOverInput(button)
    end
  elseif (gameState==gameStates["displayMap"]) then
    if (isMouse) then
      sleeping=true
      sleepTimer=0.2
      local button=convertCoordIntoButton(mouseX,mouseY)
      manageDisplayMapInput(button)
    end
  end
end

function love.keypressed( key, scancode, isrepeat )
  if (sleeping) then
    return
  elseif (gameState==gameStates["intro"]) then
    if (logoY==0) then manageIntroInput(scancode) end
  elseif (gameState==gameStates["levels"]) then
    manageLevelsInput(scancode)
  elseif (gameState==gameStates["play"]) then
    managePlayInput(scancode)
  elseif (gameState==gameStates["beforeFire"]) then
    manageBeforeFireInput(scancode)
  elseif (gameState==gameStates["gameOver"]) then
    manageGameOverInput(scancode)
  elseif (gameState==gameStates["displayMap"]) then
    manageDisplayMapInput(scancode)
  end    
end

function love.draw()
  if (gameState==gameStates["levels"]) or (gameState==gameStates["play"]) or (gameState==gameStates["beforeFire"]) or (gameState==gameStates["gameOver"]) or (gameState==gameStates["displayMap"]) then 
    love.graphics.draw(upImg,dimButtons,screenY-dimButtons*4,0,4,4)
    love.graphics.draw(downImg,dimButtons*2+dimButtons*4,screenY-dimButtons*4,0,4,4)
    love.graphics.draw(leftImg,screenX-dimButtons*8-dimButtons*2,screenY-dimButtons*4,0,4,4)
    love.graphics.draw(rightImg,screenX-dimButtons*4-dimButtons,screenY-dimButtons*4,0,4,4)
    love.graphics.draw(okImg,screenX/2,screenY-dimButtons*2,0,4,4,8,8)
  end
  local touches=love.touch.getTouches()
  if (#touches>0) then
    isTouch=true
    for i,id in ipairs(touches) do
      touchX,touchY=love.touch.getPosition(id)
      -- love.graphics.circle("fill", touchX, touchY, 10)
    end
  else
    isTouch=false
  end
  if love.mouse.isDown(1) then
    isMouse=true
    mouseX,mouseY=love.mouse.getX(),love.mouse.getY()
    -- love.graphics.circle("fill", mouseX, mouseY, 10,10)
  else
    isMouse=false
  end
  if (gameState==gameStates["intro"]) then
    if (logoY<0) then
      love.graphics.draw(logoImg,screenX/2,logoY,0,2*scaleX,2*scaleY,128,0)
      logoY=logoY+2
    else
      love.graphics.draw(logoImg,screenX/2,0,0,2*scaleX,2*scaleY,128,0)
      love.graphics.setColor(1,0,0,1)
      love.graphics.printf("Hunt The Luampus",0,(screenY/2)+16*scaleY,screenX/(2*scaleX),"center",0,2*scaleX,2*scaleY)
      love.graphics.setColor(0,1,1,1)
      love.graphics.printf("(c)2020 by Marco Bruti",0,screenY/2+60*scaleY,screenX/(1.8*scaleX),"center",0,1.8*scaleX,1.8*scaleY)
      love.graphics.printf("Texasoft Reloaded",0,screenY/2+100*scaleY,screenX/(1.8*scaleX),"center",0,1.8*scaleX,1.8*scaleY)
      love.graphics.printf("Version 1.3",0,screenY/2+140*scaleY,screenX/(1.5*scaleX),"center",0,1.5*scaleX,1.5*scaleY)
      love.graphics.setColor(1,1,0,1)
      love.graphics.printf("Press <SPACE/Touch> to start...",0,screenY/2+240*scaleY,screenX/(2*scaleX),"center",0,2*scaleX,2*scaleY)
      love.graphics.setColor(1,1,1,1)
    end
  elseif (gameState==gameStates["start"]) then  
    if (string.len(dotString)<5) then 
      dotString=dotString.."."
    else
      dotString=""
    end
    love.graphics.print(createMazeString..dotString,160*scaleX,320*scaleY,0,2*scaleX,2*scaleY)
  elseif (gameState==gameStates["levels"]) then
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf("Choose Game Level",0,16*scaleY,(screenX/2)/scaleX,"center",0,2*scaleX,2*scaleY)
    love.graphics.setColor(1,0,0,1)
    for i=1,#levelsText do
      love.graphics.print(levelsText[i][1],levelsText[i][2]*scaleX,levelsText[i][3]*scaleY,0,2,2)
    end
    love.graphics.setColor(0,1,0,1)
    for i=1,#blindText do
      love.graphics.print(blindText[i][1],blindText[i][2]*scaleX,blindText[i][3]*scaleY,0,2,2)
    end
    love.graphics.setColor(0,1,1,1)
    love.graphics.printf("Press Enter/OK to Select, Space/Right To Finish",0,560*scaleY-16*scaleY,(screenX/2)/scaleX,"center",0,2*scaleX,2*scaleY)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(imgTable["w"],224*scaleX,levelsText[levelChoice][3]*scaleY,0,2*scaleX,2*scaleY)
    love.graphics.draw(imgTable["w"],224*scaleX,blindText[blindChoice][3]*scaleY,0,2*scaleX,2*scaleY)
    if (manCursor<=#levelsText) then
      love.graphics.draw(manImg,192*scaleX,levelsText[manCursor][3]*scaleY,0,2*scaleX,2*scaleY)
    else
      love.graphics.draw(manImg,192*scaleX,blindText[manCursor-#levelsText][3]*scaleY,0,2*scaleX,2*scaleY)
    end
  elseif (gameState==gameStates["play"]) then
    drawTime()
    drawMaze()
    drawMan()
  elseif (gameState==gameStates["pit"]) then
    drawPit()
    drawManFalling()
    if (not sleeping) then
      if (man_j<screenY) then 
        man_j=man_j+16*scaleY
        sleeping=true
        sleepTimer=pitTimer
        if (pitTimer>0.1) then pitTimer=pitTimer-0.05 end
      else
        totalTime=nil
        gameState=gameStates["gameOver"]
      end
    end
  elseif (gameState==gameStates["beforeFire"]) then
    love.graphics.setColor(1,1,1,0.25)
    drawMaze()
    drawMan()
    drawTime()
    love.graphics.setColor(math.random(255)/255,math.random(255)/255,math.random(255)/255,1)
    love.graphics.draw(fireTextObj,screenX/2,screenY/2,0,scaleX,scaleY,fireTextObj:getWidth()/2,0)
  elseif (gameState==gameStates["firing"]) then
    if (arrowDir==1) or (arrowDir==3) then
      for i=1,10 do
        for j=1,40 do
          love.graphics.draw(brownImg,(i-1)*16*scaleX,(j-1)*16*scaleY,0,scaleX,scaleY)
        end
      end
      for i=31,40 do
        for j=1,40 do
          love.graphics.draw(brownImg,(i-1)*16*scaleX,(j-1)*16*scaleY,0,scaleX,scaleY)
        end
      end
    else
      for i=1,40 do
        for j=1,10 do
          love.graphics.draw(brownImg,(i-1)*16*scaleX,(j-1)*16*scaleY,0,scaleX,scaleY)
        end
      end
      for i=1,40 do
        for j=31,40 do
          love.graphics.draw(brownImg,(i-1)*16*scaleX,(j-1)*16*scaleY,0,scaleX,scaleY)
        end
      end
    end
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(arrowImg,arrowFrames[1],arrowX,arrowY,(arrowDir-1)*1.57,scaleX,scaleY,64,64)
    if (not sleeping) then
      if (arrowX>=0) and (arrowX<=screenX) and (arrowY>=0) and (arrowY<=screenY) then
        arrowX=arrowX+checkGridArray[arrowDir][1]*8*scaleX
        arrowY=arrowY+checkGridArray[arrowDir][2]*8*scaleY
        sleeping=true
        sleepTimer=0.1
        table.insert(arrowFrames,1,table.remove(arrowFrames,4))
      else
        gameState=gameStates["afterFire"]
      end
    end
  elseif (gameState==gameStates["miss"]) then
    if not toothY then toothY=128*scaleY end
    for i=1,10 do
      love.graphics.draw(toothDownImg,(i-1)*64*scaleX,(toothY-math.cos(3.14*(i-1)/9+1.57)*toothY/4),0,scaleX,scaleY)
      love.graphics.draw(toothUpImg,(i-1)*64*scaleX,(screenY-toothY+math.sin(3.14*(i-1)/9)*toothY/4),0,scaleX,scaleY)
    end
    love.graphics.draw(eyeImg,128*scaleX,toothY-128*scaleY,0,2*scaleX,2*scaleY)
    love.graphics.draw(eyeImg,384*scaleX,toothY-128*scaleY,0,2*scaleX,2*scaleY)
    if (not sleeping) then
      if (toothY<=280*scaleY) then
        sleeping=true
        sleepTimer=0.2
        toothY=toothY+8*scaleY
      else
        totalTime=nil
        gameState=gameStates["gameOver"]
        color=0
        colorInc=1
        toothY=nil
      end
    end
  elseif (gameState==gameStates["hit"]) then
    love.graphics.setColor(math.random(255)/255,math.random(255)/255,math.random(255)/255,1)
    love.graphics.printf("Congratulations, you made it!",0,32,(screenX/2)/scaleX,"center",0,2*scaleX,2*scaleY)
    love.graphics.draw(logoImg,screenX/2,screenY/2,rotAngle,scale,scale,128,128)
    if (not sleeping) then
      scale=scale-0.01
      if (scale<=0) then 
        love.graphics.setColor(1,1,1,1)
        gameState=gameStates["gameOver"]
      else
        rotAngle=rotAngle+0.1
        if (rotAngle>6.2) then rotAngle=0 end
        sleeping=true
        sleepTimer=0.02
      end
    end
  elseif (gameState==gameStates["gameOver"]) then
    love.graphics.setColor(255,255,255,color/255)
    if (totalTime) then 
      love.graphics.printf(string.format("Total Time = %07.2f",totalTime),0,288*scaleY,(screenX/2)/scaleX,"center",0,2*scaleX,2*scaleY)
    else
      love.graphics.printf("You lost the game, try again!",0,288*scaleY,(screenX/2)/scaleX,"center",0,2*scaleX,2*scaleY)
    end
    love.graphics.printf("<UP/N>ew <LEFT/R>edo <RIGHT/Q>uit <DOWN/M>ap <OK/L>evels",0,480*scaleY,(screenX/1.5)/scaleX,"center",0,1.5*scaleX,1.5*scaleY)
    color=color+colorInc
    if (color>255) then
      colorInc=-1
      color=255
    elseif (color<0) then
      colorInc=1
      color=0
    end
  elseif (gameState==gameStates["displayMap"]) then
    love.graphics.setColor(255,255,255,255)
    drawAllMaze()
    love.graphics.printf("Press <SPACE/OK> to exit...",0,16*scaleY,(screenX/2)/scaleX,"center",0,2*scaleX,2*scaleY)
  end
end

function render()
  love.graphics.clear(love.graphics.getBackgroundColor())
  love.graphics.origin()
	love.draw()
  love.graphics.present()
end
