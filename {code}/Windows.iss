#ifndef AW
    #ifdef UNICODE
        #define AW "W"
    #else
        #define AW "A"
    #endif
#endif

#define WINAPI

[Code]

type
    HANDLE      = THandle;
    HDC         = THandle;
    HRGN        = THandle;
    HGDIOBJ     = THandle;
    HCURSOR     = THandle;

    INT         = Integer;
    
#ifdef _WIN64
    LONG_PTR    = Int64;
#else
    LONG_PTR    = LongInt;
#endif
    SIZE_T      = UINT_PTR;

    LRESULT     = LongInt;
    WPARAM      = UINT_PTR;
    LPARAM      = UINT_PTR;

    COLORREF    = DWord;

    //TIMERPROC   = procedure (hWnd: HWND; uMsg: UINT; nIDEvent: UINT_PTR; uElapse: UINT);
    //WNDPROC     = function  (hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;

    TIMERPROC     = UINT_PTR;
    WNDPROC       = UINT_PTR;

const
    WM_SYSCOMMAND       = $0112;
    SC_MINIMIZE         = $F020;
    SC_MOVE             = $F010;
    HTCAPTION           = $0002;

    SRCCOPY             = $CC0020;

    GCL_STYLE           = (-26);
    GWL_WNDPROC         = (-4);
    GWL_STYLE           = (-16);
    CS_DROPSHADOW       = $20000;
    WS_BORDER           = $800000;

///////////////////////////////////////////////////////////////////////////
// include

#include ".\User32.iss"
#include ".\Gdi32.iss"
