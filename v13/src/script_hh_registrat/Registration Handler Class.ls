on construct(me)
  return(me.regMsgList(1))
  exit
end

on deconstruct(me)
  return(me.regMsgList(0))
  exit
end

on handle_ok(me, tMsg)
  if me.getComponent().pState = "openFigureCreator" then
    me.getComponent().updateState("openFigureCreator")
  end if
  exit
end

on handle_login_ok(me, tMsg)
  if getObject(#session).exists("conf_parent_email_request") then
    if getObject(#session).get("conf_parent_email_request") then
      me.getComponent().sendParentEmail()
    end if
  end if
  exit
end

on handle_regok(me, tMsg)
  tUserID = tMsg.GetStrFrom()
  me.getComponent().pUserIDFromRegistration = tUserID
  exit
end

on handle_updateok(me, tMsg)
  me.getComponent().figureUpdateReady()
  exit
end

on handle_approvenamereply(me, tMsg)
  if me.getComponent().pCheckingName = void() then
    return(1)
  end if
  me.getComponent().pCheckingName = void()
  tParm = tMsg.GetIntFrom(tMsg)
  if me = 0 then
    me.getInterface().userNameOk()
  else
    if me = 1 then
      me.getInterface().userNameTooLong()
    else
      if me = 2 then
        me.getInterface().userNameUnacceptable()
      else
        if me = 3 then
          me.getInterface().userNameUnacceptable()
        else
          if me = 4 then
            me.getInterface().userNameAlreadyReserved()
          end if
        end if
      end if
    end if
  end if
  return(1)
  exit
end

on handle_nameunacceptable(me, tMsg)
  tParm = tMsg.GetIntFrom(tMsg)
  if tParm = 0 then
    me.getInterface().userNameUnacceptable()
  end if
  exit
end

on handle_availablesets(me, tMsg)
  tSets = value(tMsg.content)
  if not listp(tSets) then
    tSets = []
  end if
  if count(tSets) < 2 then
    tSets = void()
  end if
  if objectExists("Figure_System") then
    getObject("Figure_System").setAvailableSetList(tSets)
  end if
  exit
end

on handle_acr(me, tMsg)
  me.getComponent().setAgeCheckResult(tMsg.content)
  exit
end

on handle_reregistrationrequired(me, tMsg)
  me.getComponent().reRegistrationRequired()
  exit
end

on handle_coppa_checktime(me, tMsg)
  tParm = tMsg.GetIntFrom(tMsg)
  if tParm then
    me.getComponent().resetBlockTime()
  else
    me.getComponent().continueBlocking()
  end if
  return(1)
  exit
end

on handle_coppa_getrealtime(me, tMsg)
  tdata = tMsg.content
  if not voidp(tdata) then
    me.getComponent().setBlockTime(tdata)
  end if
  return(1)
  exit
end

on handle_parent_email_required(me, tMsg)
  tFlag = tMsg.GetIntFrom(tMsg)
  me.getComponent().parentEmailNeedQueryResult(tFlag)
  return(1)
  exit
end

on handle_parent_email_validated(me, tMsg)
  tFlag = tMsg.GetIntFrom(tMsg)
  me.getComponent().parentEmailValidated(tFlag)
  return(1)
  exit
end

on handle_update_account(me, tMsg)
  tParam = tMsg.GetIntFrom(tMsg)
  me.getInterface().responseToAccountUpdate(tParam)
  return(1)
  exit
end

on handle_email_approved(me, tMsg)
  me.getInterface().userEmailOk()
  return(1)
  exit
end

on handle_email_rejected(me, tMsg)
  me.getInterface().userEmailUnacceptable()
  return(1)
  exit
end

on handle_update_request(me, tMsg)
  tConn = tMsg.connection
  if voidp(tConn) then
    return(0)
  end if
  tUpdateFlag = tConn.GetIntFrom()
  tForceFlag = tConn.GetIntFrom()
  if me = 0 then
    tMsg = getText("update_email_suggest", void())
    me.getInterface().openEmailUpdate(tForceFlag, tMsg)
  else
    if me = 1 then
      tMsg = getText("update_password_suggest", void())
      me.getInterface().openPasswordUpdate(tForceFlag, tMsg)
    else
      return(0)
    end if
  end if
  exit
end

on handle_password_approved(me, tMsg)
  tConn = tMsg.connection
  if voidp(tConn) then
    return(0)
  end if
  tResult = tConn.GetIntFrom()
  me.getInterface().userPasswordResult(tResult)
  return(1)
  exit
end

on regMsgList(me, tBool)
  tMsgs = []
  tMsgs.setaProp(1, #handle_ok)
  tMsgs.setaProp(3, #handle_login_ok)
  tMsgs.setaProp(8, #handle_availablesets)
  tMsgs.setaProp(36, #handle_approvenamereply)
  tMsgs.setaProp(37, #handle_nameunacceptable)
  tMsgs.setaProp(51, #handle_regok)
  tMsgs.setaProp(164, #handle_acr)
  tMsgs.setaProp(211, #handle_updateok)
  tMsgs.setaProp(167, #handle_reregistrationrequired)
  tMsgs.setaProp(214, #handle_coppa_checktime)
  tMsgs.setaProp(215, #handle_coppa_getrealtime)
  tMsgs.setaProp(217, #handle_parent_email_required)
  tMsgs.setaProp(218, #handle_parent_email_validated)
  tMsgs.setaProp(169, #handle_update_account)
  tMsgs.setaProp(271, #handle_email_approved)
  tMsgs.setaProp(272, #handle_email_rejected)
  tMsgs.setaProp(275, #handle_update_request)
  tMsgs.setaProp(282, #handle_password_approved)
  tCmds = []
  tCmds.setaProp("INFORETRIEVE", 7)
  tCmds.setaProp("GETAVAILABLESETS", 9)
  tCmds.setaProp("FINDUSER", 41)
  tCmds.setaProp("APPROVENAME", 42)
  tCmds.setaProp("REGISTER", 43)
  tCmds.setaProp("UPDATE", 44)
  tCmds.setaProp("AC", 46)
  tCmds.setaProp("COPPA_REG_CHECKTIME", 130)
  tCmds.setaProp("COPPA_REG_GETREALTIME", 131)
  tCmds.setaProp("PARENT_EMAIL_REQUIRED", 146)
  tCmds.setaProp("VALIDATE_PARENT_EMAIL", 147)
  tCmds.setaProp("SEND_PARENT_EMAIL", 148)
  tCmds.setaProp("UPDATE_ACCOUNT", 149)
  tCmds.setaProp("APPROVEEMAIL", 197)
  tCmds.setaProp("APPROVE_PASSWORD", 203)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  exit
end