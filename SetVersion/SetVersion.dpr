program SetVersion;

{$APPTYPE CONSOLE}

uses
  SysUtils, Windows,
  unitEXIcon in '..\Others\ColinWilson\unitEXIcon.pas',
  unitPEFile in '..\Others\ColinWilson\unitPEFile.pas',
  unitResFile in '..\Others\ColinWilson\unitResFile.pas',
  unitResourceDetails in '..\Others\ColinWilson\unitResourceDetails.pas',
  unitResourceExaminer in '..\Others\ColinWilson\unitResourceExaminer.pas',
  unitResourceGraphics in '..\Others\ColinWilson\unitResourceGraphics.pas',
  unitResourceToolbar in '..\Others\ColinWilson\unitResourceToolbar.pas',
  unitResourceVersionInfo in '..\Others\ColinWilson\unitResourceVersionInfo.pas';

type
  TVersionNumber = record
    Major, Minor, Release, Build: Integer;

    procedure FromULargeInteger(aULargeInteger: TULargeInteger);
    function  AsULargeInteger: TULargeInteger;
  end;

  TResourceType = (rtRES, rtEXE);

  TResourceFile = record
    ResourceType: TResourceType;
    FileName:     String;
  end;

function GetResourceFile(const s: String): TResourceFile;
begin
   Result.FileName := s;

   if SameText(ExtractFileExt(s), '.EXE') and FileExists(s) then
      Result.ResourceType := rtEXE

   else if SameText(ExtractFileExt(s), '.RES') and FileExists(s) then
      Result.ResourceType := rtRES

   else
   begin
      Result.FileName := ChangeFileExt(Result.FileName, '.res');
      if FileExists(Result.FileName) then
         Result.ResourceType := rtRES

      else
      begin
         Result.FileName := ChangeFileExt(Result.FileName, '.exe');
         if FileExists(Result.FileName) then
            Result.ResourceType := rtRes

         else
            raise Exception.CreateFmt('Could not find an EXE or RES file matching that name "%s".', [s]);
      end;
   end;
end;

{ VersionNumber }

function TVersionNumber.AsULargeInteger: TULargeInteger;
begin
   Result.HighPart := Major   shl 16 or Minor;
   Result.LowPart  := Release shl 16 or Build
end;

procedure TVersionNumber.FromULargeInteger(aULargeInteger: TULargeInteger);
begin
   Major   := aULargeInteger.HighPart shr 16;
   Minor   := aULargeInteger.HighPart and ((1 shl 16) - 1);
   Release := aULargeInteger.LowPart  shr 16;
   Build   := aULargeInteger.LowPart  and ((1 shl 16) - 1);
end;

function GetVersionInfoResourceDetails(aResModule: TResourceModule): TVersionInfoResourceDetails;
var
   i: Integer;
begin
   Result := nil;

   for i := 0 to aResModule.ResourceCount - 1 do
   begin
      aResModule.ResourceDetails[i];
      if aResModule.ResourceDetails[i] is TVersionInfoResourceDetails then
      begin
         Result := (aResModule.ResourceDetails[i]) as TVersionInfoResourceDetails;
         Break; // I believe there should only ever be one Version resource.
      end;
   end;
end;

procedure SetVersionFromString(var aVersionString: String; out aVersionPart: Integer);
var
   idx: Integer;
begin
   if aVersionString = '' then
      aVersionPart := 0
   else
   begin
      idx := Pos('.', aVersionString);
      if idx <= 1 then
      begin
         if not TryStrToInt(aVersionString, aVersionPart) then
            aVersionPart := 0;

         aVersionString := '';
      end
      else
      begin
         if not TryStrToInt(Copy(aVersionString, 1, idx-1), aVersionPart) then
            raise Exception.CreateFmt('"%s" is not a valid version number', [Copy(aVersionString, 1, idx-1)]);
         Delete(aVersionString, 1, idx);
      end;
   end;
end;

procedure HandleVersionNumber(const aResourceModule: TResourceModule; 
  const aFileName: String; aVersion: String; const aIncrement, aPrintVersion, aSaveFile: Boolean);
