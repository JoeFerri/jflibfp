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
  Tools for handling HTTPS requests.
}
unit HTTPSUnit;

{$mode objfpc}{$H+}{$J-}{$R+}

interface

uses
  Classes, SysUtils, Windows, WinHttp;



{*
  Checks if a given URL is valid and accessible via HTTPS.

  @param(wHost The host name or IP address of the server.)
  @param(wPath The path to the resource on the server.)
  @param(UserAgent The user agent string to be used in the HTTP request.)
  @returns(@code(True) if the URL is valid and accessible, @code(False) otherwise.)
}
function CheckHTTPSURL(const wHost: UnicodeString; const wPath: UnicodeString; const UserAgent: UnicodeString = ''): Boolean;






implementation



function CheckHTTPSURL(const wHost: UnicodeString; const wPath: UnicodeString; const UserAgent: UnicodeString = ''): Boolean;
var
  hSession: HINTERNET = nil;
  hConnect: HINTERNET = nil;
  hRequest: HINTERNET = nil;
  dwStatusCode: DWORD = 0;
  dwSize: DWORD;
begin
  Result := False;

  // Initialize WinHTTP session
  hSession := WinHttpOpen(  PWideChar(UserAgent),
                            WINHTTP_ACCESS_TYPE_DEFAULT_PROXY,
                            WINHTTP_NO_PROXY_NAME,
                            WINHTTP_NO_PROXY_BYPASS, 0);
  if not Assigned(hSession) then Exit;

  try
    // Connect to host
    hConnect := WinHttpConnect(hSession, PWideChar(wHost), INTERNET_DEFAULT_HTTPS_PORT, 0);
    if not Assigned(hConnect) then Exit;

    // Open request handle (HTTPS via WINHTTP_FLAG_SECURE)
    hRequest := WinHttpOpenRequest( hConnect, 'GET', PWideChar(wPath),
                                    nil, WINHTTP_NO_REFERER,
                                    WINHTTP_DEFAULT_ACCEPT_TYPES,
                                    WINHTTP_FLAG_SECURE);
    if not Assigned(hRequest) then Exit;

    // Send the request
    if WinHttpSendRequest(hRequest, WINHTTP_NO_ADDITIONAL_HEADERS, 0,
                          WINHTTP_NO_REQUEST_DATA, 0, 0, 0) then
    begin
      // Receive response
      if WinHttpReceiveResponse(hRequest, nil) then
      begin
        dwSize := SizeOf(dwStatusCode);
        // Query HTTP status code
        if WinHttpQueryHeaders( hRequest, WINHTTP_QUERY_STATUS_CODE or WINHTTP_QUERY_FLAG_NUMBER,
                                WINHTTP_HEADER_NAME_BY_INDEX, @dwStatusCode, @dwSize,
                                WINHTTP_NO_HEADER_INDEX) then
        begin
          if dwStatusCode = 200 then
            Result := True
          else if dwStatusCode = 404 then
            Result := False;
        end;
      end;
    end;

  finally
    // Cleanup handles
    if Assigned(hRequest) then WinHttpCloseHandle(hRequest);
    if Assigned(hConnect) then WinHttpCloseHandle(hConnect);
    if Assigned(hSession) then WinHttpCloseHandle(hSession);
  end;
end;          


end.