on getLoginParameter me, tPassword, tParameter 
  if _player <> void() then
    if _player.traceScript then
      return FALSE
    end if
  end if
  _player.traceScript = 0
  _player.traceScript = 0
  if ilk(tParameter) <> #symbol then
    return FALSE
  end if
  if tPassword <> "testing" then
    return FALSE
  end if
  if (tParameter = #g) then
    return([26417, 7007, 23303, 10522, 1861, 6955, 20261])
  else
    if (tParameter = #p) then
      return([26929, 10550, 12713, 28003, 16826, 28016, 13112, 31032, 5385, 26895, 3893, 15710, 21876, 29106, 15120, 25898, 7952, 25391, 18877, 3939])
    end if
  end if
end

on handler tName 
  return FALSE
end

on handlers  
  return([])
end
