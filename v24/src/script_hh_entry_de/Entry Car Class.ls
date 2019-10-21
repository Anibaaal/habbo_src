property pDirection, pSprite, pIndex, pPauseTime, pOffset, pTurnPnt

on define me, tsprite, tCounter 
  pIndex = (tCounter - 1)
  if ((tCounter mod 2) = 1) then
    tDirection = #left
  else
    tDirection = #right
  end if
  pSprite = tsprite
  pOffset = [0, 0]
  pTurnPnt = 0
  pDirection = tDirection
  me.reset()
  return TRUE
end

on reset me 
  if (random(2) = 1) then
    tmodel = "car2"
  else
    tmodel = "car_b2"
  end if
  if (pDirection = #left) then
    pSprite.castNum = getmemnum(tmodel)
    pSprite.flipH = 0
    pSprite.loc = point(798, 507)
    pOffset = [-2, -1]
    pTurnPnt = 488
  else
    pSprite.castNum = getmemnum(tmodel)
    pSprite.flipH = 1
    pSprite.loc = point(221, 505)
    pOffset = [2, -1]
    pTurnPnt = 487
  end if
  pSprite.width = pSprite.member.width
  pSprite.height = pSprite.member.height
  if (tmodel = "car2") then
    pSprite.ink = 41
    pSprite.backColor = (random(150) + 20)
  else
    pSprite.ink = 36
    pSprite.backColor = 0
  end if
  pPauseTime = ((pIndex * 30) + random(50))
end

on update me 
  if pPauseTime > 0 then
    pPauseTime = (pPauseTime - 1)
    return FALSE
  end if
  pSprite.loc = (pSprite.loc + pOffset)
  if (pSprite.locH = pTurnPnt) then
    pOffset.setAt(2, -pOffset.getAt(2))
    tMemName = pSprite.member.name
    tDirNum = integer(tMemName.getProp(#char, length(tMemName)))
    tDirNum = (not (tDirNum - 1) + 1)
    tMemName = tMemName.getProp(#char, 1, (length(tMemName) - 1)) & tDirNum
    pSprite.castNum = getmemnum(tMemName)
  end if
  if pSprite.locV > 510 then
    if (random(2) = 1) then
      tDirection = #left
    else
      tDirection = #right
    end if
    return(me.reset())
  end if
end
