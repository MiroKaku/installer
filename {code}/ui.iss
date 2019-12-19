#include ".\Windows.iss"
#include ".\botva2.iss"

[Code]

const
    PRODUCT_REGISTRY_KEY = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{#MyAppID}_is1';

type
    MInnoWizardMsgBox   = record
        IsInitialized   : Boolean;
        Main            : TSetupForm;
        Title           : TLabel;
        Text            : TLabel;
        Background      : TLabel;
        ImgBackground   : THandle;

        BtnClose        : HWND;
        BtnOk           : HWND;
        BtnCancel       : HWND;

        Create          : function (): Boolean;
        Handle          : function (): HWND;
        Close           : procedure();
        ShowModal       : procedure();
        Release         : procedure();
    end;

    MInnoWizardLicense  = record
        IsInitialized   : Boolean;
        Main            : TSetupForm;
        Title           : TLabel;
        Text            : TRichEditViewer;
        Background      : TLabel;
        ImgBackground   : THandle;

        BtnClose        : HWND;
        BtnOk           : HWND;
        BtnCancel       : HWND;

        Create          : function (): Boolean;
        Handle          : function (): HWND;
        Close           : procedure();
        ShowModal       : procedure();
        Release         : procedure();
    end;

    MInnoWizardMain     = record
        IsInitialized   : Boolean;
        //Main            : TWizardForm;
        Title           : TLabel;
        Path            : TEdit;
        InstalledTips   : TLabel;   
        InstallingTips  : TLabel;     
        Background      : TLabel;
        ImgBackground   : THandle;

        BtnClose        : HWND;
        BtnMinimize     : HWND;
        BtnNext         : HWND;
        BtnSelectPath   : HWND;
        BtnMoreOption   : HWND;
        BtnNormalOption : HWND;
        BtnLicense      : HWND;
        ChkLicense      : HWND;

        CurrentSlidesNo : Integer;
        CurrentSlidesPos: Integer;

        Slide_1_b       : THandle;
        Slide_2_b       : THandle;
        Slide_3_b       : THandle;
        Slide_4_b       : THandle;
        Slide_1_t       : THandle;
        Slide_2_t       : THandle;
        Slide_3_t       : THandle;
        Slide_4_t       : THandle;

        ProgressText    : TLabel;
        ImgProgressBarBackground: THandle;
        ImgProgressBarForeground: THandle;
        //ProgressBarProcOld    : function (hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM) : LRESULT;
        ProgressBarProcOld      : LONG_PTR;

        Create          : function (): Boolean;
        Handle          : function (): HWND;
        Release         : procedure();
    end;

var
    MsgBoxWindow    : MInnoWizardMsgBox;
    LicenseWindow   : MInnoWizardLicense;
    MainWindow      : MInnoWizardMain;

    MInnoWizardTimerAnimation   : UINT_PTR;
    MInnoWizardTimerSlides      : UINT_PTR;
    MInnoWizardTimerSlidesPause : UINT_PTR;
    MInnoWizardTimerSlidesPause_Count: Integer;

    InstalledVersion    : String;

    IsMainShowNormal    : Boolean;
    IsCanExitSetup      : Boolean;
    IsReleased          : Boolean;

const
    WIZARDFORM_WIDTH_NORMAL     = 600;
    WIZARDFORM_HEIGHT_NORMAL    = 400;
    WIZARDFORM_HEIGHT_MORE      = 503;
    SLIDES_PICTURE_WIDTH        = WIZARDFORM_WIDTH_NORMAL;
    SLIDES_PICTURE_HEIGHT       = 332;
    SLIDES_PAUSE_SECONDS        = 5;

////////////////////////////////////////////////////////////////////////////
// declaration

// DPI
function GetScalingFactor   (): Integer; forward;

// Window
function CreateMsgBox       (): Boolean; forward;
function CreateLicense      (): Boolean; forward;
function CreateWizardMain   (): Boolean; forward;

procedure StopTimer_Animation (); forward;
procedure StopTimer_Slide     (); forward;
procedure StopTimer_SlidePause(); forward;
procedure SlidesAnimation(hWnd: HWND; uMsg: UINT; nIDEvent: UINT_PTR; uElapse: UINT); forward;

procedure MInnoWizardAnimationShowFull  (hWnd: HWND; uMsg: UINT; nIDEvent: UINT_PTR; uElapse: UINT); forward;
procedure MInnoWizardAnimationShowNormal(hWnd: HWND; uMsg: UINT; nIDEvent: UINT_PTR; uElapse: UINT); forward;

procedure BtnClickEvent_Main_Next(hWnd : HWND); forward;

////////////////////////////////////////////////////////////////////////////
// DPI

function GetScalingFactor: Integer;
begin
    if WizardForm.Font.PixelsPerInch >= 192 then Result := 200
        else
    if WizardForm.Font.PixelsPerInch >= 168 then Result := 175
        else
    if WizardForm.Font.PixelsPerInch >= 144 then Result := 150
        else
    if WizardForm.Font.PixelsPerInch >= 120 then Result := 125
        else Result := 100;
end;

function GetScaleImage(Image: String): String;
var
    Path: String;
begin
    Path    := Format('%s\%d\%s', [ExpandConstant('{tmp}'), GetScalingFactor(), Image]);
    Result  := Path;
end;

////////////////////////////////////////////////////////////////////////////
// Inno Setup Events

//如果使用自定义卸载程序，就修改注册表，将默认卸载程序路径改为我们自己的卸载程序的路径
procedure FixUninstRegistry;
begin
    if RegValueExists(HKLM32, PRODUCT_REGISTRY_KEY, 'UninstallString') then
    begin
        RegDeleteValue(HKLM32, PRODUCT_REGISTRY_KEY, 'UninstallString');
    end;
    if RegValueExists(HKLM64, PRODUCT_REGISTRY_KEY, 'UninstallString') then
    begin
        RegDeleteValue(HKLM64, PRODUCT_REGISTRY_KEY, 'UninstallString');
    end;
    if Is64BitInstallMode then
    begin
        RegWriteStringValue(HKLM64, PRODUCT_REGISTRY_KEY, 'UninstallString', ExpandConstant('"{app}\Uninstall.exe"'));
    end else
    begin
        RegWriteStringValue(HKLM32, PRODUCT_REGISTRY_KEY, 'UninstallString', ExpandConstant('"{app}\Uninstall.exe"'));
    end;
end;

//这个函数的作用是判断是否已经安装了将要安装的产品，若已经安装，则返回True，否则返回False
function IsInstalled() : Boolean;
begin
    if Is64BitInstallMode then
    begin
        if RegKeyExists(HKLM64, PRODUCT_REGISTRY_KEY) then
        begin
            RegQueryStringValue(HKLM64, PRODUCT_REGISTRY_KEY, 'DisplayVersion', InstalledVersion);
            Result := True;
        end else
        begin
            InstalledVersion := '0.0.0';
            Result := False;
        end;
    end else
    begin
        if RegKeyExists(HKLM32, PRODUCT_REGISTRY_KEY) then
        begin
            RegQueryStringValue(HKLM32, PRODUCT_REGISTRY_KEY, 'DisplayVersion', InstalledVersion);
            Result := True;
        end else
        begin
            InstalledVersion := '0.0.0';
            Result := False;
        end;
    end;
end;

//这个函数的作用是判断是否正在安装旧版本（若系统中已经安装了将要安装的产品），是则返回True，否则返回False
function IsInstallingOlderVersion() : Boolean;
var
    installedVer            : array[1..10] of longint;
    installingVer           : array[1..10] of longint;
    oldVer                  : string;
    nowVer                  : string;
    version_installing_now  : string;
    i                       : integer;
    oldTotal                : integer;
    nowTotal                : integer;
    total                   : integer;
begin
    oldTotal := 1;
    while (Pos('.', InstalledVersion) > 0) do
    begin
        oldVer := InstalledVersion;
        Delete(oldVer, Pos('.', oldVer), ((Length(oldVer) - Pos('.', oldVer)) + 1));
        installedVer[oldTotal]    := StrToIntDef(oldVer, 0);
        oldTotal                  := oldTotal + 1;
        InstalledVersion  := Copy(InstalledVersion, (Pos('.', InstalledVersion) + 1), (Length(InstalledVersion) - Pos('.', InstalledVersion)));
    end;

    if (InstalledVersion <> '') then
    begin
        installedVer[oldTotal] := StrToIntDef(InstalledVersion, 0);
    end else
    begin
        oldTotal := oldTotal - 1;
    end;

    version_installing_now  := '{#MyAppVersion}';
    nowTotal                := 1;
    while (Pos('.', version_installing_now) > 0) do
    begin
        nowVer := version_installing_now;
        Delete(nowVer, Pos('.', nowVer), ((Length(nowVer) - Pos('.', nowVer)) + 1));
        installingVer[nowTotal] := StrToIntDef(nowVer, 0);
        nowTotal                := nowTotal + 1;
        version_installing_now  := Copy(version_installing_now, (Pos('.', version_installing_now) + 1), (Length(version_installing_now) - Pos('.', version_installing_now)));
    end;

    if (version_installing_now <> '') then
    begin
        installingVer[nowTotal] := StrToIntDef(version_installing_now, 0);
    end else
    begin
        nowTotal := nowTotal - 1;
    end;

    if (oldTotal < nowTotal) then
    begin
        for i := (oldTotal + 1) to nowTotal do
        begin
            installedVer[i] := 0;
        end;
        total := nowTotal;
    end else if (oldTotal > nowTotal) then
    begin
        for i := (nowTotal + 1) to oldTotal do
        begin
            installingVer[i] := 0;
        end;
        total := oldTotal;
    end else
    begin
        total := nowTotal;
    end;

    for i := 1 to total do
    begin
        if (installedVer[i] > installingVer[i]) then
        begin
            Result := True;
        Exit;
        end else if (installedVer[i] < installingVer[i]) then
        begin
            Result := False;
        Exit;
        end else
        begin
            Continue;
        end;
    end;

    Result := False;
end;

//释放安装程序时调用的脚本
procedure ReleaseAll();
begin
    if IsReleased = False then
    begin
        IsReleased := True;

        StopTimer_Slide();
        StopTimer_Animation();
        
        gdipShutdown();

        MsgBoxWindow.Release();
#ifdef MyAppLicenseFile
        LicenseWindow.Release();
#endif
        MainWindow.Release();
    end;
end;

// 跳过哪些标准页面
function ShouldSkipPage(PageID : Integer) : Boolean;
begin
    if (PageID = wpLicense)             then Result := True;
    if (PageID = wpPassword)            then Result := True;
    if (PageID = wpInfoBefore)          then Result := True;
    if (PageID = wpUserInfo)            then Result := True;
    if (PageID = wpSelectDir)           then Result := True;
    if (PageID = wpSelectComponents)    then Result := True;
    if (PageID = wpSelectProgramGroup)  then Result := True;
    if (PageID = wpSelectTasks)         then Result := True;
    if (PageID = wpReady)               then Result := True;
    if (PageID = wpPreparing)           then Result := True;
    if (PageID = wpInfoAfter)           then Result := True;
end;

//重载安装程序初始化函数，判断是否已经安装新版本，是则禁止安装
function InitializeSetup() : Boolean;
begin
    IsReleased := False;

#ifndef PortableMode
#ifdef  OnlyInstallNewVersion
    if IsInstalled() then
    begin
        if IsInstallingOlderVersion() then
        begin
            MsgBox(FmtMessage(SetupMessage(msgWinVersionTooLowError), ['{#MyAppFriendlyName}', '{#MyAppVersion}']), mbInformation, MB_OK);
            Result := False;
        end else
        begin
            Result := True;
        end;
    end else
    begin
        Result := True;
    end;
#else
    Result := True;
#endif
#else
    Result := True;
#endif
end;

//安装程序销毁时会调用这个函数
procedure DeinitializeSetup();
begin
    if ((IsReleased = False) and (IsCanExitSetup = False)) then
    begin
        ReleaseAll();
    end;
end;

procedure ExtractAllTemporaryFile();
var
    Path: String;
begin
    // image
    Path := Format('{tmp}\%d\*', [GetScalingFactor()]);
    ExtractTemporaryFiles(Path);

#ifdef MyAppLicenseFile
    // license
    ExtractTemporaryFile('{#MyAppLicenseFile}');
#endif
end;

//重载安装程序初始化函数（和上边那个不一样），进行初始化操作
procedure InitializeWizard();
begin
    ExtractAllTemporaryFile();

    IsMainShowNormal := True;

    CreateMsgBox    ();
    CreateLicense   ();
    CreateWizardMain();
end;

//安装步骤改变时会调用这个函数
procedure CurStepChanged(CurStep : TSetupStep);
begin
  if (CurStep = ssDone) then
  begin
    ReleaseAll();
    
#ifdef UseCustomUninstaller
    FixUninstRegistry();
#endif
  end;
end;

//安装页面改变时会调用这个函数
procedure CurPageChanged(CurPageID : Integer);
begin
    if (CurPageID = wpWelcome) then
    begin
        // 设置默认窗口
        WizardForm.ClientHeight := ScaleY(WIZARDFORM_HEIGHT_NORMAL);
    end;

    if (CurPageID = wpInstalling) then
    begin
        StopTimer_Animation;
        IsMainShowNormal            := True;
        MInnoWizardTimerAnimation   := SetTimer(0, 0, 1, CreateCallback(@MInnoWizardAnimationShowNormal));

        MainWindow.Path.Hide();
        MainWindow.InstalledTips.Hide();
        MainWindow.InstallingTips.Show();

        BtnSetVisibility(MainWindow.BtnNext         , False);
        BtnSetVisibility(MainWindow.BtnSelectPath   , False);
        BtnSetVisibility(MainWindow.BtnMoreOption   , False);
        BtnSetVisibility(MainWindow.BtnNormalOption , False);
        BtnSetVisibility(MainWindow.BtnLicense      , False);
        BtnSetVisibility(MainWindow.ChkLicense      , False);
        BtnSetVisibility(MainWindow.BtnClose        , False);
        BtnSetPosition  (MainWindow.BtnMinimize, ScaleX(WIZARDFORM_WIDTH_NORMAL - 30), ScaleY(0), ScaleX(30), ScaleY(30));

        // Background
        MainWindow.ImgBackground := ImgLoad(WizardForm.Handle, GetScaleImage('background_installing.png'),
            ScaleX(0), ScaleY(0), ScaleX(WIZARDFORM_WIDTH_NORMAL), ScaleY(WIZARDFORM_HEIGHT_NORMAL), True, True);

        // ProgressBar
        MainWindow.ImgProgressBarBackground := ImgLoad(MainWindow.Handle(), GetScaleImage('progressbar_background.png'), 
            ScaleX(20), ScaleY(374), ScaleX(560), ScaleY(8), True, True);

        MainWindow.ImgProgressBarForeground := ImgLoad(MainWindow.Handle(), GetScaleImage('progressbar_foreground.png'), 
            ScaleX(20), ScaleY(374), ScaleX(0), ScaleY(0), True, True);
                
#ifdef ShowSlidePictures
        MainWindow.Slide_1_b := ImgLoad(MainWindow.Handle(), GetScaleImage('slides_picture_1.png'),
            ScaleX(0), ScaleY(0), ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT), True, True);
        MainWindow.Slide_2_b := ImgLoad(MainWindow.Handle(), GetScaleImage('slides_picture_2.png'),
            ScaleX(0), ScaleY(0), ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT), True, True);
        MainWindow.Slide_3_b := ImgLoad(MainWindow.Handle(), GetScaleImage('slides_picture_3.png'),
            ScaleX(0), ScaleY(0), ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT), True, True);
        MainWindow.Slide_4_b := ImgLoad(MainWindow.Handle(), GetScaleImage('slides_picture_4.png'),
            ScaleX(0), ScaleY(0), ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT), True, True);
        MainWindow.Slide_1_t := ImgLoad(MainWindow.Handle(), GetScaleImage('slides_picture_1.png'),
            ScaleX(0), ScaleY(0), ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT), True, True);
        MainWindow.Slide_2_t := ImgLoad(MainWindow.Handle(), GetScaleImage('slides_picture_2.png'),
            ScaleX(0), ScaleY(0), ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT), True, True);
        MainWindow.Slide_3_t := ImgLoad(MainWindow.Handle(), GetScaleImage('slides_picture_3.png'),
            ScaleX(0), ScaleY(0), ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT), True, True);
        MainWindow.Slide_4_t := ImgLoad(MainWindow.Handle(), GetScaleImage('slides_picture_4.png'),
            ScaleX(0), ScaleY(0), ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT), True, True);

        ImgSetVisibility(MainWindow.Slide_1_t, False);
        ImgSetVisibility(MainWindow.Slide_2_t, False);
        ImgSetVisibility(MainWindow.Slide_3_t, False);
        ImgSetVisibility(MainWindow.Slide_4_t, False);
        ImgSetVisibility(MainWindow.Slide_1_b, False);
        ImgSetVisibility(MainWindow.Slide_2_b, False);
        ImgSetVisibility(MainWindow.Slide_3_b, False);
        ImgSetVisibility(MainWindow.Slide_4_b, False);
        
        StopTimer_Slide();
        StopTimer_SlidePause();
        MInnoWizardTimerSlidesPause_Count := 0;
        MInnoWizardTimerSlides := SetTimer(0, 0, 20, CreateCallback(@SlidesAnimation));
