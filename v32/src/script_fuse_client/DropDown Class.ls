on define(me, tProps)
  if ilk(tProps) <> #propList then
    return(0)
  end if
  tField = tProps.getAt(#type) & tProps.getAt(#model) & ".element"
  pProp = getObject(#layout_parser).parse(tField)
  if pProp = 0 then
    return(0)
  end if
  pState = #close
  me.pID = tProps.getAt(#id)
  me.pBuffer = tProps.getAt(#buffer)
  me.pSprite = tProps.getAt(#sprite)
  me.pLocX = pSprite.left
  me.pLocY = pSprite.top
  me.pmodel = tProps.getAt(#model)
  pAlignment = tProps.getAt(#alignment)
  pTextKeys = tProps.getAt(#keylist)
  pOrigWidth = tProps.getAt(#width)
  pLineHeight = tProps.getAt(#fixedLineSpace)
  pOpenDir = tProps.getAt(#direction)
  pMaxWidth = tProps.getAt(#maxwidth)
  pLineHeight = tProps.getAt(#height)
  pFixedSize = tProps.getAt(#fixedsize)
  pOrdering = 1
  if not voidp(pProp.getAt(#dropDownType)) then
    pDropDownType = pProp.getAt(#dropDownType).getProp(#content)
  else
    pDropDownType = #default
  end if
  pTextlist = []
  if pTextKeys.ilk <> #list then
    pTextKeys = []
  end if
  repeat while me <= undefined
    tKey = getAt(undefined, tProps)
    pTextlist.add(getText(tKey))
  end repeat
  if pTextlist.count = 0 then
    pTextlist.add("...")
  end if
  pShowOrder = []
  i = 1
  repeat while i <= pTextlist.count
    pShowOrder.add(i)
    i = 1 + i
  end repeat
  if voidp(me.pPalette) then
    if variableExists("interface.palette") then
      me.pPalette = member(getmemnum(getVariable("interface.palette")))
    else
      me.pPalette = #systemMac
    end if
  else
    if stringp(me.pPalette) then
      me.pPalette = member(getmemnum(me.pPalette))
    end if
  end if
  if voidp(pFixedSize) then
    pFixedSize = 0
  end if
  if voidp(pMaxWidth) then
    pMaxWidth = pOrigWidth
  end if
  if pMaxWidth < pOrigWidth then
    pMaxWidth = pOrigWidth
  end if
  if pLineHeight mod 2 then
    pLineHeight = pLineHeight + 1
  end if
  pSelectedItemNum = 1
  if me.pmodel = 2 then
    pLineHeight = pLineHeight - 1
  end if
  me.UpdateImageObjects(void(), #up)
  pDropMenuImg = me.createDropImg(pTextlist, 1, #up)
  me.pimage = pDropMenuImg
  me.pwidth = me.width
  pheight = me.height
  pDropActiveBtnImg = me.createDropImg([pTextlist.getAt(1)], 0, #up)
  me.pimage = pDropActiveBtnImg
  tTempOffset = me.regPoint
  me.image = me.pimage
  me.regPoint = tTempOffset
  pSprite.blend = tProps.getAt(#blend)
  return(1)
  exit
end

on prepare(me)
  me.pLocX = pSprite.locH
  me.pLocY = pSprite.locV
  if me = #center then
    me.pLocX = me.pLocX - me.pwidth - pOrigWidth / 2
  else
    if me = #right then
      me.pLocX = me.pLocX - me.pwidth - pOrigWidth
    end if
  end if
  pSprite.loc = point(me.pLocX, me.pLocY)
  exit
end

on Activate(me)
  pSprite.blend = 100
  return(1)
  exit
end

on deactivate(me)
  pSprite.blend = 50
  return(1)
  exit
end

on updateData(me, tTextList, tTextKeys, tChosenIndex, tChosenValue)
  if ilk(tTextList) <> #list then
    return(0)
  end if
  if ilk(tTextKeys) <> #list then
    return(0)
  end if
  pTextlist = tTextList
  pTextKeys = tTextKeys
  pShowOrder = []
  i = 1
  repeat while i <= pTextlist.count
    pShowOrder.add(i)
    i = 1 + i
  end repeat
  if tChosenIndex > 0 and tChosenIndex <= pShowOrder.count then
    pSelectedItemNum = tChosenIndex
  end if
  if tChosenIndex > pShowOrder.count then
    pSelectedItemNum = 1
  end if
  if not voidp(tChosenValue) then
    me.setSelection(tChosenValue)
  end if
  pDropActiveBtnImg = me.createDropImg([pTextlist.getAt(pSelectedItemNum)], 0, #up)
  me.pimage = me.pDropActiveBtnImg
  me.render()
  return(1)
  exit
end

on getSelection(me, tReturnType)
  if tReturnType = #text then
    return(pTextlist.getAt(pShowOrder.getAt(pSelectedItemNum)))
  else
    if tReturnType = #key then
      return(pTextKeys.getAt(pShowOrder.getAt(pSelectedItemNum)))
    end if
  end if
  return(pTextKeys.getAt(pShowOrder.getAt(pSelectedItemNum)))
  exit
end

on setSelection(me, tSelNumOrStr, tUpdate)
  tEarlierSelection = pSelectedItemNum
  if not listp(pTextKeys) then
    return(error(me, "pTextKeys is not a list!", #arrangeTextList, #major))
  end if
  if not listp(pShowOrder) then
    return(error(me, "pShowOrder is not a list!", #arrangeTextList, #major))
  end if
  if stringp(tSelNumOrStr) then
    tSelNum = pTextlist.getPos(tSelNumOrStr)
    if tSelNum = 0 then
      tSelNum = pTextKeys.getPos(tSelNumOrStr)
    end if
  else
    tSelNum = tSelNumOrStr
  end if
  if tSelNum <= 0 then
    return(0)
  end if
  pSelectedItemNum = pShowOrder.getPos(tSelNum)
  if not pSelectedItemNum > 0 then
    pSelectedItemNum = 1
  end if
  if tEarlierSelection = pSelectedItemNum then
    return(1)
  end if
  if tUpdate then
    me.arrangeTextList(#choose)
    pDropActiveBtnImg = me.createDropImg([pTextlist.getAt(pShowOrder.getAt(pSelectedItemNum))], 0, #up)
    me.pimage = pDropActiveBtnImg
    pSprite.loc = pLoc
    me.render()
  end if
  return(1)
  exit
end

on setShowOrder(me, tStyle, tFirstNum, tDeleteOne, tOpenDir)
  if not pOrdering then
    return(1)
  end if
  if not listp(pShowOrder) then
    return(error(me, "pShowOrder is not a list!", #arrangeTextList, #major))
  end if
  tChoice = pShowOrder.getAt(pSelectedItemNum)
  if me = #normal then
    i = 1
    repeat while i <= pTextlist.count
      pShowOrder.setAt(i, i)
      i = 1 + i
    end repeat
  end if
  if tFirstNum > 0 then
    if tOpenDir = #down then
      tTempPlace = pShowOrder.getPos(tFirstNum)
      pShowOrder.deleteAt(tTempPlace)
      pShowOrder.addAt(1, tFirstNum)
    else
      tTempPlace = pShowOrder.getPos(tFirstNum)
      pShowOrder.deleteAt(tTempPlace)
      pShowOrder.addAt(pShowOrder.count + 1, tFirstNum)
    end if
  end if
  if tDeleteOne > 0 then
    pShowOrder.deleteOne(tDeleteOne)
  end if
  pSelectedItemNum = pShowOrder.getPos(tChoice)
  return(0)
  exit
end

on setOrdering(me, tMode)
  pOrdering = tMode
  return(1)
  exit
end

on arrangeTextList(me, tStyle)
  if not listp(pShowOrder) then
    return(error(me, "pShowOrder is not a list!", #arrangeTextList, #major))
  end if
  if pDropDownType = #titleWithCancel then
    if me = #open then
      if pShowOrder.getAt(pSelectedItemNum) > 2 then
        me.setShowOrder(#normal, pShowOrder.getAt(pSelectedItemNum), 1)
      else
        me.setShowOrder(#normal, 1, 2)
      end if
      pDropMenuImg = me.createDropImg(pTextlist, 1, #up)
    else
      if me = #choose then
        if pShowOrder.getAt(pSelectedItemNum) <= 2 then
          me.setShowOrder(#normal)
          pSelectedItemNum = 1
        end if
      end if
    end if
  end if
  if pDropDownType = #default and pOpenDir = #up then
    if me = #open then
      me.setShowOrder(#normal, pShowOrder.getAt(pSelectedItemNum))
      pDropMenuImg = me.createDropImg(pTextlist, 1, #up)
    else
      if me = #choose then
        me.setShowOrder(#normal, pShowOrder.getAt(pSelectedItemNum), #down)
      end if
    end if
  end if
  if pDropDownType = #default and pOpenDir = #down then
    if me = #open then
      me.setShowOrder(#normal, pShowOrder.getAt(pSelectedItemNum), void(), #down)
      pDropMenuImg = me.createDropImg(pTextlist, 1, #up)
    else
      if me = #choose then
        me.setShowOrder(#normal, pShowOrder.getAt(pSelectedItemNum), #down)
      end if
    end if
  end if
  exit
end

on getProperty(me, tProp)
  if me = #width then
    return(pSprite.width)
  else
    if me = #height then
      return(pSprite.height)
    else
      if me = #locX then
        return(me.pLocX)
      else
        if me = #locY then
          return(me.pLocY)
        else
          if me = #depth then
            return(me.depth)
          else
            if me = #blend then
              return(pSprite.blend)
            else
              if me = #selection then
                return(pTextKeys.getAt(pShowOrder.getAt(pSelectedItemNum)))
              else
                if me = #sprite then
                  return(me.pSprite)
                else
                  return(0)
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  exit
end

on openMenu(me)
  me.arrangeTextList(#open)
  me.pimage = pDropMenuImg
  pLoc = pSprite.loc
  if me = #lastselected then
    pSprite.loc = pLoc - point(0, pSelectedItemNum - 1 * pLineHeight)
  else
    if me = #up then
      pSprite.loc = pLoc - point(0, pShowOrder.count - 1 * pLineHeight)
    end if
  end if
  me.render()
  pState = #open
  pLastRollOver = -2
  pOnFirstChoice = 1
  return(1)
  exit
end

on chooseFromMenu(me)
  pClickPass = 0
  pState = #close
  pLastRollOver = void()
  if pRollOverItem > 0 and pRollOverItem <= pShowOrder.count then
    pSelectedItemNum = pRollOverItem
    me.arrangeTextList(#choose)
    pDropActiveBtnImg = me.createDropImg([pTextlist.getAt(pShowOrder.getAt(pSelectedItemNum))], 0, #up)
    me.pimage = pDropActiveBtnImg
    pSprite.loc = pLoc
    me.render()
    if not listp(pTextKeys) then
      return(error(me, "pTextKeys is not a list!", #chooseFromMenu, #major))
    end if
    if not listp(pShowOrder) then
      return(error(me, "pShowOrder is not a list!", #chooseFromMenu, #major))
    end if
    if pSelectedItemNum > pShowOrder.count then
      return(error(me, "pShowOrder is out of sync!", #chooseFromMenu, #major))
    end if
    if pTextKeys.count < 1 then
      return("")
    end if
    if not voidp(pTextKeys.getAt(pShowOrder.getAt(pSelectedItemNum))) then
      return(pTextKeys.getAt(pShowOrder.getAt(pSelectedItemNum)))
    end if
  end if
  exit
end

on mouseDown(me)
  if pSprite.blend < 100 then
    return(0)
  end if
  pClickPass = 1
  if pState <> #open then
    return(me.openMenu())
  end if
  exit
end

on mouseUp(me)
  if pOnFirstChoice then
    pOnFirstChoice = 0
    return(0)
  end if
  if pSprite.blend < 100 then
    return(0)
  end if
  if pClickPass = 0 then
    return(0)
  end if
  me.cancelDelay()
  return(me.chooseFromMenu())
  exit
end

on mouseUpOutSide(me)
  if pSprite.locH > 5000 then
    return(0)
  end if
  pClickPass = 0
  pState = #close
  pLastRollOver = void()
  me.pimage = pDropActiveBtnImg
  me.render()
  pSprite.loc = pLoc
  return(0)
  exit
end

on mouseEnter(me)
  me.cancelDelay()
  exit
end

on cancelDelay(me)
  if not voidp(pDelayID) then
    me.Cancel(pDelayID)
    pDelayID = void()
  end if
  exit
end

on mouseLeave(me)
  if pState = #open then
    pDelayID = me.delay(500, #mouseUpOutSide)
  end if
  exit
end

on mouseWithin(me)
  if pState = #open then
    if voidp(pLastRollOver) then
      pLastRollOver = 0
    end if
    pRollOverItem = me - pSprite.top - 1 / pLineHeight + 1
    if pLastRollOver = -2 then
      pLastRollOver = -1
      return(1)
    end if
    if pOnFirstChoice and pLastRollOver = -1 then
      pLastRollOver = pRollOverItem
    end if
    if pRollOverItem <> pLastRollOver then
      pOnFirstChoice = 0
      if pRollOverItem > pShowOrder.count then
        pRollOverItem = pShowOrder.count
      end if
      if pShowOrder.count = pRollOverItem then
        tMaskFix = pMarginBottom
      else
        tMaskFix = 0
      end if
      tTempImage = pDropMenuImg.duplicate()
      tTempActiveBoxImg = image(me.pwidth, pLineHeight + tMaskFix, 8, me.pPalette)
      tMemberDesc = pProp.getAt(#up).getAt(#members).getAt(#activeline)
      tmember = member(getmemnum(tMemberDesc.getAt(#member)))
      tTempActiveBoxImg.copyPixels(tmember.image, tTempActiveBoxImg.rect, tmember.rect)
      tActiveTop = pRollOverItem - 1 * pLineHeight
      tdestrect = rect(0, tActiveTop, me.pwidth, tActiveTop + pLineHeight + tMaskFix)
      tTempImage.copyPixels(tTempActiveBoxImg, tdestrect, tTempActiveBoxImg.rect, [#maskImage:pDropMenuImg.createMatte(), #maskOffset:point(0, -tActiveTop), #ink:39])
      me.pimage = tTempImage
      me.reDraw()
      pLastRollOver = pRollOverItem
    end if
  end if
  exit
end

on reDraw(me)
  undefined.copyPixels(me.pimage, me.rect, me.rect)
  exit
end

on render(me)
  tTempOffset = me.regPoint
  pSprite.width = me.width
  pSprite.height = me.height
  me.image = me.pimage
  me.regPoint = tTempOffset
  exit
end

on UpdateImageObjects(me, tPalette, tstate)
  pDropDownImg = []
  if voidp(tPalette) then
    tPalette = me.pPalette
  else
    if stringp(tPalette) then
      tPalette = member(getmemnum(tPalette))
    end if
  end if
  repeat while me <= tstate
    tV = getAt(tstate, tPalette)
    repeat while me <= tstate
      tH = getAt(tstate, tPalette)
      tSymbol = symbol(tV & tH)
      tDesc = pProp.getAt(tstate).getAt(#members).getAt(tSymbol)
      tmember = member(getmemnum(tDesc.getAt(#member)))
      tImage = tmember.duplicate()
      if tImage.paletteRef <> tPalette then
        tImage.paletteRef = tPalette
      end if
      if tDesc.getAt(#flipH) then
        tImage = me.flipH(tImage)
      end if
      if tDesc.getAt(#flipV) then
        tImage = me.flipV(tImage)
      end if
      if not voidp(tDesc.getAt(#rotate)) then
        tImage = me.rotateImg(tImage, tDesc.getAt(#rotate))
      end if
      pDropDownImg.addProp(tV & "_" & tH, tImage)
    end repeat
  end repeat
  if not voidp(pProp.getAt(#optionalimage)) then
    tOptionalImages = pProp.getAt(#optionalimage).getAt(#members)
    i = 1
    repeat while i <= tOptionalImages.count()
      tDesc = tOptionalImages.getAt(tOptionalImages.getPropAt(i))
      tMemName = tDesc.getAt(#member)
      tmember = member(getmemnum(tMemName))
      tImage = tmember.duplicate()
      if tImage.paletteRef <> tPalette then
        tImage.paletteRef = tPalette
      end if
      if tDesc.getAt(#flipH) then
        tImage = me.flipH(tImage)
      end if
      if tDesc.getAt(#flipV) then
        tImage = me.flipV(tImage)
      end if
      pDropDownImg.addProp("optionalimage_" & tOptionalImages.getPropAt(i), tImage)
      i = 1 + i
    end repeat
  end if
  pDotLineImg = image(pMaxWidth, 1, 8, tPalette)
  tXPoint = 0
  repeat while tXPoint <= pMaxWidth / 2
    pDotLineImg.setPixel(tXPoint * 2, 0, rgb(0, 0, 0))
    tXPoint = 1 + tXPoint
  end repeat
  me.pPalette = tPalette
  return(tPalette)
  exit
end

on createDropImg(me, tItemsList, tListOfAllItemsOrNot, tstate, tSort)
  tStr = ""
  if not tListOfAllItemsOrNot then
    tStr = tStr & tItemsList.getAt(1) & "\r"
  else
    f = 1
    repeat while f <= pShowOrder.count
      tStr = tStr & tItemsList.getAt(pShowOrder.getAt(f)) & "\r"
      f = 1 + f
    end repeat
  end if
  tMemNum = getmemnum("dropdown.button.text")
  if tMemNum = 0 then
    tMemNum = createMember("dropdown.button.text", #text)
  end if
  tTextMember = member(tMemNum)
  tFontDesc = pProp.getAt(tstate).getAt(#text)
  pMarginTop = tFontDesc.getAt(#marginV)
  pMarginLeft = tFontDesc.getAt(#marginH)
  pMarginBottom = tFontDesc.getAt(#marginbottom)
  tTextMember.wordWrap = 0
  tTextMember.font = string(tFontDesc.getAt(#font))
  tTextMember.fontStyle = list(symbol(tFontDesc.getAt(#fontStyle)))
  tTextMember.fontSize = tFontDesc.getAt(#fontSize)
  tTextMember.color = rgb(tFontDesc.getAt(#color))
  tTextMember.text = tStr.getProp(#line, 1, tStr.count(#line) - 1)
  tTextMember.fixedLineSpace = pLineHeight
  if tListOfAllItemsOrNot = 1 and not voidp(pProp.getAt(#optionalimage)) then
    tOptionalImages = pProp.getAt(#optionalimage).getAt(#members)
    tOptionalImagesWidth = 0
    i = 1
    repeat while i <= tOptionalImages.count()
      tOptionalImagesWidth = tOptionalImagesWidth + pDropDownImg.getAt("optionalimage_" & tOptionalImages.getPropAt(i)).width
      i = 1 + i
    end repeat
    exit repeat
  end if
  tOptionalImagesWidth = 0
  if pFixedSize = 1 then
    tTextMember.alignment = tFontDesc.getAt(#alignment)
    pTextWidth = pOrigWidth - pMarginLeft * 2
    tTextMember.rect = rect(0, 0, pTextWidth, tTextMember.height)
    tTextImg = tTextMember.image
    me.pwidth = pOrigWidth
  else
    tTextMember.alignment = #left
    if tListOfAllItemsOrNot = 1 then
      tMaxLengt = 1
      tCharNum = 1
      tSofarChars = 0
      tLineN = 1
      repeat while tLineN <= tStr.count(#line)
        tSofarChars = tSofarChars + tStr.getPropRef(#line, tLineN).count(#char)
        if tStr.getPropRef(#line, tLineN).count(#char) > tMaxLengt then
          tMaxLengt = tSofarChars
          tCharNum = tSofarChars
          tLineWidth = tTextMember.charPosToLoc(tCharNum).locH + tFontDesc.getAt(#fontSize) * 2
          if tLineWidth > pTextWidth then
            pTextWidth = tLineWidth
          end if
        end if
        tLineN = 1 + tLineN
      end repeat
      me.pwidth = pTextWidth + pMarginLeft * 2 + tOptionalImagesWidth
      pFixedSize = 1
      pOrigWidth = me.pwidth
    end if
    tTextMember.rect = rect(0, 0, pTextWidth, tTextMember.height)
    tTextMember.alignment = tFontDesc.getAt(#alignment)
    tTextImg = tTextMember.image
  end if
  tWidth = me.pwidth
  if tItemsList.count = 1 then
    if me.pmodel = 2 then
      tNewImg = image(tWidth, pLineHeight, 8, me.pPalette)
    else
      tNewImg = image(tWidth, pLineHeight + pMarginBottom, 8, me.pPalette)
    end if
  else
    tNewImg = image(tWidth, pShowOrder.count * pLineHeight + pMarginBottom, 8, me.pPalette)
  end if
  tdestrect = rect(0, 0, 0, 0)
  tEndPointX = 0
  tEndPointY = 0
  tLastX = 0
  tStartPoint = 0
  if tItemsList.count = 1 then
    tItemCount = 1
  else
    tItemCount = pShowOrder.count
  end if
  repeat while me <= tListOfAllItemsOrNot
    f = getAt(tListOfAllItemsOrNot, tItemsList)
    tStartPoint = tEndPointY
    tEndPointX = 0
    if me = "top" then
      tEndPointY = tEndPointY + pDropDownImg.getAt(1).height
    else
      if me = "middle" then
        tEndPointY = tEndPointY + tItemCount * pLineHeight - tEndPointY * 2 + pMarginBottom
      else
        if me = "bottom" then
          tEndPointY = tEndPointY + pDropDownImg.getAt(1).height
        end if
      end if
    end if
    repeat while me <= tListOfAllItemsOrNot
      i = getAt(tListOfAllItemsOrNot, tItemsList)
      tLastX = tEndPointX
      if me = "left" then
        tEndPointX = tEndPointX + pDropDownImg.getProp(f & "_" & i).width
      else
        if me = "middle" then
          tEndPointX = tEndPointX + tWidth - pDropDownImg.getProp(#top_left).width - pDropDownImg.getProp(#top_right).width
        else
          if me = "right" then
            tEndPointX = tEndPointX + pDropDownImg.getProp(f & "_" & i).width
          end if
        end if
      end if
      tdestrect = rect(tLastX, tStartPoint, tEndPointX, tEndPointY)
      tNewImg.copyPixels(pDropDownImg.getProp(f & "_" & i), tdestrect, pDropDownImg.getProp(f & "_" & i).rect)
    end repeat
  end repeat
  if tListOfAllItemsOrNot = 0 and not voidp(pProp.getAt(#optionalimage)) then
    tOptionalImages = pProp.getAt(#optionalimage).getAt(#members)
    i = 1
    repeat while i <= tOptionalImages.count()
      tPosition = tOptionalImages.getPropAt(i)
      tOptionalImg = pDropDownImg.getAt("optionalimage_" & tOptionalImages.getPropAt(i))
      tOptionImgRect = tOptionalImg.rect
      tOptionImgMargH = tOptionalImages.getAt(tOptionalImages.getPropAt(i)).getAt(#marginH)
      tOptionImgMargV = tNewImg.height / 2 - tOptionImgRect.height / 2
      if tPosition = #right then
        tdestrect = tOptionImgRect + rect(me.pwidth - tOptionImgMargH - tOptionImgRect.width, tOptionImgMargV, me.pwidth - tOptionImgMargH - tOptionImgRect.width, tOptionImgMargV)
      else
        if tPosition = #left then
          tdestrect = tOptionImgRect + rect(tOptionImgMargH, tOptionImgMargV, tOptionImgMargH, tOptionImgMargV)
        end if
      end if
      tNewImg.copyPixels(tOptionalImg, tdestrect, tOptionImgRect, [#ink:36])
      i = 1 + i
    end repeat
  end if
  if tItemCount > 1 then
    f = 1
    repeat while f <= tItemCount - 1
      tdestrect = rect(0, f * pLineHeight, tWidth - 1, f * pLineHeight + 1)
      tNewImg.copyPixels(pDotLineImg, tdestrect, rect(0, 0, tWidth - 1, 1), [#ink:36])
      f = 1 + f
    end repeat
  end if
  tdestrect = tTextImg.rect + rect(0, pMarginTop, 0, pMarginTop)
  if me = #left then
    tdestrect = tdestrect + rect(pMarginLeft, 0, pMarginLeft, 0)
  else
    if me = #center then
      tdestrect = tdestrect + rect(tNewImg.width / 2, 0, tNewImg.width / 2, 0) - rect(pTextWidth / 2, 0, pTextWidth / 2, 0)
    else
      if me = #right then
        tdestrect = tdestrect + rect(tNewImg.width, 0, tNewImg.width, 0) - rect(pTextWidth + pDropDownImg.getProp("top_right").width, 0, pTextWidth + pDropDownImg.getProp("top_right").width, 0)
      end if
    end if
  end if
  if variableExists("dropdown.top.offset") then
    tdestrect = tdestrect + rect(0, getVariable("dropdown.top.offset"), 0, getVariable("dropdown.top.offset"))
  end if
  tNewImg.copyPixels(tTextImg, tdestrect, tTextImg.rect)
  return(tNewImg)
  exit
end

on flipH(me, tImg)
  tImage = image(tImg.width, tImg.height, tImg.depth, tImg.paletteRef)
  tQuad = [point(tImg.width, 0), point(0, 0), point(0, tImg.height), point(tImg.width, tImg.height)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return(tImage)
  exit
end

on flipV(me, tImg)
  tImage = image(tImg.width, tImg.height, tImg.depth, tImg.paletteRef)
  tQuad = [point(0, tImg.height), point(tImg.width, tImg.height), point(tImg.width, 0), point(0, 0)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return(tImage)
  exit
end

on rotateImg(me, tImg, tDirection)
  tImage = image(tImg.height, tImg.width, tImg.depth, tImg.paletteRef)
  tQuad = [point(0, 0), point(tImg.height, 0), point(tImg.height, tImg.width), point(0, tImg.width)]
  tQuad = me.RotateQuad(tQuad, tDirection)
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return(tImage)
  exit
end

on RotateQuad(me, tDestquad, tClockwise)
  tPoint1 = tDestquad.getAt(1)
  tPoint2 = tDestquad.getAt(2)
  tPoint3 = tDestquad.getAt(3)
  tPoint4 = tDestquad.getAt(4)
  if tClockwise = 1 then
    tDestquad = [tPoint2, tPoint3, tPoint4, tPoint1]
  else
    tDestquad = [tPoint4, tPoint1, tPoint2, tPoint3]
  end if
  return(tDestquad)
  exit
end

on handlers()
  return([])
  exit
end