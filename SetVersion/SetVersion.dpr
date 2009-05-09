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

function GetResFile(const s: String): String;
begin
   Result := s;
   if not SameText(ExtractFileExt(Result), '.RES') then
      Result := ChangeFileExt(Result, '.res');
   if not FileExists(Result) then
      raise Exception.Create('Could not find the RES file.');
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

function GetVersionInfoResourceDetails(aResModule: TResModule): TVersionInfoResourceDetails;
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

var
  i: Integer;
  version, filename: String;
  increment, print_version, save_file: Boolean;
  ResModule: TResModule;
  VersionInfoResourceDetails: TVersionInfoResourceDetails;
  VersionNumber: TVersionNumber;
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
      Writeln(' -s will save the changes to the RES file.');
      Writeln('');
      Exit;
    end;

    increment     := false;
    print_version := false;
    save_file     := false;
    version  := '';
    filename := '';

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
        filename := GetResFile(ParamStr(i));
    end;

    ResModule := TResModule.Create;
    try
      ResModule.LoadFromFile(filename);

      VersionInfoResourceDetails := GetVersionInfoResourceDetails(ResModule);

      if not Assigned(VersionInfoResourceDetails) then
         raise Exception.CreateFmt('No VersionInfo found in %s', [filename])
      else
      begin
        VersionNumber.FromULargeInteger(VersionInfoResourceDetails.FileVersion);

        if version <> '' then
        begin
          SetVersionFromString(version, VersionNumber.Major);
          SetVersionFromString(version, VersionNumber.Minor);
          SetVersionFromString(version, VersionNumber.Release);
          SetVersionFromString(version, VersionNumber.Build);
        end;

        if increment then
          Inc(VersionNumber.Build);

        if print_version then
        begin
          Writeln(
            Format(
               '%s: %d.%d.%d.%d',
               [filename, VersionNumber.Major, VersionNumber.Minor, VersionNumber.Release, VersionNumber.Build]
            )
          );
        end;

        VersionInfoResourceDetails.FileVersion := VersionNumber.AsULargeInteger;

        if save_file then
        begin
          // commenting this out will copy existing RES files to [resfile].~res backup files
          DeleteFile(PChar(filename));
          ResModule.SaveToFile(filename);
        end;
      end;
    finally
      ResModule.Free;
    end;

    version  := '';
    filename := '';
  except
    on E:Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;

  ReportMemoryLeaksOnShutdown := true;
end.
