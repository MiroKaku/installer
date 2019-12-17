[Code]
// 用于 botva2.dll 库 0.9.9 版的模块
// 由 South.Tver 创建于 03/2015
// http://krinkels.org/resources/botva2.47/

const
    // Button 和 CheckBox/RadioButton 的事件标识符
    BtnClickEventID      = 1;
    BtnMouseEnterEventID = 2;
    BtnMouseLeaveEventID = 3;
    BtnMouseMoveEventID  = 4;
    BtnMouseDownEventID  = 5;
    BtnMouseUpEventID    = 6;

    // 对齐按钮上的文字
    balLeft     = 0; //将文字向左对齐
    balCenter   = 1; //文本在中心水平对齐
    balRight    = 2; //将文字向右对齐
    balVCenter  = 4; //文本在中心的垂直对齐


// function & procedure

function ImgLoad_(Wnd: HWND; FileName: PAnsiChar; Left, Top, Width, Height: integer; Stretch, IsBkg: boolean): THandle; external 'ImgLoad@files:botva2.dll stdcall delayload';
// 将图片加载到内存中，保存传递的参数
// Wnd                  - 将在其中显示图像的窗口的句柄
// FileName             - 图片文件
// Left, Top            - 图像输出的左上角坐标（在工作区 Wnd 的坐标中）
// Width, Height        - 图像宽度, 图像高度
//                          如果 Stretch = True，则图像将在矩形区域中被拉伸/压缩
//                              Rect.Left   := Left;
//                              Rect.Top    := Top;
//                              Rect.Right  := Left + Width;
//                              Rect.Bottom := Top + Height;
//                          如果 Stretch = False，则 Width 和 Height 参数将被 ImgLoad 本身忽略并进行计算，即可以传入0
// Stretch              - 是否拉伸图像
// IsBkg                - 如果 IsBkg = True，则图像将显示在窗体的背景上，图形对象（TLabel，TBitmapImage等）将绘制在其顶部，
//                          然后带有标志的图像将显示在所有内容的顶部
//                        如果 IsBkg = False, 返回值指向存储图像及其参数的结构的指针，将其转换为Longint类型，将按调用ImgLoad的顺序显示

procedure ImgSetVisiblePart(img: THandle; NewLeft, NewTop, NewWidth, NewHeight: integer); external 'ImgSetVisiblePart@files:botva2.dll stdcall delayload';
// 设置图像可见部分的新坐标，即新的宽度和高度。 在原始图像的坐标中
// img                  - 调用ImgLoad时获得的值。
// NewLeft, NewTop      - 可见区域的新的 Left, Top
// NewWidth, NewHeight  - 可见区域的新的 Width, Height
// PS最初（在调用ImgLoad时）被视为完全可见。 如果您只需要显示图片的一部分，请使用以下步骤

procedure ImgGetVisiblePart(img: THandle; var Left, Top, Width, Height: integer); external 'ImgGetVisiblePart@files:botva2.dll stdcall delayload';
// 获取图像可见部分的坐标，宽度和高度
// img                  - 调用 ImgLoad 时获得的值
// NewLeft, NewTop      - 可见区域的 Left, Top
// NewWidth, NewHeight  - 可见区域的 Width, Height

procedure ImgSetPosition(img: THandle; NewLeft, NewTop, NewWidth, NewHeight: integer); external 'ImgSetPosition@files:botva2.dll stdcall delayload';
// 设置显示图像的新坐标. 在父窗口的坐标中
// img                  - 调用ImgLoad时获得的值
// NewLeft, NewTop      - 新的 Left, Top
// NewWidth, NewHeight  - 新的 Width, Height. 如果 Stretch = False 传递给 ImgLoad，则将忽略 NewWidth 和 NewHeight
procedure ImgGetPosition(img: THandle; var Left, Top, Width, Height: integer); external 'ImgGetPosition@files:botva2.dll stdcall delayload';
// 获取图像的坐标
// img                  - 调用 ImgLoad 时获得的值
// Left, Top
// Width, Height

procedure ImgSetVisibility(img: THandle; Visible: boolean); external 'ImgSetVisibility@files:botva2.dll stdcall delayload';
// 设置图像可见性
// img                  - 调用ImgLoad时获得的值
// Visible              - 是否可见

