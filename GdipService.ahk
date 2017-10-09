class GdipService {
	Init() {
		If !this.gdipToken := Gdip_Startup()
		{
			MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
			ExitApp
		} else 
		{
			;MsgBox, oo
		}
	}

	SetWinTitle(winTitle) {
		this.hwnd := WinExist(winTitle)
		return this.hwnd
	}
	
	GetHwnd() {
		return this.hwnd		
	}
	
	GetBmpHaystack() {
		this.bmpHaystack := Gdip_BitmapFromHWND(this.hwnd)
		return this.bmpHaystack
	}
	
	GdipImageSearch(imagePath = "img/pk.png", direction = 1) {
		LIST = 0		
		this.bmpHaystack := Gdip_BitmapFromHWND(this.hwnd)
		this.bmpNeedle := Gdip_CreateBitmapFromFile(imagePath)				
		RET := Gdip_ImageSearch(this.bmpHaystack, this.bmpNeedle, LIST, 0, 0, 0, 0, 100, "0xFFFFFF", direction, 1)
		;MsgBox % this.bmpHaystack "_" bmpNeedle "_" RET "_" LIST
		Gdip_DisposeImage(this.bmpNeedle) 
		Gdip_DisposeImage(this.bmpHaystack)
		return List
	}
	
	Capture(title) {
		FileCreateDir, capture
		formattime, nowtime,,yyyy-MM-dd_HH-mm-ss
		;MsgBox % nowtime
		;Gdip_SetBitmapToClipboard(this.bmpHaystack)
		this.bmpHaystack := Gdip_BitmapFromHWND(this.hwnd)
		Gdip_SaveBitmapToFile(this.bmpHaystack, "capture/Capture_" . title . "_" . nowtime . ".png", 100)		
		
		return
	}
	
	ShutDownGdip() {		
		Gdip_Shutdown(this.gdipToken)
		VarSetCapacity(this.gdipToken,0)
		VarSetCapacity(this.hwnd,0)
		VarSetCapacity(this.bmpHaystack,0)
		VarSetCapacity(this.bmpNeedle,0)
		VarSetCapacity(this.RET,0)
		return
	}
}

 