property pLastRoomForwardTimeStamp

on construct me 
  pLastRoomForwardTimeStamp = 0
  return(me.regMsgList(1))
end

on deconstruct me 
  pLastRoomForwardTimeStamp = 0
  return(me.regMsgList(0))
end

on handle_flatinfo me, tMsg 
  tConn = tMsg.connection
  tFlat = [:]
  tFlat.setAt(#ableothersmovefurniture, tConn.GetIntFrom())
  tFlat.setAt(#door, tConn.GetIntFrom())
  tFlat.setAt(#flatId, string(tConn.GetIntFrom()))
  tFlat.setAt(#id, "f_" & tFlat.getAt(#flatId))
  tFlat.setAt(#owner, tConn.GetStrFrom())
  tFlat.setAt(#marker, tConn.GetStrFrom())
  tFlat.setAt(#name, tConn.GetStrFrom())
  tFlat.setAt(#description, tConn.GetStrFrom())
  tFlat.setAt(#showownername, tConn.GetIntFrom())
  tFlat.setAt(#trading, tConn.GetIntFrom())
  tFlat.setAt(#alert, tConn.GetIntFrom())
  tFlat.setAt(#maxVisitors, tConn.GetIntFrom())
  tFlat.setAt(#absoluteMaxVisitors, tConn.GetIntFrom())
  tFlat.setAt(#nodeType, 2)
  if (tFlat.getAt(#door) = 0) then
    tFlat.setAt(#door, "open")
  else
    if (tFlat.getAt(#door) = 1) then
      tFlat.setAt(#door, "closed")
    else
      if (tFlat.getAt(#door) = 2) then
        tFlat.setAt(#door, "password")
      end if
    end if
  end if
  if tFlat.getAt(#maxVisitors) < 1 then
    tFlat.setAt(#maxVisitors, 25)
  end if
  if tFlat.getAt(#absoluteMaxVisitors) < 1 then
    tFlat.setAt(#absoluteMaxVisitors, 50)
  end if
  if (tFlat.getAt(#alert) = 1) and (tFlat.getAt(#owner) = getObject(#session).GET(#user_name)) then
    executeMessage(#setEnterRoomAlert, "alert_no_category")
  end if
  me.getComponent().updateSingleSubNodeInfo(tFlat)
  me.getComponent().getInfoBroker().processNavigatorData(tFlat)
  return TRUE
end

on handle_flat_results me, tMsg 
  tResult = [:]
  tList = [:]
  tDelim = the itemDelimiter
  the itemDelimiter = "\t"
  tContent = tMsg.content
  i = 1
  repeat while i <= tContent.count(#line)
    tLine = tContent.getProp(#line, i)
    if tLine.count(#item) > 0 and tLine.count(#item) < 9 then
      nothing()
    else
      if (tLine = "") then
      else
        tFlat = [:]
        tFlat.setAt(#id, "f_" & tLine.getProp(#item, 1))
        tFlat.setAt(#flatId, tLine.getProp(#item, 1))
        tFlat.setAt(#name, tLine.getProp(#item, 2))
        tFlat.setAt(#owner, tLine.getProp(#item, 3))
        tFlat.setAt(#door, tLine.getProp(#item, 4))
        tFlat.setAt(#port, tLine.getProp(#item, 5))
        tFlat.setAt(#usercount, tLine.getProp(#item, 6))
        tFlat.setAt(#maxUsers, tLine.getProp(#item, 7))
        tFlat.setAt(#filter, tLine.getProp(#item, 8))
        tFlat.setAt(#description, tLine.getProp(#item, 9))
        tFlat.setAt(#nodeType, 2)
        tList.setAt(tFlat.getAt(#id), tFlat)
        i = (1 + i)
      end if
      tResult.addProp(#children, tList)
      if (tMsg.subject = 16) then
        tResult.setAt(#id, #own)
      else
        if (tMsg.subject = 55) then
          tResult.setAt(#id, #src)
        end if
      end if
      the itemDelimiter = tDelim
      me.getComponent().saveNodeInfo(tResult)
    end if
  end repeat
end

on handle_favouriteroomresults me, tMsg 
  tConn = tMsg.connection
  tNodeMask = tConn.GetIntFrom()
  tNodeId = tConn.GetIntFrom()
  tNodeType = tConn.GetIntFrom()
  tNodeInfo = [#id:string(tNodeId), #nodeType:tNodeType, #name:tConn.GetStrFrom(), #usercount:tConn.GetIntFrom(), #maxUsers:tConn.GetIntFrom(), #parentid:string(tConn.GetIntFrom())]
  tResult = [#id:#fav, #children:[:]]
  if (tNodeType = 2) then
    tResult.setAt(#children, me.parseFlatCategoryNode(tMsg))
  end if
  repeat while tConn <> void()
    tNode = me.parseNode(tMsg)
    if listp(tNode) then
      tResult.getAt(#children).addProp(tNode.getAt(#id), tNode)
      next repeat
    end if
  end repeat
  return(me.getComponent().saveNodeInfo(tResult))
end

on handle_noflatsforuser me, tMsg 
  me.getComponent().noflatsforuser()
end

on handle_noflats me, tMsg 
  me.getComponent().noflats()
end

on handle_flatpassword_ok me, tMsg 
  me.getComponent().flatAccessResult("flatpassword_ok")
end

on handle_navnodeinfo me, tMsg 
  tConn = tMsg.connection
  tCategoryIndex = [:]
  tNodeMask = tConn.GetIntFrom()
  tNodeInfo = me.parseNode(tMsg)
  if (tNodeInfo = 0) then
    return FALSE
  end if
  tNodeInfo.addProp(#nodeMask, tNodeMask)
  tCategoryId = tNodeInfo.getAt(#id)
  tCategoryIndex.setaProp(tCategoryId, [#name:tNodeInfo.getAt(#name), #parentid:tNodeInfo.getAt(#parentid), #children:[]])
  repeat while tConn <> void()
    tNode = me.parseNode(tMsg)
    if (tNode = 0) then
    else
      tNodeId = tNode.getAt(#id)
      tParentId = tNode.getAt(#parentid)
      if (tParentId = tCategoryId) then
        tNodeInfo.getAt(#children).setaProp(tNodeId, tNode)
      end if
      if tCategoryIndex.getAt(tParentId) <> 0 then
        tCategoryIndex.getAt(tParentId).getAt(#children).add(tNodeId)
      end if
      if (tNode.getAt(#nodeType) = 0) or (tNode.getAt(#nodeType) = 1) and (tCategoryIndex.getAt(tNodeId) = 0) then
        tCategoryIndex.setaProp(tNodeId, [#name:tNode.getAt(#name), #parentid:tParentId, #children:[]])
      end if
    end if
  end repeat
  me.getComponent().updateCategoryIndex(tCategoryIndex)
  me.getComponent().saveNodeInfo(tNodeInfo)
  me.getComponent().getInfoBroker().processNavigatorData(tNodeInfo)
  return TRUE
end

on handle_error me, tMsg 
  tErr = tMsg.content
  error(me, tMsg.connection.getID() & ":" && tErr, #handle_error, #dummy)
  if tErr <> "Only 10 favorite rooms allowed!" then
    if (tErr = "nav_error_toomanyfavrooms") then
      executeMessage(#alert, [#Msg:getText("nav_error_toomanyfavrooms")])
    end if
    return TRUE
  end if
end

on parseNode me, tMsg 
  tConn = tMsg.connection
  tNodeId = tConn.GetIntFrom()
  if tNodeId <= 0 then
    return FALSE
  end if
  tNodeType = tConn.GetIntFrom()
  tNodeInfo = [#id:string(tNodeId), #nodeType:tNodeType, #name:tConn.GetStrFrom(), #usercount:tConn.GetIntFrom(), #maxUsers:tConn.GetIntFrom(), #parentid:string(tConn.GetIntFrom())]
  if (tNodeType = 0) then
    tNodeInfo.addProp(#children, [:])
  else
    if (tNodeType = 1) then
      tNodeInfo.addProp(#unitStrId, tConn.GetStrFrom())
      tNodeInfo.addProp(#port, tConn.GetIntFrom())
      tNodeInfo.addProp(#door, tConn.GetIntFrom())
      tCasts = tConn.GetStrFrom()
      tNodeInfo.addProp(#casts, [])
      tDelim = the itemDelimiter
      the itemDelimiter = ","
      c = 1
      repeat while c <= tCasts.count(#item)
        tNodeInfo.getAt(#casts).add(tCasts.getProp(#item, c))
        c = (1 + c)
      end repeat
      the itemDelimiter = tDelim
      tNodeInfo.addProp(#usersInQueue, tConn.GetIntFrom())
      tNodeInfo.addProp(#isVisible, tConn.GetBoolFrom())
    else
      if (tNodeType = 2) then
        tNodeInfo.setAt(#nodeType, 0)
        tFlatList = me.parseFlatCategoryNode(tMsg)
        tNodeInfo.addProp(#children, tFlatList)
      end if
    end if
  end if
  return(tNodeInfo)
end

on parseFlatCategoryNode me, tMsg 
  tConn = tMsg.connection
  tFlatCount = tConn.GetIntFrom()
  tFlatList = [:]
  i = 1
  repeat while i <= tFlatCount
    tFlatID = string(tConn.GetIntFrom())
    tFlatInfo = [:]
    tFlatInfo.setAt(#id, "f_" & tFlatID)
    tFlatInfo.setAt(#flatId, tFlatID)
    tFlatInfo.setAt(#name, tConn.GetStrFrom())
    tFlatInfo.setAt(#owner, tConn.GetStrFrom())
    tFlatInfo.setAt(#door, tConn.GetStrFrom())
    tFlatInfo.setAt(#usercount, tConn.GetIntFrom())
    tFlatInfo.setAt(#maxUsers, tConn.GetIntFrom())
    tFlatInfo.setAt(#description, tConn.GetStrFrom())
    tFlatInfo.setAt(#nodeType, 2)
    tFlatList.addProp("f_" & tFlatID, tFlatInfo)
    i = (1 + i)
  end repeat
  return(tFlatList)
end

on handle_userflatcats me, tMsg 
  tList = [:]
  tConn = tMsg.getaProp(#connection)
  tItemCount = tConn.GetIntFrom()
  t = 1
  repeat while t <= tItemCount
    tNodeId = tConn.GetIntFrom()
    tNodeName = tConn.GetStrFrom()
    tList.addProp(string(tNodeId), tNodeName)
    t = (1 + t)
  end repeat
  getObject(#session).set("user_flat_cats", tList)
  return TRUE
end

on handle_flatcat me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tFlatID = tConn.GetIntFrom()
  tCategoryId = tConn.GetIntFrom()
  me.getComponent().setNodeProperty("f_" & tFlatID, #parentid, tCategoryId)
  executeMessage(#flatcat_received, [#flatId:tFlatID, #id:"f_" & tFlatID, #parentid:tCategoryId])
  return TRUE
end

on handle_spacenodeusers me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tNodeId = string(tConn.GetIntFrom())
  tUserCount = tConn.GetIntFrom()
  tUserList = []
  i = 1
  repeat while i <= tUserCount
    tUserList.append(tConn.GetStrFrom())
    i = (1 + i)
  end repeat
  me.getInterface().showSpaceNodeUsers(tNodeId, tUserList)
  return TRUE
end

on handle_cantconnect me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tError = tConn.GetIntFrom()
  executeMessage(#leaveRoom)
  if (tError = 1) then
    tError = "nav_error_room_full"
  else
    if (tError = 2) then
      tError = "nav_error_room_closed"
    else
      if (tError = 3) then
        tError = "queue_set." & tConn.GetStrFrom() & ".alert"
      end if
    end if
  end if
  return(executeMessage(#alert, [#id:"nav_error", #Msg:tError]))
end

on handle_success me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tMsgId = tConn.GetIntFrom()
  return TRUE
end

on handle_failure me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tMsgId = tConn.GetIntFrom()
  tErrorTxt = tConn.GetStrFrom()
  if tErrorTxt <> "" then
    executeMessage(#alert, [#Msg:tErrorTxt])
  end if
  return TRUE
end

on handle_parentchain me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tChildId = string(tConn.GetIntFrom())
  tNodeName = tConn.GetStrFrom()
  tCategoryIndex = [:]
  repeat while tConn <> void()
    tid = tConn.GetIntFrom()
    if tid <= 0 then
    else
      tid = string(tid)
      tName = tConn.GetStrFrom()
      if tCategoryIndex.getAt(tChildId) <> void() then
        tCategoryIndex.getAt(tChildId).setaProp(#parentid, tid)
      end if
      tCategoryIndex.addProp(tid, [#name:tName, #parentid:tid, #children:[tChildId]])
      tChildId = tid
    end if
  end repeat
  return(me.getComponent().updateCategoryIndex(tCategoryIndex))
end

on handle_roomforward me, tMsg 
  tTimeSinceLast = (the milliSeconds - pLastRoomForwardTimeStamp)
  tTimeout = getVariable("navigator.room.forward.timeout")
  if tTimeSinceLast < tTimeout then
    return FALSE
  else
    pLastRoomForwardTimeStamp = the milliSeconds
  end if
  tConn = tMsg.connection
  tIsPublic = tConn.GetIntFrom()
  if tIsPublic > 0 then
    tStrRoomType = #public
  else
    tStrRoomType = #private
  end if
  tStrRoomId = string(tConn.GetIntFrom())
  return(executeMessage(#roomForward, tStrRoomId, tStrRoomType))
end

on regMsgList me, tBool 
  tMsgs = [:]
  tMsgs.setaProp(16, #handle_flat_results)
  tMsgs.setaProp(33, #handle_error)
  tMsgs.setaProp(54, #handle_flatinfo)
  tMsgs.setaProp(55, #handle_flat_results)
  tMsgs.setaProp(57, #handle_noflatsforuser)
  tMsgs.setaProp(58, #handle_noflats)
  tMsgs.setaProp(61, #handle_favouriteroomresults)
  tMsgs.setaProp(130, #handle_flatpassword_ok)
  tMsgs.setaProp(220, #handle_navnodeinfo)
  tMsgs.setaProp(221, #handle_userflatcats)
  tMsgs.setaProp(222, #handle_flatcat)
  tMsgs.setaProp(223, #handle_spacenodeusers)
  tMsgs.setaProp(224, #handle_cantconnect)
  tMsgs.setaProp(225, #handle_success)
  tMsgs.setaProp(226, #handle_failure)
  tMsgs.setaProp(227, #handle_parentchain)
  tMsgs.setaProp(286, #handle_roomforward)
  tCmds = [:]
  tCmds.setaProp("SBUSYF", 13)
  tCmds.setaProp("SUSERF", 16)
  tCmds.setaProp("SRCHF", 17)
  tCmds.setaProp("GETFVRF", 18)
  tCmds.setaProp("ADD_FAVORITE_ROOM", 19)
  tCmds.setaProp("DEL_FAVORITE_ROOM", 20)
  tCmds.setaProp("GETFLATINFO", 21)
  tCmds.setaProp("DELETEFLAT", 23)
  tCmds.setaProp("UPDATEFLAT", 24)
  tCmds.setaProp("SETFLATINFO", 25)
  tCmds.setaProp("NAVIGATE", 150)
  tCmds.setaProp("GETUSERFLATCATS", 151)
  tCmds.setaProp("GETFLATCAT", 152)
  tCmds.setaProp("SETFLATCAT", 153)
  tCmds.setaProp("GETSPACENODEUSERS", 154)
  tCmds.setaProp("REMOVEALLRIGHTS", 155)
  tCmds.setaProp("GETPARENTCHAIN", 156)
  if tBool then
    registerListener(getVariable("connection.info.id", #info), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id", #info), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id", #info), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id", #info), me.getID(), tCmds)
  end if
  return TRUE
end