function ImgGetVisibility(img: THandle): boolean; external 'ImgGetVisibility@files:botva2.dll stdcall delayload';
// 获取图像可见性
// img                  - 调用ImgLoad时获得的值

procedure ImgSetTransparent(img: THandle; Value:integer); external 'ImgSetTransparent@files:botva2.dll stdcall delayload';
// 设置图像透明度
// img                  - 调用ImgLoad时获得的值
// Value                - 透明度 (0-255)

function ImgGetTransparent(img: THandle): integer; external 'ImgGetTransparent@files:botva2.dll stdcall delayload';
// 获取图像透明度
// img                  - 调用ImgLoad时获得的值

procedure ImgRelease(img: THandle); external 'ImgRelease@files:botva2.dll stdcall delayload';
// 释放内存中的图像
// img                  - 调用ImgLoad时获得的值

procedure ImgApplyChanges(h: HWND); external 'ImgApplyChanges@files:botva2.dll stdcall delayload';
// 确认输出屏幕的最终图像
// 调用ImgLoad，ImgSetPosition，ImgSetVisibility，ImgRelease所做的所有更改并更新窗口
// h                    - 您要为其创建新图像的窗口的句柄



function BtnCreate_(hParent :HWND; Left, Top, Width, Height :integer; FileName :PAnsiChar; ShadowWidth :integer; IsCheckBtn :boolean) :HWND; external 'BtnCreate@files:botva2.dll stdcall delayload';
// hParent              - 将创建按钮的父窗口的句柄
// Left, Top
// Width, Height
// FileName             - 常规按钮的图像文件的按钮需要4个按钮状态 (分别为4个图像)
//                        IsCheckBtn = True 需要8个按钮状态.
//                        (图像垂直放置)
// ShadowWidth          - 从按钮图片的边缘到图片的实际边界的像素数. 有必要按预期改变按钮和光标的状态
// IsCheckBtn           - CheckBox
// Return               - 创建的按钮的句柄

procedure BtnSetText(h :HWND; Text :PAnsiChar); external 'BtnSetText@files:botva2.dll stdcall delayload';
// 设置按钮文本(类似于Button.Caption:='bla-bla-bla')
// h                    - 按钮句柄 (BtnCreate返回的结果)
// Text                 - 我们想要在按钮上看到的文字

procedure BtnGetText_(h: HWND; Text: PAnsiChar; var NewSize: integer); external 'BtnGetText@files:botva2.dll stdcall delayload';
// 获取按钮文本
// h                    - 按钮句柄 (BtnCreate返回的结果)
// Text                 - 缓冲区接收按钮文本
// Return               - 文本字符串长度

procedure BtnSetTextAlignment(h :HWND; HorIndent, VertIndent :integer; Alignment :DWORD); external 'BtnSetTextAlignment@files:botva2.dll stdcall delayload';
// 在按钮上设置文本对齐方式
// h                    - 按钮句柄 (BtnCreate返回的结果)
// HorIndent            - 从按钮边缘开始的文本水平缩进
// VertIndent           - 从按钮边缘开始的文本垂直缩进
// Alignment            - 文本的对齐方式. 由常量 balLeft, balCenter, balRight, balVCenter 定义.
//                          或 balVCenter与其他组合. 例如 (balVCenter or balRight)

procedure BtnSetFont(h :HWND; Font :Cardinal); external 'BtnSetFont@files:botva2.dll stdcall delayload';
// 设置按钮的字体
// h                    - 按钮句柄 (BtnCreate返回的结果)
// Font                 - 设置字体的句柄
// 为了不遭受基于WinAPI的功能的困扰，您可以使用标准的Inno工具创建字体并传递其句柄
//       例如,
//       var
//         Font:TFont;
//         . . .
//       begin
//         . . .
//         Font:=TFont.Create;
//         创建属性时，默认值无法填充所有属性。我们只改变我们所需要的
//         with Font do begin
//           Name:='Tahoma';
//           Size:=10;
//           . . .
//         end;
//         BtnSetFont(hBtn,Font.Handle);
//         . . .
//       end;
//       当您退出程序时 (或在不必要时), 请不要忘记调用 Font.Free 销毁字体

