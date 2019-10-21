property pWindowTitle, pOpenWindow, pProps, pHistoryItemHeight, pWriterPlainBoldLeft, pDefaultPrivateRoomIcon, pWriterPlainNormWrap, pResourcesReady, pWriterPlainBoldCent, pWriterPrivPlain, pListItemHeight, pWriterBackTabs, pWriterUnderNormLeft, pHideFullLinkImages, pRoomBackImages, pCatBackImages, pWriterPlainNormLeft, pRoomInfoHeight, pBufferDepth

on construct me 
  pWindowTitle = getText("navigator", "Hotel Navigator")
  pProps = [:]
  pRoomInfoHeight = 96
  pListAreaWidth = 311
  pListItemHeight = 18
  pHistoryItemHeight = 18
  pBufferDepth = 32
  pOpenWindow = "nav_gr0"
  if variableExists("navigator.default.view") then
    tDefView = getVariable("navigator.default.view")
    if (tDefView = "public") then
      pOpenWindow = "nav_pr"
    else
      if (tDefView = "private") then
        pOpenWindow = "nav_gr0"
      else
        pOpenWindow = "nav_gr0"
      end if
    end if
  end if
  pDefaultPrivateRoomIcon = "nav_ico_def_gr"
  if variableExists("navigator.private.room.default.icon") then
    if memberExists(getVariable("navigator.private.room.default.icon")) then
      pDefaultPrivateRoomIcon = getVariable("navigator.private.room.default.icon")
    end if
  end if
  pResourcesReady = 0
  pLastWindowName = ""
  return(me.createImgResources())
end

