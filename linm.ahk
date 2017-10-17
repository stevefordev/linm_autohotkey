; linm automation library v1.0.3 by steve park 2017-10-10
;
;#####################################################################################
/*
SetFormat 커맨드 사용을 자제하세요, 속도가 느려집니다
기본환경변수를 제거해, 혹시모를 변수간의 충돌을 방지하고 성능을 높이기 위해서 #NoEnv 을 사용하세요
오토핫키는 자동으로 최근 실행된 코드라인을 기억합니다, ListLines, Off 로 중지하세요
오토핫키는 자체적으로 키로그를 남깁니다, #KeyHistory 0 으로 중지하세요
프로세스의 우선순위를 높임으로서 성능향샹을 기대할 수 있습니다, Process, Priority,, High
Send 보다는 SendInput 을 사용하세요. 훨씬 빠르고 안정적(실행중엔 유저키입력 차단)이랍니다
오토핫키는 기본적으로 라인마다 Sleep, 10 을 수행합니다, SetBatchLines, -1 으로 Sleep 을 제거해 속도를 높이세요
SetWinDelay와 SetControlDelay 를 사용해 Win과 Control 관련 명령어의 속도를 높이세요
SetKeyDelay와 SetMouseDelay 를 사용해 Send와 Mouse 관련 명령어의 속도를 높이세요
VarSetCapacity 를 통해 사이즈가 큰 문자열변수의 메모리를 미리 설정해 속도를 높일 수 있습니다
단순 true, false를 비교하는 if, else일 경우 Ternary Operator 를 사용하는것이 더 빠릅니다
초기실행이후 사용되지 않을 변수는 메모리에서 제거하세요 변수명 := "" 또는 VarSetCapacity(변수명,0)
코드의 메모리가 높아 줄이고 싶다면 대기상태의 라인에 DllCall("psapi.dll\EmptyWorkingSet", "Ptr", -1) 을 추가하세요
[출처]: http://knowledgeisfree.tistory.com/104

*/
;#####################################################################################

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance force ; reload the old instance automatically
#WinActivateForce
#KeyHistory 0

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

Gui, Add, CheckBox, x15 y65 w200 h20 vCheckBoxPK gCheckBoxPKAction, Detect PK
Gui, Add, DropDownList, x220 y65 w60 h800 choose1 vDropSlotPK gDropSlotPKAction, Slot-1|Slot-2|Slot-3|Slot-4|Slot-5|Slot-6|Slot-7|Slot-8
Gui, Add, CheckBox, x300 y65 w60 h20 vCheckBoxPKQuit gCheckBoxPKQuitAction, Quit

Gui, Add, CheckBox, x15 y90 w200 h20 vCheckBoxPotionHPempty gCheckBoxPotionHPemptyAction, Detect HP Potion Empty
Gui, Add, DropDownList, x220 y90 w60 h800 choose1 vDropSlotPotionHPempty gDropSlotPotionHPemptyAction, Slot-1|Slot-2|Slot-3|Slot-4|Slot-5|Slot-6|Slot-7|Slot-8
Gui, Add, CheckBox, x300 y90 w60 h20 vCheckBoxPotionHPemptyQuit gCheckBoxPotionHPemptyQuitAction, Quit

Gui, Add, CheckBox, x15 y115 w200 h20 vCheckBoxPoisonRock gCheckBoxPoisonRockAction, Detect Poison
Gui, Add, DropDownList, x220 y115 w60 h800 choose1 vDropSlotPoisonRock gDropSlotPoisonRockAction, Slot-1|Slot-2|Slot-3|Slot-4|Slot-5|Slot-6|Slot-7|Slot-8

Gui, Font, cRed
Gui, Add, Text, x15 y145, ===== Choose your process =====

CreateDDLRunningProcess()
Gui, Add, DropDownList,x15 y170 w360 h600 choose1 vWinTitle gWinTitleAction, %ddlTitle%

Gui, Font, cBlack
Gui, Add, Text, x15 y205 vTextColorBlack, ===== Log =====
GuiControl, Font, TextColorBlack

Gui, Add, ListBox, x15 y225 w360 h148 vListBoxLog

Gui, Add, GroupBox, x390 y45 w205 h338, TEST
Gui, Add, Button, x400 y70 w90 h20, RandomMove
Gui, Add, Button, x496 y70 w90 h20, OpenDir
Gui, Add, Button, x400 y100 w90 h20, SlotNum1
Gui, Add, Button, x400 y130 w90 h20, SlotNum8
Gui, Add, Button, x400 y160 w90 h20, Capture
Gui, Add, Button, x400 y190 w90 h20, SearchQuest
Gui, Add, Button, x400 y220 w90 h20, SearchInven

GuiControl, disable, RandomMove
GuiControl, disable, SlotNum1
GuiControl, disable, SlotNum8
GuiControl, disable, Capture 
GuiControl, disable, SearchQuest
GuiControl, disable, SearchInven

Global application := "linm_v1.0.4"

