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
	
	GdipImageSearch(imagePath = "img/pk.png") {
		LIST = 0		
		bmpNeedle := Gdip_CreateBitmapFromFile(imagePath)				
		RET := Gdip_ImageSearch(this.bmpHaystack,bmpNeedle,LIST,0,0,0,0,100, "0xFFFFFF" ,1,1)
		;MsgBox % this.bmpHaystack "_" bmpNeedle "_" RET
		Gdip_DisposeImage(bmpNeedle) 
		
		return List ? true : false
	}
	
	Capture(title) {
		FileCreateDir, capture
		formattime, nowtime,,yyyy-MM-dd_HH-mm-ss
		;MsgBox % nowtime
		;Gdip_SetBitmapToClipboard(this.bmpHaystack)
		Gdip_SaveBitmapToFile(this.bmpHaystack, "capture/Capture_" . title . "_" . nowtime . ".png", 100)		
		
		return
	}
	
	ShutDownGdip() {
		Gdip_DisposeImage(this.BmpHaystack) 		
		Gdip_Shutdown(this.gdipToken)
		return
	}
}

 