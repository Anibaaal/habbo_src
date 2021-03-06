on construct me 
  return TRUE
end

on deconstruct me 
  return(me.ancestor.deconstruct())
end

on executeGameChat me, tdata 
  tSystemState = me.getComponent().getSystemState()
  if tSystemState <> #after_game then
    if (tSystemState = #pre_game) then
      executeMessage(#showCustomMessage, [#mode:"CHAT", #id:string(tdata.getaProp(#id)), #message:tdata.getaProp(#message), #loc:point(450, 500)])
    else
      executeMessage(#showChatMessage, "CHAT", string(tdata.getaProp(#id)), tdata.getaProp(#message))
    end if
    return TRUE
  end if
end
