on construct(me)
  pMessage = ""
  pPackageID = ""
  pCardWndID = "Card" && getUniqueID()
  pNoIconPlaceholderName = "icon_placeholder"
  registerMessage(#leaveRoom, me.getID(), #hideCard)
  registerMessage(#changeRoom, me.getID(), #hideCard)
  pIconType = void()
  pIconCode = void()
  pIconColor = void()
  return(1)
  exit
end

on deconstruct(me)
  if windowExists(pCardWndID) then
    removeWindow(pCardWndID)
  end if
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  return(1)
  exit
end

on define(me, tProps)
  pPackageID = tProps.getAt(#id)
  pMessage = tProps.getAt(#Msg)
  me.showCard(tProps.getAt(#loc) + [0, -220])
  return(1)
  exit
end

on showCard(me, tloc)
  if windowExists(pCardWndID) then
    removeWindow(pCardWndID)
  end if
  if voidp(tloc) then
    tloc = [100, 100]
  end if
  if the stage > rect.width - 260 then
    1.setAt(the stage, rect.width - 260)
  end if
  if tloc.getAt(2) < 2 then
    tloc.setAt(2, 2)
  end if
  if not createWindow(pCardWndID, "package_card.window", tloc.getAt(1), tloc.getAt(2)) then
    return(0)
  end if
  tWndObj = getWindow(pCardWndID)
  if tWndObj = 0 then
    return(0)
  end if
  tUserRights = getObject(#session).GET("user_rights")
  tUserCanOpen = getObject(#session).GET("room_owner") or tUserRights.findPos("fuse_pick_up_any_furni")
  if not tUserCanOpen and tWndObj.getElement("open_package") <> 0 then
    tWndObj.getElement("open_package").hide()
  end if
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcCard, me.getID(), #mouseUp)
  tWndObj.getElement("package_msg").setText(pMessage)
  return(1)
  exit
end

on hideCard(me)
  if windowExists(pCardWndID) then
    removeWindow(pCardWndID)
  end if
  return(1)
  exit
end

on openPresent(me)
  return(getThread(#room).getComponent().getRoomConnection().send("PRESENTOPEN", pPackageID))
  exit
end

on showContent(me, tdata)
  if not windowExists(pCardWndID) then
    return(0)
  end if
  pIconType = tdata.getAt(#type)
  pIconCode = tdata.getAt(#code)
  pIconColor = tdata.getAt(#color)
  tMemNum = void()
  if pIconColor = "" then
    pIconColor = void()
  end if
  if me = "ticket" then
    tMemNum = getmemnum("ticket_icon")
  else
    if me = "film" then
      tMemNum = getmemnum("film_icon")
    end if
  end if
  if pIconType contains "*" then
    tDelim = the itemDelimiter
    the itemDelimiter = "*"
    pIconType = pIconType.getProp(#item, 1)
    the itemDelimiter = tDelim
  end if
  if memberExists(pIconCode & "_small") then
    tMemNum = getmemnum(pIconCode & "_small")
  else
    if memberExists("ctlg_pic_small_" & pIconCode) then
      tMemNum = getmemnum("ctlg_pic_small_" & pIconCode)
    end if
  end if
  if tMemNum = 0 then
    tDynThread = getThread(#dynamicdownloader)
    if tDynThread = 0 then
      tImg = getObject("Preview_renderer").renderPreviewImage(void(), void(), pIconColor, pIconType)
    else
      tDownloadIdName = ""
      if pIconType contains "poster" then
        tDownloadIdName = pIconCode
      else
        tDownloadIdName = pIconType
      end if
      tDynComponent = tDynThread.getComponent()
      tRoomSizePrefix = ""
      tRoomThread = getThread(#room)
      if tRoomThread <> 0 then
        tTileSize = tRoomThread.getInterface().getGeometry().getTileWidth()
        if tTileSize = 32 then
          tRoomSizePrefix = "s_"
        end if
      end if
      tDownloadIdName = tRoomSizePrefix & tDownloadIdName
      if not tDynComponent.isAssetDownloaded(tDownloadIdName) then
        tDynComponent.downloadCastDynamically(tDownloadIdName, #unknown, me.getID(), #packetIconDownloadCallback, 1)
        tImg = member(pNoIconPlaceholderName).image
      else
        me.packetIconDownloadCallback(tDownloadIdName)
      end if
    end if
  else
    tImg = image.duplicate()
  end if
  me.feedIconToCard(tImg)
  exit
end

on packetIconDownloadCallback(me, tDownloadedClass)
  if tDownloadedClass contains "poster" then
    tImg = getObject("Preview_renderer").renderPreviewImage(void(), void(), pIconColor, pIconCode)
  else
    tImg = getObject("Preview_renderer").renderPreviewImage(void(), void(), pIconColor, pIconType)
  end if
  me.feedIconToCard(tImg)
  exit
end

on feedIconToCard(me, tImg)
  if ilk(tImg) <> #image then
    return(error(me, "tImg is not an #image", #feedIconToCard, #minor))
  end if
  tWndObj = getWindow(pCardWndID)
  if tWndObj = 0 then
    me.showCard()
    tWndObj = getWindow(pCardWndID)
    if tWndObj = 0 then
      return(0)
    end if
  end if
  tElem = tWndObj.getElement("small_img")
  if tElem = 0 then
    return(0)
  end if
  tWid = tElem.getProperty(#width)
  tHei = tElem.getProperty(#height)
  tCenteredImage = image(tWid, tHei, 32)
  tMatte = tImg.createMatte()
  tXchange = tCenteredImage.width - tImg.width / 2
  tYchange = tCenteredImage.height - tImg.height / 2
  tRect1 = tImg.rect + rect(tXchange, tYchange, tXchange, tYchange)
  tCenteredImage.copyPixels(tImg, tRect1, tImg.rect, [#maskImage:tMatte, #ink:41])
  tElem.feedImage(tCenteredImage)
  tWndObj.getElement("card_icon").hide()
  tWndObj.getElement("small_img").setProperty(#blend, 100)
  tWndObj.getElement("open_package").hide()
  exit
end

on eventProcCard(me, tEvent, tElemID, tParam)
  if tEvent <> #mouseUp then
    return(0)
  end if
  if me = "close" then
    return(me.hideCard())
  else
    if me = "open_package" then
      return(me.openPresent())
    end if
  end if
  exit
end