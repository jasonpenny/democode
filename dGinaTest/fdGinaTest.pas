unit fdGinaTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmdGinaTest = class(TForm)
    btnLoad: TButton;
    btnDisableTaskbar: TButton;
    btnUnload: TButton;
    procedure btnLoadClick(Sender: TObject);
    procedure btnUnloadClick(Sender: TObject);
    procedure btnDisableTaskbarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmdGinaTest: TfrmdGinaTest;

implementation

{$R *.dfm}

uses
   BTMemoryModule;

var
   HookLib: PBTMemoryModule = nil;

   pDisableItem: procedure(Key: integer; disable: integer) stdcall = nil;
   pRestoreAll : procedure stdcall = nil;

const
   wlTaskBar = 1;

procedure TfrmdGinaTest.btnLoadClick(Sender: TObject);
   function LoadLibraryFromResource(const aResourceName: String): PBTMemoryModule;
   var
      ms: TMemoryStream;
      rs: TResourceStream;
   begin
      ms := TMemoryStream.Create;
      try
         rs := TResourceStream.Create(HInstance, aResourceName, RT_RCDATA);
         try
            ms.CopyFrom(rs, 0);
            ms.Position := 0;
         finally
            rs.Free;
         end;

         Result := BTMemoryLoadLibary(ms.Memory, ms.Size);
      finally
         ms.Free;
      end;
   end;
begin
   HookLib := LoadLibraryFromResource('dgina');                            // HookLib := LoadLibrary('dgina.dll');

   if Hooklib <> nil then
   begin
      @pDisableItem := BTMemoryGetProcAddress(HookLib, 'wlDisableItem');   // pDisableItem := GetProcAddress(HookLib, 'wlDisableItem');
      @pRestoreAll  := BTMemoryGetProcAddress(HookLib, 'wlRestoreAll');    // pRestoreAll  := GetProcAddress(HookLib, 'wlRestoreAll');
   end;
end;

procedure TfrmdGinaTest.btnDisableTaskbarClick(Sender: TObject);
begin
   pDisableItem(wlTaskBar, 1);
end;

procedure TfrmdGinaTest.btnUnloadClick(Sender: TObject);
begin
   pRestoreAll;

   if HookLib <> nil then
      BTMemoryFreeLibrary(HookLib);                                        // FreeLibrary(HookLib);
end;

end.
