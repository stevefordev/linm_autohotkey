GetSkillPosition(value, ByRef xPosition, ByRef yPosition)
{	
	;GoTo % IsLabel("Case-" value) ? "Case-" value : "Case-Default"
	;availableRange = 0
	if (value = 1)
	{
		Random, randx, 545-15, 545+15
	} else if (value = 2)
	{
		Random, randx, 625-15, 625+15
	} else if (value = 3)
	{
		Random, randx, 705-15, 705+15
	} else if (value = 4)
	{
		Random, randx, 785-15, 785+15
	} else if (value = 5)
	{
		Random, randx, 970-15, 970+15
	} else if (value = 6)
	{
		Random, randx, 1050-15, 1050+15
	} else if (value = 7)
	{
		Random, randx, 1130-15, 1130+15
	} else
	{
		Random, randx, 1210-15, 1210+15
	}

	Random, randy, 665-15, 665+15
	  
	xPosition = %randx%
	yPosition = %randy%
	  
	Return
}

;get direction(the four cardinal points) randomly
GetRandomDirection()
{
 Random, rand, 1, 4
 return rand
}

RandomMoveBySend(ahkId)
{
	nVar := GetRandomDirection()
	MsgBox % nVar ahkId
	
	nVar=1
  if nVar = 1
  {
	ControlSend, {w down}, NoxPlayerLin
	sleep 5000
	ControlSend, [w up}, NoxPlayerLin
  }
  else if nVar = 2
  {
	ControlSend, {a down}, ahk_id %ahkId%
     sleep 5000
	ControlSend, [a up}, ahk_id %ahkId%
  }
  else if nVar = 2
  {
	ControlSend, {s down}, ahk_id %ahkId%
     sleep 5000
	ControlSend, [s up}, ahk_id %ahkId%
  }
  else if nVar = 2
  {
	ControlSend, {d down}, ahk_id %ahkId%
     sleep 5000
	ControlSend, [d up}, ahk_id %ahkId%
  }
  return
}