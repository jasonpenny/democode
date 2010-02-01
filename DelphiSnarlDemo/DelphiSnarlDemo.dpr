program DelphiSnarlDemo;

uses
  Forms,
  fDelphiSnarlDemo in 'fDelphiSnarlDemo.pas' {frmDelphiSnarlDemo},
  uSnarl in 'uSnarl.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmDelphiSnarlDemo, frmDelphiSnarlDemo);
  Application.Run;
end.