on deconstruct me 
  if windowExists(#login_a) then
    removeWindow(#login_a)
  end if
  if windowExists(#login_b) then
    removeWindow(#login_b)
  end if
  if windowExists(pWindowTitle) then
    removeWindow(pWindowTitle)
  end if
  return(me.removeImgResources())
end

on getNaviView me 
  if (pOpenWindow = "nav_pr") then
    return(#unit)
  else
    if (pOpenWindow = "nav_gr0") then
      return(#flat)
    else
      if (pOpenWindow = "nav_gr_own") then
        return(#own)
      else
        if (pOpenWindow = "nav_gr_src") then
          return(#src)
        else
          if (pOpenWindow = "nav_gr_fav") then
            return(#fav)
          else
            if pOpenWindow <> "nav_gr_mod" then
              if pOpenWindow <> "nav_gr_mod_b" then
                if pOpenWindow <> "nav_gr_modify_delete1" then
                  if pOpenWindow <> "nav_gr_modify_delete2" then
                    if pOpenWindow <> "nav_gr_modify_delete3" then
                      if (pOpenWindow = "nav_modify_removerights") then
                        return(#mod)
                      else
                        return(#none)
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
  end if
end

on getProperty me, tProp, tView 
  if (tView = void()) then
    tView = me.getNaviView()
  end if
  if (tView = #mod) then
    tView = #own
  end if
  if (tView = 0) then
    return(void())
  end if
  if (pProps.getAt(tView) = void()) then
    return(void())
  end if
  if not voidp(pProps.getAt(tView).getAt(tProp)) then
    return(pProps.getAt(tView).getAt(tProp))
  else
    return(void())
  end if
end

on setProperty me, tProp, tValue, tView 
  if (tView = void()) then
    tView = me.getNaviView()
  end if
  if (tView = 0) then
    return FALSE
  end if
  if (tView = #src) or (tView = #own) or (tView = #fav) and (tProp = #categoryId) then
    tValue = tView
  end if
  if (pProps.getAt(tView) = void()) then
    pProps.setAt(tView, [:])
  end if
  pProps.getAt(tView).setAt(tProp, tValue)
  return TRUE
end

on showNavigator me 
  me.getInterface().setUpdates(1)
  if windowExists(pWindowTitle) then
    getWindow(pWindowTitle).show()
    if (pOpenWindow = "nav_pr") then
      me.sendTrackingCall()
    end if
  else
    return(me.ChangeWindowView(pOpenWindow))
  end if
  return FALSE
end

on hideNavigator me, tHideOrRemove 
  me.getInterface().setUpdates(0)
  me.getInterface().setRecomUpdates(0)
  if voidp(tHideOrRemove) then
    tHideOrRemove = #Remove
  end if
  if windowExists(pWindowTitle) then
    if (tHideOrRemove = #Remove) then
      removeWindow(pWindowTitle)
    else
      getWindow(pWindowTitle).hide()
    end if
  end if
  return TRUE
end

on showhidenavigator me, tHideOrRemove 
  if voidp(tHideOrRemove) then
    tHideOrRemove = #Remove
  end if
  if windowExists(pWindowTitle) then
    if getWindow(pWindowTitle).getProperty(#visible) then
      me.hideNavigator(tHideOrRemove)
    else
      me.showNavigator()
    end if
  else
    me.showNavigator()
  end if
end

on isOpen me 
  if windowExists(pWindowTitle) then
    return(getWindow(pWindowTitle).getProperty(#visible))
  end if
  return FALSE
end

on ChangeWindowView me, tWindowName 
  if (tWindowName = "nav_pr") then
    me.sendTrackingCall()
  end if
  tWndObj = getWindow(pWindowTitle)
  tScrollOffset = 0
  if tWndObj <> 0 then
    if tWindowName contains "nav_pr" and tWndObj.elementExists("nav_scrollbar") then
      tScrollOffset = tWndObj.getElement("nav_scrollbar").getScrollOffset()
    end if
    tWndObj.unmerge()
  else
    tStageWidth = (the stageRight - the stageLeft)
    if not createWindow(pWindowTitle, "habbo_basic.window", (tStageWidth - 375), 20) then
      return(error(me, "Failed to create window for Navigator!", #ChangeWindowView, #major))
    end if
    tWndObj = getWindow(pWindowTitle)
    tWndObj.registerClient(me.getID())
  end if
  if not tWndObj.merge(tWindowName & ".window") then
    return(tWndObj.close())
  end if
  pLastWindowName = tWindowName
  tPassword = 0
  if tWindowName <> "nav_gr_password" then
    if tWindowName <> "nav_gr_trypassword" then
      if (tWindowName = "nav_gr_passwordincorrect") then
        tName = me.getComponent().getNodeProperty(me.getProperty(#viewedNodeId), #name)
        if not stringp(tName) then
          tName = ""
        end if
        getWindow(me.pWindowTitle).getElement("nav_roomname_text").setText(tName)
        tPassword = 1
      else
        if (tWindowName = "nav_remove_rights") then
          nothing()
        else
          pOpenWindow = tWindowName
        end if
      end if
      if tWndObj.elementExists("nav_roomlist") then
        tWndObj.getElement("nav_roomlist").clearImage()
      end if
      tCategoryId = me.getProperty(#categoryId)
      tRoomInfoState = me.getProperty(#roomInfoState)
      if tPassword then
        tWndObj.registerProcedure(#eventProcNavigatorPrivate, me.getID(), #mouseDown)
        tWndObj.registerProcedure(#eventProcNavigatorPrivate, me.getID(), #mouseUp)
        tWndObj.registerProcedure(#eventProcNavigatorPrivate, me.getID(), #keyDown)
        return TRUE
      end if
      tNaviView = me.getNaviView()
      if (tWindowName = #unit) then
        tWndObj.registerProcedure(#eventProcNavigatorPublic, me.getID(), #mouseDown)
        tWndObj.registerProcedure(#eventProcNavigatorPublic, me.getID(), #mouseUp)
        tWndObj.registerProcedure(#eventProcNavigatorPublic, me.getID(), #keyDown)
        me.getComponent().createNaviHistory(tCategoryId)
        me.updateRoomList(tCategoryId, void())
        if (tRoomInfoState = #hide) then
          me.setProperty(#roomInfoState, #show)
          me.setRoomInfoArea(#hide)
        else
          me.showNodeInfo(me.getProperty(#viewedNodeId), tCategoryId)
        end if
        return TRUE
      else
        if tWindowName <> #flat then
          if tWindowName <> #src then
            if tWindowName <> #own then
              if (tWindowName = #fav) then
                tWndObj.registerProcedure(#eventProcNavigatorPrivate, me.getID(), #mouseDown)
                tWndObj.registerProcedure(#eventProcNavigatorPrivate, me.getID(), #mouseUp)
                tWndObj.registerProcedure(#eventProcNavigatorPrivate, me.getID(), #keyDown)
                if (tNaviView = #flat) then
                  me.getComponent().createNaviHistory(tCategoryId)
                  me.updateRoomList(tCategoryId, void())
                else
                  me.getComponent().updateInterface(tCategoryId)
                end if
                if (tRoomInfoState = #hide) then
                  me.setProperty(#roomInfoState, #show)
                  me.setRoomInfoArea(#hide)
                else
                  me.showNodeInfo(me.getProperty(#viewedNodeId), tCategoryId)
                end if
                return TRUE
              else
                if (tWindowName = #mod) then
                  tWndObj.registerProcedure(#eventProcNavigatorModify, me.getID(), #mouseDown)
                  tWndObj.registerProcedure(#eventProcNavigatorModify, me.getID(), #mouseUp)
                  tWndObj.registerProcedure(#eventProcNavigatorModify, me.getID(), #keyDown)
                  if tWndObj.elementExists("nav_choosecategory") then
                    me.prepareCategoryDropMenu(me.getProperty(#viewedNodeId))
                  end if
                  if tWndObj.elementExists("nav_room_name") then
                    tElem = tWndObj.getElement("nav_room_name")
                    tName = me.getComponent().getNodeProperty(me.getProperty(#viewedNodeId), #name)
                    if not stringp(tName) then
                      tName = ""
                    end if
                    tElem.setText(tName)
                  end if
                end if
              end if
              return TRUE
            end if
          end if
        end if
      end if
    end if
  end if
end

on updateRecomRoomList me, tRoomList 
  if (tRoomList.getAt(#children).count = 0) then
    tImage = 0
  else
    tImage = me.renderRoomList(tRoomList.getAt(#children))
  end if
  if windowExists(pWindowTitle) then
    tWndObj = getWindow(pWindowTitle)
    if tWndObj.elementExists("nav_recom_roomlist") then
      tElem = tWndObj.getElement("nav_recom_roomlist")
      if not tImage then
        tElem.clearImage()
      else
        tElem.feedImage(tImage)
      end if
    end if
  end if
  return TRUE
end

on updateRoomList me, tNodeId, tRoomList 
  me.setLoadingCursor(0)
  if listp(tRoomList) then
    tImage = me.renderRoomList(tRoomList)
    if (tNodeId = me.getProperty(#categoryId, #unit)) then
      me.setProperty(#cacheImg, tImage, #unit)
    end if
    if (tNodeId = me.getProperty(#categoryId, #flat)) then
      me.setProperty(#cacheImg, tImage, #flat)
    end if
    if tNodeId <> me.getProperty(#categoryId) and tNodeId <> me.getNaviView() then
      return TRUE
    end if
  else
    if (tNodeId = me.getProperty(#categoryId)) and not voidp(me.getProperty(#cacheImg)) then
      tImage = me.getProperty(#cacheImg)
      me.getComponent().updateInterface(tNodeId)
    else
      return FALSE
    end if
  end if
  tWndObj = getWindow(pWindowTitle)
  if (tWndObj = 0) then
    return FALSE
  end if
  tName = me.getComponent().getNodeProperty(tNodeId, #name)
  if tName <> 0 and tWndObj.elementExists("nav_roomlist_hd") then
    tHeaderImage = me.pWriterPlainBoldLeft.render(tName)
    tWndObj.getElement("nav_roomlist_hd").feedImage(tHeaderImage)
  end if
  tLstElement = tWndObj.getElement("nav_roomlist")
  if (tLstElement = 0) then
    return FALSE
  end if
  tLstElement.feedImage(tImage)
  me.setHideFullRoomsLink()
  tBarElement = tWndObj.getElement("nav_scrollbar")
  if (tBarElement = 0) then
    return TRUE
  end if
  if tBarElement.getScrollOffset() > tImage.height then
    tBarElement.setScrollOffset((tImage.height - tLstElement.getProperty(#height)))
  end if
  return TRUE
end

on setRecomUpdates me, tBool 
  tTimeoutID = #recom_update
  if tBool then
    me.getComponent().updateRecomRooms()
    if timeoutExists(tTimeoutID) then
      return TRUE
    end if
    tInterval = me.getComponent().getRecomUpdateInterval()
    return(createTimeout(tTimeoutID, tInterval, #setRecomUpdates, me.getID(), 1, 0))
  else
    if timeoutExists(tTimeoutID) then
      return(removeTimeout(tTimeoutID))
    end if
  end if
end

on setUpdates me, tBoolean 
  if tBoolean then
    me.getComponent().updateInterface(me.getProperty(#categoryId))
    if timeoutExists(#navigator_update) then
      return TRUE
    end if
    tUpdateInterval = me.getComponent().getUpdateInterval()
    return(createTimeout(#navigator_update, tUpdateInterval, #setUpdates, me.getID(), 1, 0))
  else
    if timeoutExists(#navigator_update) then
      removeTimeout(#navigator_update)
    end if
    return TRUE
  end if
end

on clearRoomList me 
  tWndObj = getWindow(me.pWindowTitle)
  if (tWndObj = 0) then
    return FALSE
  end if
  if tWndObj.elementExists("nav_roomlist") then
    tWndObj.getElement("nav_roomlist").clearImage()
  end if
  if tWndObj.elementExists("nav_roomlist_hd") then
    tWndObj.getElement("nav_roomlist_hd").clearImage()
  end if
  if tWndObj.elementExists("nav_roomlist") then
    tWndObj.getElement("nav_roomlist").clearBuffer()
  end if
  if tWndObj.elementExists("nav_roomlist_hd") then
    tWndObj.getElement("nav_roomlist_hd").clearBuffer()
  end if
  if tWndObj.elementExists("nav_scrollbar") then
    tWndObj.getElement("nav_scrollbar").setScrollOffset(0)
  end if
  return TRUE
end

on renderHistory me, tNodeId, tHistoryTxt, tShowRecoms 
  if not (tNodeId = me.getProperty(#categoryId)) then
    return FALSE
  end if
  tWndObj = getWindow(me.pWindowTitle)
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("nav_roomlistBackTabs")
  if (tElem = 0) then
    return FALSE
  end if
  if not tWndObj.elementExists("nav_recom_roomlist") then
    tShowRecoms = 0
  end if
  if not variableExists("room.recommendations") then
    tShowRecoms = 0
  end if
  if getVariable("room.recommendations") <> 1 then
    tShowRecoms = 0
  end if
  tRecomView = tWndObj.elementExists("nav_recom_roomlist")
  tRoomlistOrigV = me.getProperty(#historyOrigV)
  if (tRoomlistOrigV = void()) then
    tRoomlistOrigV = tWndObj.getElement("nav_roomlist").getProperty(#locV)
    me.setProperty(#historyOrigV, tRoomlistOrigV)
  end if
  tRoomlistAreaOrigV = me.getProperty(#roomlistAreaOrigV)
  if voidp(tRoomlistAreaOrigV) then
    tRoomlistAreaOrigV = tWndObj.getElement("nav_roomlistArea").getProperty(#locV)
    me.setProperty(#roomlistAreaOrigV, tRoomlistAreaOrigV)
  end if
  if tRecomView then
    tRecomsOrigV = me.getProperty(#recomsOrigV)
    if voidp(tRecomsOrigV) then
      tRecomsOrigV = tWndObj.getElement("nav_recom_roomlist_hd").getProperty(#locV)
      me.setProperty(#recomsOrigV, tRecomsOrigV)
    end if
  end if
  if tShowRecoms then
    tRecomHeaderElem = tWndObj.getElement("nav_recom_roomlist_hd")
    tRecomListElem = tWndObj.getElement("nav_recom_roomlist")
    tRecomListElem.show()
  end if
  tItemCount = tHistoryTxt.count(#line)
  if (tHistoryTxt = "") then
    tItemCount = 0
  end if
  tRoomlistCurrentV = tWndObj.getElement("nav_roomlist").getProperty(#locV)
  tRoomlistOffset = (tRoomlistOrigV - tRoomlistCurrentV)
  tHistoryOffset = (tItemCount * pHistoryItemHeight)
  if (me.getNaviView() = #flat) and tItemCount > 0 then
    tHistoryOffset = (tHistoryOffset + 7)
  end if
  tRoomlistOffset = (tRoomlistOffset + tHistoryOffset)
  if tShowRecoms then
    tRoomlistOffset = (tRoomlistOffset + 80)
    tHeaderImage = pWriterPlainBoldLeft.render(getText("nav_recommended_rooms")).duplicate()
    tRecomHeaderElem.feedImage(tHeaderImage)
    me.getComponent().showHideRefreshRecoms(1, 1)
  end if
  if tShowRecoms then
    tRecomsCurrentV = tWndObj.getElement("nav_recom_roomlist_hd").getProperty(#locV)
    tRecomsOffset = (tRecomsOrigV - tRecomsCurrentV)
    tRecomsOffset = (tRecomsOffset + tHistoryOffset)
    tElemList = []
    tElemList.add(tWndObj.getElement("nav_recom_roomlist"))
    tElemList.add(tWndObj.getElement("nav_recom_roomlist_hd"))
    tElemList.add(tWndObj.getElement("nav_refresh_recoms"))
    call(#moveBy, tElemList, 0, tRecomsOffset)
  end if
  if not tShowRecoms and tWndObj.elementExists("nav_recom_roomlist_hd") then
    tWndObj.getElement("nav_recom_roomlist_hd").clearImage()
    tWndObj.getElement("nav_recom_roomlist").clearImage()
    tWndObj.getElement("nav_recom_roomlist").hide()
    me.getComponent().showHideRefreshRecoms(0, 1)
  end if
  tRoomlistAreaCurrentV = tWndObj.getElement("nav_roomlistArea").getProperty(#locV)
  tAreaOffset = (tRoomlistAreaOrigV - tRoomlistAreaCurrentV)
  if not tShowRecoms then
    tAreaOffset = (tAreaOffset + tHistoryOffset)
  end if
  if tHistoryOffset > 0 and tShowRecoms then
    tAreaOffset = (tAreaOffset + tHistoryOffset)
  end if
  tWndObj.getElement("nav_roomlist_hd").moveBy(0, tRoomlistOffset)
  tScaleList = []
  tScaleList.add(tWndObj.getElement("nav_roomlist"))
  tScaleList.add(tWndObj.getElement("nav_scrollbar"))
  tScaleList.add(tWndObj.getElement("nav_hidefull"))
  call(#moveBy, tScaleList, 0, tRoomlistOffset)
  call(#resizeBy, tScaleList, 0, -tRoomlistOffset)
  tAreaElem = tWndObj.getElement("nav_roomlistArea")
  tAreaElem.moveBy(0, tAreaOffset)
  tAreaElem.resizeBy(0, -tAreaOffset)
  tTextImg = me.pWriterBackTabs.render(tHistoryTxt)
  if variableExists("nav_roomlist_marginv") then
    tMargin = getVariable("nav_roomlist_marginv")
    tTempImg = image(tTextImg.width, (tTextImg.height + tMargin), me.pBufferDepth)
    tTempImg.copyPixels(tTextImg, (tTextImg.rect + rect(0, tMargin, 0, tMargin)), tTextImg.rect)
    tTextImg = tTempImg
  end if
  tWndObj.getElement("nav_roomlistBackLinks").feedImage(tTextImg)
  if tShowRecoms then
    me.setRecomUpdates(1)
  else
    me.setRecomUpdates(0)
  end if
end

on showNodeInfo me, tNodeId, tCategoryId 
  me.setLoadingCursor(0)
  if not windowExists(pWindowTitle) then
    return FALSE
  end if
  tWndObj = getWindow(pWindowTitle)
  tElem = tWndObj.getElement("nav_roomnfo_hd")
  if (tElem = 0) then
    return FALSE
  end if
  if not voidp(tNodeId) then
    tNodeInfo = me.getComponent().getNodeInfo(tNodeId, tCategoryId)
  end if
  if not listp(tNodeInfo) then
    tNodeInfo = 0
  else
    if (tNodeInfo.getAt(#nodeType) = 0) then
      tNodeInfo = 0
    end if
  end if
  me.setRoomInfoArea(#show)
  tView = me.getNaviView()
  if (tNodeInfo = 0) then
    if (tView = #unit) then
      tIconName = "nav_ico_def_pr"
      tRoomDesc = getText("nav_public_helptext")
      tHeaderTxt = getText("nav_public_helptext_hd")
    else
      if (tView = #src) then
        tIconName = "nav_ico_def_src"
        tRoomDesc = getText("nav_search_helptext")
        tHeaderTxt = getText("nav_private_helptext_hd")
      else
        if (tView = #fav) then
          tIconName = "nav_ico_def_fav"
          tRoomDesc = getText("nav_favourites_helptext")
          tHeaderTxt = getText("nav_private_helptext_hd")
        else
          if (tView = #own) then
            tIconName = "nav_ico_def_own"
            tRoomDesc = getText("nav_ownrooms_helptext")
            tHeaderTxt = getText("nav_private_helptext_hd")
          else
            tIconName = pDefaultPrivateRoomIcon
            tRoomDesc = getText("nav_private_helptext")
            tHeaderTxt = getText("nav_private_helptext_hd")
            if textExists("nav_private_helptext_hd_main") then
              tHeaderTxt = getText("nav_private_helptext_hd_main")
            end if
          end if
        end if
      end if
    end if
    if tWndObj.elementExists("nav_modify_button") then
      tWndObj.getElement("nav_modify_button").hide()
    end if
    if tWndObj.elementExists("nav_addtofavourites_button") then
      tWndObj.getElement("nav_addtofavourites_button").hide()
    end if
    if tWndObj.elementExists("nav_removefavourites_button") then
      tWndObj.getElement("nav_removefavourites_button").hide()
    end if
    tWndObj.getElement("nav_go_button").hide()
  else
    if (tView = #unit) then
      tTextId = "nav_venue_" & tNodeInfo.getAt(#unitStrId) & "/" & tNodeInfo.getAt(#door) & "_desc"
      if not textExists(tTextId) then
        tDelim = the itemDelimiter
        the itemDelimiter = "_"
        tTextId = "nav_venue_" & tNodeInfo.getAt(#unitStrId).getProp(#item, 1, (tNodeInfo.getAt(#unitStrId).count(#item) - 1)) & "_desc"
        the itemDelimiter = tDelim
      end if
      tRoomDesc = getText(tTextId)
      tIconName = "thumb." & tNodeInfo.getAt(#unitStrId)
      if not memberExists(tIconName) then
        tDelim = the itemDelimiter
        the itemDelimiter = "_"
        tIconName = tIconName.getProp(#item, 1, (tIconName.count(#item) - 1))
        the itemDelimiter = tDelim
      end if
      if not memberExists(tIconName) then
        tIconName = "nav_ico_def_pr"
      end if
      if voidp(tNodeInfo.getAt(#usercount)) then
        tNodeInfo.setAt(#usercount, 0)
      end if
      if voidp(tNodeInfo.getAt(#maxUsers)) then
        tNodeInfo.setAt(#maxUsers, 0)
      end if
      tHeaderTxt = tNodeInfo.getAt(#name) & space() & "(" & tNodeInfo.getAt(#usercount) & "/" & tNodeInfo.getAt(#maxUsers) & ") "
      if tWndObj.elementExists("nav_addtofavourites_button") then
        tWndObj.getElement("nav_addtofavourites_button").show()
      end if
      tWndObj.getElement("nav_go_button").show()
    else
      if voidp(tNodeInfo.getAt(#name)) then
        tNodeInfo.setAt(#name, "-")
      end if
      if voidp(tNodeInfo.getAt(#usercount)) then
        tNodeInfo.setAt(#usercount, 0)
      end if
      if voidp(tNodeInfo.getAt(#maxUsers)) then
        tNodeInfo.setAt(#maxUsers, 0)
      end if
      if voidp(tNodeInfo.getAt(#owner)) then
        tNodeInfo.setAt(#owner, "-")
      end if
      if voidp(tNodeInfo.getAt(#description)) then
        tNodeInfo.setAt(#description, "-")
      end if
      if getObject(#session).GET("user_rights").getOne("fuse_see_flat_ids") <> 0 then
        tNameTxt = tNodeInfo.getAt(#name) && "(id: " & tNodeInfo.getAt(#flatId) & ")"
      else
        tNameTxt = tNodeInfo.getAt(#name)
      end if
      tHeaderTxt = tNameTxt & "\r" & "(" & tNodeInfo.getAt(#usercount) & "/" & tNodeInfo.getAt(#maxUsers) & ") "
      tHeaderTxt = tHeaderTxt & getText("nav_owner") & ":" && tNodeInfo.getAt(#owner)
      tRoomDesc = tNodeInfo.getAt(#description)
      if (tView = "open") then
        tIconName = "door_open"
      else
        if (tView = "closed") then
          tIconName = "door_closed"
        else
          if (tView = "password") then
            tIconName = "door_password"
          else
            tNodeInfo.setAt(#door, "open")
            tIconName = "door_open"
          end if
        end if
      end if
      if tWndObj.elementExists("nav_modify_button") then
        tWndObj.getElement("nav_modify_button").show()
      end if
      if tWndObj.elementExists("nav_addtofavourites_button") then
        tWndObj.getElement("nav_addtofavourites_button").show()
      end if
      if tWndObj.elementExists("nav_removefavourites_button") then
        tWndObj.getElement("nav_removefavourites_button").show()
      end if
      if tWndObj.elementExists("nav_go_button") then
        tWndObj.getElement("nav_go_button").show()
      end if
    end if
  end if
  tHeaderImage = pWriterPlainBoldLeft.render(tHeaderTxt)
  tWidth = tElem.getProperty(#width)
  pWriterPlainNormWrap.define([#rect:rect(0, 0, tWidth, 0)])
  tImage = pWriterPlainNormWrap.render(tRoomDesc)
  tMargin = 2
  tDataImage = image(tWidth, ((tHeaderImage.height + tMargin) + tImage.height), 8)
  tDataImage.copyPixels(tHeaderImage, tHeaderImage.rect, tHeaderImage.rect)
  tSourceRect = rect(0, 0, tImage.width, tImage.height)
  tTargetRect = rect(0, (tHeaderImage.height + tMargin), tImage.width, ((tImage.height + tHeaderImage.height) + tMargin))
  tDataImage.copyPixels(tImage, tTargetRect, tSourceRect)
  tElem.feedImage(tDataImage)
  if memberExists(tIconName) and tWndObj.elementExists("nav_roomnfo_icon") then
    tElemID = "nav_roomnfo_icon"
    tTempImg = member(getmemnum(tIconName)).image
    tTempImg = tTempImg.trimWhiteSpace()
    tElement = tWndObj.getElement(tElemID)
    tWidth = tElement.getProperty(#width)
    tHeight = tElement.getProperty(#height)
    tDepth = tElement.getProperty(#depth)
    tPrewImg = image(tWidth, tHeight, tDepth)
    tdestrect = (tPrewImg.rect - tTempImg.rect)
    tdestrect = rect((tdestrect.width / 2), (tdestrect.height / 2), (tTempImg.width + (tdestrect.width / 2)), ((tdestrect.height / 2) + tTempImg.height))
    tPrewImg.copyPixels(tTempImg, tdestrect, tTempImg.rect, [#ink:8])
    tElement.clearImage()
    tElement.feedImage(tPrewImg)
  end if
  return TRUE
end

on createImgResources me 
  if pResourcesReady then
    return FALSE
  end if
  tPlain = getStructVariable("struct.font.plain")
  tBold = getStructVariable("struct.font.bold")
  tLink = getStructVariable("struct.font.link")
  createWriter("nav_plain_norm_left", tPlain)
  pWriterPlainNormLeft = getWriter("nav_plain_norm_left")
  createWriter("nav_plain_bold_left", tBold)
  pWriterPlainBoldLeft = getWriter("nav_plain_bold_left")
  createWriter("nav_under_norm_left", tLink)
  pWriterUnderNormLeft = getWriter("nav_under_norm_left")
  createWriter("nav_plain_bold_cent", tBold)
  pWriterPlainBoldCent = getWriter("nav_plain_bold_cent")
  pWriterPlainBoldCent.define([#alignment:#center])
  createWriter("nav_plain_norm_wrap", tPlain)
  pWriterPlainNormWrap = getWriter("nav_plain_norm_wrap")
  pWriterPlainNormWrap.define([#wordWrap:1])
  createWriter("nav_private_plain", tPlain)
  pWriterPrivPlain = getWriter("nav_private_plain")
  pWriterPrivPlain.define([#wordWrap:0, #fixedLineSpace:pListItemHeight])
  createWriter("nav_backtabs_plain", tBold)
  pWriterBackTabs = getWriter("nav_backtabs_plain")
  pWriterBackTabs.define([#wordWrap:0, #fixedLineSpace:pHistoryItemHeight, #color:rgb(51, 102, 102)])
  pGoLinkTextImg = pWriterUnderNormLeft.render(getText("nav_gobutton")).duplicate()
  pWriterUnderNormLeft.define([#color:rgb(212, 121, 121)])
  pFullLinkTextImg = pWriterUnderNormLeft.render(getText("nav_fullbutton")).duplicate()
  pWriterUnderNormLeft.define([#color:rgb(0, 0, 0)])
  pOpenLinkTextImg = pWriterUnderNormLeft.render(getText("nav_openbutton")).duplicate()
  createWriter("nav_showfull", getStructVariable("struct.font.link"))
  tWriter = getWriter("nav_showfull")
  tWriter.define([#wordWrap:0, #color:rgb("#7B9498"), #alignment:#right])
  pHideFullLinkImages = [:]
  pHideFullLinkImages.setAt(#show, tWriter.render(getText("nav_showfull")).duplicate())
  pHideFullLinkImages.setAt(#hide, tWriter.render(getText("nav_hidefull")).duplicate())
  removeWriter("nav_showfull")
  tWriter = void()
  createWindow("naviTempWindow")
  tTempWindowObj = getWindow("naviTempWindow")
  pRoomBackImages = []
  pRoomBackImages.add(createRoomItemImage(1, paletteIndex(81)))
  pRoomBackImages.add(createRoomItemImage(2, paletteIndex(128)))
  pRoomBackImages.add(createRoomItemImage(3, paletteIndex(129)))
  pRoomBackImages.add(createRoomItemImage(4, paletteIndex(130)))
  pRoomBackImages.add(createRoomItemImage(5, paletteIndex(131)))
  pCatBackImages = []
  pCatBackImages.add(createCatItemImage(1, paletteIndex(81)))
  pCatBackImages.add(createCatItemImage(2, paletteIndex(128)))
  pCatBackImages.add(createCatItemImage(3, paletteIndex(129)))
  pCatBackImages.add(createCatItemImage(4, paletteIndex(130)))
  removeWindow("naviTempWindow")
  pResourcesReady = 1
  return TRUE
end

on removeImgResources me 
  if not pResourcesReady then
    return FALSE
  end if
  removeWriter(pWriterPlainNormLeft.getID())
  pWriterPlainNormLeft = void()
  removeWriter(pWriterPlainBoldLeft.getID())
  pWriterPlainBoldLeft = void()
  removeWriter(pWriterUnderNormLeft.getID())
  pWriterUnderNormLeft = void()
  removeWriter(pWriterPlainBoldCent.getID())
  pWriterPlainBoldCent = void()
  removeWriter(pWriterPlainNormWrap.getID())
  pWriterPlainNormWrap = void()
  removeWriter(pWriterPrivPlain.getID())
  pWriterPrivPlain = void()
  removeWriter(pWriterBackTabs.getID())
  pWriterBackTabs = void()
  pHideFullLinkImages = void()
  pResourcesReady = 0
  return TRUE
end

on createCatItemImage tNum, tColor 
  tImg = image(311, 16, 8, member("nav_ui_palette"))
  tSrc = member("nav_rw_lf" & tNum).image
  tImg.copyPixels(tSrc, tSrc.rect, tSrc.rect)
  tImg.fill(6, 0, 311, 16, tColor)
  tSrc = member("nav_rw_lf" & tNum).image
  tImg.copyPixels(tSrc, [point(311, 0), point(305, 0), point(305, 16), point(311, 16)], tSrc.rect)
  tSrc = member("nav_rw_plus").image
  tImg.copyPixels(tSrc, rect(6, 4, 14, 12), tSrc.rect, [#ink:36])
  tSrc = member("nav_rw_arr").image
  tImg.copyPixels(tSrc, rect(286, 4, 293, 12), tSrc.rect, [#ink:36])
  tImg.copyPixels(tSrc, rect(293, 4, 300, 12), tSrc.rect, [#ink:36])
  tImg.copyPixels(tSrc, rect(300, 4, 307, 12), tSrc.rect, [#ink:36])
  return(tImg)
end

on createRoomItemImage tNum, tColor 
  tImg = image(311, 16, 8, member("nav_ui_palette"))
  tSrc = member("nav_rw_lf").image
  tImg.copyPixels(tSrc, tSrc.rect, tSrc.rect)
  tImg.fill(6, 0, 246, 16, paletteIndex(82))
  tSrc = member("nav_rw_lf").image
  tImg.copyPixels(tSrc, [point(251, 0), point(245, 0), point(245, 16), point(251, 16)], tSrc.rect)
  tSrc = member("nav_rw_lf" & tNum).image
  tImg.copyPixels(tSrc, rect(253, 0, 259, 16), tSrc.rect)
  tImg.fill(259, 0, 305, 16, tColor)
  tSrc = member("nav_rw_lf" & tNum).image
  tImg.copyPixels(tSrc, [point(311, 0), point(305, 0), point(305, 16), point(311, 16)], tSrc.rect)
  tSrc = member("nav_rw_arr").image
  tImg.copyPixels(tSrc, rect(300, 4, 307, 12), tSrc.rect, [#ink:36])
  return(tImg)
end

on renderRoomList me, tList 
  if not listp(tList) then
    return FALSE
  end if
  tCount = tList.count
  tListHeight = (tCount * me.pListItemHeight)
  tTargetImg = image(me.pListAreaWidth, tListHeight, me.pBufferDepth)
  tLockMemImgA = member(getmemnum("lock1")).image
  tLockMemImgB = member(getmemnum("lock2")).image
  tNameTxt = ""
  i = 1
  repeat while i <= tCount
    tItem = tList.getAt(i)
    tItemName = tItem.getAt(#name)
    tNameTxt = tNameTxt & tItemName & "\r"
    if tItem.getAt(#maxUsers) < 1 then
      tItem.setAt(#maxUsers, 25)
    end if
    tUserStatus = (float(tItem.getAt(#usercount)) / tItem.getAt(#maxUsers))
    if (tItem.getAt(#nodeType) = 0) then
      me.renderRoomListItem(#cat, i, tTargetImg, tUserStatus)
    else
      me.renderRoomListItem(#room, i, tTargetImg, tUserStatus, tItem.getAt(#nodeType))
    end if
    if (tItem.getAt(#door) = "closed") then
      tLockImg = tLockMemImgA
    else
      if (tItem.getAt(#door) = "password") then
        tLockImg = tLockMemImgB
      else
        tLockImg = 0
      end if
    end if
    if tLockImg <> 0 then
      tSrcRect = tLockImg.rect
      tLocV = ((i - 1) * me.pListItemHeight)
      tdestrect = (tSrcRect + rect(7, (tLocV + 5), 7, (tLocV + 5)))
      tTargetImg.copyPixels(tLockImg, tdestrect, tSrcRect, [#ink:36])
    end if
    i = (1 + i)
  end repeat
  if variableExists("nav_roomlist_marginv") then
    tNameVertMargin = getVariable("nav_roomlist_marginv")
  else
    tNameVertMargin = 0
  end if
  tNameImage = me.pWriterPrivPlain.render(tNameTxt)
  tNameRect = tNameImage.rect.duplicate()
  if tNameRect.width > 230 then
    tNameRect.setAt(3, 230)
  end if
  tTargetImg.copyPixels(tNameImage, (tNameRect + rect(17, (-5 + tNameVertMargin), 17, (-5 + tNameVertMargin))), tNameRect)
  return(tTargetImg)
end

on renderRoomListItem me, ttype, tNum, tTargetImg, tUserStatus, tNodeType 
  if (tNodeType = 1) then
    if (tUserStatus = 0) then
      tBackImgId = 1
    else
      if tUserStatus < 0.34 then
        tBackImgId = 2
      else
        if tUserStatus < 0.76 then
          tBackImgId = 3
        else
          if tUserStatus < 0.99 then
            tBackImgId = 4
          else
            tBackImgId = 5
          end if
        end if
      end if
    end if
  else
    if (tUserStatus = 0) then
      tBackImgId = 1
    else
      if tUserStatus < 0.34 then
        tBackImgId = 2
      else
        if tUserStatus < 0.76 then
          tBackImgId = 3
        else
          if tUserStatus < 0.99 or (ttype = #cat) then
            tBackImgId = 4
          else
            tBackImgId = 5
          end if
        end if
      end if
    end if
  end if
  if (ttype = #room) then
    tBackImg = me.getProp(#pRoomBackImages, tBackImgId)
  else
    tBackImg = me.getProp(#pCatBackImages, tBackImgId)
  end if
  tLocV = ((tNum - 1) * me.pListItemHeight)
  tdestrect = (tBackImg.rect + rect(0, tLocV, 0, tLocV))
  tTargetImg.copyPixels(tBackImg, tdestrect, tBackImg.rect)
  if (ttype = #room) then
    tAddOffset = 0
    if (tBackImgId = 5) then
      tLinkImage = me.pFullLinkTextImg
      if variableExists("nav_full_link_voffset") then
        tAddOffset = getVariable("nav_full_link_voffset")
      end if
    else
      tLinkImage = me.pGoLinkTextImg
      if variableExists("nav_go_link_voffset") then
        tAddOffset = getVariable("nav_go_link_voffset")
      end if
    end if
    tX1 = ((tBackImg.width - tLinkImage.width) - 12)
    tX2 = (tX1 + tLinkImage.width)
    tY1 = ((3 + tLocV) + tAddOffset)
    tY2 = (tY1 + tLinkImage.height)
    tdestrect = rect(tX1, tY1, tX2, tY2)
    tTargetImg.copyPixels(tLinkImage, tdestrect, tLinkImage.rect, [#bgColor:rgb("#DDDDDD"), #ink:36])
  else
    tAddOffset = 0
    if variableExists("nav_open_link_voffset") then
      tAddOffset = getVariable("nav_open_link_voffset")
    end if
    tX1 = ((tBackImg.width - me.pOpenLinkTextImg.width) - 27)
    tX2 = (tX1 + me.pOpenLinkTextImg.width)
    tY1 = ((3 + tLocV) + tAddOffset)
    tY2 = (tY1 + me.pOpenLinkTextImg.height)
    tdestrect = rect(tX1, tY1, tX2, tY2)
    tTargetImg.copyPixels(me.pOpenLinkTextImg, tdestrect, me.pOpenLinkTextImg.rect, [#bgColor:rgb("#DDDDDD"), #ink:36])
  end if
  return TRUE
end

on setHideFullRoomsLink me 
  if not windowExists(pWindowTitle) then
    return FALSE
  end if
  tWndObj = getWindow(pWindowTitle)
  tElem = tWndObj.getElement("nav_hidefull")
  if (tElem = 0) then
    return FALSE
  end if
  tstate = me.getComponent().getCurrentNodeMask()
  if tstate then
    tImage = pHideFullLinkImages.getAt(#show)
  else
    tImage = pHideFullLinkImages.getAt(#hide)
  end if
  tOffX = (tImage.width - tElem.getProperty(#width))
  tOffY = 0
  if variableExists("nav_showhide_full_voffset") then
    tOffY = (tOffY + getVariable("nav_showhide_full_voffset"))
  end if
  tElem.feedImage(tImage)
  tElem.adjustOffsetTo(tOffX, tOffY)
  return TRUE
end

on setRoomInfoArea me, tstate 
  if not windowExists(me.pWindowTitle) then
    return FALSE
  end if
  if (me.getProperty(#roomInfoState) = void()) then
    me.setProperty(#roomInfoState, #show)
  end if
  if (tstate = me.getProperty(#roomInfoState)) then
    return FALSE
  end if
  me.setProperty(#roomInfoState, tstate)
  if (tstate = #hide) then
    me.setProperty(#viewedNodeId, void())
  end if
  tWndObj = getWindow(me.pWindowTitle)
  tScaleElemList = [tWndObj.getElement("nav_roomlist"), tWndObj.getElement("nav_scrollbar"), tWndObj.getElement("nav_roomlistArea")]
  tOffset = pRoomInfoHeight
  if (tstate = #show) then
    tOffset = -tOffset
  end if
  call(#resizeBy, tScaleElemList, 0, tOffset)
  return TRUE
end

on setLoadingCursor me, tstate 
  if tstate then
    setcursor(#timer)
  else
    setcursor(#arrow)
  end if
end

on renderLoadingText me, tTempElementId 
  if voidp(tTempElementId) then
    return FALSE
  end if
  tElem = getWindow(me.pWindowTitle).getElement(tTempElementId)
  tWidth = tElem.getProperty(#width)
  tHeight = tElem.getProperty(#height)
  tTempImg = image(tWidth, tHeight, pBufferDepth)
  tTextImg = pWriterPlainBoldCent.render(getText("loading"))
  tOffX = ((tWidth - tTextImg.width) / 2)
  tOffY = ((tHeight - tTextImg.height) / 2)
  tDstRect = (tTextImg.rect + rect(tOffX, tOffY, tOffX, tOffY))
  tTempImg.copyPixels(tTextImg, tDstRect, tTextImg.rect)
  tElem.feedImage(tTempImg)
  return TRUE
end

on flipImage me, tImg_a 
  tImg_b = image(tImg_a.width, tImg_a.height, tImg_a.depth)
  tQuad = [point(tImg_a.width, 0), point(0, 0), point(0, tImg_a.height), point(tImg_a.width, tImg_a.height)]
  tImg_b.copyPixels(tImg_a, tQuad, tImg_a.rect)
  return(tImg_b)
end

on updatePasswordAsterisks me, tParams 
  if not windowExists(tParams.getAt(1)) then
    return FALSE
  end if
  tWndObj = getWindow(tParams.getAt(1))
  if not tWndObj.elementExists(tParams.getAt(2)) then
    return FALSE
  end if
  tElementId = tParams.getAt(2)
  tElement = tWndObj.getElement(tParams.getAt(2))
  tPwdTxt = tElement.getText()
  tPreviousTxt = me.getProp(#pFlatPasswords, tElementId)
  tPos = 1
  repeat while tPos <= tPwdTxt.length
    tNewChar = chars(tPwdTxt, tPos, tPos)
    if tNewChar <> "*" then
      tPreviousTxt = tPreviousTxt & tNewChar
    end if
    tPos = (1 + tPos)
  end repeat
  me.setProp(#pFlatPasswords, tElementId, tPreviousTxt)
  tStars = ""
  i = 1
  repeat while i <= me.getPropRef(#pFlatPasswords, tElementId).length
    tStars = tStars & "*"
    i = (1 + i)
  end repeat
  tElement.setText(tStars)
end

on sendTrackingCall me 
  executeMessage(#sendTrackingPoint, "/navigator")
end