procedure BtnSetFontColor(h :HWND; NormalFontColor, FocusedFontColor, PressedFontColor, DisabledFontColor :Cardinal); external 'BtnSetFontColor@files:botva2.dll stdcall delayload';
// 设置按钮的字体颜色
// h                    - 按钮句柄 (BtnCreate返回的结果)
// NormalFontColor      - 正常状态下按钮上文本的颜色
// FocusedFontColor     - 处于焦点显示状态的按钮上的文本的颜色
// PressedFontColor     - 处于按下状态的按钮上文本的颜色
// DisabledFontColor    - 禁用状态下按钮上文本的颜色

function BtnGetVisibility(h :HWND) :boolean; external 'BtnGetVisibility@files:botva2.dll stdcall delayload';
// 获取按钮的可见性 (模拟 f := Button.Visible )
// h                    - 按钮句柄 (BtnCreate返回的结果)
// Return               -按钮的可见性

procedure BtnSetVisibility(h :HWND; Value :boolean); external 'BtnSetVisibility@files:botva2.dll stdcall delayload';
// 设置按钮的可见性 (模拟 Button.Visible:=True / Button.Visible:=False )
// h                    - 按钮句柄 (BtnCreate返回的结果)
// Value                - 按钮的可见性

function BtnGetEnabled(h :HWND) :boolean; external 'BtnGetEnabled@files:botva2.dll stdcall delayload';
// 获取按钮的可用性 (模拟 f := Button.Enabled )
// h                    - 按钮句柄 (BtnCreate返回的结果)
// Return               - 按钮的可用性

procedure BtnSetEnabled(h :HWND; Value :boolean); external 'BtnSetEnabled@files:botva2.dll stdcall delayload';
// 设置按钮的可用性 (模拟 f := Button.Enabled:=True / Button.Enabled:=False )
// h                    - 按钮句柄 (BtnCreate返回的结果)
// Value                - 按钮的可用性

function BtnGetChecked(h :HWND) :boolean; external 'BtnGetChecked@files:botva2.dll stdcall delayload';
// 获取 CheckBox 按钮的状态 (打开/关闭) (模拟 f:=Checkbox.Checked)
// h                    - 按钮句柄 (BtnCreate返回的结果)

procedure BtnSetChecked(h :HWND; Value :boolean); external 'BtnSetChecked@files:botva2.dll stdcall delayload';
// 设置 CheckBox 按钮的状态 (打开/关闭) (模拟 Сheckbox.Checked:=True / Сheckbox.Checked:=False)
// h                    - 按钮句柄 (BtnCreate返回的结果)
// Value                - 按钮打开或关闭

procedure BtnSetEvent(h :HWND; EventID :integer; Event :Longword); external 'BtnSetEvent@files:botva2.dll stdcall delayload';
// 设置按钮的事件
// h                    - 按钮句柄 (BtnCreate返回的结果)
// EventID              - 由常量 BtnClickEventID，BtnMouseEnterEventID，BtnMouseLeaveEventID，BtnMouseMoveEventID 指定的事件标识符
// Event                - 发生指定事件时执行的回调函数的地址
// example              - BtnSetEvent(hBtn, BtnClickEventID, CreateCallback(@BtnClick));

procedure BtnGetPosition(h:HWND; var Left, Top, Width, Height: integer);  external 'BtnGetPosition@files:botva2.dll stdcall delayload';
// 获取按钮位置
// h                    - 按钮句柄 (BtnCreate返回的结果)
// Left, Top
// Width, Height

procedure BtnSetPosition(h:HWND; NewLeft, NewTop, NewWidth, NewHeight: integer);  external 'BtnSetPosition@files:botva2.dll stdcall delayload';
// 设置按钮位置
// h                    - 按钮句柄 (BtnCreate返回的结果)
// NewLeft, NewTop
// NewWidth, NewHeight

procedure BtnRefresh(h :HWND); external 'BtnRefresh@files:botva2.dll stdcall delayload';
// 立即重绘按钮，绕过消息队列. 如果按钮没有时间重绘, 则调用
// h                    - 按钮句柄 (BtnCreate返回的结果)

