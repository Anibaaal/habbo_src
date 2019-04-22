on feedContentText(me, tWndObj)
  if tWndObj = 0 then
    return(0)
  end if
  tElem = tWndObj.getElement("if_text")
  if tElem = 0 then
    return(0)
  end if
  tText = getText("badge_desc_" & me.getaProp(#value))
  tText = replaceChunks(tText, "\\r", "\r")
  tElem.setText(tText)
  return(1)
  exit
end

on feedContentImage(me, tWndObj)
  if tWndObj = 0 then
    return(0)
  end if
  tElem = tWndObj.getElement("if_icon")
  if tElem = 0 then
    return(0)
  end if
  tMemNum = getmemnum("badge" && me.getaProp(#value))
  if tMemNum = 0 then
    error(me, "Badge 'badge" && me.getaProp(#value) & "' not found.", #minor)
    tMemNum = getmemnum("if.icon.temp")
    if tMemNum = 0 then
      return(0)
    end if
  end if
  tImage = member(tMemNum).image
  tImage = me.alignIconImage(tImage, tElem.getProperty(#width), tElem.getProperty(#height))
  tElem.feedImage(tImage)
  return(1)
  exit
end