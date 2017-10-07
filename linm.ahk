#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force ;reload the old instance automatically
#WinActivateForce

;inital settings
Gui, Add, Button, x20 y15 w110 h20, Start
Gui, Add, Button, x140 y15 w110 h20, Stop
Gui, Add, GroupBox, x5 y45 w255 h100, Settings
Gui, Add, CheckBox, x15 y65 w210 h20 vCheckBox1, Auto Return Home(PK)
Gui, Add, CheckBox, x15 y85 w210 h20 vCheckBox2, Auto Refill Potion
Gui, Add, DropDownList,x20 y115 w220 h150 vDrop gDropAction, A|B|C
Gui, Show, w270 h200, Shelob v1.0
;
Global bStart := false
log_dir = log.txt

;v for DetectPK
Global firstHit_reaction_sec := 3000
Global directions := ["w", "a", "s", "d"]
Global bHome := false

return


;Function to write logs to file
WriteLog(string)
{
  Global log_dir
  FileAppend,[%A_Mon%/%A_Mday% %A_Hour%:%A_Min%:%A_Sec%] %string%`n, %log_dir%
}

;get direction(the four cardinal points) randomly
Fnc_getRandomDirection()
{
 Random, rand, 1, 4
 return rand
}

Fnc_randomMove()
{
  nVar := Fnc_getRandomDirection()

  if nVar = 1
  {
     Send, {w down}
     sleep 5000
     Send, [w up}
  }
  else if nVar = 2
  {
     Send, {a down}
     sleep 5000
     Send, [a up}
  }
  else if nVar = 2
  {
     Send, {s down}
     sleep 5000
     Send, [s up}
  }
  else if nVar = 2
  {
     Send, {d down}
     sleep 5000
     Send, [d up}
  }

  return
}

Fnc_Init()
{
	bHome := false
}


Fnc_DetectPK()
{
   ImageSearch, x1, y1, 1660, 740, 1731, 805, *50 skull.png 

   if(errorlevel = 0)
   {
     WriteLog("pk detected")
     MouseMove, 1670, 880
     Sleep firstHit_reaction_sec 
     MouseClick, L, 1670, 880, 2
 
   }
}

Fnc_DetectAllin()
{

   if(bHome = false)
   {
       ImageSearch, x2, y2, 0, 0, 800, 800, *100 allin.bmp

       if(errorlevel = 0)
       {
  
     	    WriteLog("All-in")
     	    MouseMove, 1670, 880
            Sleep 1000
     	    MouseClick, L, 1670, 880, 2
     	    Sleep 1000
            bHome := true
     
       }
       else if(errorlevel = 1)
       {
       }

    }

}



ButtonStart:
{
  WriteLog("Pressed button 'Start'")
  GuiControl, disable, Start
  GuiControl, enable, Stop
  
  Fnc_Init()
  
  bStart := true
  
  While bStart=true
  {
     ;Fnc_DetectPK()  
     Fnc_DetectAllin()
  }
  
}
return

ButtonStop:
{
  WriteLog("Pressed button 'Stop'")
  GuiControl, enable, Start
  GuiControl, disable, Stop
  bStart := false
  
}
return


F3::
{
MouseGetPos, mX,mY
MsgBox, 0, 좌표위치, x%mX% y%mY%
}
return
F7::ExitApp


DropAction:
gui, submit, nohide
if drop = A
{
 msgbox, A
}
else if drop = B
{
 msgbox, B
}

F10::
{
   IfWinExist, momo_lin
   {
      ;MsgBox, 윈도우창 실행중, 위치 조정
      ;WinMove, momo_lin, , 0, 100
      WinGetPos , X, Y, , , momo_lin
      MsgBox, position is %X%`,%Y%

   }
   else
   {
      MsgBox, 어플이 실행되지 않음
    }
}
return 

f12::
WinGet, WindowList, List
loop %WindowList%
{
  id :=  WindowList%A_Index%
  WinGetTitle, title, ahk_id %id%
  Msgbox %id% `n %title%
}

Return


