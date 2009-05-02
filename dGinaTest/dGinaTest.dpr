program dGinaTest;

{$R 'dgina.res' 'dgina.rc'}

uses
  Forms,
  fdGinaTest in 'fdGinaTest.pas' {frmdGinaTest},
  BTMemoryModule in 'BTMemoryModule.pas';

{$R *.res}

begin
  Application.Initialize;
{$IF CompilerVersion > 18}
  Application.MainFormOnTaskbar := True;
{$IFEND}
  Application.CreateForm(TfrmdGinaTest, frmdGinaTest);
  Application.Run;
end.
