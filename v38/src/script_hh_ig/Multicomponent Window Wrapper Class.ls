property pUpdateCounter, pSetList, pVisible, pSetIndex, pSetOrderIndex, pLocX, pLocY, pProcedureList

on construct me 
  pSetIndex = [:]
  pSetOrderIndex = []
  pSetList = [:]
  pProcedureList = [:]
  pVisible = 1
  receiveUpdate(me.getID())
  return TRUE
end

on deconstruct me 
  removeUpdate(me.getID())
  me.removeAllParts()
  return TRUE
end

on update me 
  pUpdateCounter = (pUpdateCounter + 1)
  if pUpdateCounter < 3 then
    return TRUE
  end if
  pUpdateCounter = 0
  repeat while pSetList <= undefined
    tObject = getAt(undefined, undefined)
    tObject.update()
  end repeat
  return TRUE
end

on getProperty me, tKey 
  if (tKey = #visible) then
    return(pVisible)
  else
    if (tKey = #height) then
      return(me.getWrapperProperty(#height, #max))
    else
      if (tKey = #width) then
        tSetCount = me.count(#pSetOrderIndex)
        tWidth = 0
        i = 1
        repeat while i <= tSetCount
          tWidth = (tWidth + me.getWrapperProperty(#width, #max, i))
          i = (1 + i)
        end repeat
        return(tWidth)
      end if
    end if
  end if
  return FALSE
end

on moveTo me, tLocX, tLocY 
  me.pLocX = tLocX
  me.pLocY = tLocY
  tOffsetX = 0
  tTopOffsetY = 0
  tColumnCount = me.count(#pSetOrderIndex)
  repeat while me.pSetOrderIndex <= tLocY
    tSetColumn = getAt(tLocY, tLocX)
    tOffsetY = tTopOffsetY
    tColumnMaxWidth = 0
    repeat while me.pSetOrderIndex <= tLocY
      tSetID = getAt(tLocY, tLocX)
      tSetObject = pSetList.getaProp(tSetID)
      if tSetObject <> 0 then
        tSetObject.moveTo((tLocX + tOffsetX), (tLocY + tOffsetY))
        tOffsetY = (tOffsetY + tSetObject.getProperty(#height))
        if tSetObject.getProperty(#span_all_columns) then
          tTopOffsetY = tOffsetY
        else
          tWidth = tSetObject.getProperty(#width)
          if tWidth > tColumnMaxWidth then
            tColumnMaxWidth = tWidth
          end if
        end if
      end if
    end repeat
    tOffsetX = (tOffsetX + tColumnMaxWidth)
  end repeat
  return TRUE
end

on moveZ me, tZ 
  me.pLocZ = tZ
  repeat while me.pSetList <= undefined
    tSetObject = getAt(undefined, tZ)
    if tSetObject <> 0 then
      tSetObject.moveZ(me.pLocZ)
    end if
  end repeat
  return TRUE
end

on addOneWindow me, tPartId, tLayout, tSetID, tProps 
  if (tSetID = void()) then
    return FALSE
  end if
  if pSetIndex.findPos(tPartId) > 0 then
    return(me.replaceOneWindow(tPartId, tLayout, 0))
  end if
  tSetItem = me.getSet(tSetID)
  if (tSetItem = 0) then
    tSetItem = me.createSet(tSetID)
  end if
  if (tSetItem = 0) then
    return FALSE
  end if
  tOrderNum = (tSetItem.getHighestIndex(tSetID) + 1)
  createWindow(tPartId, tLayout)
  tWndObj = getWindow(tPartId)
  if (tWndObj = 0) then
    return FALSE
  end if
  tWndObj.moveZ(me.pLocZ)
  tWndObj.lock()
  if not pVisible then
    tWndObj.hide()
  end if
  me.addCurrentProceduresOnWindow(tWndObj)
  if listp(tProps) then
    tScrollToPlace = tProps.findPos(#scrollFromLocX)
    if not tScrollToPlace and tProps.findPos(#locX) and tProps.findPos(#locY) then
      tWndObj.moveTo(tProps.getaProp(#locX), tProps.getaProp(#locY))
    end if
  end if
  if not tSetItem.addOneWindow(tPartId, tOrderNum, tProps) then
    return FALSE
  end if
  pSetIndex.setaProp(tPartId, tSetID)
  return TRUE
end

on initSet me, tSetID, tColumnNum, tOrderNum 
  if me.existsSet(tSetID) then
    return(me.clearSet(tSetID))
  else
    return(me.createSet(tSetID, tColumnNum, tOrderNum))
  end if
end

on Activate me 
  repeat while me.pSetOrderIndex <= undefined
    tSetColumn = getAt(undefined, undefined)
    repeat while me.pSetOrderIndex <= undefined
      tSetID = getAt(undefined, undefined)
      tSetObject = pSetList.getaProp(tSetID)
      if tSetObject <> 0 then
        tSetObject.Activate()
      end if
    end repeat
  end repeat
end

on activateSet me, tSetID 
  tSetObject = me.getSet(tSetID)
  if (tSetObject = 0) then
    return FALSE
  end if
  return(tSetObject.Activate())
end

on createSet me, tSetID, tColumnNum, tOrderNum 
  if me.existsSet(tSetID) then
    return TRUE
  end if
  tSetObject = createObject(#temp, "Multicomponent Window Wrapper Set Class")
  if (tSetObject = 0) then
    return FALSE
  end if
  tSetObject.define(tSetID)
  if (tColumnNum = void()) then
    tColumnNum = 1
  end if
  if (tOrderNum = void()) then
    tOrderNum = me.getNextFreeSetIndex(tColumnNum)
  end if
  pSetList.setaProp(tSetID, tSetObject)
  if pSetOrderIndex.count < tColumnNum then
    tCount = pSetOrderIndex.count
    i = (tCount + 1)
    repeat while i <= tColumnNum
      pSetOrderIndex.setAt(i, [:])
      i = (1 + i)
    end repeat
  end if
  pSetOrderIndex.getAt(tColumnNum).setaProp(tOrderNum, tSetID)
  me.getPropRef(#pSetOrderIndex, tColumnNum).sort()
  me.moveTo(pLocX, pLocY)
  return(tSetObject)
end

on clearSet me, tSetID, tRender 
  if (tSetID = void()) then
    return FALSE
  end if
  tSetObject = me.getSet(tSetID)
  if (tSetObject = void()) then
    return TRUE
  end if
  tSetObject.clearSet()
  i = 1
  repeat while i <= me.count(#pSetIndex)
    if (me.getProp(#pSetIndex, i) = tSetID) then
      me.pSetIndex.deleteAt(i)
      next repeat
    end if
    i = (i + 1)
  end repeat
  me.moveTo(pLocX, pLocY)
  return TRUE
end

on removeSet me, tSetID, tRender 
  if (tSetID = void()) then
    return FALSE
  end if
  tSetObject = me.getSet(tSetID)
  if (tSetObject = void()) then
    return TRUE
  end if
  tSetObject.deconstruct()
  me.pSetList.deleteProp(tSetID)
  i = 1
  repeat while i <= me.count(#pSetIndex)
    if (me.getProp(#pSetIndex, i) = tSetID) then
      me.pSetIndex.deleteAt(i)
      next repeat
    end if
    i = (i + 1)
  end repeat
  tDone = 0
  i = 1
  repeat while i <= pSetOrderIndex.count
    tSetColumn = pSetOrderIndex.getAt(i)
    j = 1
    repeat while j <= tSetColumn.count
      if (tSetColumn.getAt(j) = tSetID) then
        tDone = 1
        tSetColumn.deleteAt(j)
      end if
      if (tDone = 1) then
      else
        j = (1 + j)
      end if
    end repeat
    if (tDone = 1) then
    else
      i = (1 + i)
    end if
  end repeat
  if tRender then
    me.render()
  end if
  return TRUE
end

on removeMatchingSets me, tWindowSetId, tRender 
  if (tWindowSetId = void()) then
    return FALSE
  end if
  tIdLength = tWindowSetId.length
  i = 1
  repeat while i <= me.count(#pSetIndex)
    tTestString = me.getProp(#pSetIndex, i)
    if (tTestString.getProp(#char, 1, tIdLength) = tWindowSetId) then
      me.removeSet(tTestString, tRender)
      next repeat
    end if
    i = (i + 1)
  end repeat
  return TRUE
end

on existsSet me, tSetID 
  if pSetList.findPos(tSetID) > 0 then
    return TRUE
  end if
  return FALSE
end

on getSetItems me, tSetID 
  tSetObject = pSetList.getaProp(tSetID)
  if (tSetObject = 0) then
    return FALSE
  end if
  return(tSetObject.getItems())
end

on removeOneWindow me, tPartId, tRender 
  tSetID = me.pSetIndex.getaProp(tPartId)
  if (tSetID = 0) then
    return(error(me, "Part not found in any set:" && tPartId, #removeOneWindow))
  end if
  tSetObject = pSetList.getaProp(tSetID)
  if (tSetObject = 0) then
    return(error(me, "Set object not found:" && tSetID, #removeOneWindow))
  end if
  if tSetObject.removeOneWindow(tPartId) then
    pSetIndex.deleteProp(tPartId)
    if (tSetObject.getCount() = 0) then
      me.removeSet(tSetID)
    end if
  end if
  if tRender then
    me.render()
  end if
  return TRUE
end

on replaceOneWindow me, tPartId, tLayout, tRender 
  if (tPartId = void()) then
    return FALSE
  end if
  tSetID = me.pSetIndex.getaProp(tPartId)
  if (tSetID = 0) then
    return(error(me, "Part not found in set index:" && tPartId, #replaceOneWindow))
  end if
  tSetObject = pSetList.getaProp(tSetID)
  if (tSetObject = 0) then
    return(error(me, "Set object not found:" && tSetID, #replaceOneWindow))
  end if
  removeWindow(tPartId)
  createWindow(tPartId, tLayout)
  tWndObj = getWindow(tPartId)
  if (tWndObj = 0) then
    return(error(me, "New window not found:" && tPartId, #replaceOneWindow))
  end if
  tWndObj.moveZ(me.pLocZ)
  tWndObj.lock()
  me.addCurrentProceduresOnWindow(tWndObj)
  if not pVisible then
    tWndObj.hide()
  end if
  if tRender then
    me.render()
  end if
  return TRUE
end

on windowExists me, tPartId 
  if (tPartId = void()) then
    return FALSE
  end if
  return(me.pSetIndex.findPos(tPartId) <> 0)
end

on getElement me, tElemID, tWndID 
  repeat while me.pSetList <= tWndID
    tSetObject = getAt(tWndID, tElemID)
    tElem = tSetObject.getElement(tElemID)
    if objectp(tElem) then
      return(tElem)
    end if
  end repeat
  return FALSE
end

on render me 
  tOldLocation = me.getRealLocation()
  tMaxHeight = me.getWrapperProperty(#height, #total, 1)
  tColumnCount = me.count(#pSetOrderIndex)
  repeat while me.pSetOrderIndex <= undefined
    tSetColumn = getAt(undefined, undefined)
    repeat while me.pSetOrderIndex <= undefined
      tSetID = getAt(undefined, undefined)
      tSetObject = pSetList.getaProp(tSetID)
      if tSetObject <> 0 then
        tSetObject.render(-1, tMaxHeight)
        if tSetObject.getProperty(#span_all_columns) then
          tMaxHeight = (tMaxHeight - tSetObject.getProperty(#height))
        end if
      end if
    end repeat
  end repeat
  me.moveTo(tOldLocation.getAt(1), tOldLocation.getAt(2))
  return TRUE
end

on hide me 
  pVisible = 0
  repeat while me.pSetList <= undefined
    tSetObject = getAt(undefined, undefined)
    if objectp(tSetObject) then
      tSetObject.hide()
    end if
  end repeat
  return TRUE
end

on show me 
  pVisible = 1
  repeat while me.pSetList <= undefined
    tSetObject = getAt(undefined, undefined)
    if objectp(tSetObject) then
      tSetObject.show()
    end if
  end repeat
  return TRUE
end

on registerProcedure me, tMethod, tClientID, tEvent 
  if (tEvent = void()) then
    return FALSE
  end if
  if (tClientID = void()) then
    return FALSE
  end if
  if (tMethod = void()) then
    return FALSE
  end if
  tEventItem = pProcedureList.getaProp(tEvent)
  if (tEventItem = void()) then
    tEventItem = [:]
  end if
  tEventItem.setaProp(tClientID, tMethod)
  pProcedureList.setaProp(tEvent, tEventItem)
  repeat while me.pSetList <= tClientID
    tSetObject = getAt(tClientID, tMethod)
    if (tSetObject = 0) then
      return FALSE
    end if
    tPartList = tSetObject.getItems()
    repeat while me.pSetList <= tClientID
      tWindowID = getAt(tClientID, tMethod)
      tWindow = getWindow(tWindowID)
      if (tWindow = 0) then
        return FALSE
      end if
      tWindow.registerProcedure(tMethod, tClientID, tEvent)
    end repeat
  end repeat
  return TRUE
end

on removeProcedure me, tEvent 
  if (tEvent = void()) then
    return FALSE
  end if
  tEventItem = pProcedureList.getaProp(tEvent)
  if (tEventItem = void()) then
    return TRUE
  end if
  i = 1
  repeat while i <= tEventItem.count
    tItemClientId = tEventItem.getPropAt(i)
    tWindow = getWindow(tItemClientId)
    if tWindow <> 0 then
      tWindow.removeProcedure(tEvent)
    end if
    i = (1 + i)
  end repeat
  pProcedureList.deleteProp(tEvent)
  return TRUE
end

on getRealLocation me 
  if (me.count(#pSetOrderIndex) = 0) then
    return(point(pLocX, pLocY))
  end if
  tSetColumn = me.getProp(#pSetOrderIndex, 1)
  if (tSetColumn.count = 0) then
    return(point(pLocX, pLocY))
  end if
  tSetObject = me.getSet(tSetColumn.getAt(1))
  return(tSetObject.getRealLocation())
end

on getSet me, tSetID 
  return(pSetList.getaProp(tSetID))
end

on getWrapperProperty me, tKey, tMode, tColumnNum, tResult 
  tSetCount = me.count(#pSetOrderIndex)
  if tColumnNum > tSetCount then
    return FALSE
  end if
  if tColumnNum < 1 then
    i = 1
    repeat while i <= tSetCount
      tValue = me.getWrapperProperty(tKey, #total, i)
      if (tMode = #total) then
        tResult = (tResult + tValue)
      else
        if (tMode = #max) then
          if tValue > tResult then
            tResult = tValue
          end if
        end if
      end if
      i = (1 + i)
    end repeat
    exit repeat
  end if
  tSetColumn = me.getProp(#pSetOrderIndex, tColumnNum)
  j = 1
  repeat while j <= tSetColumn.count
    tSetObject = me.getSet(tSetColumn.getAt(j))
    if (tSetObject = 0) then
      return(error(me, "Set object not found:" && tSetColumn.getAt(j), #getWrapperProperty))
    end if
    tResult = tSetObject.getAllWindowProperty(tKey, tMode, tResult)
    j = (1 + j)
  end repeat
  return(tResult)
end

on getNextFreeSetIndex me, tColumnNum 
  if tColumnNum > me.count(#pSetOrderIndex) then
    return TRUE
  end if
  tSetColumn = me.getProp(#pSetOrderIndex, tColumnNum)
  i = 1
  repeat while i <= tSetColumn.count
    tNextIndex = (tSetColumn.getPropAt(i) + 1)
    if (tSetColumn.findPos(tNextIndex) = 0) then
      return(tNextIndex)
    end if
    i = (1 + i)
  end repeat
  return FALSE
end

on addCurrentProceduresOnWindow me, tWndObj 
  if (tWndObj = 0) then
    return FALSE
  end if
  i = 1
  repeat while i <= pProcedureList.count
    tEvent = pProcedureList.getPropAt(i)
    tProc = pProcedureList.getAt(i)
    j = 1
    repeat while j <= tProc.count
      tClientID = tProc.getPropAt(j)
      tMethod = tProc.getAt(j)
      tWndObj.registerProcedure(tMethod, tClientID, tEvent)
      j = (1 + j)
    end repeat
    i = (1 + i)
  end repeat
  return TRUE
end

on removeAllParts me 
  i = 1
  repeat while i <= me.count(#pSetOrderIndex)
    tSetColumn = me.getProp(#pSetOrderIndex, i)
    repeat while tSetColumn.count > 0
      tSetID = tSetColumn.getAt(1)
      me.removeSet(tSetID)
    end repeat
    i = (1 + i)
  end repeat
  pItemList = [:]
  pSetIndex = [:]
  pSetList = [:]
  pSetOrderIndex = []
  return TRUE
end
