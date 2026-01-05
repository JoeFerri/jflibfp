{
  This file is part of the JFLibFP Free Pascal Library.

  Copyright (c) 2025 Giuseppe Ferri <jfinfoit@gmail.com>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as
  published by the Free Software Foundation, either version 3 of the
  License, or (at your option) any later version.

  See the file LICENSE, included in this distribution,
  for details about the copyright.

 **********************************************************************}



{*
  Tools for handling INI files.
}
unit INIUnit;

{$mode objfpc}{$H+}{$J-}{$R+}

interface

uses
  Classes, SysUtils, IniPropStorage, IniFiles, Forms;



type
  {* Mode for positioning a form. }
  TFormPosMode = (fpmDefault, fpmFollowActiveMonitor, fpmSpecificMonitor);


type
  {*
    Tools for handling INI files.
  }
  TIniPropStorageHelper = class helper for TIniPropStorage
  public
    {* Reads an integer value from a specific section.
        @param(ASection The name of the section [SectionName].)
        @param(AKey The key to read.)
        @param(ADefault Value returned if the key is missing or an error occurs.)
        @return(The integer value or ADefault.) }
    function ReadIntSect(const ASection, AKey: string; ADefault: Integer): Integer;

    {* Reads a String value from a specific section.
        @param(ASection The name of the section.)
        @param(AKey The key to read.)
        @param(ADefault Value returned if the key is missing.)
        @return(The String value or ADefault.) }
    function ReadStringSect(const ASection, AKey: string; const ADefault: string): string;

    {* Reads a boolean value from a specific section.
        @param(ASection The name of the section.)
        @param(AKey The key to read.)
        @param(ADefault Value returned if the key is missing.)
        @return(The boolean value or ADefault.) }
    function ReadBoolSect(const ASection, AKey: string; ADefault: Boolean): Boolean;

    {* Reads a double precision floating point value from a specific section.
        @param(ASection The name of the section.)
        @param(AKey The key to read.)
        @param(ADefault Value returned if the key is missing or invalid.)
        @return(The double value or ADefault.) }
    function ReadDoubleSect(const ASection, AKey: string; ADefault: Double): Double;

    {* Reads a TDateTime value from a specific section.
        @param(ASection The name of the section.)
        @param(AKey The key to read.)
        @param(ADefault Value returned if the key is missing or invalid.)
        @return(The TDateTime value or ADefault.) }
    function ReadDateTimeSect(const ASection, AKey: string; ADefault: TDateTime): TDateTime;

    {* Retrieves all key names within a specific section.
        @param(ASection The name of the section to scan.)
        @param(AList A TStrings object to be populated with key names.) }
    procedure ReadKeysSect(const ASection: string; AList: TStrings);

    {* Writes an integer value to a specific section.
        @param(ASection The name of the section.)
        @param(AKey The key to write.)
        @param(AValue The integer value to store.) }
    procedure WriteIntSect(const ASection, AKey: string; AValue: Integer);

    {* Writes a String value to a specific section.
        @param(ASection The name of the section.)
        @param(AKey The key to write.)
        @param(AValue The String value to store.) }
    procedure WriteStringSect(const ASection, AKey: string; const AValue: string);

    {* Writes a boolean value to a specific section.
        @param(ASection The name of the section.)
        @param(AKey The key to write.)
        @param(AValue The boolean value to store.) }
    procedure WriteBoolSect(const ASection, AKey: string; AValue: Boolean);

    {* Writes a double precision floating point value to a specific section.
        Note: Uses FloatToStr to ensure DecimalSeparator consistency.
        @param(ASection The name of the section.)
        @param(AKey The key to write.)
        @param(AValue The double value to store.) }
    procedure WriteDoubleSect(const ASection, AKey: string; AValue: Double);

    {* Writes a TDateTime value to a specific section.
        @param(ASection The name of the section.)
        @param(AKey The key to write.)
        @param(AValue The TDateTime value to store.) }
    procedure WriteDateTimeSect(const ASection, AKey: string; AValue: TDateTime);

    {* Erases an entire section and all its keys from the storage.
        @param(ASection The name of the section to remove.) }
    procedure EraseSect(const ASection: string);
  end;





implementation


{ TIniPropStorageHelper }

function TIniPropStorageHelper.ReadIntSect(const ASection, AKey: string;
  ADefault: Integer): Integer;
var
  IniFile: TIniFile;
begin
  Result := ADefault;

  if Trim(Self.IniFileName) = '' then
    Exit;

  if not FileExists(Self.IniFileName) then
    Exit;

  IniFile := TIniFile.Create(Self.IniFileName);
  try
    Result := IniFile.ReadInteger(ASection, AKey, ADefault);
  finally
    IniFile.Free;
  end;
end;



function TIniPropStorageHelper.ReadStringSect(const ASection, AKey: string;
  const ADefault: string): string;
var
  IniFile: TIniFile;
begin
  Result := ADefault;

  if Trim(Self.IniFileName) = '' then
    Exit;

  if not FileExists(Self.IniFileName) then
    Exit;

  IniFile := TIniFile.Create(Self.IniFileName);
  try
    Result := IniFile.ReadString(ASection, AKey, ADefault);
  finally
    IniFile.Free;
  end;
end;