#endif
    end;

    if (CurPageID = wpFinished) then
    begin
    #ifdef ShowSlidePictures
        StopTimer_Slide();
        StopTimer_SlidePause();
        MInnoWizardTimerSlidesPause_Count := 0;
    #endif

        MainWindow.InstallingTips.Hide();
        MainWindow.ProgressText.Hide();
        
        ImgSetVisibility(MainWindow.ImgProgressBarForeground, False);
        ImgSetVisibility(MainWindow.ImgProgressBarBackground, False);

        BtnSetVisibility(MainWindow.BtnClose, True);
        BtnSetPosition  (MainWindow.BtnMinimize, ScaleX(WIZARDFORM_WIDTH_NORMAL - 30 - 30), ScaleY(0), ScaleX(30), ScaleY(30));

        MainWindow.BtnNext := BtnCreate(MainWindow.Handle(),
            ScaleX(214), ScaleY(305), ScaleX(180), ScaleY(44), GetScaleImage('button_finish.png'), 0, False);

        BtnSetEvent(MainWindow.BtnNext , BtnClickEventID, CreateCallback(@BtnClickEvent_Main_Next));
        BtnSetEvent(MainWindow.BtnClose, BtnClickEventID, CreateCallback(@BtnClickEvent_Main_Next));

        MainWindow.ImgBackground := ImgLoad(MainWindow.Handle(), GetScaleImage('background_finish.png'),
            ScaleX(0), ScaleY(0), ScaleX(WIZARDFORM_WIDTH_NORMAL), ScaleY(WIZARDFORM_HEIGHT_NORMAL), True, True);
    end;

    ImgApplyChanges (MainWindow.Handle());
