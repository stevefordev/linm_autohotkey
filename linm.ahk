; linm automation library v1.0.2 by steve park 2017-10-09
;
;#####################################################################################
;#####################################################################################

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force ; reload the old instance automatically
#WinActivateForce

#Include Gdip.ahk
#Include Gdip_ImageSearch.ahk 
#Include GdipService.ahk
#Include UtilsService.ahk 

; 5 : 785 670
; 5 : 785 670
; 5 : 700 670
; 5 : 785 670
; 5 : 840 600
; 6 : 915 600
; 7 : 1130 670
; 8 : 1215 670

;inital settings
log_dir = log\log.txt

Global isStart := false
Global isHome := false

;v for DetectPK
Global firstHit_reaction_sec := 3000
Global directions := ["w", "a", "s", "d"]

Global ddlTitle := ""
Global currentProcessTitle := ""
Global currentProcessId := ""

Gui, Add, Button, x5 y15 w110 h20, Start
Gui, Add, Button, x125 y15 w110 h20, Stop
Gui, Add, Button, x245 y15 w110 h20, Quit
GUI, Add, Picture, x365 y15 gPicProc, %A_ScriptDir%/img/ico.jpg
Gui, Add, GroupBox, x5 y45 w380 h338, Settings

Gui, Add, CheckBox, x15 y65 w200 h20 vCheckBoxPK, Detect PK
Gui, Add, DropDownList, x220 y65 w60 h800 choose1 vDropSlotPK gDropSlotPKAction, Slot1|Slot2|Slot3|Slot4|Slot5|Slot6|Slot7|Slot8

Gui, Add, CheckBox, x15 y90 w200 h20 vCheckBoxHPempty, Detect HP Potion Empty
Gui, Add, DropDownList, x220 y90 w60 h800 choose1 vDropSlotHPempty gDropSlotHPemptyAction, Slot1|Slot2|Slot3|Slot4|Slot5|Slot6|Slot7|Slot8

Gui, Add, CheckBox, x15 y115 w200 h20 vCheckBoxPoison, Detect Poison
Gui, Add, DropDownList, x220 y115 w60 h800 choose1 vDropSlotPoison gDropSlotPoisonAction, Slot1|Slot2|Slot3|Slot4|Slot5|Slot6|Slot7|Slot8

Gui, Font, cRed
Gui, Add, Text, x15 y145, ===== Choose your process =====

CreateDDLRunningProcess()
Gui, Add, DropDownList,x15 y170 w360 h600 choose1 vWinTitle gWinTitleAction, %ddlTitle%

Gui, Font, cBlack
Gui, Add, Text, x15 y205 vTextColorBlack, ===== Log =====
GuiControl, Font, TextColorBlack

Gui, Add, ListBox, x15 y225 w360 h148 vListBoxLog

Gui, Add, GroupBox, x390 y45 w205 h338, TEST
Gui, Add, Button, x400 y70 w95 h20, RandomMove
Gui, Add, Button, x400 y100 w95 h20, SlotNum1
Gui, Add, Button, x400 y130 w95 h20, SlotNum8
Gui, Add, Button, x400 y160 w95 h20, SearchQuest
Gui, Add, Button, x400 y190 w95 h20, Capture

GuiControl, disable, RandomMove
GuiControl, disable, SlotNum1
GuiControl, disable, SlotNum8
GuiControl, disable, SearchQuest
GuiControl, disable, Capture 

Gui, Show, w600 h400, linm_v1.0.2
 
return

;#region for logging 
;Function to write logs to file
WriteLog(logData)
{
  LogShow(logData)
  LogWriteFile(logData) 
  return
}

LogShow(logData) {
	formattime, nowtime,,yyyy-MM-dd HH:mm:ss
	guicontrol, , ListBoxLog, [%nowtime%]  %logData% . ||
    
    
    return
}

