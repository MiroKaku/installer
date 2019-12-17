[Code]

///////////////////////////////////////////////////////////////////////////
// forward declaration

function CreateRoundRectRgn(x1, y1, x2, y2, w, h: INT): HRGN;
external 'CreateRoundRectRgn@Gdi32.dll stdcall delayload';

function DeleteObject(ho: HGDIOBJ): BOOL;
external 'DeleteObject@Gdi32.dll stdcall delayload';

function BitBlt(DestDC: HDC; x, y, cx, cy: INT; SrcDC: HDC; x1, y1: INT; rop: DWORD): BOOL;
external 'BitBlt@Gdi32.dll stdcall delayload';