procedure BtnSetCursor(h:HWND; hCur:Cardinal); external 'BtnSetCursor@files:botva2.dll stdcall delayload';
// 设置按钮的光标
// h                    - 按钮句柄 (BtnCreate返回的结果)
// hCur                 - 光标的句柄
// 不需要调用 DestroyCursor, 它将在 gdipShutDown 时销毁

function GetSysCursorHandle(id:integer):Cardinal; external 'GetSysCursorHandle@files:botva2.dll stdcall delayload';
// 通过其标识符加载标准光标
// id                   - 标准光标的标识符. 标准光标的标识符由 OCR _... 常量设置，其值在 MSDN 上搜索
//Return                - 加载的光标的句柄

procedure gdipShutdown; external 'gdipShutdown@files:botva2.dll stdcall delayload';
// 释放GDI资源, 要保证在退出前调用


procedure CreateFormFromImage_(h:HWND; FileName:PAnsiChar); external 'CreateFormFromImage@files:botva2.dll stdcall delayload';
//使用 PNG 图片创建 Form（原则上, 您可以使用其他图片格式）
// h                    - 窗口句柄
// FileName             - 图像文件的路径
//在此 Form, 控件 (按钮, 复选框, 编辑等) 将不可见!

function CreateBitmapRgn(DC: LongWord; Bitmap: HBITMAP; TransClr: DWORD; dX:integer; dY:integer): LongWord; external 'CreateBitmapRgn@files:botva2.dll stdcall delayload';
// 根据位图创建区域
// DC                   - 表单上下文
// Bitmap               - 我们将在其上构建区域的位图
// TransClr             - 不会包含在区域中的像素的颜色（透明颜色）
// dX, dY               - 表单上区域的偏移量

procedure SetMinimizeAnimation(Value: Boolean); external 'SetMinimizeAnimation@files:botva2.dll stdcall delayload';
// 最小化窗口时启用 / 禁用动画

function GetMinimizeAnimation: Boolean; external 'GetMinimizeAnimation@files:botva2.dll stdcall delayload';
//获取最小化窗口动画的当前状态



function CheckBoxCreate_(hParent:HWND; Left,Top,Width,Height:integer; FileName:PAnsiChar; GroupID, TextIndent:integer) :HWND; external 'CheckBoxCreate@files:botva2.dll stdcall delayload';
// hParent，Left，Top，Width，Height，FileName
// GroupID              - 用于RadioButton. 在同一组中，只能选择1个radibaton.
//                          GroupID = 0, 没有组.  这将是一个 CheckBox, 否则是 RadioButton
// TextIndent           - CheckBox/RadioButton 的文本缩进 (以像素为单位)

// 所有其他过程/功能都类似于按钮
procedure CheckBoxSetText(h :HWND; Text :PAnsiChar); external 'CheckBoxSetText@files:botva2.dll stdcall delayload';
procedure CheckBoxGetText_(h: HWND; Text: PAnsiChar; var NewSize: integer); external 'CheckBoxGetText@files:botva2.dll stdcall delayload'; //скорее всего работает криво
procedure CheckBoxSetFont(h:HWND; Font:LongWord); external 'CheckBoxSetFont@files:botva2.dll stdcall delayload';
procedure CheckBoxSetEvent(h:HWND; EventID:integer; Event:Longword); external 'CheckBoxSetEvent@files:botva2.dll stdcall delayload';
procedure CheckBoxSetFontColor(h:HWND; NormalFontColor, FocusedFontColor, PressedFontColor, DisabledFontColor: Cardinal); external 'CheckBoxSetFontColor@files:botva2.dll stdcall delayload';
function  CheckBoxGetEnabled(h:HWND):boolean; external 'CheckBoxGetEnabled@files:botva2.dll stdcall delayload';
procedure CheckBoxSetEnabled(h:HWND; Value:boolean); external 'CheckBoxSetEnabled@files:botva2.dll stdcall delayload';
function  CheckBoxGetVisibility(h:HWND):boolean; external 'CheckBoxGetVisibility@files:botva2.dll stdcall delayload';
procedure CheckBoxSetVisibility(h:HWND; Value:boolean); external 'CheckBoxSetVisibility@files:botva2.dll stdcall delayload';
procedure CheckBoxSetCursor(h:HWND; hCur:LongWord); external 'CheckBoxSetCursor@files:botva2.dll stdcall delayload';
procedure CheckBoxSetChecked(h:HWND; Value:boolean); external 'CheckBoxSetChecked@files:botva2.dll stdcall delayload';
function  CheckBoxGetChecked(h:HWND):boolean; external 'CheckBoxGetChecked@files:botva2.dll stdcall delayload';  
procedure CheckBoxRefresh(h:HWND); external 'CheckBoxRefresh@files:botva2.dll stdcall delayload';
procedure CheckBoxSetPosition(h:HWND; NewLeft, NewTop, NewWidth, NewHeight: integer); external 'CheckBoxSetPosition@files:botva2.dll stdcall delayload';
procedure CheckBoxGetPosition(h:HWND; var Left, Top, Width, Height: integer); external 'CheckBoxGetPosition@files:botva2.dll stdcall delayload';



