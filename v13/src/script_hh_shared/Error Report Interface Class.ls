property pWindowID, pCurrentErrorIndex

on construct me 
  pWindowID = getText("error_report")
  pCurrentErrorIndex = 1
  return TRUE
end

on deconstruct me 
  return TRUE
end

on showErrors me 
  tReportLists = me.getComponent().getErrorLists()
  if (tReportLists.count = 0) then
    return FALSE
  end if
  if not windowExists(pWindowID) then
    createWindow(pWindowID, "habbo_full.window")
    tWndObj = getWindow(pWindowID)
    tWndObj.merge("error_report_details.window")
    tWndObj.center()
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcErrorReport, me.getID(), #mouseUp)
    tWndObj.getElement("error_report_prev").setText("<<<")
    tWndObj.getElement("error_report_next").setText(">>>")
  end if
  me.updateErrorView()
end

on showPreviousError me 
  tTriedErrorIndex = (pCurrentErrorIndex - 1)
  tReportList = me.getComponent().getErrorLists()
  if tTriedErrorIndex < 1 or (tReportList.count = 0) then
    return FALSE
  end if
  pCurrentErrorIndex = tTriedErrorIndex
  me.updateErrorView()
end

on showNextError me 
  tTriedErrorIndex = (pCurrentErrorIndex + 1)
  tReportList = me.getComponent().getErrorLists()
  if tTriedErrorIndex > tReportList.count then
    return FALSE
  end if
  pCurrentErrorIndex = tTriedErrorIndex
  me.updateErrorView()
end

on updateErrorView me 
  tWndObj = getWindow(pWindowID)
  tIndexOfCurrentReport = pCurrentErrorIndex
  tReportList = me.getComponent().getErrorLists()
  tErrorReport = tReportList.getAt(tIndexOfCurrentReport)
  tCounts = pCurrentErrorIndex & "/" & tReportList.count
  tWndObj.getElement("error_report_count").setText(tCounts)
  tTexts = [:]
  tTexts.setAt("error_report_errorid", "ID:" && tErrorReport.getAt(#errorId))
  tExplainText = ""
  tExplainText = tErrorReport.getAt(#time) & "\r"
  tExplainText = tExplainText & getText("error_report_trigger_message") & ":" && tErrorReport.getAt(#errorMsgId)
  tTexts.setAt("error_report_details", tExplainText)
  tIndex = 1
  repeat while tIndex <= tTexts.count
    tElementName = tTexts.getPropAt(tIndex)
    tText = tTexts.getAt(tIndex)
    if tWndObj.elementExists(tElementName) then
      tElement = tWndObj.getElement(tElementName)
      tElement.setText(tText)
    end if
    tIndex = (1 + tIndex)
  end repeat
end

on hideErrorReportWindow me 
  if not windowExists(pWindowID) then
    return FALSE
  end if
  tWndObj = getWindow(pWindowID)
  tWndObj.close()
end

on eventProcErrorReport me, tEvent, tElemID, tParams 
  if (tEvent = #mouseUp) then
    if tElemID <> "error_report_ok" then
      if (tElemID = "close") then
        me.hideErrorReportWindow()
      else
        if (tElemID = "error_report_prev") then
          me.showPreviousError()
        else
          if (tElemID = "error_report_next") then
            me.showNextError()
          end if
        end if
      end if
    end if
  end if
end
