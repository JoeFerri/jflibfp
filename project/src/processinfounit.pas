{
  This file is part of the JFUtils Free Pascal Library.

  Copyright (c) 2025 Giuseppe Ferri <jfinfoit@gmail.com>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as
  published by the Free Software Foundation, either version 3 of the
  License, or (at your option) any later version.

  See the file LICENSE, included in this distribution,
  for details about the copyright.

 **********************************************************************}



{*
  Tools for handling processes and retrieving execution information.
}
unit ProcessInfoUnit;

{$mode objfpc}{$H+}{$J-}{$R+}

interface

uses
  Classes, SysUtils, Windows, JwaTlHelp32;

type
  {*
    Criteria for selecting a process when multiple instances of the same 
    executable name are running.
  }
  TProcessSelectionCriteria = (
    {* Returns the first instance encountered in the process snapshot. }
    pscFirstFound,
    {* Returns the instance with the earliest creation date. }
    pscOldest,
    {* Returns the instance with the most recent creation date. }
    pscNewest
  );

{*
  Normalizes an executable name by trimming spaces, converting to lowercase 
  and ensuring the .exe extension is present.
  @param(AName The original executable name or path.)
  @returns(The normalized executable name.)
}
function NormalizeExeName(const AName: string): string;

{*
  Checks if a process with the given executable name is currently running.
  @param(AExeName The name of the executable (e.g., 'notepad.exe' or just 'notepad').)
  @returns(@code(True) if at least one instance of the process is found, @code(False) otherwise.)
}
function IsProcessRunning(const AExeName: string): Boolean;

{*
  Converts a Windows @code(TFileTime) structure to a local @code(TDateTime).
  @param(@code(TFileTime) The Windows file time structure.)
  @param(ADateTime Out parameter that receives the converted @code(TDateTime).)
  @returns(@code(True) if conversion was successful, @code(False) otherwise.)
}
function FileTimeToDateTimeLocal(const AFileTime: TFileTime; out ADateTime: TDateTime): Boolean;

{*
  Retrieves the creation time of a process given its PID.
  @param(ANativePID The Native Process ID.)
  @param(ACreationTime Out parameter that receives the process creation time.)
  @returns(@code(True) if the information was successfully retrieved.)
}
function GetProcessCreationTimeByPID(ANativePID: DWORD; out ACreationTime: TDateTime): Boolean;

{*
  Finds the start time of a specific executable. 
  If multiple instances are running, it selects one based on the ACriteria parameter.
  @param(AExeName The name of the executable to search for.)
  @param(AStartTime Out parameter that receives the found creation time.)
  @param(ACriteria The criteria used to select the instance (First, Oldest, Newest).)
  @returns(@code(True) if at least one instance was found and its time retrieved.)
}
function FindProcessStartForExe(const AExeName: string; out AStartTime: TDateTime; ACriteria: TProcessSelectionCriteria = pscOldest): Boolean;


implementation


function NormalizeExeName(const AName: string): string;
begin
  Result := Trim(AName);
  Result := LowerCase(Result);
  if ExtractFileExt(Result) = '' then
    Result := Result + '.exe';
end;   



function IsProcessRunning(const AExeName: string): Boolean;
var
  Snap: THandle;
  pe: TProcessEntry32;
  exeLower: string;
begin
  Result := False;
  exeLower := NormalizeExeName(AExeName);

  Snap := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Snap = INVALID_HANDLE_VALUE then
    Exit;

  try
    pe.dwSize := SizeOf(pe);
    if Process32First(Snap, pe) then
    begin
      repeat
        if LowerCase(StrPas(pe.szExeFile)) = exeLower then
        begin
          Result := True;
          Break;
        end;
      until not Process32Next(Snap, pe);
    end;
  finally
    CloseHandle(Snap);
  end;
end;



function FileTimeToDateTimeLocal(const AFileTime: TFileTime; out ADateTime: TDateTime): Boolean;
var
  localFT: TFileTime;
  st: TSystemTime;
begin
  Result := False;
  ADateTime := 0;

  if not FileTimeToLocalFileTime(AFileTime, localFT) then Exit;
  if not FileTimeToSystemTime(localFT, st) then Exit;

  try
    ADateTime := SystemTimeToDateTime(st);
    Result := True;
  except
    Result := False;
  end;
end;



function GetProcessCreationTimeByPID(ANativePID: DWORD; out ACreationTime: TDateTime): Boolean;
var
  hProc: THandle;
  ftCreate, ftExit, ftKernel, ftUser: TFileTime;
begin
  Result := False;
  ACreationTime := 0;

  // Try with limited information rights first (more likely to succeed on modern Windows for other users' processes)
  hProc := OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION or SYNCHRONIZE, False, ANativePID);
  if hProc = 0 then
  begin
    hProc := OpenProcess(PROCESS_QUERY_INFORMATION or SYNCHRONIZE, False, ANativePID);
    if hProc = 0 then Exit;
  end;

  try
    if not GetProcessTimes(hProc, ftCreate, ftExit, ftKernel, ftUser) then
      Exit;

    Result := FileTimeToDateTimeLocal(ftCreate, ACreationTime);
  finally
    CloseHandle(hProc);
  end;
end;



function FindProcessStartForExe(const AExeName: string; out AStartTime: TDateTime; ACriteria: TProcessSelectionCriteria = pscOldest): Boolean;
var
  Snap: THandle;
  pe: TProcessEntry32;
  exeLower, procNameLower: string;
  curPID: DWORD;
  creationTime: TDateTime;
  foundAny: Boolean;
begin
  Result := False;
  AStartTime := 0;
  foundAny := False;
  exeLower := NormalizeExeName(AExeName);

  Snap := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Snap = INVALID_HANDLE_VALUE then
    Exit;

  try
    pe.dwSize := SizeOf(pe);
    if Process32First(Snap, pe) then
    begin
      repeat
        procNameLower := LowerCase(StrPas(pe.szExeFile));
        if procNameLower = exeLower then
        begin
          curPID := pe.th32ProcessID;
          if GetProcessCreationTimeByPID(curPID, creationTime) then
          begin
            case ACriteria of
              pscFirstFound:
                begin
                  AStartTime := creationTime;
                  foundAny := True;
                  Break; // Optimization: exit loop immediately
                end;
                
              pscOldest:
                if (not foundAny) or (creationTime < AStartTime) then
                  AStartTime := creationTime;
                  
              pscNewest:
                if (not foundAny) or (creationTime > AStartTime) then
                  AStartTime := creationTime;
            end;
            foundAny := True;
          end;
        end;
      until not Process32Next(Snap, pe);
    end;
  finally
    CloseHandle(Snap);
  end;

  Result := foundAny;
end;


end.