Gui, Show, w600 h400, %application%
 
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
   if (position := gdipService.GdipImageSearch("img/pk.png", 8))
   {  
      WriteLog("detected pk !!!!!!!!!!!!!!!!!")
      
      gdipService.Capture("pk")
       
      GetDirection(xPosition, yPosition)   
      loop 5
      {   
         ControlClick, x%xPosition% y%yPosition%, %currentProcessTitle%, , Left, 3
         WriteLog("detected pk and click:" . xPosition . "_" . yPosition)
         Sleep 1000
      }
      
      WriteLog("detected pk position:" . position)
      
      GuiControlGet, DropSlotPK
      values := StrSplit(DropSlotPK, "-")
      slotNum := values[2]
      WriteLog("slot:" . slotNum)
      
      GetSlotPosition(slotNum, xPo, yPo)
      ControlClick, x%xPo% y%yPo%, %currentProcessTitle%, , Left, 2 
      
      WriteLog("detected pk and go home:" . xPo . "_" . yPo)
      Sleep, 200
      
      GuiControlGet, CheckBoxPKQuit
      
      if (CheckBoxPKQuit) {
         gosub, ButtonStop
      }
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
      ;gdipService.Capture("poison")
      Sleep, 200      
      GuiControlGet, DropSlotPoisonRock
      values := StrSplit(DropSlotPoisonRock, "-")
      slotNum := values[2]
      WriteLog("slot:" . slotNum)
      GetSlotPosition(slotNum, xPosition, yPosition)
      ControlClick, x%xPosition% y%yPosition%, %currentProcessTitle%, , Left, 2 
      
      WriteLog("detected poison : click " . xPosition . "_" . yPosition)
      Sleep, 200
   } 
   else 
   {
      WriteLog("poison check OK")
      
   }
   Sleep, 200
   return
}

;소지한 빨갱이 물약이 있는지 체크
DetectPotionHPempty()
{        
   if(position := gdipService.GdipImageSearch("img/empty_potion_hp.png"))
   {
      ;gdipService.Capture("empty_potion_hp")
      
      Sleep, 2000
      GuiControlGet, DropSlotPotionHPempty
      values := StrSplit(DropSlotPotionHPempty, "-")
      slotNum := values[2]
      WriteLog("slot:" . slotNum)
      GetSlotPosition(slotNum, xPosition, yPosition)
      ControlClick, x%xPosition% y%yPosition%, %currentProcessTitle%, , Left, 2 
      
      WriteLog("detected allin HP potion : click" . xPosition . "_" . yPosition)
      
      Sleep, 200
      
      GuiControlGet, CheckBoxPotionHPemptyQuit

      if (CheckBoxPotionHPemptyQuit) {
         gosub, ButtonStop
      }
   }
   else
   {
      WriteLog("enough potion HP")
      Sleep, 200
   }
   return
}

