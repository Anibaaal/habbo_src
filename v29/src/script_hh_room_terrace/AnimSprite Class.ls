on construct(me)
  pAnimFrame = 0
  return(1)
  exit
end

on setData(me, tProps)
  pVisible = tProps.getAt(#visible)
  pMaxFrames = tProps.getAt(#AnimFrames)
  pAnimFrame = tProps.getAt(#startFrame)
  pStartAnim = tProps.getAt(#startFrame)
  pMember = tProps.getAt(#MemberName)
  pID = tProps.getAt(#id)
  if not voidp(tProps.getAt(#loc)) then
    pLoc = tProps.getAt(#loc)
    getThread(#room).getInterface().getRoomVisualizer().getSprById(pID).loc = pLoc
  end if
  me.setVisible(pVisible)
  exit
end

on Activate(me)
  me.delay(250, #setVisible, 1)
  exit
end

on setVisible(me, tVisible)
  pVisible = tVisible
  tVisual = getThread(#room).getInterface().getRoomVisualizer()
  if not tVisual then
    return(0)
  end if
  tVisual.getSprById(pID).visible = tVisible
  pAnimFrame = pStartAnim
  exit
end

on updateSplashs(me)
  if pVisible <> 1 then
    return(0)
  end if
  if pAnimFrame < pMaxFrames then
    tVisual = getThread(#room).getInterface().getRoomVisualizer()
    if not tVisual then
      return(0)
    end if
    tmember = member(getmemnum(pMember & pAnimFrame))
    tVisual.getSprById(pID).setMember(tmember)
    pAnimFrame = pAnimFrame + 1
  else
    me.setVisible(0)
  end if
  exit
end