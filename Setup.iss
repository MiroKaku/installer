
#if VER < EncodeVer(6,0,0)
  #error Please upgrade your Inno Setup to at least V6.0.0 !!!
#endif

#include ".\Version.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 预定义

;指定是否在安装时轮播图片
#define ShowSlidePictures

;指定是否为绿色版安装程序（仅释放文件，不写入注册表条目，也不生成卸载程序）
;#define PortableMode

;指定是否只能安装新版本，而不能用旧版本覆盖新版本
#define OnlyInstallNewVersion

;指定是否使用自定义卸载程序
;#define UseCustomUninstaller

;若想开启禁止安装旧版本的功能，此处版本号请注意一定要是
;点分十进制的正整数，除数字和英文半角句点以外不允许出现任何其他字符，
;否则程序无法判断版本的高低。
#define MyAppBinDir         ".\{app}"
;#define MyAppVersion        GetFileVersion(MyAppBinDir + '\' + MyAppExeName)
#define MyAppVersion        str(MINNO_VERSION_MAJOR) + "." + str(MINNO_VERSION_MINOR) + "." + str(MINNO_VERSION_PATCH) + "." + str(MINNO_VERSION_BUILD)      
#define MyAppPublisher      str(MINNO_COMPANY_NAME_STR)
#define MyAppPublisherURL   str(MINNO_COMPANY_URL_STR)
#define MyAppSupportURL     str(MINNO_SUPPORT_URL_STR)
#define MyAppUpdatesURL     str(MINNO_UPDATE_URL_STR)
#define MyAppContact        str(MINNO_CONTACT_STR)
#define MyAppReadmeURL      str(MINNO_README_URL_STR)
#define MyAppLicenseURL     str(MINNO_LICENSE_URL_STR)
#define MyAppCopyright      str(MINNO_COPYRIGHT_STR)
#define MyAppID             str(MINNO_APP_ID_STR)
#define MyAppMutex          str(MINNO_APP_MUTEX_STR)
#define MyAppExeName        str(MINNO_EXE_NAME_STR)
#define MyAppFriendlyName   str(MINNO_APP_FRIENDLY_NAME_STR)

#ifdef MINNO_LICENSE_FILE_STR
  #define MyAppLicenseFile  str(MINNO_LICENSE_FILE_STR)
#endif

#ifdef _WIN64
  #define MyAppName         str(MINNO_APP_NAME_STR) + "(64-bit)"
  #define MyAppSetupExe     MyAppName + "_" + MyAppVersion + "_x64"
#else
  #define MyAppName         str(MINNO_APP_NAME_STR)
  #define MyAppSetupExe     MyAppName + "_" + MyAppVersion + "_x86"
#endif

#ifdef PortableMode
  #define MyAppSetupExe     MyAppSetupExe + "_" + "Portable"
#else
  #define MyAppSetupExe     MyAppSetupExe + "_" + "Setup"
#endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Setup

