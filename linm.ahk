; linm automation library v1.0.0 by steve park 2017-10-08
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

Gui, Add, Button, x20 y15 w110 h20, Start
Gui, Add, Button, x140 y15 w110 h20, Stop
Gui, Add, Button, x260 y15 w110 h20, Quit
Gui, Add, GroupBox, x5 y45 w395 h300, Settings
Gui, Add, CheckBox, x15 y65 w210 h20 vCheckBox1, Auto Return Home(PK)
Gui, Add, CheckBox, x15 y85 w210 h20 vCheckBox2, Auto Refill Potion

;Gui, Add, DropDownList,x20 y115 w220 h150 vDrop gDropAction, A|B|C 
CreateDDLRunningProcess()
Gui, Add, DropDownList,x20 y115 w360 h800 choose1 vWinTitle gWinTitleAction, %ddlTitle%
Gui, Add, ListBox, x20 y160 w360 h100 vListBoxLog

Gui, Show, w600 h400, linm_v1.0.0
 
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

DetectPK() 
{
   return
}

;석화독에 걸렸는지 체크
DetectPoisonRock() 
{  
   if (gdipService.GdipImageSearch("img/poison_rock.png"))
   {  
      gdipService.Capture("pk")
       
      GetSkillPosition(1, xPosition, yPosition)
      ControlClick, x%xPosition% y%yPosition%, ahk_id %currentProcessId%, ,Left,2 
      Sleep, 500
      WriteLog("detected poison and click:" . randx . "_" . randy)
   } 
   else 
   {
      WriteLog("no poison")
   }
   return
}

;소지한 빨갱이 물약이 있는지 체크
DetectEmptyPotionHP()
{        
   if(gdipService.GdipImageSearch("img/empty_potion_hp.png"))
   {  
      gdipService.Capture("empty_potion_hp")
   
      GetSkillPosition(8, xPosition, yPosition)
      ControlClick, x%xPosition% y%yPosition%, ahk_id %currentProcessId%, ,Left,2 
      
      WriteLog("detected all in HP Potion:" . randx . "_" . randy)
      Sleep, 500
      gosub, ButtonStop
   }
   else
   {
      WriteLog("enough potion HP")
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
  
  Fnc_Init()
  
  isStart := true
  
  While isStart=true
  {
      gdipService := new GdipService
      gdipService.Init()
      gdipService.SetWinTitle("NoxPlayerLin")
      currentProcessId := gdipService.GetHwnd()
      gdipService.GetBmpHaystack()
      
      ;Fnc_DetectPK()  
      ;Fnc_DetectAllin()
      DetectEmptyPotionHP()
      DetectPoisonRock()

      gdipService.ShutDownGdipToken()
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
  isStart := false
  return
}

ButtonQuit:
{
  WriteLog("Pressed button 'Quit'")
  ExitApp
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
   gui, submit, nohide
   currentProcessTitle = %WinTitle%
   
   WinActivate, %WinTitle%
   WriteLog("pick process : " . currentProcessTitle)   
   ;"detected poison and click:" . randx . "_" . randy
   return 
}


;###########################################################################################
; 단일 테스트
;###########################################################################################
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
   GetSkillPosition(1, xPosition, yPosition)
   
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