end;

//重载主界面取消按钮被按下后的处理过程
procedure CancelButtonClick(CurPageID : Integer; var Cancel, Confirm: Boolean);
begin
    Confirm := False;
    MsgBoxWindow.ShowModal();
    
    if IsCanExitSetup then
    begin
        ReleaseAll();
        Cancel := True;
    end else
    begin
        Cancel := False;
    end;
end;

////////////////////////////////////////////////////////////////////////////
// MsgBoxWindow

procedure OnMoveWindow_MsgBox(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture();
  SendMessage(MsgBoxWindow.Handle(), WM_SYSCOMMAND, (SC_MOVE or HTCAPTION), 0);
end;

procedure BtnClickEvent_MsgBox_Ok(hWnd: HWND);
begin
    IsCanExitSetup := True;
    MsgBoxWindow.Close();
end;

procedure BtnClickEvent_MsgBox_Cancel(hWnd: HWND);
begin
    IsCanExitSetup := False;
    MsgBoxWindow.Close();
end;

function MInnoWizardMsgBox_Create(): Boolean;
begin
    // Framework
    MsgBoxWindow.Main := CreateCustomForm();
    with MsgBoxWindow.Main do
    begin
        BorderStyle     := bsNone;
        ClientWidth     := ScaleX(380);
        ClientHeight    := ScaleY(190);
        Color           := clWhite;
        Caption         := 'MInnoWizardMsgBox';
    end;
    
    // Title
    MsgBoxWindow.Title := TLabel.Create(MsgBoxWindow.Main);
    with MsgBoxWindow.Title do
    begin
        Parent          := MsgBoxWindow.Main;
        AutoSize        := False;
        Left            := ScaleX(30);
        Top             := ScaleY(5);
        ClientWidth     := ScaleX(500);
        ClientHeight    := ScaleY(20);
        Font.Size       := ScaleX(10);
        Font.Color      := clWhite;
        Caption         := FmtMessage(SetupMessage(msgSetupWindowTitle), ['{#MyAppFriendlyName}']);
        Transparent     := True;
        OnMouseDown     := @OnMoveWindow_MsgBox;
    end;
    
    // Text
    MsgBoxWindow.Text := TLabel.Create(MsgBoxWindow.Main);
    with MsgBoxWindow.Text do
    begin
        Parent          := MsgBoxWindow.Main;
        AutoSize        := False;
        Left            := ScaleX(70);
        Top             := ScaleY(64);
        ClientWidth     := ScaleX(400);
        ClientHeight    := ScaleY(20);
        Font.Size       := ScaleX(10);
        Font.Color      := clBlack;
        Caption         := SetupMessage(msgExitSetupTitle);
        Transparent     := True;
        OnMouseDown     := @OnMoveWindow_MsgBox;
    end;

    // Background
    MsgBoxWindow.Background := TLabel.Create(MsgBoxWindow.Main);
    with MsgBoxWindow.Background do
    begin
        Parent          := MsgBoxWindow.Main;
        AutoSize        := False;
        Left            := ScaleX(0);
        Top             := ScaleY(0);
        ClientWidth     := MsgBoxWindow.Main.ClientWidth;
        ClientHeight    := MsgBoxWindow.Main.ClientHeight;
        Caption         := '';
        Transparent     := True;
        OnMouseDown     := @OnMoveWindow_MsgBox;
    end;

    // Background Image
    MsgBoxWindow.ImgBackground := ImgLoad(MsgBoxWindow.Handle(), GetScaleImage('background_messagebox.png'),
        ScaleX(0), ScaleY(0), ScaleX(380), ScaleY(190), False, True);
 
    // Button
    MsgBoxWindow.BtnOk      := BtnCreate(MsgBoxWindow.Handle(), 
        ScaleX(206), ScaleY(150), ScaleX(76), ScaleY(28), GetScaleImage('button_ok.png'), 0, False);

    MsgBoxWindow.BtnCancel  := BtnCreate(MsgBoxWindow.Handle(), 
        ScaleX(293), ScaleY(150), ScaleX(76), ScaleY(28), GetScaleImage('button_cancel.png'), 0, False);

    MsgBoxWindow.BtnClose   := BtnCreate(MsgBoxWindow.Handle(), 
        ScaleX(350), ScaleY(0), ScaleX(30), ScaleY(30), GetScaleImage('button_close.png'), 0, False);

    // Button-Event
    BtnSetEvent(MsgBoxWindow.BtnOk,     BtnClickEventID, CreateCallback(@BtnClickEvent_MsgBox_Ok));
    BtnSetEvent(MsgBoxWindow.BtnCancel, BtnClickEventID, CreateCallback(@BtnClickEvent_MsgBox_Cancel));
    BtnSetEvent(MsgBoxWindow.BtnClose,  BtnClickEventID, CreateCallback(@BtnClickEvent_MsgBox_Cancel));

    // Style
    SetClassLong (MsgBoxWindow.Handle(), GCL_STYLE, GetClassLong (MsgBoxWindow.Handle(), GCL_STYLE) or CS_DROPSHADOW);
    SetWindowLong(MsgBoxWindow.Handle(), GWL_STYLE, GetWindowLong(MsgBoxWindow.Handle(), GWL_STYLE) or WS_BORDER);

    // Apply
    ImgApplyChanges(MsgBoxWindow.Handle());
    Result := True;
end;

function MInnoWizardMsgBox_Handle(): HWND;
begin
    Result := MsgBoxWindow.Main.Handle;
end;

procedure MInnoWizardMsgBox_Close();
begin
    MsgBoxWindow.Main.Close();
end;

procedure MInnoWizardMsgBox_ShowModal();
begin
    MsgBoxWindow.Main.ShowModal();
end;

procedure MInnoWizardMsgBox_Release();
begin
    ImgRelease(MsgBoxWindow.ImgBackground);
    MsgBoxWindow.Main.Release();
end;

function CreateMsgBox(): Boolean;
begin
    MsgBoxWindow.Create     := @MInnoWizardMsgBox_Create;
    MsgBoxWindow.Close      := @MInnoWizardMsgBox_Close;
    MsgBoxWindow.Handle     := @MInnoWizardMsgBox_Handle;
    MsgBoxWindow.ShowModal  := @MInnoWizardMsgBox_ShowModal;
    MsgBoxWindow.Release    := @MInnoWizardMsgBox_Release;

    Result := MsgBoxWindow.Create(); 
end;


////////////////////////////////////////////////////////////////////////////
// LicenseWindow

#ifdef MyAppLicenseFile
procedure OnMoveWindow_License(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture();
  SendMessage(LicenseWindow.Handle(), WM_SYSCOMMAND, (SC_MOVE or HTCAPTION), 0);
end;

procedure BtnClickEvent_License_Ok(hWnd: HWND);
begin
    BtnSetChecked(MainWindow.ChkLicense , True);
    BtnSetEnabled(MainWindow.BtnNext    , True);
    LicenseWindow.Close();
end;

procedure BtnClickEvent_License_Cancel(hWnd: HWND);
begin
    BtnSetChecked(MainWindow.ChkLicense , False);
    BtnSetEnabled(MainWindow.BtnNext    , False);
    LicenseWindow.Close();
end;

function MInnoWizardLicense_Create(): Boolean;
begin
    // Framework
    LicenseWindow.Main := CreateCustomForm();
    with LicenseWindow.Main do
    begin
        BorderStyle     := bsNone;
        ClientWidth     := ScaleX(510);
        ClientHeight    := ScaleY(447);
        Color           := clWhite;
        Caption         := 'MInnoWizardLicense';
    end;
    
    // Title
    //LicenseWindow.Title := TLabel.Create(LicenseWindow.Main);
    //with LicenseWindow.Title do
    //begin
    //    Parent          := LicenseWindow.Main;
    //    AutoSize        := False;
    //    Left            := ScaleX(30);
    //    Top             := ScaleY(5);
    //    ClientWidth     := ScaleX(500);
    //    ClientHeight    := ScaleY(20);
    //    Font.Size       := ScaleX(10);
    //    Font.Color      := clWhite;
    //    Caption         := FmtMessage(SetupMessage(msgSetupWindowTitle), ['{#MyAppFriendlyName}']);
    //    Transparent     := True;
    //    OnMouseDown     := @OnMoveWindow_License;
    //end;
    
    // Text
    LicenseWindow.Text := TRichEditViewer.Create(LicenseWindow.Main);
    with LicenseWindow.Text do
    begin
        Parent          := LicenseWindow.Main;
        Left            := ScaleX(16);
        Top             := ScaleY(32);
        ClientWidth     := ScaleX(478);
        ClientHeight    := ScaleY(370);
        //Font.Size       := ScaleX(10);
        //Font.Color      := clBlack;
        ScrollBars      := ssVertical;
        TabStop         := False;
        ReadOnly        := True;
        Lines.LoadFromFile(ExpandConstant('{tmp}\{#MyAppLicenseFile}'));
    end;

    // Background
    LicenseWindow.Background := TLabel.Create(LicenseWindow.Main);
    with LicenseWindow.Background do
    begin
        Parent          := LicenseWindow.Main;
        AutoSize        := False;
        Left            := ScaleX(0);
        Top             := ScaleY(0);
        ClientWidth     := LicenseWindow.Main.ClientWidth;
        ClientHeight    := LicenseWindow.Main.ClientHeight;
        Caption         := '';
        Transparent     := True;
        OnMouseDown     := @OnMoveWindow_License;
    end;

    // Background Image
    LicenseWindow.ImgBackground := ImgLoad(LicenseWindow.Handle(), GetScaleImage('background_form_license.png'),
        ScaleX(0), ScaleY(0), ScaleX(510), ScaleY(447), False, True);
 
    // Button
    LicenseWindow.BtnOk      := BtnCreate(LicenseWindow.Handle(), 
        ScaleX(114), ScaleY(412), ScaleX(106), ScaleY(24), GetScaleImage('button_agree.png'), 0, False);

    LicenseWindow.BtnCancel  := BtnCreate(LicenseWindow.Handle(), 
        ScaleX(285), ScaleY(412), ScaleX(106), ScaleY(24), GetScaleImage('button_disagree.png'), 0, False);

    LicenseWindow.BtnClose   := BtnCreate(LicenseWindow.Handle(), 
        ScaleX(510 - 30 - 1), ScaleY(1), ScaleX(30), ScaleY(30), GetScaleImage('button_close.png'), 0, False);

    // Button-Event
    BtnSetEvent(LicenseWindow.BtnOk,     BtnClickEventID, CreateCallback(@BtnClickEvent_License_Ok));
    BtnSetEvent(LicenseWindow.BtnCancel, BtnClickEventID, CreateCallback(@BtnClickEvent_License_Cancel));
    BtnSetEvent(LicenseWindow.BtnClose,  BtnClickEventID, CreateCallback(@BtnClickEvent_License_Cancel));

    // Style
    SetClassLong (LicenseWindow.Handle(), GCL_STYLE, GetClassLong (LicenseWindow.Handle(), GCL_STYLE) or CS_DROPSHADOW);
    SetWindowLong(LicenseWindow.Handle(), GWL_STYLE, GetWindowLong(LicenseWindow.Handle(), GWL_STYLE) or WS_BORDER);

    // Apply
    ImgApplyChanges(LicenseWindow.Handle());
    Result := True;
end;

function MInnoWizardLicense_Handle(): HWND;
begin
    Result := LicenseWindow.Main.Handle;
end;

procedure MInnoWizardLicense_Close();
begin
    LicenseWindow.Main.Close();
end;

procedure MInnoWizardLicense_ShowModal();
begin
    LicenseWindow.Main.ShowModal();
end;

procedure MInnoWizardLicense_Release();
begin
    ImgRelease(LicenseWindow.ImgBackground);
    LicenseWindow.Main.Release();
end;

function CreateLicense(): Boolean;
begin
    LicenseWindow.Create     := @MInnoWizardLicense_Create;
    LicenseWindow.Close      := @MInnoWizardLicense_Close;
    LicenseWindow.Handle     := @MInnoWizardLicense_Handle;
    LicenseWindow.ShowModal  := @MInnoWizardLicense_ShowModal;
    LicenseWindow.Release    := @MInnoWizardLicense_Release;

    Result := LicenseWindow.Create(); 
end;
#endif

////////////////////////////////////////////////////////////////////////////
// MainWindow

// 停止动画计时器
procedure StopTimer_Animation;
begin
    if (MInnoWizardTimerAnimation <> 0) then
    begin
        KillTimer(0, MInnoWizardTimerAnimation);
        MInnoWizardTimerAnimation := 0;
    end;
end;

// 窗口变大动画
procedure MInnoWizardAnimationShowFull(hWnd: HWND; uMsg: UINT; nIDEvent: UINT_PTR; uElapse: UINT);
begin
    if (WizardForm.ClientHeight < ScaleY(WIZARDFORM_HEIGHT_MORE)) then
    begin
        WizardForm.ClientHeight := WizardForm.ClientHeight + ScaleY(10);
    end else
    begin
        StopTimer_Animation;
        WizardForm.ClientHeight := ScaleY(WIZARDFORM_HEIGHT_MORE);
    end;
end;

// 窗口变小动画
procedure MInnoWizardAnimationShowNormal(hWnd: HWND; uMsg: UINT; nIDEvent: UINT_PTR; uElapse: UINT);
begin
    if (WizardForm.ClientHeight > ScaleY(WIZARDFORM_HEIGHT_NORMAL)) then
    begin
        WizardForm.ClientHeight := WizardForm.ClientHeight - ScaleY(10);
    end else
    begin
        StopTimer_Animation;
        WizardForm.ClientHeight := ScaleY(WIZARDFORM_HEIGHT_NORMAL);
    end;
end;

//停止轮播计时器
procedure StopTimer_Slide();
begin
    if (MInnoWizardTimerSlides <> 0) then
    begin
        KillTimer(0, MInnoWizardTimerSlides);
        MInnoWizardTimerSlides := 0;
    end;
end;

//停止暂停轮播用的计时器
procedure StopTimer_SlidePause();
begin
    if (MInnoWizardTimerSlidesPause <> 0) then
    begin
        KillTimer(0, MInnoWizardTimerSlidesPause);
        MInnoWizardTimerSlidesPause         := 0;
        MInnoWizardTimerSlidesPause_Count   := 0;
    end;
end;

//暂停轮播
procedure SlidesPauseForAWhile(hWnd: HWND; uMsg: UINT; nIDEvent: UINT_PTR; uElapse: UINT);
begin
  StopTimer_Slide();

  if (MInnoWizardTimerSlidesPause_Count >= (SLIDES_PAUSE_SECONDS * 1000)) then
  begin
    StopTimer_SlidePause();

    MInnoWizardTimerSlidesPause_Count   := 0;
    MInnoWizardTimerSlides              := SetTimer(0, 0, 20, CreateCallback(@SlidesAnimation));
  end else
  begin
    MInnoWizardTimerSlidesPause_Count   := MInnoWizardTimerSlidesPause_Count + 50;
  end;
end;

procedure PauseSlidesForAWhile();
begin
  if (MainWindow.CurrentSlidesPos <= 0) then
  begin
    StopTimer_Slide();
    if (MInnoWizardTimerSlidesPause = 0) then
    begin
      MInnoWizardTimerSlidesPause := SetTimer(0, 0, 10, CreateCallback(@SlidesPauseForAWhile));
    end;
  end;
end;

//安装时轮播图片
procedure SlidesAnimation(hWnd: HWND; uMsg: UINT; nIDEvent: UINT_PTR; uElapse: UINT);
begin
  MainWindow.CurrentSlidesPos := MainWindow.CurrentSlidesPos + 10;
  if (ScaleX(MainWindow.CurrentSlidesPos) > ScaleX(SLIDES_PICTURE_WIDTH)) then
  begin
    MainWindow.CurrentSlidesNo  := MainWindow.CurrentSlidesNo + 1;
    MainWindow.CurrentSlidesPos := 0;

    PauseSlidesForAWhile();
  end else
  begin
    if (MainWindow.CurrentSlidesNo = 1) then
    begin
      ImgSetPosition  (MainWindow.Slide_1_t, ScaleX(MainWindow.CurrentSlidesPos - SLIDES_PICTURE_WIDTH), ScaleY(0), ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT));
      ImgSetVisibility(MainWindow.Slide_2_t, False);
      ImgSetVisibility(MainWindow.Slide_3_t, False);
      ImgSetVisibility(MainWindow.Slide_4_t, False);
      ImgSetVisibility(MainWindow.Slide_1_t, True);
    end;
    if (MainWindow.CurrentSlidesNo = 2) then
    begin
      ImgSetPosition  (MainWindow.Slide_2_t, ScaleX(MainWindow.CurrentSlidesPos - SLIDES_PICTURE_WIDTH), ScaleY(0), ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT));
      ImgSetVisibility(MainWindow.Slide_1_t, False);
      ImgSetVisibility(MainWindow.Slide_3_t, False);
      ImgSetVisibility(MainWindow.Slide_4_t, False);
      ImgSetVisibility(MainWindow.Slide_2_t, True);
      ImgSetVisibility(MainWindow.Slide_1_b, True);
      ImgSetVisibility(MainWindow.Slide_3_b, False);
      ImgSetVisibility(MainWindow.Slide_4_b, False);
      ImgSetVisibility(MainWindow.Slide_2_b, False);
    end;
    if (MainWindow.CurrentSlidesNo = 3) then
    begin
      ImgSetPosition  (MainWindow.Slide_3_t, ScaleX(MainWindow.CurrentSlidesPos - SLIDES_PICTURE_WIDTH), ScaleY(0), ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT));
      ImgSetVisibility(MainWindow.Slide_1_t, False);
      ImgSetVisibility(MainWindow.Slide_2_t, False);
      ImgSetVisibility(MainWindow.Slide_4_t, False);
      ImgSetVisibility(MainWindow.Slide_3_t, True);
      ImgSetVisibility(MainWindow.Slide_1_b, False);
      ImgSetVisibility(MainWindow.Slide_3_b, False);
      ImgSetVisibility(MainWindow.Slide_4_b, False);
      ImgSetVisibility(MainWindow.Slide_2_b, True);
    end;
    if (MainWindow.CurrentSlidesNo = 4) then
    begin
      ImgSetPosition  (MainWindow.Slide_4_t, ScaleX(MainWindow.CurrentSlidesPos - SLIDES_PICTURE_WIDTH), ScaleY(0), ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT));
      ImgSetVisibility(MainWindow.Slide_1_t, False);
      ImgSetVisibility(MainWindow.Slide_2_t, False);
      ImgSetVisibility(MainWindow.Slide_3_t, False);
      ImgSetVisibility(MainWindow.Slide_4_t, True);
      ImgSetVisibility(MainWindow.Slide_1_b, False);
      ImgSetVisibility(MainWindow.Slide_3_b, True);
      ImgSetVisibility(MainWindow.Slide_4_b, False);
      ImgSetVisibility(MainWindow.Slide_2_b, False);
    end;
    if (MainWindow.CurrentSlidesNo > 4) then
    begin
      ImgSetPosition  (MainWindow.Slide_1_t, ScaleX(MainWindow.CurrentSlidesPos - SLIDES_PICTURE_WIDTH), ScaleY(0), ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT));
      ImgSetVisibility(MainWindow.Slide_2_t, False);
      ImgSetVisibility(MainWindow.Slide_3_t, False);
      ImgSetVisibility(MainWindow.Slide_4_t, False);
      ImgSetVisibility(MainWindow.Slide_1_t, True);
      ImgSetVisibility(MainWindow.Slide_1_b, False);
      ImgSetVisibility(MainWindow.Slide_3_b, False);
      ImgSetVisibility(MainWindow.Slide_4_b, True);
      ImgSetVisibility(MainWindow.Slide_2_b, False);
      MainWindow.CurrentSlidesNo := 1;
    end;
  end;
  ImgApplyChanges(MainWindow.Handle());
