unit uSnarl;

///   I took the file available at fullphat.net and modified it to add some things
///
///   I make no claim that this code works, and take no responsibility.


{ For complete information about this unit, please see the Snarl API.
  http://www.fullphat.net/developer/developerGuide/api/index.html  }

{$ifdef FPC}
  {$mode delphi}
{$endif}

interface

uses
  Windows, Messages;

const
   WM_SNARL_REPLY = WM_USER + 1623;

(*
 * Registered window message and event identifiers (passed in wParam when either SNARL_GLOBAL_MSG or ReplyMsg is received)
 *)
const
   SNARL_GLOBAL_MSG = 'SnarlGlobalEvent';
//   SNARL_NOTIFICATION_CANCELLED = 0; // V37 changes this.
   SNARL_LAUNCHED = 1;
   SNARL_QUIT = 2;
   SNARL_ASK_APPLET_VER = 3; // introduced in V36
   SNARL_SHOW_APP_UI = 4; // introduced in V37

   SNARL_NOTIFICATION_CLICKED = 32; // notification was right-clicked by user
   SNARL_NOTIFICATION_TIMED_OUT = 33;
   SNARL_NOTIFICATION_ACK = 34; // notification was left-clicked by user
   SNARL_NOTIFICATION_CANCELLED = 37;

   WM_SNARLTEST = WM_USER + 237;

   SNARL_NOTIFICATION_LEFT_CLICKED  = SNARL_NOTIFICATION_ACK;
   SNARL_NOTIFICATION_RIGHT_CLICKED = SNARL_NOTIFICATION_CLICKED;
(*
 * Snarl Data Types
 *)
type
  TSnarlCommand = (
    SNARL_SHOW        = 1,
    SNARL_HIDE        = 2,
    SNARL_UPDATE      = 3,
    SNARL_IS_VISIBLE  = 4,
    SNARL_GET_VERSION = 5,
    SNARL_REGISTER_CONFIG_WINDOW = 6,
    SNARL_REVOKE_CONFIG_WINDOW = 7,
    SNARL_REGISTER_ALERT = 8,
    SNARL_REVOKE_ALERT = 9,
    SNARL_REGISTER_CONFIG_WINDOW_2 = 10,
    SNARL_EX_SHOW = 32
  );

  TSnarlBuffer = array[0..1023] of Byte;

  TSnarlStruct = record
    Cmd:      TSnarlCommand;         // What to do...
    Id:       Integer;                // Message ID (returned by snShowMessage())
    Timeout:  Integer;                // Timeout in seconds (0=sticky)
    LngData2: Integer;                // Reserved
    Title:    TSnarlBuffer;
    Text:     TSnarlBuffer;
    Icon:     TSnarlBuffer;
  end;

  TSnarlStructEx = record
    Cmd:      TSnarlCommand;         // What to do...
    Id:       Integer;                // Message ID (returned by snShowMessage())
    Timeout:  Integer;                // Timeout in seconds (0=sticky)
    LngData2: Integer;                // Reserved
    Title:    TSnarlBuffer;
    Text:     TSnarlBuffer;
    Icon:     TSnarlBuffer;

    SnarlClass: TSnarlBuffer;
    Extra: TSnarlBuffer;
    Extra2: TSnarlBuffer;
    Reserved1: Integer;
    Reserved2: Integer;
  end;

(*
 * Snarl Helper Functions
 *)
function snGetSnarlWindow: Cardinal;
function snGetAppPath: String;
function snGetGlobalMsg: Integer;
function snGetIconsPath: String;

function snShowMessage(const ATitle, AText: String; ATimeout: Integer = 0;
  const AIconPath: String = ''; AhwndReply: Integer = 0; AReplyMsg: Integer = 0): Integer;

function snShowMessageEx(const ASnarlClass, ATitle, AText: String; ATimeout: Integer = 0;
  const AIconPath: String = ''; AhwndReply: Integer = 0; AReplyMsg: Integer = 0;
  const ASoundPath: String = ''): Integer;

{$IFNDEF UNICODE}
function snShowMessageExWide(const ASnarlClass, ATitle, AText: WideString; ATimeout: Integer = 0;
  const AIconPath: WideString = ''; AhwndReply: Integer = 0; AReplyMsg: Integer = 0;
  const ASoundPath: WideString = ''): Integer; overload;
{$ENDIF}

function snUpdateMessage(AId: Integer; const ATitle, AText: String; ATimeOut: Integer = 0): Boolean;
function snHideMessage(AId: Integer): Boolean;
function snIsMessageVisible(AId: Integer): Boolean;
function snGetVersion(var Major, Minor: Word): Boolean;
function snGetVersionEx: Integer;
function snRegisterConfig(AHandle: HWND; const AAppName: String; AReplyMsg: Integer): Integer;
function snRegisterConfig2(AHandle: HWND; const AAppName: String; AReplyMsg: Integer; const AIconPath: String): Integer;
function snRevokeConfig(AHandle: HWND): Integer;
function snRegisterAlert(const AAppName, AAlertName: String): Integer;
function snRevokeAlert: Integer;

implementation

var
   hWndFrom: HWND = 0;

(*
 * Private utility functions:
 *    _Send(TSnarlStruct)
 *         Used by most public helper functions to send the WM_COPYDATA message.
 *      _Clear(TSnarlStruct)
 *         Clears all data in the structure
 *)
function _Send(pss: TSnarlStruct): Integer; overload;
var
  hwnd: THandle;
  pcd: TCopyDataStruct;
begin
  { WIll get a window class when snarl is released }
  hwnd := snGetSnarlWindow;
  if not IsWindow(hwnd) then
    Result := 0
  else
  begin
    pcd.dwData := 2;
    pcd.cbData := Sizeof(pss);
    pcd.lpData := @pss;
    Result := Integer(SendMessage(hwnd, WM_COPYDATA, hWndFrom, Integer(@pcd)));
  end;
end;

function _Post(pss: TSnarlStruct): Integer; overload;
var
  hwnd: THandle;
  pcd: TCopyDataStruct;
begin
  { WIll get a window class when snarl is released }
  hwnd := snGetSnarlWindow;
  if not IsWindow(hwnd) then
    Result := 0
  else
  begin
    pcd.dwData := 2;
    pcd.cbData := Sizeof(pss);
    pcd.lpData := @pss;
    Result := Integer(PostMessage(hwnd, WM_COPYDATA, hWndFrom, Integer(@pcd)));
  end;
end;

function _Send(pss: TSnarlStructEx): Integer; overload;
var
  hwnd: THandle;
  pcd: TCopyDataStruct;
begin
  { WIll get a window class when snarl is released }
  hwnd := snGetSnarlWindow;
  if not IsWindow(hwnd) then
    Result := 0
  else
  begin
    pcd.dwData := 2;
    pcd.cbData := Sizeof(pss);
    pcd.lpData := @pss;
    Result := Integer(SendMessage(hwnd, WM_COPYDATA, hWndFrom, Integer(@pcd)));
  end;
end;

procedure _Clear(var pss: TSnarlStruct); overload;
begin
  FillChar(pss, Sizeof(pss), 0);
end;

procedure _Clear(var pss: TSnarlStructEx); overload;
begin
  FillChar(pss, Sizeof(pss), 0);
end;

procedure _CopySnarlBuffer(const aDestination: Pointer; const aText: String);
begin
   CopyMemory(aDestination, PByte(UTF8String(aText) + #0), 1023);
end;

(************************************************************
 * The Helper Functions
 ************************************************************)

function snGetSnarlWindow: Cardinal;
begin
   Result := FindWindow(nil, 'Snarl');
end;

function snGetAppPath: String;
var
   hWnd, hWndPath: Cardinal;
   hr: Integer;
   some_string: array[0..MAX_PATH] of Char;
begin
   hWnd := snGetSnarlWindow;
   if hWnd <> 0 then
   begin
     hWndPath := FindWindowEx(hWnd, 0, 'static', nil);
     if hWndPath <> 0 then
     begin
       hr := GetWindowText(hWndPath, some_string, MAX_PATH+1);
       if hr > 0 then
         Result := Copy(some_string, 0, hr);
     end;
   end;
end;

function snGetGlobalMsg: Integer;
begin
   Result := RegisterWindowMessage(SNARL_GLOBAL_MSG);
end;

function snGetIconsPath: String;
var
   s: String;
begin
   Result := '';

   s := snGetAppPath;
   if s <> '' then
      Result := s + 'etc\icons\';
end;

function snShowMessage(const ATitle, AText: String; ATimeout: Integer = 0;
  const AIconPath: String = ''; AhwndReply: Integer = 0; AReplyMsg: Integer = 0): Integer;
var
  pss: TSnarlStruct;
begin
  _Clear(pss);

  pss.Cmd := SNARL_SHOW;

  _CopySnarlBuffer(@pss.Title, ATitle);
  _CopySnarlBuffer(@pss.Text,  AText);
  _CopySnarlBuffer(@pss.Icon,  AIconPath);

  pss.Timeout := ATimeout;
  { R0.3 }
  pss.LngData2 := AhwndReply;
  pss.Id := AReplyMsg;

  Result := _Send(pss);
end;

/// SNARL_EX_SHOW (V36)
///   Parameter Description
///--------------------------
///   Cmd:      SNARL_EX_SHOW
///   Id:       Message to send back if notification is clicked by user
///   Timeout:  Number of seconds to display notification for (0 means infinite)
///   LngData2: Handle of window to send reply message to if notification is clicked by user
///   Title:    Text to display in title
///   Text:     Text to display in notification body
///   Icon:     Path of image to use
///   Extra:    Path to sound file to play
function snShowMessageEx(const ASnarlClass, ATitle, AText: String; ATimeout: Integer = 0;
  const AIconPath: String = ''; AhwndReply: Integer = 0; AReplyMsg: Integer = 0;
  const ASoundPath: String = ''): Integer;
var
  pssEx: TSnarlStructEx;
begin
  _Clear(pssEx);

  pssEx.Cmd := SNARL_EX_SHOW;
  pssEx.Id := AReplyMsg;
  pssEx.Timeout := ATimeout;
  pssEx.LngData2 := AhwndReply;

  _CopySnarlBuffer(@pssEx.Title,      ATitle);
  _CopySnarlBuffer(@pssEx.Text,       AText);
  _CopySnarlBuffer(@pssEx.Icon,       AIconPath);

  // V36
  _CopySnarlBuffer(@pssEx.SnarlClass, ASnarlClass);
  _CopySnarlBuffer(@pssEx.Extra,      ASoundPath);

  Result := _Send(pssEx);
end;

{$IFNDEF UNICODE}
///   Snarl expects UTF-8 encoded strings.
///   For Delphi versions where UNICODE is defined, UTF8String() [in _CopySnarlBuffer()] will convert the UnicodeStrings to UTF-8
///   Delphi versions prior to where UNICODE is defined, you must explicitly call UTF8Encode()
function snShowMessageExWide(const ASnarlClass, ATitle, AText: WideString; ATimeout: Integer = 0;
  const AIconPath: WideString = ''; AhwndReply: Integer = 0; AReplyMsg: Integer = 0;
  const ASoundPath: WideString = ''): Integer;
begin
   Result := snShowMessageEx(
      UTF8Encode(ASnarlClass),
      UTF8Encode(ATitle),
      UTF8Encode(AText),
      ATimeout,
      UTF8Encode(AIconPath),
      AhwndReply,
      AReplyMsg,
      UTF8Encode(ASoundPath)
   );
end;
{$ENDIF}

function snUpdateMessage(AId: Integer; const ATitle, AText: String; ATimeOut: Integer = 0): Boolean;
var
  pss: TSnarlStruct;
begin
  _Clear(pss);

  pss.Id := AId;
  pss.Cmd := SNARL_UPDATE;
  pss.Timeout := ATimeOut;

  _CopySnarlBuffer(@pss.Title, ATitle);
  _CopySnarlBuffer(@pss.Text,  AText);

  Result := Boolean(_Send(pss));
end;

function snHideMessage(AId: Integer): Boolean;
var
  pss: TSnarlStruct;
begin
  _Clear(pss);

  pss.Id := AId;
  pss.Cmd := SNARL_HIDE;

  Result := Boolean(_Send(pss));
end;

function snIsMessageVisible(AId: Integer): Boolean;
var
  pss: TSnarlStruct;
begin
  _Clear(pss);

  pss.Id := AId;
  pss.Cmd := SNARL_IS_VISIBLE;

  Result := Boolean(_Send(pss));
end;

function snGetVersion(var Major, Minor: Word): Boolean;
var
  pss: TSnarlStruct;
  hr: Integer;
begin
  _Clear(pss);

  pss.Cmd := SNARL_GET_VERSION;

  hr := Integer(_Send(pss));
  Result := hr <> 0;
  if Result then
  begin
    Major := HiWord(hr);
    Minor := LoWord(hr);
  end;
end;

function snGetVersionEx: Integer;
var
  pss: TSnarlStruct;
begin
  _Clear(pss);

  pss.Cmd := SNARL_GET_VERSION;

  Result := Integer(_Send(pss));
end;

   function _snRegisterConfig(aCmd: TSnarlCommand; AHandle: HWND; const AAppName: String; AReplyMsg: Integer; const AIconPath: String): Integer;
   var
      pss: TSnarlStruct;
   begin
      hWndFrom := AHandle;

      _Clear(pss);

      pss.Cmd      := aCmd;
      pss.Id       := AReplyMsg;
      pss.LngData2 := AHandle;

      _CopySnarlBuffer(@pss.Title, AAppName);
      _CopySnarlBuffer(@pss.Icon,  AIconPath);

      Result := _Send(pss);
   end;

function snRegisterConfig(AHandle: HWND; const AAppName: String; AReplyMsg: Integer): Integer;
begin
   Result := _snRegisterConfig(SNARL_REGISTER_CONFIG_WINDOW,   AHandle, AAppName, AReplyMsg, '');
end;

function snRegisterConfig2(AHandle: HWND; const AAppName: String; AReplyMsg: Integer; const AIconPath: String): Integer;
begin
   Result := _snRegisterConfig(SNARL_REGISTER_CONFIG_WINDOW_2, AHandle, AAppName, AReplyMsg, AIconPath);
end;

function snRevokeConfig(AHandle: HWND): Integer;
var
   pss: TSnarlStruct;
begin
   hWndFrom := 0;

   _Clear(pss);

   pss.Cmd := SNARL_REVOKE_CONFIG_WINDOW;
   pss.LngData2 := AHandle;
   
   Result := _Send(pss);
end;

/// SNARL_REGISTER_ALERT (V37)
///   Parameter Description
///------------------------
///   Cmd:     SNARL_REGISTER_ALERT
///   Title:   Name of the application the alert belongs to
///   Text:    Name of the alert
function snRegisterAlert(const AAppName, AAlertName: String): Integer;
var
   pss: TSnarlStruct;
begin
   _Clear(pss);

   pss.Cmd := SNARL_REGISTER_ALERT;

   _CopySnarlBuffer(@pss.Title, AAppName);
   _CopySnarlBuffer(@pss.Text,  AAlertName);

   Result := _Send(pss);
end;

function snRevokeAlert: Integer;
var
   pss: TSnarlStruct;
begin
   _Clear(pss);

   pss.Cmd := SNARL_REVOKE_ALERT;

   Result := _Send(pss);
end;

end.
