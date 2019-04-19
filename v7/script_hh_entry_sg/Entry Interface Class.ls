on construct(me)
  pEntryVisual = "entry_view"
  pBottomBar = "entry_bar"
  pSignSprList = []
  pSignSprLocV = 0
  pItemObjList = []
  pUpdateTasks = []
  pViewMaxTime = 500
  pViewOpenTime = void()
  pViewCloseTime = void()
  pAnimUpdate = 0
  pInActiveIconBlend = 40
  pNewMsgCount = 0
  pNewBuddyRequests = 0
  pClubDaysCount = 0
  pMessengerFlash = 0
  pFirstInit = 1
  pFrameCounter = 0
  registerMessage(#userlogin, me.getID(), #showEntryBar)
  registerMessage(#messenger_ready, me.getID(), #activateIcon)
  return(1)
  exit
end

on deconstruct(me)
  unregisterMessage(#userlogin, me.getID())
  unregisterMessage(#messenger_ready, me.getID())
  return(me.hideAll())
  exit
end

on showHotel(me)
  if not visualizerExists(pEntryVisual) then
    if not createVisualizer(pEntryVisual, "entry.visual") then
      return(0)
    end if
    tVisObj = getVisualizer(pEntryVisual)
    pSignSprList = []
    pSignSprList.add(tVisObj.getSprById("entry_sign"))
    pSignSprList.add(tVisObj.getSprById("entry_sign_sd"))
    pSignSprLocV = pSignSprList.getAt(1).locV
    pItemObjList = []
    tSpr = tVisObj.getSprById("fountain")
    if tSpr <> 0 then
      tObj = createObject(#temp, "Entry Fountain Class")
      tObj.define(tSpr, "sg_fountain_")
      pItemObjList.add(tObj)
    end if
    i = 1
    repeat while 1
      tSpr = tVisObj.getSprById("boat" & i)
      if tSpr <> 0 then
        tObj = createObject(#temp, "Entry Boat Class")
        if i > 1 then
          tSpr2 = tVisObj.getSprById("boat" & i & "_roof")
          tObj.define([tSpr, tSpr2], i)
        else
          tObj.define(tSpr, i)
        end if
        pItemObjList.add(tObj)
      else
      end if
      i = i + 1
    end repeat
    i = 1
    repeat while 1
      tSpr = tVisObj.getSprById("cloud" & i)
      if tSpr <> 0 then
        tObj = createObject(#temp, "Entry Cloud Class")
        tObj.define(tSpr, i)
        pItemObjList.add(tObj)
      else
      end if
      i = i + 1
    end repeat
    me.remAnimTask(#closeView)
    pViewOpenTime = the milliSeconds + 500
    receivePrepare(me.getID())
    me.delay(500, #addAnimTask, #openView)
  end if
  return(1)
  exit
end

on hideHotel(me)
  if visualizerExists(pEntryVisual) then
    me.addAnimTask(#closeView)
    me.remAnimTask(#animSign)
    me.remAnimTask(#openView)
    pViewCloseTime = the milliSeconds
  end if
  pItemObjList = []
  removePrepare(me.getID())
  return(1)
  exit
end

on showEntryBar(me)
  if not windowExists(pBottomBar) then
    if not createWindow(pBottomBar, "entry_bar.window", 0, 535) then
      return(0)
    end if
    tWndObj = getWindow(pBottomBar)
    tWndObj.lock(1)
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcEntryBar, me.getID(), #mouseUp)
    me.addAnimTask(#animEntryBar)
  end if
  registerMessage(#updateMessageCount, me.getID(), #updateMessageCount)
  registerMessage(#updateCreditCount, me.getID(), #updateCreditCount)
  registerMessage(#updateBuddyrequestCount, me.getID(), #updateBuddyrequestCount)
  registerMessage(#updateFigureData, me.getID(), #updateEntryBar)
  registerMessage(#updateClubStatus, me.getID(), #updateClubStatus)
  return(me.updateEntryBar())
  exit
end

on hideEntrybar(me)
  unregisterMessage(#updateMessageCount, me.getID())
  unregisterMessage(#updateCreditCount, me.getID())
  unregisterMessage(#updateBuddyrequestCount, me.getID())
  unregisterMessage(#updateFigureData, me.getID())
  unregisterMessage(#updateClubStatus, me.getID())
  if timeoutExists(#flash_messenger_icon) then
    removeTimeout(#flash_messenger_icon)
  end if
  if windowExists(pBottomBar) then
    removeWindow(pBottomBar)
  end if
  return(1)
  exit
end

on hideAll(me)
  me.hideHotel()
  me.hideEntrybar()
  return(1)
  exit
end

on prepare(me)
  pAnimUpdate = not pAnimUpdate
  if pAnimUpdate then
    tVisual = getVisualizer(pEntryVisual)
    if not tVisual then
      return(removePrepare(me.getID()))
    end if
    pFrameCounter = pFrameCounter + 1
    if pFrameCounter > 2 then
      if voidp(pWaterAnimCounter) then
        pWaterAnimCounter = 1
      else
        pWaterAnimCounter = pWaterAnimCounter + 1
      end if
      if pWaterAnimCounter > 7 then
        pWaterAnimCounter = 0
      end if
      tSpr = tVisual.getSprById("bg2")
      tMem = tSpr.member
      tMem.paletteRef = member(getmemnum("water" & pWaterAnimCounter & "_palette"))
      pFrameCounter = 0
    end if
    call(#update, pItemObjList)
  end if
  exit
end

on update(me)
  repeat while me <= undefined
    tMethod = getAt(undefined, undefined)
    call(tMethod, me)
  end repeat
  exit
end

on updateEntryBar(me)
  tWndObj = getWindow(pBottomBar)
  if tWndObj = 0 then
    return(0)
  end if
  tSession = getObject(#session)
  tName = tSession.get("user_name")
  tText = tSession.get("user_customData")
  if tSession.exists("user_walletbalance") then
    tCrds = tSession.get("user_walletbalance")
  else
    tCrds = getText("loading", "Loading")
  end if
  if tSession.exists("club_status") then
    tClub = tSession.get("club_status")
  else
    tClub = getText("loading", "Loading")
  end if
  tWndObj.getElement("ownhabbo_name_text").setText(tName)
  tWndObj.getElement("ownhabbo_mission_text").setText(tText)
  if pFirstInit then
    me.deActivateAllIcons()
    pFirstInit = 0
  end if
  me.updateCreditCount(tCrds)
  executeMessage(#messageUpdateRequest)
  executeMessage(#buddyUpdateRequest)
  me.updateClubStatus(tClub)
  me.createMyHeadIcon()
  return(1)
  exit
end

on addAnimTask(me, tMethod)
  if pUpdateTasks.getPos(tMethod) = 0 then
    pUpdateTasks.add(tMethod)
  end if
  return(receiveUpdate(me.getID()))
  exit
end

on remAnimTask(me, tMethod)
  pUpdateTasks.deleteOne(tMethod)
  if pUpdateTasks.count = 0 then
    removeUpdate(me.getID())
  end if
  return(1)
  exit
end

on animSign(me)
  tVisObj = getVisualizer(pEntryVisual)
  if tVisObj = 0 then
    return(me.remAnimTask(#animSign))
  end if
  repeat while me <= undefined
    tSpr = getAt(undefined, undefined)
    tSpr.locV = tSpr.locV + 30
  end repeat
  if pSignSprList.getAt(1).locV >= 0 then
    pSignSprList.getAt(1).locV = 0
    pSignSprList.getAt(2).locV = 0
    me.remAnimTask(#animSign)
  end if
  exit
end

on openView(me)
  tVisObj = getVisualizer(pEntryVisual)
  if tVisObj = 0 then
    return(me.remAnimTask(#openView))
  end if
  tTopSpr = tVisObj.getSprById("box_top")
  tBotSpr = tVisObj.getSprById("box_bottom")
  tTimeLeft = pViewMaxTime - the milliSeconds - pViewOpenTime / 0
  tmoveLeft = tTopSpr.height - abs(tTopSpr.locV)
  if tTimeLeft <= 0 then
    tOffset = abs(tmoveLeft)
  else
    tOffset = abs(tmoveLeft / tTimeLeft) / the frameTempo
  end if
  tTopSpr.locV = tTopSpr.locV - tOffset
  tBotSpr.locV = tBotSpr.locV + tOffset
  if tTopSpr.locV <= -tTopSpr.height then
    me.addAnimTask(#animSign)
    me.remAnimTask(#openView)
  end if
  exit
end

on closeView(me)
  tVisObj = getVisualizer(pEntryVisual)
  if tVisObj = 0 then
    return(me.remAnimTask(#closeView))
  end if
  tTopSpr = tVisObj.getSprById("box_top")
  tBotSpr = tVisObj.getSprById("box_bottom")
  tTimeLeft = pViewMaxTime - the milliSeconds - pViewCloseTime / 0
  tmoveLeft = 0 - abs(tTopSpr.locV)
  if tTimeLeft <= 0 then
    tOffset = abs(tmoveLeft)
  else
    tOffset = abs(tmoveLeft / tTimeLeft) / the frameTempo
  end if
  tTopSpr.locV = tTopSpr.locV + tOffset
  tBotSpr.locV = tBotSpr.locV - tOffset
  if tTopSpr.locV >= 0 then
    me.remAnimTask(#closeView)
    removeVisualizer(pEntryVisual)
  end if
  exit
end

on animEntryBar(me)
  tWndObj = getWindow(pBottomBar)
  if tWndObj = 0 then
    return(me.remAnimTask(#animEntryBar))
  end if
  tWndObj = getWindow(pBottomBar)
  if the platform contains "windows" then
    tWndObj.moveBy(0, -5)
  else
    tWndObj.moveTo(0, 485)
  end if
  if tWndObj.getProperty(#locY) <= 485 then
    me.remAnimTask(#animEntryBar)
  end if
  exit
end

on updateCreditCount(me, tCount)
  tWndObj = getWindow(pBottomBar)
  if tWndObj <> 0 then
    tElement = tWndObj.getElement("own_credits_text")
    if not tElement then
      return(0)
    end if
    tElement.setText(tCount && getText("int_credits"))
  end if
  return(1)
  exit
end

on updateClubStatus(me, tStatus)
  tWndObj = getWindow(pBottomBar)
  if tWndObj <> 0 then
    if not tWndObj.elementExists("club_bottombar_text1") then
      return(0)
    end if
    if not tWndObj.elementExists("club_bottombar_text2") then
      return(0)
    end if
    if listp(tStatus) then
      if me = "active" then
        tStr = getText("club_habbo.bottombar.link.member")
        tStr = replaceChunks(tStr, "%days%", tStatus.getAt(#daysLeft))
        tWndObj.getElement("club_bottombar_text1").setText(getText("club_habbo.bottombar.text.member"))
        tWndObj.getElement("club_bottombar_text2").setText(tStr)
      else
        if me = "inactive" then
          tWndObj.getElement("club_bottombar_text1").setText(getText("club_habbo.bottombar.text.notmember"))
          tWndObj.getElement("club_bottombar_text2").setText(getText("club_habbo.bottombar.link.notmember"))
        end if
      end if
    else
      tWndObj.getElement("club_bottombar_text1").setText(getText("club_habbo.bottombar.text.notmember"))
      tWndObj.getElement("club_bottombar_text2").setText(getText("club_habbo.bottombar.link.notmember"))
    end if
  end if
  return(1)
  exit
end

on updateMessageCount(me, tCount)
  tWndObj = getWindow(pBottomBar)
  if tWndObj <> 0 then
    me.activateIcon(#messenger)
    pNewMsgCount = value(tCount)
    tText = tCount && getText("int_newmessages")
    tElem = tWndObj.getElement("new_messages_text")
    tFont = tElem.getFont()
    if pNewMsgCount > 0 then
      tFont.setaProp(#fontStyle, [#underline])
      tElem.setProperty(#cursor, "cursor.finger")
    else
      tFont.setaProp(#fontStyle, [#plain])
      tElem.setProperty(#cursor, 0)
    end if
    tElem.setFont(tFont)
    tElem.setText(tText)
    me.flashMessengerIcon()
  end if
  exit
end

on updateBuddyrequestCount(me, tCount)
  tWndObj = getWindow(pBottomBar)
  if tWndObj <> 0 then
    me.activateIcon(#messenger)
    pNewBuddyRequests = value(tCount)
    tText = tCount && getText("int_newrequests")
    tElem = tWndObj.getElement("friendrequests_text")
    tFont = tElem.getFont()
    if pNewBuddyRequests > 0 then
      tFont.setaProp(#fontStyle, [#underline])
      tElem.setProperty(#cursor, "cursor.finger")
    else
      tFont.setaProp(#fontStyle, [#plain])
      tElem.setProperty(#cursor, 0)
    end if
    tElem.setFont(tFont)
    tElem.setText(tText)
    me.flashMessengerIcon()
  end if
  exit
end

on flashMessengerIcon(me)
  tWndObj = getWindow(pBottomBar)
  if tWndObj <> 0 then
    if pMessengerFlash then
      tmember = "mes_lite_icon"
      pMessengerFlash = 0
    else
      tmember = "mes_dark_icon"
      pMessengerFlash = 1
    end if
    if pNewMsgCount = 0 and pNewBuddyRequests = 0 then
      tmember = "mes_dark_icon"
      if timeoutExists(#flash_messenger_icon) then
        removeTimeout(#flash_messenger_icon)
      end if
    else
      if pNewMsgCount > 0 then
        if not timeoutExists(#flash_messenger_icon) then
          createTimeout(#flash_messenger_icon, 500, #flashMessengerIcon, me.getID(), void(), 0)
        end if
      else
        tmember = "mes_lite_icon"
        if timeoutExists(#flash_messenger_icon) then
          removeTimeout(#flash_messenger_icon)
        end if
      end if
    end if
    #image.setProperty(member(getmemnum(tmember)), image.duplicate())
  end if
  exit
end

on activateIcon(me, tIcon)
  if windowExists(pBottomBar) then
    if me = #navigator then
      getWindow(pBottomBar).getElement("nav_icon_image").setProperty(#blend, 100)
    else
      if me = #messenger then
        getWindow(pBottomBar).getElement("messenger_icon_image").setProperty(#blend, 100)
      end if
    end if
  end if
  exit
end

on deActivateIcon(me, tIcon)
  if windowExists(pBottomBar) then
    if me = #navigator then
      getWindow(pBottomBar).getElement("nav_icon_image").setProperty(#blend, pInActiveIconBlend)
    else
      if me = #messenger then
        getWindow(pBottomBar).getElement("messenger_icon_image").setProperty(#blend, pInActiveIconBlend)
      end if
    end if
  end if
  exit
end

on deActivateAllIcons(me)
  tIcons = ["messenger"]
  if windowExists(pBottomBar) then
    repeat while me <= undefined
      tIcon = getAt(undefined, undefined)
      getWindow(pBottomBar).getElement(tIcon & "_icon_image").setProperty(#blend, pInActiveIconBlend)
    end repeat
  end if
  exit
end

on createMyHeadIcon(me)
  if objectExists("Figure_Preview") then
    getObject("Figure_Preview").createHumanPartPreview(pBottomBar, "ownhabbo_icon_image", ["hd", "fc", "ey", "hr"])
  end if
  exit
end

on eventProcEntryBar(me, tEvent, tSprID, tParam)
  if me = "help_icon_image" then
    return(executeMessage(#openGeneralDialog, #help))
  else
    if me <> "get_credit_text" then
      if me = "purse_icon_image" then
        return(executeMessage(#openGeneralDialog, #purse))
      else
        if me = "nav_icon_image" then
          return(executeMessage(#show_hide_navigator))
        else
          if me = "messenger_icon_image" then
            return(executeMessage(#show_hide_messenger))
          else
            if me = "new_messages_text" then
              if pNewMsgCount > 0 then
                return(executeMessage(#show_hide_messenger))
              end if
            else
              if me = "friendrequests_text" then
                if pNewBuddyRequests > 0 then
                  return(executeMessage(#show_hide_messenger))
                end if
              else
                if me <> "update_habboid_text" then
                  if me = "ownhabbo_icon_image" then
                    if threadExists(#registration) then
                      getThread(#registration).getComponent().openFigureUpdate()
                    end if
                  else
                    if me <> "club_icon_image" then
                      if me = "club_bottombar_text2" then
                        return(executeMessage(#show_clubinfo))
                      end if
                      exit
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end