end;

// Button-Event
procedure OnMoveWindow_Main(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture();
  SendMessage(MainWindow.Handle(), WM_SYSCOMMAND, (SC_MOVE or HTCAPTION), 0);
end;

procedure MInnoWizardMain_ChangePath(Sender : TObject);
begin
    WizardForm.DirEdit.Text := MainWindow.Path.Text;
end;

procedure BtnClickEvent_Main_Close(hWnd: HWND);
begin
  WizardForm.CancelButton.OnClick(WizardForm);
end;

procedure BtnClickEvent_Main_Minimize(hWnd: HWND);
begin
  SendMessage(MainWindow.Handle(), WM_SYSCOMMAND, SC_MINIMIZE, 0);
end;

procedure BtnClickEvent_Main_Next(hWnd : HWND);
begin
  WizardForm.NextButton.OnClick(WizardForm);
end;

procedure BtnClickEvent_Main_MoreOption(hWnd: HWND);
begin
    if IsMainShowNormal then
    begin
        StopTimer_Animation;

        IsMainShowNormal := False;
        MainWindow.ImgBackground  := ImgLoad(MainWindow.Handle(), GetScaleImage('background_welcome_more.png'),
            ScaleX(0), ScaleY(0), ScaleX(WIZARDFORM_WIDTH_NORMAL), ScaleY(WIZARDFORM_HEIGHT_MORE), True, True);

        BtnSetVisibility(MainWindow.BtnMoreOption   , False);
        BtnSetVisibility(MainWindow.BtnNormalOption , True);
        BtnSetVisibility(MainWindow.BtnSelectPath   , True);
        MainWindow.Path.Show();

  #ifndef PortableMode
        // 如果已安装, 则不允许更改目录
        if IsInstalled() then
        begin
            MainWindow.InstalledTips.Show();
            MainWindow.Path.Enabled := False;
            BtnSetEnabled(MainWindow.BtnSelectPath, False);
        end;
  #endif

        MInnoWizardTimerAnimation := SetTimer(0, 0, 1, CreateCallback(@MInnoWizardAnimationShowFull));
    end else
    begin
        StopTimer_Animation;

        IsMainShowNormal := True;
        MainWindow.ImgBackground  := ImgLoad(MainWindow.Handle(), GetScaleImage('background_welcome.png'),
            ScaleX(0), ScaleY(0), ScaleX(WIZARDFORM_WIDTH_NORMAL), ScaleY(WIZARDFORM_HEIGHT_NORMAL), True, True);
            
        BtnSetVisibility(MainWindow.BtnMoreOption   , True);
        BtnSetVisibility(MainWindow.BtnNormalOption , False);
        BtnSetVisibility(MainWindow.BtnSelectPath   , False);
        MainWindow.Path.Hide();
        MainWindow.InstalledTips.Hide();

        MInnoWizardTimerAnimation := SetTimer(0, 0, 1, CreateCallback(@MInnoWizardAnimationShowNormal));
    end;
    ImgApplyChanges(MainWindow.Handle());
end;

procedure BtnClickEvent_Main_SelectPath(hWnd: HWND);
begin
    WizardForm.DirBrowseButton.OnClick(WizardForm);
    MainWindow.Path.Text := WizardForm.DirEdit.Text;
end;

procedure BtnClickEvent_Main_License(hWnd : HWND);
var
    DosCode : Integer;

begin
#ifdef MyAppLicenseFile
    LicenseWindow.ShowModal();
#else
    ShellExec('', '{#MyAppLicenseURL}', '', '', SW_SHOW, ewNoWait, DosCode);
#endif
end;

//同意许可协议的复选框被点击时执行的脚本
procedure ChkClickEvent_Main_License(hWnd : HWND);
begin
    BtnSetEnabled(MainWindow.BtnNext, BtnGetChecked(MainWindow.ChkLicense));
end;

//复制文件时执行的脚本，每复制1%都会被调用一次，若要调整进度条或进度提示请在此段修改
function ProgressBarProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM) : LRESULT;
var
    pr, i1, i2 : EXTENDED;
    w : integer;
