GetSlotPosition(value, ByRef xPosition, ByRef yPosition)
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

GetRandomNumber()
{
 Random, rand, 1, 4
 return rand
}

GetDirection(ByRef xPosition, ByRef yPosition)
{
	value := GetRandomNumber()
	if value = 1
	{
		Random, randx, 425-20, 425+20
		Random, randy, 240-20, 240+20
	}
	else if value = 2
	{
		Random, randx, 850-20, 850+20
		Random, randy, 240-20, 240+20
	}
	else if value = 3
	{
		Random, randx, 850-20, 850+20
		Random, randy, 480-20, 480+20
	}
	else
	{
		Random, randx, 425-20, 425+20
		Random, randy, 480-20, 480+20
	}
	
	xPosition = %randx%
	yPosition = %randy%
	return
}