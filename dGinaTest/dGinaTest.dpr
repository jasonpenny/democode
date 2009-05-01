program dGinaTest;

{$R 'dgina.res' 'dgina.rc'}

uses
  Forms,
  fdGinaTest in 'fdGinaTest.pas' {frmdGinaTest},
  BTMemoryModule in 'BTMemoryModule.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmdGinaTest, frmdGinaTest);
  Application.Run;
end.
