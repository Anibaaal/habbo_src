property pWindowID, pTargetElementID

on construct me 
  pWindowID = "IG Recommends"
  return TRUE
end

on deconstruct me 
  me.hide()
  return TRUE
end

on renderSubComponents me 
  tService = me.getIGComponent("GameList")
  if (tService = 0) then
    return FALSE
  end if
  if tService.isUpdateTimestampExpired() then
    return(tService.pollContentUpdate())
  end if
  if (tService.getListCount() = 0) then
    return TRUE
  end if
  me.createMyWindow()
  return TRUE
end

on handleUpdate me, tUpdateId, tSenderId 
  put("* IG RecommendedUI Class.handleUpdate" && tUpdateId && tSenderId && windowExists(pWindowID))
  return(me.renderUI())
end

on hide me 
  me.removeMyWindow()
  return TRUE
end

on setTarget me, tTargetID 
  pTargetElementID = tTargetID
end

on createMyWindow me 
  if not windowExists(pWindowID) then
    createWindow(pWindowID, "ig_popup_bg.window")
    tWndObj = getWindow(pWindowID)
    if (tWndObj = 0) then
      return(error(me, "Cannot create window!", #createMyWindow))
    end if
    if not tWndObj.merge("ig_recommeded_popup.window") then
      return(error(me, "Cannot merge in window!", #createMyWindow))
    end if
    tWndObj.lock()
    tWndObj.moveTo(471, 359)
    tWndObj.registerProcedure(#popupEntered, me.getID(), #mouseEnter)
    tWndObj.registerProcedure(#popupLeft, me.getID(), #mouseLeave)
    tWndObj.registerProcedure(#eventProcMouseDown, me.getID(), #mouseUp)
  end if
  me.renderList()
  return TRUE
end

on renderList me 
  tService = me.getIGComponent("GameList")
  if (tService = 0) then
    return FALSE
  end if
  tWndObj = getWindow(pWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  i = 1
  repeat while i <= 3
    me.renderListItem(i, tService.getGameEntry(tService.getListIdByIndex(i)), tWndObj)
    i = (1 + i)
  end repeat
  return TRUE
end

on renderListItem me, tIndex, tGameRef, tWndObj 
  if (tGameRef = 0) then
    tElem = tWndObj.getElement("nav_popup_link_go" & tIndex)
    if (tElem = 0) then
      return FALSE
    end if
    tElem.hide()
  else
    tElem = tWndObj.getElement("nav_popup_link_go" & tIndex)
    if (tElem = 0) then
      return FALSE
    end if
    tElem.show()
    tElem = tWndObj.getElement("info_gamemode" & tIndex)
    if (tElem = 0) then
      return FALSE
    end if
    tImage = tGameRef.getProperty(#game_type_icon)
    if tImage <> 0 then
      tElem.feedImage(tImage)
    end if
    tElem = tWndObj.getElement("ig_level_name" & tIndex)
    if (tElem = 0) then
      return FALSE
    end if
    tElem.setText(tGameRef.getProperty(#level_name))
    tElem = tWndObj.getElement("info_team_amount" & tIndex)
    if (tElem = 0) then
      return FALSE
    end if
    tMemNum = getmemnum("ig_icon_teams_" & tGameRef.getTeamCount())
    if (tMemNum = 0) then
      return FALSE
    end if
    tElem.feedImage(member(tMemNum).image)
    tElem = tWndObj.getElement("ig_players_joined" & tIndex)
    if (tElem = 0) then
      return FALSE
    end if
    tElem.setText(tGameRef.getPlayerCount() & "/" & tGameRef.getMaxPlayerCount())
  end if
  return TRUE
end

on removeMyWindow me 
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  return TRUE
end

on popupEntered me 
  executeMessage(#popupEntered, pTargetElementID)
end

on popupLeft me 
  executeMessage(#popupLeft, pTargetElementID)
end

on eventProcMouseDown me, tEvent, tSprID, tParam, tWndID 
  if (me.getMainThread() = 0) then
    return FALSE
  end if
  if tSprID <> "ig_players_joined1" then
    if tSprID <> "ig_players_joined2" then
      if tSprID <> "ig_players_joined3" then
        if tSprID <> "info_team_amount1" then
          if tSprID <> "info_team_amount2" then
            if tSprID <> "info_team_amount3" then
              if tSprID <> "info_gamemode1" then
                if tSprID <> "info_gamemode2" then
                  if tSprID <> "info_gamemode3" then
                    if tSprID <> "ig_level_name1" then
                      if tSprID <> "ig_level_name2" then
                        if tSprID <> "ig_level_name3" then
                          if tSprID <> "room_obj_disp_bg1" then
                            if tSprID <> "room_obj_disp_bg2" then
                              if tSprID <> "room_obj_disp_bg3" then
                                if tSprID <> "nav_popup_link_go1" then
                                  if tSprID <> "nav_popup_link_go2" then
                                    if (tSprID = "nav_popup_link_go3") then
                                      tIndex = integer(tSprID.getProp(#char, tSprID.length))
                                      if (tIndex = void()) then
                                        return FALSE
                                      end if
                                      tService = me.getIGComponent("GameList")
                                      if (tService = 0) then
                                        return FALSE
                                      end if
                                      tID = tService.getListIdByIndex(tIndex)
                                      if (tID = -1) then
                                        return FALSE
                                      end if
                                      executeMessage(#sendTrackingPoint, "/game/joined/recom")
                                      tService.joinTeamWithLeastMembers(tID)
                                    else
                                      executeMessage(#show_ig, "GameList")
                                    end if
                                    me.Remove()
                                    return TRUE
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
            end if
          end if
        end if
      end if
    end if
  end if
end

on eventProcMouseHover me, tEvent, tSprID, tParam, tWndID 
  put("* IG RecommendedUI Class mousehover")
end