begin
    Result := CallWindowProc(MainWindow.ProgressBarProcOld, hWnd, uMsg, wParam, lParam);
    if ((uMsg = $402) and (WizardForm.ProgressGauge.Position > WizardForm.ProgressGauge.Min)) then
    begin
      i1 := WizardForm.ProgressGauge.Position - WizardForm.ProgressGauge.Min;
      i2 := WizardForm.ProgressGauge.Max      - WizardForm.ProgressGauge.Min;
      pr := (i1 * 100) / i2;
      MainWindow.ProgressText.Caption := Format('%d', [Round(pr)]) + '%';

      w := Round((ScaleX(560) * pr) / 100);
      ImgSetPosition   (MainWindow.ImgProgressBarForeground, ScaleX(20), ScaleY(374), w, ScaleY(8));
      ImgSetVisiblePart(MainWindow.ImgProgressBarForeground, ScaleX(0), ScaleY(0), w, ScaleY(8));
      ImgApplyChanges  (MainWindow.Handle());
    end;
end;

function MInnoWizardMain_Create(): Boolean;
var
    Tips : string;

begin
    WizardForm.InnerNotebook.Hide();
    WizardForm.OuterNotebook.Hide();
    WizardForm.Bevel.Hide();
    
    // Framework
    // 先创建最大 Width/Height 的窗口
    //  然后在 CurPageChanged().wpWelcome 调整成 Normal 的窗口
    //  避免黑屏问题
    with WizardForm do
    begin
        BorderStyle     := bsNone;
        Position        := poDesktopCenter;
        ClientWidth     := ScaleX(WIZARDFORM_WIDTH_NORMAL);
        ClientHeight    := ScaleY(WIZARDFORM_HEIGHT_MORE);
        Color           := clWhite;
        NextButton.ClientHeight     := 0;
        CancelButton.ClientHeight   := 0;
        BackButton.Visible          := False;
    end;
    
    // Title
    MainWindow.Title := TLabel.Create(WizardForm);
    with MainWindow.Title do
    begin
        Parent          := WizardForm;
        AutoSize        := False;
        Left            := ScaleX(10);
        Top             := ScaleY(5);
        ClientWidth     := ScaleX(300);
        ClientHeight    := ScaleY(20);
        Font.Size       := ScaleX(9);
        Font.Color      := clWhite;
        Caption         := FmtMessage(CustomMessage('NameAndVersion'), ['{#MyAppFriendlyName}', '{#MyAppVersion}']);
        Transparent     := True;
        OnMouseDown     := @OnMoveWindow_Main;
    end;

    // Background
    MainWindow.Background := TLabel.Create(WizardForm);
    with MainWindow.Background do
    begin
        Parent          := WizardForm;
        AutoSize        := False;
        Left            := ScaleX(0);
        Top             := Scaley(0);
        ClientWidth     := WizardForm.ClientWidth;
        ClientHeight    := WizardForm.ClientHeight;
        Caption         := '';
        Transparent     := True;
        OnMouseDown     := @OnMoveWindow_Main;
    end;

    // Path
    MainWindow.Path := TEdit.Create(WizardForm);
    with MainWindow.Path do
    begin
        Parent          := WizardForm;
        Text            := WizardForm.DirEdit.Text;
        BorderStyle     := bsNone;
        Left            := ScaleX(91);
        Top             := Scaley(423);
        ClientWidth     := ScaleX(402);
        ClientHeight    := Scaley(20);
        Font.Size       := ScaleX(9);
        Color           := clWhite;
        TabStop         := False;
        OnChange        := @MInnoWizardMain_ChangePath;
    end;
    MainWindow.Path.Hide();

    // Installed Tips
    Tips := SetupMessage(msgFinishedLabelNoIcons);
    StringChangeEx(Tips, '[name]', '{#MyAppFriendlyName}', True);

    MainWindow.InstalledTips := TLabel.Create(WizardForm);
    with MainWindow.InstalledTips do
    begin
        Parent          := WizardForm;
        AutoSize        := False;
        Left            := ScaleX(85);
        Top             := ScaleY(449);
        ClientWidth     := ScaleX(300);
        ClientHeight    := ScaleY(20);
        Font.Size       := ScaleX(9);
        Font.Color      := clGray;
        Caption         := Tips;
        Transparent     := True;
        OnMouseDown     := @OnMoveWindow_Main;
    end;
    MainWindow.InstalledTips.Hide();
    
    // Installing Tips
    MainWindow.InstallingTips := TLabel.Create(WizardForm);
    with MainWindow.InstallingTips do
    begin
        Parent          := WizardForm;
        AutoSize        := False;
        Left            := ScaleX(20);
        Top             := ScaleY(349);
        ClientWidth     := ScaleX(60);
        ClientHeight    := ScaleY(30);
        Font.Size       := ScaleX(9);
        Font.Color      := clBlack;
        Caption         := SetupMessage(msgWizardInstalling);
        Transparent     := True;
        OnMouseDown     := @OnMoveWindow_Main;
    end;
    MainWindow.InstallingTips.Hide();
    
    // ProgressText
    MainWindow.ProgressText := TLabel.Create(WizardForm);
    with MainWindow.ProgressText do
    begin
      Parent        := WizardForm;
      AutoSize      := False;
      Left          := ScaleX(547);
      Top           := ScaleY(349);
      ClientWidth   := ScaleX(50);
      ClientHeight  := ScaleY(30);
      Font.Size     := ScaleX(10);
      Font.Color    := clBlack;
      Caption       := '';
      Transparent   := True;
      Alignment     := taRightJustify;
      OnMouseDown   := @OnMoveWindow_Main;
    end;


    // Background
    MainWindow.ImgBackground := ImgLoad(MainWindow.Handle(), GetScaleImage('background_welcome.png'), 
        ScaleX(0), ScaleY(0), ScaleX(WIZARDFORM_WIDTH_NORMAL), ScaleY(WIZARDFORM_HEIGHT_NORMAL), True, True);

    // Button
    MainWindow.BtnClose         := BtnCreate(MainWindow.Handle(), 
        ScaleX(WIZARDFORM_WIDTH_NORMAL - 30), ScaleY(0), ScaleX(30), ScaleY(30), GetScaleImage('button_close.png'), 0, False);

    MainWindow.BtnMinimize      := BtnCreate(MainWindow.Handle(), 
        ScaleX(WIZARDFORM_WIDTH_NORMAL - 30 - 30), ScaleY(0), ScaleX(30), ScaleY(30), GetScaleImage('button_minimize.png'), 0, False);
    
    MainWindow.BtnNext          := BtnCreate(MainWindow.Handle(),
        ScaleX(211), ScaleY(305), ScaleX(182), ScaleY(44), GetScaleImage('button_setup_or_next.png'), 0, False);

    MainWindow.BtnSelectPath    := BtnCreate(MainWindow.Handle(),
        ScaleX(506), ScaleY(420), ScaleX(75), ScaleY(24), GetScaleImage('button_browse.png'), 0, False);

    MainWindow.BtnMoreOption    := BtnCreate(MainWindow.Handle(),
        ScaleX(511), ScaleY(374), ScaleX(79), ScaleY(16), GetScaleImage('button_customize_setup.png'), 0, False);

    MainWindow.BtnNormalOption  := BtnCreate(MainWindow.Handle(),
        ScaleX(511), ScaleY(374), ScaleX(79), ScaleY(16), GetScaleImage('button_uncustomize_setup.png'), 0, False);

    MainWindow.BtnLicense := BtnCreate(MainWindow.Handle(), 
        ScaleX(110), ScaleY(376), ScaleX(96), ScaleY(12), GetScaleImage('button_license.png'), 0, False);
             
    MainWindow.ChkLicense := BtnCreate(MainWindow.Handle(), 
        ScaleX(11), ScaleY(374), ScaleX(92), ScaleY(16), GetScaleImage('checkbox_license.png'), 0, True);

    // Button-Event
    BtnSetEvent(MainWindow.BtnClose         , BtnClickEventID, CreateCallback(@BtnClickEvent_Main_Close));
    BtnSetEvent(MainWindow.BtnMinimize      , BtnClickEventID, CreateCallback(@BtnClickEvent_Main_Minimize));
    BtnSetEvent(MainWindow.BtnNext          , BtnClickEventID, CreateCallback(@BtnClickEvent_Main_Next));
    BtnSetEvent(MainWindow.BtnSelectPath    , BtnClickEventID, CreateCallback(@BtnClickEvent_Main_SelectPath));
    BtnSetEvent(MainWindow.BtnMoreOption    , BtnClickEventID, CreateCallback(@BtnClickEvent_Main_MoreOption));
    BtnSetEvent(MainWindow.BtnNormalOption  , BtnClickEventID, CreateCallback(@BtnClickEvent_Main_MoreOption));
    BtnSetEvent(MainWindow.BtnLicense       , BtnClickEventID, CreateCallback(@BtnClickEvent_Main_License));
    BtnSetEvent(MainWindow.ChkLicense       , BtnClickEventID, CreateCallback(@ChkClickEvent_Main_License));
    
    BtnSetChecked(MainWindow.ChkLicense, True);
    
    // Button-Visiable
    BtnSetVisibility(MainWindow.BtnSelectPath   , False);
    BtnSetVisibility(MainWindow.BtnMoreOption   , True);
    BtnSetVisibility(MainWindow.BtnNormalOption , False);

    // ProgressBar-WndProc
    MainWindow.ProgressBarProcOld := SetWindowLong(WizardForm.ProgressGauge.Handle, GWL_WNDPROC, CreateCallback(@ProgressBarProc));

    // Slide Picture
    MainWindow.CurrentSlidesNo  := 0;
    MainWindow.CurrentSlidesPos := 0;
    
    // Style
    SetClassLong (MainWindow.Handle(), GCL_STYLE, GetClassLong (MainWindow.Handle(), GCL_STYLE) or CS_DROPSHADOW);
    SetWindowLong(MainWindow.Handle(), GWL_STYLE, GetWindowLong(MainWindow.Handle(), GWL_STYLE) or WS_BORDER);

    // Apply
    ImgApplyChanges(MainWindow.Handle());
    Result := True;
end;

function MInnoWizardMain_Handle(): HWND;
begin
    Result := WizardForm.Handle;
end;

procedure MInnoWizardMain_Release();
begin
    ImgRelease(MainWindow.ImgBackground);
    WizardForm.Release();
end;

function CreateWizardMain(): Boolean;
begin
    MainWindow.Create     := @MInnoWizardMain_Create;
    MainWindow.Handle     := @MInnoWizardMain_Handle;
    MainWindow.Release    := @MInnoWizardMain_Release;

    Result := MainWindow.Create(); 
end;