function BtnGetText(hBtn: HWND): String;
var
    buf     : AnsiString;
    NewSize : integer;
begin
    buf     :='';
    NewSize :=0;
    BtnGetText_(hBtn, PAnsiChar(buf), NewSize);
    if NewSize > 0 then begin
        SetLength(buf, NewSize);
        BtnGetText_(hBtn, PAnsiChar(buf), NewSize);
    end;
    Result  := String(buf);
end;

function CheckBoxGetText(hBtn: HWND): String;
var
    buf     : AnsiString;
    NewSize : integer;
begin
    buf     :='';
    NewSize :=0;
    CheckBoxGetText_(hBtn, PAnsiChar(buf), NewSize);
    if NewSize > 0 then begin
        SetLength(buf, NewSize);
        CheckBoxGetText_(hBtn, PAnsiChar(buf), NewSize);
    end;
    Result  := String(buf);
end;

function ImgLoad(Wnd :HWND; FileName :PAnsiChar; Left, Top, Width, Height :integer; Stretch, IsBkg :boolean): THandle;
begin
    if not FileExists(FileName) then begin
        ExtractTemporaryFile(FileName);
        Result := ImgLoad_(Wnd,ExpandConstant('{tmp}\')+FileName,Left,Top,Width,Height,Stretch,IsBkg);
        DeleteFile(ExpandConstant('{tmp}\')+FileName);
    end else Result := ImgLoad_(Wnd,FileName,Left,Top,Width,Height,Stretch,IsBkg);
end;

function BtnCreate(hParent :HWND; Left, Top, Width, Height :integer; FileName :PAnsiChar; ShadowWidth :integer; IsCheckBtn :boolean) :HWND; 
begin
    if not FileExists(FileName) then begin
        ExtractTemporaryFile(FileName);
        Result := BtnCreate_(hParent,Left,Top,Width,Height,ExpandConstant('{tmp}\')+FileName,ShadowWidth,IsCheckBtn);
        DeleteFile(ExpandConstant('{tmp}\')+FileName);
    end else Result := BtnCreate_(hParent,Left,Top,Width,Height,FileName,ShadowWidth,IsCheckBtn);
end;

function CheckBoxCreate(hParent:HWND; Left,Top,Width,Height:integer; FileName:PAnsiChar; GroupID, TextIndent:integer):HWND;
begin
    if not FileExists(FileName) then begin
        ExtractTemporaryFile(FileName);
        Result := CheckBoxCreate_(hParent,Left,Top,Width,Height,ExpandConstant('{tmp}\')+FileName,GroupID,TextIndent);
        DeleteFile(ExpandConstant('{tmp}\')+FileName);
    end else Result := CheckBoxCreate_(hParent,Left,Top,Width,Height,FileName,GroupID,TextIndent);
end;

procedure CreateFormFromImage(h:HWND; FileName:PAnsiChar);
begin
    if not FileExists(FileName) then begin
        ExtractTemporaryFile(FileName);
        CreateFormFromImage_(h, ExpandConstant('{tmp}\')+FileName);
        DeleteFile(ExpandConstant('{tmp}\')+FileName);
    end else CreateFormFromImage_(h, FileName);
end;
