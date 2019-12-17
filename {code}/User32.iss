[Code]

///////////////////////////////////////////////////////////////////////////
// forward declaration

function LoadCursorFromFile(FileName: String): HCURSOR;
external 'LoadCursorFromFile{#AW}@User32.dll stdcall delayload';

function SetWindowRgn(hWnd: HWND; hRgn: HRGN; Redraw: BOOL): INT;
external 'SetWindowRgn@User32.dll stdcall delayload';

function SetLayeredWindowAttributes(hWnd: HWND; crKey: COLORREF; bAlpha: BYTE; dwFlags: DWORD): BOOL;
external 'SetLayeredWindowAttributes@User32.dll stdcall delayload';

function GetDC(hWnd: HWND): HDC;
external 'GetDC@User32.dll stdcall delayload';

function ReleaseDC(hWnd: HWND; hDC: HDC): INT;
external 'ReleaseDC@User32.dll stdcall delayload';

function SetCapture(hWnd: HWND): HWND;
external 'SetCapture@User32.dll stdcall delayload';

function ReleaseCapture(): BOOL;
external 'ReleaseCapture@User32.dll stdcall delayload';

function SetTimer(hWnd: HWND; nIDEvent: UINT_PTR; uElapse: UINT; lpTimerFunc: TIMERPROC): UINT_PTR;
external 'SetTimer@User32.dll stdcall delayload';

function KillTimer(hWnd: HWND; nIDEvent: UINT_PTR): BOOL;
external 'KillTimer@User32.dll stdcall delayload';

function CallWindowProc(lpPrevWndFunc: WNDPROC; hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
external 'CallWindowProc{#AW}@User32.dll stdcall delayload';

function SetWindowLong(hWnd: HWND; nIndex: INT; dwNewLong: LONG_PTR): LONG_PTR;
external 'SetWindowLong{#AW}@User32.dll stdcall delayload';

function GetWindowLong(hWnd: HWND; nIndex: INT): LONG_PTR;
external 'GetWindowLong{#AW}@User32.dll stdcall delayload';

function SetClassLong(hWnd: HWND; nIndex: INT; dwNewLong: LONG_PTR): LONG_PTR;
external 'SetClassLong{#AW}@User32.dll stdcall delayload';

function GetClassLong(hWnd: HWND; nIndex: INT): LONG_PTR;
external 'GetClassLong{#AW}@User32.dll stdcall delayload';
