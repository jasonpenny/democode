unit fMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, ExtCtrls, StdCtrls;

type
  TfrmMain = class(TForm)
    WebBrowser1: TWebBrowser;
    btnInject: TButton;
    Edit1: TEdit;
    btnSetProgValue: TButton;
    btnIncProgValue: TButton;
    procedure btnInjectClick(Sender: TObject);
    procedure btnSetProgValueClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnIncProgValueClick(Sender: TObject);
  private
    { Private declarations }
    fAlreadyDone: Boolean;

    procedure ExecJS(const javascript: String);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
   MSHTML, ActiveX;

procedure TfrmMain.btnInjectClick(Sender: TObject);
   function GetFileAsString(const aFileName: String): String;
   var
      ts: TStringList;
   begin
      ts := TStringList.Create;
      try
         ts.LoadFromFile(aFileName);
         Result := ts.Text;
      finally
         ts.Free;
      end;
   end;

   function ChangeImagePaths(const source: String): String;
      function FileProtocol(const s: String): String;
      begin
         Result := 'file:///' + StringReplace(s, '\', '/', [rfReplaceAll]);
      end;
      function AppPath(const s: String): String;
      begin
         Result := IncludeTrailingPathDelimiter( ExtractFilePath(Forms.Application.ExeName) ) + s;
      end;
   begin
      Result := StringReplace(source, 'url(images', 'url(' + FileProtocol(AppPath('images')), [rfReplaceAll]);
   end;
var
   document: IHTMLDocument2;
   stylesheet: IHTMLStyleSheet;
   stylesheetIndex: Integer;
begin
   // Inject JavaScripts
   ExecJS(GetFileAsString('jquery-1.3.2.min.js'));
   ExecJS(GetFileAsString('jquery-ui-1.7.1.custom.min.js'));

   // Inject CSS Style Sheets
   document := webBrowser1.Document as IHTMLDocument2;

   stylesheetIndex := document.styleSheets.length;
   if stylesheetIndex > 31 then
      raise Exception.Create('Already have the maximum amount of CSS stylesheets');

   stylesheet := document.createStyleSheet('', stylesheetIndex);
   stylesheet.cssText := ChangeImagePaths( GetFileAsString('jquery-ui-1.7.1.custom.css') );

   stylesheetIndex := document.styleSheets.length;
   if stylesheetIndex > 31 then
      raise Exception.Create('Already have the maximum amount of CSS stylesheets');
   stylesheet := document.createStyleSheet('', stylesheetIndex);
   stylesheet.cssText := ChangeImagePaths(
      '.ui-progressbar { ' +
      '   height: 1em; ' +
      '} ' +
      '.ui-progressbar-value { ' +
      '   background-image: url(images/pbar-ani.gif); ' +
      '}'
   );

   // Add a JQuery UI ProgressBar to the end of the [document.body]
   ExecJS(
      '$(document.body).append(''<br />''); ' +
      '$(document.body).append(''<div id="progressbar"></div>'');'
   );
   ExecJS(
      '$("#progressbar").progressbar({value: 0});'
   );
end;

procedure TfrmMain.btnSetProgValueClick(Sender: TObject);
begin
   ExecJS(
      Format(
         '$("#progressbar").progressbar(''option'', ''value'', %s);',
         [Edit1.Text]
      )
   );
end;

procedure TfrmMain.btnIncProgValueClick(Sender: TObject);
begin
   ExecJS(
      Format(
         'var i = $("#progressbar").progressbar(''option'', ''value''); ' +
         '$("#progressbar").progressbar(''option'', ''value'', parseInt(i) + 1);',
         [Edit1.Text]
      )
   );
end;

procedure TfrmMain.ExecJS(const javascript: String);
var
   aHTMLDocument2: IHTMLDocument2;
begin
   if Supports(WebBrowser1.Document, IHTMLDocument2, aHTMLDocument2) then
      aHTMLDocument2.parentWindow.execScript(javascript, 'JavaScript');
end;

procedure TfrmMain.FormActivate(Sender: TObject);
begin
   if not fAlreadyDone then
   begin
      WebBrowser1.Navigate('http://www.google.com/');
      fAlreadyDone := true;
   end;
end;

end.