[Setup]
AppId                           = {{#MyAppID}
AppName                         = {#MyAppFriendlyName}
AppVersion                      = {#MyAppVersion}
AppVerName                      = {#MyAppName} {#MyAppVersion}
AppPublisher                    = {#MyAppPublisher}
AppPublisherURL                 = {#MyAppPublisherURL}
AppSupportURL                   = {#MyAppSupportURL}
AppUpdatesURL                   = {#MyAppUpdatesURL}
AppContact                      = {#MyAppContact}
AppReadmeFile                   = {#MyAppReadmeURL}
AppCopyright                    = {#MyAppCopyright}
DefaultGroupName                = {#MyAppFriendlyName}
VersionInfoDescription          = {#MyAppFriendlyName} Setup
VersionInfoProductName          = {#MyAppFriendlyName}
VersionInfoCompany              = {#MyAppPublisher}
VersionInfoCopyright            = {#MyAppCopyright}
VersionInfoProductVersion       = {#MyAppVersion}
VersionInfoProductTextVersion   = {#MyAppVersion}
VersionInfoTextVersion          = {#MyAppVersion}
VersionInfoVersion              = {#MyAppVersion}
OutputDir                       = "{output}"
SetupIconFile                   = ".\{tmp}\logo.ico"
Compression                     = lzma2/ultra64
InternalCompressLevel           = ultra64
SolidCompression                = yes
LZMAUseSeparateProcess          = yes
;LZMANumBlockThreads             = 6
DisableProgramGroupPage         = yes
DisableDirPage                  = yes
DisableReadyMemo                = yes
DisableReadyPage                = yes
TimeStampsInUTC                 = yes
SetupMutex                      = {{#MyAppID}Setup,Global\{{#MyAppID}Setup
AppMutex                        = {{#MyAppMutex}
LanguageDetectionMethod         = uilanguage
ShowLanguageDialog              = no
AllowCancelDuringInstall        = no
#ifdef _WIN64
    ArchitecturesAllowed        = x64
    ArchitecturesInstallIn64BitMode = x64
#else
    ArchitecturesAllowed        = x86 x64
#endif
DefaultDirName                  = {autopf}\{#MyAppPublisher}\{#MyAppName}
#ifdef PortableMode
    Uninstallable               = no
    PrivilegesRequired          = lowest
#else
    Uninstallable               = yes
    PrivilegesRequired          = admin
    UninstallDisplayName        = {#MyAppName}
    UninstallDisplayIcon        = {app}\{#MyAppExeName},0
    UninstallFilesDir           = {app}\Uninstaller
#endif
OutputBaseFilename              = {#MyAppSetupExe}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Languages

[Languages]
;此段的第一个语言为默认语言，除此之外，语言的名称与顺序都无所谓           
Name: "ChineseSimplified";   MessagesFile: ".\{lang}\ChineseSimplified.isl"
Name: "English";             MessagesFile: "compiler:Default.isl"
Name: "Armenian";            MessagesFile: "compiler:Languages\Armenian.isl"
Name: "BrazilianPortuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "Catalan";             MessagesFile: "compiler:Languages\Catalan.isl"
Name: "Corsican";            MessagesFile: "compiler:Languages\Corsican.isl"
Name: "Czech";               MessagesFile: "compiler:Languages\Czech.isl"
Name: "Danish";              MessagesFile: "compiler:Languages\Danish.isl"
Name: "Dutch";               MessagesFile: "compiler:Languages\Dutch.isl"
Name: "Finnish";             MessagesFile: "compiler:Languages\Finnish.isl"
Name: "French";              MessagesFile: "compiler:Languages\French.isl"
Name: "German";              MessagesFile: "compiler:Languages\German.isl"
Name: "Hebrew";              MessagesFile: "compiler:Languages\Hebrew.isl"
Name: "Icelandic";           MessagesFile: "compiler:Languages\Icelandic.isl"
Name: "Italian";             MessagesFile: "compiler:Languages\Italian.isl"
Name: "Japanese";            MessagesFile: "compiler:Languages\Japanese.isl"
Name: "Norwegian";           MessagesFile: "compiler:Languages\Norwegian.isl"
Name: "Polish";              MessagesFile: "compiler:Languages\Polish.isl"
Name: "Portuguese";          MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "Russian";             MessagesFile: "compiler:Languages\Russian.isl"
Name: "Slovak";              MessagesFile: "compiler:Languages\Slovak.isl"
Name: "Slovenian";           MessagesFile: "compiler:Languages\Slovenian.isl"
Name: "Spanish";             MessagesFile: "compiler:Languages\Spanish.isl"
Name: "Turkish";             MessagesFile: "compiler:Languages\Turkish.isl"
Name: "Ukrainian";           MessagesFile: "compiler:Languages\Ukrainian.isl"
Name: "Korean";              MessagesFile: ".\{lang}\Korean.isl"
Name: "ChineseTraditional";  MessagesFile: ".\{lang}\ChineseTraditional.isl"


[CustomMessages]
;此段条目在等号后面直接跟具体的值，不能加双引号
;English（默认语言）
English.messagebox_close_title                          ={#MyAppName} Setup
English.messagebox_close_text                           =Are you sure to abort {#MyAppName} setup?
English.init_setup_outdated_version_warning             =You have already installed a newer version of {#MyAppName}, so you are not allowed to continue. Click <OK> to abort.
English.wizardform_title                                ={#MyAppName} V{#MyAppVersion} Setup
English.no_change_destdir_warning                       =You are not allowed to change destination folder.
English.installing_label_text                           =Installing
;简体中文
ChineseSimplified.messagebox_close_title                ={#MyAppName} 安装
ChineseSimplified.messagebox_close_text                 =您确定要退出“{#MyAppName}”安装程序吗？
ChineseSimplified.init_setup_outdated_version_warning   =您已安装更新版本的“{#MyAppName}”，不允许使用旧版本替换新版本，请单击“确定”按钮退出此安装程序。
ChineseSimplified.wizardform_title                      ={#MyAppName} V{#MyAppVersion} 安装
ChineseSimplified.no_change_destdir_warning             =软件已经安装，不允许更换目录。
ChineseSimplified.installing_label_text                 =正在安装

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Files

[Files]
;包含所有临时资源文件
Source: ".\{tmp}\*"; DestDir: "{tmp}"; Flags: dontcopy solidbreak; Attribs: hidden system

;包含待打包项目的所有文件及文件夹
Source: "{#MyAppBinDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

; 自定义卸载程序
#ifndef PortableBuild
    #ifdef UseCustomUninstaller
        #if FileExists(".\{output}\Uninstall.exe")
            Source: ".\{output}\Uninstall.exe"; DestDir: "{app}"; Flags: ignoreversion
        #endif
    #endif
#endif

[Dirs]
;创建一个隐藏的系统文件夹存放卸载程序
#ifndef PortableMode
    Name: "{app}\Uninstaller"; Attribs: hidden system
#endif

[INI]
#ifndef PortableMode
    #ifdef UseCustomUninstaller
        Filename: "{app}\Uninstall.ini"; Section: "General"; Key: "Name";    String: "{#MyAppName}"
        Filename: "{app}\Uninstall.ini"; Section: "General"; Key: "Version"; String: "{#MyAppVersion}"
        Filename: "{app}\Uninstall.ini"; Section: "General"; Key: "Mutex";   String: "{#MyAppMutex}"
        Filename: "{app}\Uninstall.ini"; Section: "General"; Key: "Path";    String: "{uninstallexe}"
        Filename: "{app}\Uninstall.ini"; Section: "General"; Key: "Params";  String: "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART"
        Filename: "{app}\Uninstall.ini"; Section: "General"; Key: "Dir";     String: "{app}\Uninstaller"
        Filename: "{app}\Uninstall.ini"; Section: "General"; Key: "File";    String: "Uninstaller.zip"
    #endif
#endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Icons

[Icons]
;若有创建快捷方式的需要，请取消此区段的注释并自行添加相关脚本
Name: "{group}\{#MyAppFriendlyName}"; Filename: "{app}\{#MyAppExeName}"; MinVersion: 0.0,5.0;
Name: "{group}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppSupportURL}"; MinVersion: 0.0,5.0;
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"; MinVersion: 0.0,5.0;
Name: "{commondesktop}\{#MyAppFriendlyName}"; Filename: "{app}\{#MyAppExeName}"; MinVersion: 0.0,5.0;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Run

[Run]
;若有安装完立即启动的需要，请取消此区段的注释并自行添加相关脚本
;Filename: "{app}\{#MyAppExeName}"; MinVersion: 0.0,5.0; Flags: postinstall skipifsilent nowait

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Uninstall

[UninstallRun]
;自定义卸载程序
;#ifndef PortableMode
;    #ifdef UseCustomUninstaller
;        ;卸载时运行反注册程序
;        Filename: "{app}\{#MyAppExeName}"; Parameters: "--uninstall"; WorkingDir: "{app}"; Flags: waituntilterminated skipifdoesntexist
;    #endif
;#endif

[UninstallDelete]
#ifndef PortableMode
    ;卸载时删除安装目录下的所有文件及文件夹
    Type: filesandordirs; Name: "{app}"
#endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; UI Code

#include ".\{code}\ui.iss"
