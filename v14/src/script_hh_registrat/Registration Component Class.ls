property pRegMsgStruct, pState, pFigurePartListLoadedFlag, pAvailableSetListLoadedFlag, pParentEmailAddress, pAgeCheckFlag, pParentEmailNeededFlag, pUserIDFromRegistration

on construct me 
  pValidPartProps = [:]
  pValidPartGroups = [:]
  pFigurePartListLoadedFlag = 0
  pAvailableSetListLoadedFlag = 0
  pState = 0
  pAgeCheckFlag = void()
  pParentEmailNeededFlag = void()
  pParentEmailAddress = ""
  pRegMsgStruct = [:]
  pRegMsgStruct.setAt("parentagree", [#id:1, "type":#boolean])
  pRegMsgStruct.setAt("name", [#id:2, "type":#string])
  pRegMsgStruct.setAt("password", [#id:3, "type":#string])
  pRegMsgStruct.setAt("figure", [#id:4, "type":#string])
  pRegMsgStruct.setAt("sex", [#id:5, "type":#string])
  pRegMsgStruct.setAt("customData", [#id:6, "type":#string])
  pRegMsgStruct.setAt("email", [#id:7, "type":#string])
  pRegMsgStruct.setAt("birthday", [#id:8, "type":#string])
  pRegMsgStruct.setAt("directMail", [#id:9, "type":#boolean])
  pRegMsgStruct.setAt("has_read_agreement", [#id:10, "type":#boolean])
  pRegMsgStruct.setAt("isp_id", [#id:11, "type":#string])
  pRegMsgStruct.setAt("partnersite", [#id:12, "type":#string])
  pRegMsgStruct.setAt("oldpassword", [#id:13, "type":#string])
  registerMessage(#enterRoom, me.getID(), #closeFigureCreator)
  registerMessage(#changeRoom, me.getID(), #closeFigureCreator)
  registerMessage(#leaveRoom, me.getID(), #closeFigureCreator)
  registerMessage(#show_registration, me.getID(), #openFigureCreator)
  registerMessage(#hide_registration, me.getID(), #closeFigureCreator)
  registerMessage(#figure_ready, me.getID(), #figureSystemReady)
end

on deconstruct me 
  unregisterMessage(#enterRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#show_registration, me.getID())
  unregisterMessage(#hide_registration, me.getID())
  unregisterMessage(#figure_ready, me.getID())
  return(me.updateState("reset"))
end

on setBlockTime me, tdata 
  setPref("blocktime", tdata)
  me.closeFigureCreator()
  executeMessage(#alert, [#title:"alert_win_coppa", #Msg:"alert_reg_age", #id:"underage", #modal:1])
  return(removeConnection(getVariable("connection.info.id")))
end

on continueBlocking me 
  me.closeFigureCreator()
  executeMessage(#alert, [#title:"alert_win_coppa", #Msg:"alert_reg_blocked", #id:"underage", #modal:1])
  return(removeConnection(getVariable("connection.info.id")))
end

on getRealtime me 
  getConnection(getVariable("connection.info.id")).send("COPPA_REG_GETREALTIME")
end

on checkBlockTime me 
  tdata = getPref("Blocktime")
  getConnection(getVariable("connection.info.id")).send("COPPA_REG_CHECKTIME", [#string:tdata])
end

on resetBlockTime me 
  setPref("blocktime", "0")
  return(me.updateState("openFigureCreator"))
end

on openFigureCreator me 
  return(me.updateState("openFigureCreator"))
end

on openFigureUpdate me 
  return(me.updateState("openFigureUpdate"))
end

on closeFigureCreator me 
  return(me.getInterface().closeFigureCreator())
end

on reRegistrationRequired me 
  return(me.updateState("openForcedUpdate"))
end

on figureSystemReady me 
  return(me.updateState(pState))
end

on checkUserName me, tNameStr 
  if objectExists(#string_validator) then
    if not getObject(#string_validator).validateString(tNameStr) then
      tFailed = getObject(#string_validator).getFailedChar()
      setText("alert_InvalidChar", replaceChunks(getText("alert_InvalidUserName"), "\\x", tFailed))
      executeMessage(#alert, [#Msg:"alert_InvalidChar", #id:"nameinvalid"])
      return FALSE
    end if
  end if
  pCheckingName = tNameStr
  if connectionExists(getVariable("connection.info.id", #info)) then
    getConnection(getVariable("connection.info.id", #info)).send("APPROVENAME", [#string:tNameStr, #integer:0])
  end if
  return TRUE
end

on sendNewFigureDataToServer me, tPropList 
  tPropList = tPropList.duplicate()
  if not objectExists("Figure_System") then
    return(error(me, "Figure system object not found", #sendNewFigureDataToServer, #major))
  end if
  if not voidp(tPropList.getAt("figure")) then
    tFigure = getObject("Figure_System").GenerateFigureDataToServerMode(tPropList.getAt("figure"), tPropList.getAt("sex"))
    tPropList.setAt("figure", tFigure.getAt("figuretoServer"))
  end if
  if variableExists("user_isp") then
    if not voidp(getVariable("user_isp")) then
      tPropList.setAt("isp_id", getVariable("user_isp"))
    end if
  end if
  if variableExists("user_partnersite") then
    if not voidp(getVariable("user_partnersite")) then
      tPropList.setAt("partnersite", getVariable("user_partnersite"))
    end if
  end if
  tMsg = [:]
  f = 1
  repeat while f <= tPropList.count
    tProp = tPropList.getPropAt(f)
    if voidp(tPropList.getAt(tProp)) then
      return(error(me, "Data missing!!" && tProp, #sendNewFigureDataToServer, #major))
    end if
    tValue = tPropList.getAt(tProp)
    if not voidp(pRegMsgStruct.getAt(tProp)) then
      tMsg.addProp(#short, pRegMsgStruct.getAt(tProp).id)
      if (pRegMsgStruct.getAt(tProp).type = #boolean) then
        tValue = integer(tValue)
      end if
      if (pRegMsgStruct.getAt(tProp).type = #string) and tValue.ilk <> #string then
        tValue = string(tValue)
      end if
      if (pRegMsgStruct.getAt(tProp).type = #short) and tValue.ilk <> #integer then
        tValue = integer(tValue)
      end if
      tMsg.addProp(pRegMsgStruct.getAt(tProp).type, tValue)
    end if
    f = (1 + f)
  end repeat
  if connectionExists(getVariable("connection.info.id")) then
    return(getConnection(getVariable("connection.info.id")).send("REGISTER", tMsg))
  else
    return(error(me, "Connection not found:" && getVariable("connection.info.id"), #sendNewFigureDataToServer, #major))
  end if
end

on sendFigureUpdateToServer me, tPropList 
  tPropList = tPropList.duplicate()
  if not objectExists("Figure_System") then
    return(error(me, "Figure system object not found", #sendFigureUpdateToServer, #major))
  end if
  if not voidp(tPropList.getAt("figure")) then
    tFigure = getObject("Figure_System").GenerateFigureDataToServerMode(tPropList.getAt("figure"), tPropList.getAt("sex"))
    tPropList.setAt("figure", tFigure.getAt("figuretoServer"))
  end if
  if not voidp(tPropList.getAt("password")) then
    if tPropList.getAt("password") <> "" then
      if (tPropList.getAt("password") = void()) then
        return(error(me, "Password was reseted, abort update!", #sendFigureUpdateToServer, #minor))
      end if
      tMsg = [:]
      repeat while ["figure", "sex", "customData", "directMail", "has_read_agreement", "parentagree"] <= 1
        tProp = getAt(1, count(["figure", "sex", "customData", "directMail", "has_read_agreement", "parentagree"]))
        tValue = tPropList.getAt(tProp)
        if getObject(#session).exists("user_" & tProp) then
          tStoredValue = getObject(#session).GET("user_" & tProp)
        end if
        if not [tValue].getPos(tStoredValue) and not voidp(tValue) then
          if not voidp(pRegMsgStruct.getAt(tProp)) then
            tMsg.addProp(#short, pRegMsgStruct.getAt(tProp).id)
            if (pRegMsgStruct.getAt(tProp).type = #boolean) then
              tValue = integer(tValue)
            end if
            if (pRegMsgStruct.getAt(tProp).type = #string) and tValue.ilk <> #string then
              tValue = string(tValue)
            end if
            if (pRegMsgStruct.getAt(tProp).type = #short) and tValue.ilk <> #integer then
              tValue = integer(tValue)
            end if
            tMsg.addProp(pRegMsgStruct.getAt(tProp).type, tValue)
          end if
        end if
      end repeat
      if connectionExists(getVariable("connection.info.id")) then
        return(getConnection(getVariable("connection.info.id")).send("UPDATE", tMsg))
      else
        return(error(me, "Connection not found:" && getVariable("connection.info.id"), #sendFigureUpdateToServer, #major))
      end if
    end if
  end if
end

on newFigureReady me 
  me.closeFigureCreator()
  me.updateState("start")
  return TRUE
end

on figureUpdateReady me 
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("INFORETRIEVE")
  else
    error(me, "Connection not found:" && getVariable("connection.info.id"), #figureUpdateReady, #major)
  end if
  if getObject(#session).exists("conf_parent_email_request_reregistration") then
    if getObject(#session).GET("conf_parent_email_request_reregistration") then
      me.sendParentEmail()
    end if
  end if
  me.closeFigureCreator()
  return(me.updateState("start"))
end

on setAvailableSetList me, tList 
  if pFigurePartListLoadedFlag and not voidp(tList) then
    me.initializeSelectablePartList(tList)
    pAvailableSetListLoadedFlag = 1
    if (pState = "openFigureCreator") then
      return(me.updateState("openFigureCreator"))
    else
      if (pState = "openFigureUpdate") then
        return(me.updateState("openFigureUpdate"))
      end if
    end if
  end if
end

on getAvailableSetList me 
  if (pFigurePartListLoadedFlag = 1) and (pAvailableSetListLoadedFlag = 0) then
    if connectionExists(getVariable("connection.info.id")) then
      getConnection(getVariable("connection.info.id")).send("GETAVAILABLESETS")
    end if
  end if
end

on checkAge me, tAge 
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("AC", tAge)
  end if
  return TRUE
end

on checkEmailAddress me, tEmail 
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("APPROVEEMAIL", [#string:tEmail])
  end if
  return TRUE
end

on parentEmailNeedQuery me, tBirthday, tHabboID 
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("PARENT_EMAIL_REQUIRED", [#string:tBirthday, #string:tHabboID])
  end if
  return TRUE
end

on sendParentEmail me 
  if pParentEmailAddress <> "" then
    tParentEmail = pParentEmailAddress
    if connectionExists(getVariable("connection.info.id")) then
      getConnection(getVariable("connection.info.id")).send("SEND_PARENT_EMAIL", [#string:tParentEmail])
    end if
  end if
  return TRUE
end

on validateParentEmail me, tUserEmail, tParentEmail 
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("VALIDATE_PARENT_EMAIL", [#string:tParentEmail])
  end if
  pParentEmailAddress = tParentEmail
  return TRUE
end

on setAgeCheckResult me, tFlag 
  pAgeCheckFlag = tFlag
  return(me.getInterface().finishRegistration(tFlag))
end

on getAgeCheckResult me 
  return(pAgeCheckFlag)
end

on parentEmailNeedQueryResult me, tFlag 
  pParentEmailNeededFlag = tFlag
  return(me.getInterface().parentEmailQueryStatus(tFlag))
end

on parentEmailValidated me, tFlag 
  if tFlag then
    me.getInterface().parentEmailOk()
  else
    pParentEmailAddress = ""
    me.getInterface().parentEmailIncorrect()
  end if
end

on getParentEmailNeededFlag me 
  return(pParentEmailNeededFlag)
end

on sendUpdateAccountMsg me, tPropList 
  if not ilk(tPropList, #propList) then
    return(error(me, "tPropList was not propertylist:" && tPropList, #sendUpdateAccountMsg, #major))
  else
    if voidp(tPropList.getAt("oldpassword")) or voidp(tPropList.getAt("birthday")) then
      return(error(me, "Missing old password or birthday:" && tPropList, #sendUpdateAccountMsg, #major))
    else
      if voidp(tPropList.getAt("password")) and voidp(tPropList.getAt("email")) then
        return(error(me, "Password or email required:" && tPropList, #sendUpdateAccountMsg, #major))
      else
        if not voidp(tPropList.getAt("password")) and not voidp(tPropList.getAt("email")) then
          return(error(me, "Password and email cannot appear together:" && tPropList, #sendUpdateAccountMsg, #major))
        end if
      end if
    end if
  end if
  tMsg = [:]
  f = 1
  repeat while f <= tPropList.count
    tProp = tPropList.getPropAt(f)
    if voidp(tPropList.getAt(tProp)) then
      return(error(me, "Data missing!!" && tProp, #sendUpdateAccountMsg, #major))
    end if
    tValue = tPropList.getAt(tProp)
    if not voidp(pRegMsgStruct.getAt(tProp)) then
      tMsg.addProp(#short, pRegMsgStruct.getAt(tProp).id)
      if (pRegMsgStruct.getAt(tProp).type = #boolean) then
        tValue = integer(tValue)
      end if
      if (pRegMsgStruct.getAt(tProp).type = #string) and tValue.ilk <> #string then
        tValue = string(tValue)
      end if
      if (pRegMsgStruct.getAt(tProp).type = #short) and tValue.ilk <> #integer then
        tValue = integer(tValue)
      end if
      tMsg.addProp(pRegMsgStruct.getAt(tProp).type, tValue)
    else
      return(error(me, "Data property not found from structs!" && tProp, #sendUpdateAccountMsg, #major))
    end if
    f = (1 + f)
  end repeat
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("UPDATE_ACCOUNT", tMsg)
  end if
end

on sendValidatePassword me, tPassword 
  if voidp(tPassword) or ilk(tPassword) <> #string then
    tPassword = ""
  end if
  tUserName = getObject(#session).GET(#userName)
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("APPROVE_PASSWORD", [#string:tUserName, #string:tPassword])
  end if
  return TRUE
end

on getState me 
  return(pState)
end

on updateState me, tstate, tProps 
  if (tstate = "reset") then
    pState = tstate
    me.construct()
    return FALSE
  else
    if (tstate = "loadFigurePartList") then
      return()
    else
      if (tstate = "initialize") then
        pState = tstate
        tMemName = getVariable("external.figurepartlist.txt")
        if (tMemName = 0) then
          tMemName = ""
        end if
        if not memberExists(tMemName) then
          tValidpartList = void()
          error(me, "Failure while loading part list", #updateState, #minor)
        else
          try()
          tValidpartList = value(member(getmemnum(tMemName)).text)
          if catch() then
            tValidpartList = void()
          end if
        end if
        me.initializeValidPartLists(tValidpartList)
        pFigurePartListLoadedFlag = 1
        setVariable("figurepartlist.loaded", 1)
        if memberExists(tMemName) then
          removeMember(tMemName)
        end if
        return(me.updateState("start"))
      else
        if (tstate = "start") then
          pState = tstate
          return TRUE
        else
          if (tstate = "openFigureCreator") then
            pState = tstate
            if not objectExists("Figure_System") then
              return(error(me, "Figure system object not found", #updateState, #major))
            end if
            if not objectExists(#session) then
              return(error(me, "Session object not found", #updateState, #major))
            end if
            if threadExists(#login) and not connectionExists(getVariable("connection.info.id")) then
              getThread(#login).getComponent().connect()
              me.getInterface().showLoadingWindow()
            else
              if objectExists(#getServerDate) then
                if not getObject(#session).exists("server_date") then
                  getObject(#getServerDate).getDate()
                end if
              end if
              tRegistrationProcessMode = "registration"
              if getObject(#session).exists("conf_parent_email_request") then
                if getObject(#session).GET("conf_parent_email_request") then
                  tRegistrationProcessMode = "parent_email"
                end if
              end if
              if getObject(#session).exists("conf_strong_coppa_required") then
                if getObject(#session).GET("conf_strong_coppa_required") then
                  tRegistrationProcessMode = "parent_email_strong_coppa"
                end if
              end if
              if getObject(#session).GET("conf_coppa") and getPref("Blocktime") > 0 then
                return(me.checkBlockTime())
              end if
              if not getObject("Figure_System").isFigureSystemReady() then
                me.getInterface().showLoadingWindow()
                return FALSE
              else
                me.getInterface().openFigureCreator(tRegistrationProcessMode)
              end if
            end if
            return TRUE
          else
            if (tstate = "openFigureUpdate") then
              pState = tstate
              if not objectExists("Figure_System") then
                return(error(me, "Figure system object not found", #updateState, #major))
              end if
              if not getObject("Figure_System").isFigureSystemReady() then
                me.getInterface().showLoadingWindow("update")
                return()
              end if
              tFigure = getObject("Figure_System").validateFigure(getObject(#session).GET("user_figure"), getObject(#session).GET("user_sex"))
              getObject(#session).set("user_figure", tFigure)
              me.getInterface().showHideFigureCreator("update")
              return TRUE
            else
              if (tstate = "openForcedUpdate") then
                pState = tstate
                if not objectExists("Figure_System") then
                  return(error(me, "Figure system object not found", #updateState, #major))
                end if
                if not getObject("Figure_System").isFigureSystemReady() then
                  me.getInterface().showLoadingWindow("forced")
                  return()
                end if
                tFigure = getObject("Figure_System").validateFigure(getObject(#session).GET("user_figure"), getObject(#session).GET("user_sex"))
                getObject(#session).set("user_figure", tFigure)
                tCoppaFlag = getObject(#session).GET("conf_coppa")
                tParentEmailFlag = getObject(#session).GET("conf_parent_email_request_reregistration")
                if (tCoppaFlag = 1) and (tParentEmailFlag = 0) then
                  me.getInterface().showHideFigureCreator("coppa_forced", 1)
                else
                  if (tCoppaFlag = 1) and (tParentEmailFlag = 1) then
                    me.getInterface().showHideFigureCreator("parent_email_coppa_forced", 1)
                  else
                    if (tCoppaFlag = 0) and (tParentEmailFlag = 1) then
                      me.getInterface().showHideFigureCreator("parent_email_forced", 1)
                    else
                      me.getInterface().showHideFigureCreator("forced", 1)
                    end if
                  end if
                end if
                if getObject(#session).GET("conf_parent_email_request_reregistration") then
                  tTempBirthday = getObject(#session).GET("user_birthday")
                  tBirthday = ""
                  if stringp(tTempBirthday) then
                    tDelim = the itemDelimiter
                    the itemDelimiter = "."
                    if (tTempBirthday.count(#item) = 3) then
                      tBirthday = tTempBirthday.getProp(#item, 3) & "." & tTempBirthday.getProp(#item, 2) & "." & tTempBirthday.getProp(#item, 1)
                    end if
                    the itemDelimiter = tDelim
                  end if
                  tHabboID = getObject(#session).GET("user_name")
                  me.parentEmailNeedQuery(tBirthday, tHabboID)
                end if
                return TRUE
              else
                return(error(me, "Unknown state:" && tstate, #updateState, #minor))
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on tryLoginAfterRegistration me 
  tLoginThread = getThread(#login)
  if (tLoginThread = 0) then
    error(me, "Login thread not found!", #tryLoginAfterRegistration, #major)
    return FALSE
  end if
  tLoginComponent = tLoginThread.getComponent()
  tLoginComponent.pOkToLogin = 1
  tTmp = [:]
  executeMessage(#partnerRegistrationRequired, tTmp)
  if tTmp.getAt("retval") then
    tUserID = pUserIDFromRegistration
    executeMessage(#partnerRegistration, tUserID)
  else
    executeMessage(#performLogin)
  end if
end