var
  VersionInfoResourceDetails: TVersionInfoResourceDetails;
  VersionNumber: TVersionNumber;
begin
   aResourceModule.LoadFromFile(aFileName);
  
   VersionInfoResourceDetails := GetVersionInfoResourceDetails(aResourceModule);
  
   if not Assigned(VersionInfoResourceDetails) then
      raise Exception.CreateFmt('No VersionInfo found in %s', [aFileName])
   else
   begin
     VersionNumber.FromULargeInteger(VersionInfoResourceDetails.FileVersion);
  
     if aPrintVersion and aIncrement and (not aSaveFile) and (aVersion = '') then
       Writeln('Warning: Increment was chosen, but Save was not; file will not be updated.');

     if aVersion <> '' then
     begin
       SetVersionFromString(aVersion, VersionNumber.Major);
       SetVersionFromString(aVersion, VersionNumber.Minor);
       SetVersionFromString(aVersion, VersionNumber.Release);
       SetVersionFromString(aVersion, VersionNumber.Build);
     end;
    
     if aIncrement then
       Inc(VersionNumber.Build);
    
     if aPrintVersion then
     begin
       Writeln(
         Format(
            '%s: %d.%d.%d.%d',
            [aFileName, VersionNumber.Major, VersionNumber.Minor, VersionNumber.Release, VersionNumber.Build]
         )
       );
     end;

     VersionInfoResourceDetails.FileVersion := VersionNumber.AsULargeInteger;
    
     if aSaveFile then
     begin
       // commenting this out will copy existing RES files to [resfile].~res backup files
       DeleteFile(PChar(aFileName));
       aResourceModule.SaveToFile(aFileName);
     end;
   end;
end;

procedure HandleResFile(const aFileName, aVersion: String; const aIncrement, aPrintVersion, aSaveFile: Boolean);
var
  ResModule: TResModule;
begin
  ResModule := TResModule.Create;
  try
    HandleVersionNumber(ResModule, aFileName, aVersion, aIncrement, aPrintVersion, aSaveFile);
  finally
    ResModule.Free;
  end;
end;

procedure HandleExeFile(const aFileName, aVersion: String; const aIncrement, aPrintVersion, aSaveFile: Boolean);
var
  PEResourceModule: TPEResourceModule;
begin
  PEResourceModule := TPEResourceModule.Create;
  try
    HandleVersionNumber(PEResourceModule, aFileName, aVersion, aIncrement, aPrintVersion, aSaveFile);
  finally
    PEResourceModule.Free;
  end;
end;

var
  i: Integer;
  version: String;
  increment, print_version, save_file: Boolean;
  ResourceFile: TResourceFile;
begin
  try
    if ParamCount < 1 then
    begin
      Writeln('');
      Writeln('Usage: ', ExtractFileName(ParamStr(0)), ' [-vX.X.X.X] [-i] [-p] [-s] project_name');
      Writeln('');
      Writeln(' -vX.X.X.X will set the version to X.X.X.X');
      Writeln(' -i will increment the build number');
      Writeln(' -p will print the (new) build number');
      Writeln(' -s will save the changes to the EXE/RES file.');
      Writeln('');
      Exit;
    end;

    increment     := false;
    print_version := false;
    save_file     := false;

    for i := 1 to ParamCount do
    begin
      if Copy(ParamStr(i), 1, 2) = '-v' then
        version := Copy(ParamStr(i), 3)
      else if Copy(ParamStr(i), 1, 2) = '-i' then
        increment := true
      else if Copy(ParamStr(i), 1, 2) = '-p' then
        print_version := true
      else if Copy(ParamStr(i), 1, 2) = '-s' then
        save_file := true
      else
        ResourceFile := GetResourceFile(ParamStr(i));
    end;

    case ResourceFile.ResourceType of
      rtRES: HandleResFile(ResourceFile.FileName, version, increment, print_version, save_file);
      rtEXE: HandleExeFile(ResourceFile.FileName, version, increment, print_version, save_file);
    end;

    ResourceFile.FileName := '';
  except
    on E:Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;

  ReportMemoryLeaksOnShutdown := true;
end.