LogWriteFile(logData) {
   FileCreateDir, log
   Global log_dir 
   formattime, nowtime,,yyyy-MM-dd HH:mm:ss
   FileAppend, [%nowtime%]  %logData%`n, %log_dir%	
   return
}
;#end logging


;활성화 상태일때 가능
;뒤치기 당하는지 체크
Fnc_DetectPK()
{
   ImageSearch, x1, y1, 1660, 740, 1731, 805, *50 skull.png 

   if(errorlevel = 0)
   {
     WriteLog("pk detected")
     ;MouseMove, 1670, 880
     Sleep firstHit_reaction_sec 
     ;MouseClick, L, 1670, 880, 2 
   }
   return
}

;PK 감지
DetectPK() 
{
   if (position := gdipService.GdipImageSearch("img/pk.png"))
   {  
      gdipService.Capture("pk")
       
      GetDirection(xPosition, yPosition)   
      loop 5
      {   
         ControlClick, x%xPosition% y%yPosition%, ahk_id %currentProcessId%, , Left, 2
         Sleep 1000
      }
      
      WriteLog("detected pk and click:" . xPosition . "_" . yPosition)
      
      GetSlotPosition(8, xPo, yPo)
      ControlClick, x%xPo% y%yPo%, ahk_id %currentProcessId%, , Left, 2 
      
      WriteLog("detected pk and go home:" . xPo . "_" . yPo)
      Sleep, 200
      gosub, ButtonStop
   } 
   else 
   {
      WriteLog("pk check OK")
      Sleep, 200
   }
   return
}

;석화독에 걸렸는지 체크
DetectPoisonRock() 
{  
   if (position := gdipService.GdipImageSearch("img/poison_rock.png"))
   {  
      ;gdipService.Capture("posion")
      
      Sleep, 2000      
      GetSlotPosition(1, xPosition, yPosition)
      ControlClick, x%xPosition% y%yPosition%, ahk_id %currentProcessId%, , Left, 2 
      
      WriteLog("detected poison : click " . xPosition . "_" . yPosition)
   } 
   else 
   {
      WriteLog("poison check OK")
      
   }
   Sleep, 200
   return
}

;소지한 빨갱이 물약이 있는지 체크
DetectEmptyPotionHP()
{        
   if(position := gdipService.GdipImageSearch("img/empty_potion_hp.png"))
   {  
      ;gdipService.Capture("empty_potion_hp")
      
      Sleep, 2000      
      GetSlotPosition(8, xPosition, yPosition)
      ControlClick, x%xPosition% y%yPosition%, ahk_id %currentProcessId%, , Left, 2 
      
      WriteLog("detected allin HP potion : click" . xPosition . "_" . yPosition)
      Sleep, 200
      gosub, ButtonStop
   }
   else
   {
      WriteLog("enough potion HP")
      Sleep, 200
   }
   return
}

;현재 실행중인 프로세스 리스트를 불러와 dromdownlist 형식으로 string 생성한다
CreateDDLRunningProcess()
{   
   WinGet, window_, List 
   
   Loop, %window_%
   {      
      WinGetTitle, processTitle,% "ahk_id" window_%A_Index%
      WinGetClass, processClass,% "ahk_id" window_%A_Index%
      LogWriteFile(processTitle . "_" . window_%A_Index% . "_" . processClass)
      ddlTitle.= processTitle ? processTitle "|" : ""
   }
   ;msgbox % ddlTitle
   return
}

Fnc_Init()
{
   return
}

ButtonStart:
{
  WriteLog("Pressed button 'Start'")
  GuiControl, disable, Start
  GuiControl, enable, Stop
  GuiControl, disable, WinTitle
  
   GuiControl, enable, RandomMove
   GuiControl, enable, SlotNum1
   GuiControl, enable, SlotNum8
   GuiControl, enable, SearchQuest
   GuiControl, enable, Capture 
   
  Fnc_Init()
  
  isStart := true
  loopCount := 0
  While isStart=true
  {
      loopCount = loopCount + 1
      gdipService := new GdipService
      gdipService.Init()
      gdipService.SetWinTitle(currentProcessTitle)
      currentProcessId := gdipService.GetHwnd()
      gdipService.GetBmpHaystack()
      
      ;Fnc_DetectPK()  
      ;Fnc_DetectAllin()
      DetectPK()
      DetectEmptyPotionHP()
      DetectPoisonRock()

      gdipService.ShutDownGdipToken()
      
      if(loopCount = 100) 
      {
         GuiControl, , ListBoxLog, |
      }
      Sleep, 2000
  }
   return  
}

ButtonStop:
{
   WriteLog("Pressed button 'Stop'")
   GuiControl, enable, Start
   GuiControl, disable, Stop
   GuiControl, enable, WinTitle
  
   GuiControl, disable, RandomMove
   GuiControl, disable, SlotNum1
   GuiControl, disable, SlotNum8
   GuiControl, disable, SearchQuest
   GuiControl, disable, Capture 

   isStart := false
   return
}

ButtonQuit:
{
  WriteLog("Pressed button 'Quit'")
  ExitApp
  return
}

ButtonRandomMove:
{
   GetDirection(xPosition, yPosition)   
   loop 5
   {   
      ControlClick, x%xPosition% y%yPosition%, %currentProcessTitle%, , Left, 2 
      Sleep 1000
   }
   
   Sleep 500
   return
}

ButtonSlotNum1:
{
   Sleep 500
   
   GetSlotPosition(1, xPosition, yPosition)
   ControlClick, x%xPosition% y%yPosition%, %currentProcessTitle%, , Left, 2 
   
   Sleep 500
   return
}

ButtonSlotNum8:
{
   Sleep 500
   
   GetSlotPosition(8, xPosition, yPosition)
   ControlClick, x%xPosition% y%yPosition%, %currentProcessTitle%, , Left, 2 
   
   Sleep 500
   return
}

ButtonSearchQuest:
{
   if(position := gdipService.GdipImageSearch("img/btn_quest.png"))
   {   
      Sleep, 500
      positionArray := StrSplit(position, ",")
      xPosition := positionArray[1] 
      yPosition := positionArray[2] 
      ControlClick, x%xPosition% y%yPosition%, ahk_id %currentProcessId%, , Left, 1 
      
      WriteLog(position)
      Sleep, 200
   }
   else
   {      
      Sleep, 500
      gdipService.Capture("quest")
      WriteLog("can't find quest button:" . position)
      Sleep, 200
   }
   return
}

ButtonCapture:
{
   Sleep, 200
   gdipService.Capture("TEST")
   WriteLog("capture done")
   return
}

DropAction:
{
   gui, submit, nohide
      if drop = A
      {
         msgbox, A
      } else if drop = B
      {
         msgbox, B
      }
   return
}

WinTitleAction:
{
   ;Settitlematchmode, 2
   gui, submit, nohide
   currentProcessTitle = %WinTitle%
   
   WinActivate, %WinTitle%
   Sleep, 200
   ;WinMove, %WinTitle%, , , , , 808
   WriteLog("pick process : " . currentProcessTitle)   
   ;"detected poison and click:" . randx . "_" . randy
   return 
}

DropSlotPKAction:
{
   gui, submit, nohide
   slot = %DropSlotPK%
   WriteLog("For PK isCheck : " . CheckBoxPK)   
   WriteLog("For PK Slot : " . slot)   
   return 
}

DropSlotHPemptyAction:
{
   gui, submit, nohide
   WriteLog("For HP empty isCheck : " . CheckBoxHPempty)
   WriteLog("For HP empty Slot : " . DropSlotHPempty)   
   return 
}

DropSlotPoisonAction:
{
   gui, submit, nohide
   WriteLog("For Posion isCheck : " . CheckBoxPoison)
   WriteLog("For Posion Slot : " . DropSlotPoison)   
   return 
}

PicProc:
{
   Run, https://stevefordev.github.io/linm_autohotkey/
   WriteLog("PicProc")   
   return
}


;###########################################################################################
; 단일 테스트
;###########################################################################################
^1::
{
   GuiControl, , ListBoxLog, |
   return
}

^2::
{
   ;gdipService.Capture("test")
   ;RandomMoveBySend(currentProcessTitle)
   WriteLog(currentProcessTitle)  
   Sleep, 1000   
   WinGetClass, this_class, %currentProcessTitle%
   
   GetDirection(xPosition, yPosition)
   
   loop 5
   {   
      ControlClick, x%xPosition% y%yPosition%, %currentProcessTitle%, , Left, 2 
      Sleep 1000
   }
   
   Sleep 500
   return
}

^3::
{
	WinGet, id, list
	Loop, %id%
    {
      this_id := id%A_Index%
      WinActivate, ahk_id %this_id%
      WinGetClass, this_class, ahk_id %this_id%
      WinGetTitle, this_title, ahk_id %this_id%
      ;MsgBox, 4, , Visiting All Windows`n%a_index% of %id%`nahk_id %this_id%`nahk_class %this_class%`n%this_title%`n`nContinue?
      ;IfMsgBox, NO, break
    }
   Return
}

^4::
{   
   GetSlotPosition(8,xPosition, yPosition)
   
   ControlClick, x%xPosition% y%yPosition%, ahk_id %currentProcessId%, ,Left,2 
   WriteLog(currentProcessId . " : " . xPosition . "_" . yPosition)
}
 
^5::
{
   winget,list,list,ahk_class Notepad 
      loop,%list% 
      { 
        temp:=list%A_Index% 
        title=ahk_id %temp% 
        controlsend,Edit1,Hello World,%title% 
      } 
   return
}

^6::
{
   Sleep 1000
   MouseMove, 20, 40
   Sleep 1000
   MouseClick, Left, 20, 40, 2
   Sleep 1000
   return
} 

F3::
{
   MouseGetPos, mX,mY
   xx := A_ScreenWidth - mX
   MsgBox, 0, 좌표위치1, x%mX% y%mY%
   MsgBox, 0, 좌표위치2, %xx% y%mY%
   return
}

 
F4::ExitApp

F10::
{   
   IfWinExist, NoxPlayerLin
   {
		;MsgBox, 윈도우창 실행중, 위치 조정
		;WinMove, momo_lin, , 0, 100
		;WinGetPos , X, Y, , , momo_lin
		;MsgBox, position is %X%`,%Y%
      
   tmpHwnd := WinExist("NoxPlayerLin")
     
   Sleep 1000
   ControlSend,,  {C Down},  ahk_id %tmpHwnd%
   KeyWait C
   Sleep 3000
   ControlSend,,  {C Up}, ahk_id %tmpHwnd%
   ;ControlSend, , {Esc}, NoxPlayerLin
   ;ControlSend, , {w down}, NoxPlayerLin
   Sleep, 1000
   ;RandomMoveBySend(tmpHwnd) 
   }
   else
   {
		MsgBox, 어플이 실행되지 않음
   }
	return 
}

F12::
{
   WinGet, WindowList, List
   loop %WindowList%
   {
     id :=  WindowList%A_Index%
     WinGetTitle, title, ahk_id %id%
     Msgbox %id% `n %title%
     Return
   }
}
