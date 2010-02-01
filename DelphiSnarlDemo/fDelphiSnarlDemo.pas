unit fDelphiSnarlDemo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  uSnarl;

type
  TfrmDelphiSnarlDemo = class(TForm)
    btnRegister: TButton;
    btnSendText: TButton;
    btnSendTextWithImage: TButton;
    btnUnregister: TButton;
    lblTitle: TLabel;
    lblText: TLabel;
    eTitle: TEdit;
    eText: TEdit;
    lblMessages: TLabel;
    mmMessages: TMemo;
    eDuration: TEdit;
    lblDuration: TLabel;
    btnTestWideChars: TButton;
    procedure btnRegisterClick(Sender: TObject);
    procedure btnUnregisterClick(Sender: TObject);
    procedure btnSendTextClick(Sender: TObject);
    procedure btnSendTextWithImageClick(Sender: TObject);
    procedure btnTestWideCharsClick(Sender: TObject);
  protected
    procedure WMSnarlReply(var Msg: TMessage); message WM_SNARL_REPLY;
  private
    { Private declarations }
    function SendSnarl(const aImagePath: String): Integer;
  public
    { Public declarations }
  end;

var
  frmDelphiSnarlDemo: TfrmDelphiSnarlDemo;

implementation

{$R *.dfm}

procedure TfrmDelphiSnarlDemo.btnRegisterClick(Sender: TObject);
begin
   snRegisterConfig(Self.Handle, 'Delphi Snarl Demo', 0);
   mmMessages.Lines.Add('Registered');
end;

procedure TfrmDelphiSnarlDemo.btnSendTextClick(Sender: TObject);
var
   id: Integer;
begin
   id := SendSnarl('');
   mmMessages.Lines.Add(Format('  Sent message no image, id: %d', [id]));
end;

procedure TfrmDelphiSnarlDemo.btnSendTextWithImageClick(Sender: TObject);
var
   imagePath: String;
   id: Integer;
begin
   imagePath := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'image.png';

   id := SendSnarl(imagePath);
   mmMessages.Lines.Add(Format('  Sent message with image, id: %d', [id]));
end;

procedure TfrmDelphiSnarlDemo.btnUnregisterClick(Sender: TObject);
begin
   snRevokeConfig(Self.Handle);
   mmMessages.Lines.Add('Unregistered');
end;

procedure TfrmDelphiSnarlDemo.btnTestWideCharsClick(Sender: TObject);
var
   w: WideString;
begin
   w := 'Some UTF-8 chars [ÿ ⌂]';
   snShowMessageEx(
      'Default',
      'Test snShowMessageEx',
      w,
      StrToIntDef(eDuration.Text, 60),
      IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'image.png',
      Self.Handle,
      WM_SNARL_REPLY
   );
{$IFNDEF UNICODE}
   snShowMessageExWide(
      'Default',
      'Test snShowMessageExWide',
      w,
      StrToIntDef(eDuration.Text, 60),
      IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'image.png',
      Self.Handle,
      WM_SNARL_REPLY
   );
{$ENDIF}
   mmMessages.Lines.Add(Format('  Sent WideString message, [%s]', [w]));
end;

function TfrmDelphiSnarlDemo.SendSnarl(const aImagePath: String): Integer;
begin
   Result := snShowMessageEx(
      'Default',
      eTitle.Text,
      eText.Text,
      StrToIntDef(eDuration.Text, 60),
      aImagePath,
      Self.Handle,
      WM_SNARL_REPLY
   );
end;

procedure TfrmDelphiSnarlDemo.WMSnarlReply(var Msg: TMessage);
var
   id: Integer;
begin
   id := Msg.LParam;

   if Msg.WParam = SNARL_NOTIFICATION_LEFT_CLICKED then
      mmMessages.Lines.Add(Format('    Left clicked on Snarl Message, id: %d', [id]))

   else if Msg.WParam = SNARL_NOTIFICATION_RIGHT_CLICKED then
      mmMessages.Lines.Add(Format('    Right clicked on Snarl Message, id: %d', [id]))

   else if Msg.WParam = SNARL_NOTIFICATION_CANCELLED then // user clicked the X button to close
      mmMessages.Lines.Add(Format('    Snarl Message closed, id: %d', [id]))

   else if Msg.WParam = SNARL_NOTIFICATION_TIMED_OUT then
      mmMessages.Lines.Add(Format('    Snarl Message Timed out, id: %d', [id]))

end;

end.