;HP 가 x% 이하 일때
DetectDangerHP()
{        
   if(position := gdipService.GdipImageSearch("img/danger_hp.png"))
   {  
      gdipService.Capture("danger_hp")

      WriteLog("detected danger HP")
      Sleep, 200
   }
   else
   {
      ;WriteLog("enough potion HP")
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

CleanMemory(PID)  ;Written with help from "Temp01" on the AHK IRC chat (thank you again, temp01!!!)
{
   Process, Exist  ;Sets ErrorLevel to the PID of this running script
   h := DllCall("OpenProcess", "UInt", 0x0400, "Int", false, "UInt", ErrorLevel)  ;Get the handle of this script with PROCESS_QUERY_INFORMATION (0x0400)
   DllCall("Advapi32.dll\OpenProcessToken", "UInt", h, "UInt", 32, "UIntP", t)  ;Open an adjustable access token with this process (TOKEN_ADJUST_PRIVILEGES = 32)
   VarSetCapacity(ti, 16, 0)  ;Structure of privileges
   NumPut(1, ti, 0)  ;One entry in the privileges array...
   DllCall("Advapi32.dll\LookupPrivilegeValueA", "UInt", 0, "Str", "SeDebugPrivilege", "Int64P", luid)  ;Retrieves the locally unique identifier of the debug privilege:
   NumPut(luid, ti, 4, "int64")
   NumPut(2, ti, 12)  ;Enable this privilege: SE_PRIVILEGE_ENABLED = 2
   DllCall("Advapi32.dll\AdjustTokenPrivileges", "UInt", t, "Int", false, "UInt", &ti, "UInt", 0, "UInt", 0, "UInt", 0)  ;Update the privileges of this process with the new access token:
   DllCall("CloseHandle", "UInt", h)  ;Close this process handle to save memory
   hModule := DllCall("LoadLibrary", "Str", "Psapi.dll")  ;Increase performance by preloading the libaray
   h := DllCall("OpenProcess", "UInt", 0x400|0x100, "Int", false, "UInt", pid)  ;Open process with: PROCESS_QUERY_INFORMATION (0x0400) | PROCESS_SET_QUOTA (0x100)
   e := DllCall("psapi.dll\EmptyWorkingSet", "UInt", h)
   DllCall("CloseHandle", "UInt", h)  ;Close process handle to save memory
   DllCall("FreeLibrary", "UInt", hModule)  ;Unload the library to free memory
   Return e
}

ButtonStart:
{
   gui, submit, nohide
   
   WriteLog("Pressed button 'Start'")
   GuiControl, disable, Start
   GuiControl, enable, Stop
   GuiControl, disable, WinTitle

   GuiControl, enable, RandomMove
   GuiControl, enable, SlotNum1
   GuiControl, enable, SlotNum8   
   GuiControl, enable, Capture 
   GuiControl, enable, SearchQuest
   GuiControl, enable, SearchInven

   Winget, Value, Pid, %application%
   
   Fnc_Init()

   isStart := true
   loopCount := 0
   While isStart=true
   {
      try
      {
         ;WriteLog("loopCount:" . loopCount)
         loopCount += 1
         gdipService := new GdipService
         gdipService.Init()
         gdipService.SetWinTitle(currentProcessTitle)
         ;gdipService.GetBmpHaystack()
         
         ;Fnc_DetectPK()  
         ;Fnc_DetectAllin()
         WriteLog("==================== " . loopCount)
         
         if (CheckBoxPK)
         {
            DetectPK()
         }
         
         if (CheckBoxPotionHPempty)
         {
            DetectPotionHPempty()
         }
         
         if (CheckBoxPoisonRock)
         {
            DetectPoisonRock()
         }
         
         ;DetectDangerHP()
         gdipService.ShutDownGdipToken()
         
         if(loopCount = 1000) 
         {
            GuiControl, , ListBoxLog, |         
            loopCount = 0
            ;CleanMemory(Pid)
         } 
         
         Sleep, 50
         ;DllCall("psapi.dll\EmptyWorkingSet", "Ptr", -1)                  
      } catch e {
         WriteLog("Error:" . e)
      }
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
   GuiControl, disable, Capture 
   GuiControl, disable, SearchQuest
   GuiControl, disable, SearchInven

   gdipService.ShutDownGdipToken()
   isStart := false
   Sleep, 1000
   return
}

ButtonQuit:
{
  WriteLog("Pressed button 'Quit'")
  
  gdipService.ShutDownGdipToken()
  Sleep, 1000
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

ButtonOpenDir:
{
   Run, Explorer %A_ScriptDir%
   
   Sleep 500
   return
}

ButtonSlotNum1:
{
   Sleep 500
   
   GetSlotPosition(1, xPosition, yPosition)
   ControlClick, x%xPosition% y%yPosition%, %currentProcessTitle%, , Left, 1
   
   Sleep 500
   return
}

ButtonSlotNum8:
{
   Sleep 500
   
   GetSlotPosition(8, xPosition, yPosition)
   ControlClick, x%xPosition% y%yPosition%, %currentProcessTitle%, , Left, 1
   
   Sleep 500
   return
}

ButtonSearchQuest:
{
   if(position := gdipService.GdipImageSearch("img/btn_quest.png",8))
   {   
      Sleep, 500
      positionArray := StrSplit(position, ",")
      xPosition := positionArray[1] 
      yPosition := positionArray[2] + 20
      ControlClick, x%xPosition% y%yPosition%, %currentProcessTitle%, , left, 1
      
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

ButtonSearchInven:
{
   if(position := gdipService.GdipImageSearch("img/btn_inven.png",8))
   {   
      Sleep, 500
      positionArray := StrSplit(position, ",")
      xPosition := positionArray[1] 
      yPosition := positionArray[2] + 20
      ControlClick, x%xPosition% y%yPosition%, %currentProcessTitle%, , left, 1
      
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
   WriteLog("For PK Slot : " . DropSlotPK)
   return 
}

DropSlotPotionHPemptyAction:
{
   gui, submit, nohide
   WriteLog("For HP empty Slot : " . DropSlotPotionHPempty)   
   return 
}

DropSlotPoisonRockAction:
{
   gui, submit, nohide
   WriteLog("For Poison Slot : " . DropSlotPoisonRock)   
   return 
}

CheckBoxPKAction:
{
   gui, submit, nohide
   WriteLog("For PK isCheck : " . CheckBoxPK) 
   return
}

CheckBoxPKQuitAction:
{
   gui, submit, nohide
   WriteLog("Quit For PK isCheck : " . CheckBoxPKQuit) 
   return
}

CheckBoxPotionHPemptyAction:
{
   gui, submit, nohide
   WriteLog("For HP potion empty isCheck : " . CheckBoxPotionHPempty) 
   return
}

CheckBoxPotionHPemptyQuitAction:
{
   gui, submit, nohide
   WriteLog("Quit For HP potion empty isCheck : " . CheckBoxPotionHPemptyQuit) 
   return
}

CheckBoxPoisonRockAction:
{
   gui, submit, nohide
   WriteLog("For PK isCheck : " . CheckBoxPoisonRock)
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
   ;GuiControl, , ListBoxLog, |
   Run, Explorer %A_ScriptDir%
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
