program JQueryUIProgBar;

uses
  Forms,
  fMain in 'fMain.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
{$IF CompilerVersion > 18.0}
  Application.MainFormOnTaskbar := True;
{$IFEND}
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