function TIniPropStorageHelper.ReadBoolSect(const ASection, AKey: string;
  ADefault: Boolean): Boolean;
var
  IniFile: TIniFile;
begin
  Result := ADefault;

  if Trim(Self.IniFileName) = '' then
    Exit;

  if not FileExists(Self.IniFileName) then
    Exit;

  IniFile := TIniFile.Create(Self.IniFileName);
  try
    Result := IniFile.ReadBool(ASection, AKey, ADefault);
  finally
    IniFile.Free;
  end;
end;



function TIniPropStorageHelper.ReadDoubleSect(const ASection, AKey: string;
  ADefault: Double): Double;
var
  IniFile: TIniFile;
  StrValue: string;
begin
  Result := ADefault;

  if Trim(Self.IniFileName) = '' then
    Exit;

  if not FileExists(Self.IniFileName) then
    Exit;

  IniFile := TIniFile.Create(Self.IniFileName);
  try
    StrValue := IniFile.ReadString(ASection, AKey, '');
    if StrValue <> '' then
    begin
      if not TryStrToFloat(StrValue, Result) then
        Result := ADefault;
    end;
  finally
    IniFile.Free;
  end;
end;



function TIniPropStorageHelper.ReadDateTimeSect(const ASection, AKey: string;
  ADefault: TDateTime): TDateTime;
var
  IniFile: TIniFile;
  StrValue: string;
begin
  Result := ADefault;

  if Trim(Self.IniFileName) = '' then
    Exit;

  if not FileExists(Self.IniFileName) then
    Exit;

  IniFile := TIniFile.Create(Self.IniFileName);
  try
    StrValue := IniFile.ReadString(ASection, AKey, '');
    if StrValue <> '' then
    begin
      if not TryStrToDateTime(StrValue, Result) then
        Result := ADefault;
    end;
  finally
    IniFile.Free;
  end;
end;



procedure TIniPropStorageHelper.ReadKeysSect(const ASection: string;
  AList: TStrings);
var
  IniFile: TIniFile;
begin
  if not Assigned(AList) then
    raise Exception.Create('AList parameter cannot be nil');

  AList.Clear;

  if Trim(ASection) = '' then
    raise Exception.Create('Section name cannot be empty');

  if Trim(Self.IniFileName) = '' then
    raise Exception.Create('IniFileName not set');

  if not FileExists(Self.IniFileName) then
    Exit;

  IniFile := TIniFile.Create(Self.IniFileName);
  try
    IniFile.ReadSection(ASection, AList);
  finally
    IniFile.Free;
  end;
end;



procedure TIniPropStorageHelper.WriteIntSect(const ASection, AKey: string;
  AValue: Integer);
var
  IniFile: TIniFile;
begin
  if Trim(Self.IniFileName) = '' then
    raise Exception.Create('IniFileName not set');

  IniFile := TIniFile.Create(Self.IniFileName);
  try
    IniFile.WriteInteger(ASection, AKey, AValue);
  finally
    IniFile.Free;
  end;
end;



procedure TIniPropStorageHelper.WriteStringSect(const ASection, AKey: string;
  const AValue: string);
var
  IniFile: TIniFile;
begin
  if Trim(Self.IniFileName) = '' then
    raise Exception.Create('IniFileName not set');

  IniFile := TIniFile.Create(Self.IniFileName);
  try
    IniFile.WriteString(ASection, AKey, AValue);
  finally
    IniFile.Free;
  end;
end;



procedure TIniPropStorageHelper.WriteBoolSect(const ASection, AKey: string;
  AValue: Boolean);
var
  IniFile: TIniFile;
begin
  if Trim(Self.IniFileName) = '' then
    raise Exception.Create('IniFileName not set');

  IniFile := TIniFile.Create(Self.IniFileName);
  try
    IniFile.WriteBool(ASection, AKey, AValue);
  finally
    IniFile.Free;
  end;
end;



procedure TIniPropStorageHelper.WriteDoubleSect(const ASection, AKey: string;
  AValue: Double);
var
  IniFile: TIniFile;
begin
  if Trim(Self.IniFileName) = '' then
    raise Exception.Create('IniFileName not set');

  IniFile := TIniFile.Create(Self.IniFileName);
  try
    IniFile.WriteString(ASection, AKey, FloatToStr(AValue));
  finally
    IniFile.Free;
  end;
end;



procedure TIniPropStorageHelper.WriteDateTimeSect(const ASection, AKey: string;
  AValue: TDateTime);
var
  IniFile: TIniFile;
begin
  if Trim(Self.IniFileName) = '' then
    raise Exception.Create('IniFileName not set');

  IniFile := TIniFile.Create(Self.IniFileName);
  try
    IniFile.WriteString(ASection, AKey, DateTimeToStr(AValue));
  finally
    IniFile.Free;
  end;
end;



procedure TIniPropStorageHelper.EraseSect(const ASection: string);
var
  IniFile: TIniFile;
begin
  if Trim(ASection) = '' then
    raise Exception.Create('Section name cannot be empty');

  if Trim(Self.IniFileName) = '' then
    raise Exception.Create('IniFileName not set');

  if not FileExists(Self.IniFileName) then
    Exit;

  IniFile := TIniFile.Create(Self.IniFileName);
  try
    IniFile.EraseSection(ASection);
  finally
    IniFile.Free;
  end;
end;



end.