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
  Provides utilities for managing a separate-thread console input/output interface.

  This unit implements the @link(TConsoleReaderThread) class,
  which runs a separate thread to handle console input (stdin)
  and provides methods for writing to the console (stdout).
  It is designed to allow visual applications (like TForms) to interact with a background console.
}
unit ConsoleUnit;

{$mode objfpc}{$H+}{$J-}{$R+}

interface

uses
  Classes, SysUtils, DateUtils, Forms,
  Windows, Crt;


type
  {*
    Interface to handle console input received by the worker thread.
    Components wishing to receive user input from the console managed by @link(TConsoleReaderThread) must implement this interface.
  }
  IConsoleInputHandler = interface
    ['{A1F9D607-9CCA-4E4B-9E93-0A2F45B6171A}']
    {*
      Executes when a full line of input is read from the console.
      This procedure is typically queued to execute in the context of the main VCL/Lazarus thread.
      @param(S The line of text read from the console's standard input.)
    }
    procedure ConsoleInputExecute(const S: string);
  end;


type
  {* Specifies the log level for console messages. }
  TLevelLog = (csNoticeLog, csWarningLog, csErrorLog, csInfoLog, csDebugLog, csLog);

type
  {* Array type for mapping @link(TLevelLog) to strings. }
  TLevelLogArray = array[TLevelLog] of String;
const
  {*
    String representations for @link(TLevelLog) values.
    Used primarily in the log entry formatting by @link(TConsoleReaderThread.CSWriteLogEntryUTC).
  }
  LevelLogArray: TLevelLogArray = ('Notice', 'Warning', 'Error', 'Info', 'Debug', 'Log');
              
type
  TConsolePosMode = (cpmDefault, cpmFollowMain, cpmSpecificMonitor);





type
  {*
    A thread class dedicated to creating and managing a separate Windows console for input/output.
    The thread continuously monitors the console's standard input (stdin)
    and delivers received lines to the @link(Owner) using the @link(IConsoleInputHandler) interface.
  }
  TConsoleReaderThread = class(TThread)
  private
    {* Reference to the component implementing @link(IConsoleInputHandler). }
    FOwner: IConsoleInputHandler;
    {* The last line read from the console input. }
    FLine: string;
    {* The handle to the console's standard input (CONIN$). }
    FStdInHandle: THandle;

    {* Flag indicating whether console output should be stored. }
    FStoreText: Boolean;
    {* Stores console output if @link(FStoreText) is True. }
    FStoredText: String;

    {* Flag to block console writing when set to True. }
    FBlockWrite: Boolean;
    {*
      Queues the delivery of the input line to the owner.
      Uses @link(TThread.Queue) to execute @link(IConsoleInputHandler.ConsoleInputExecute) safely in the main thread.
    }
    procedure DeliverLine;

  protected
    {* The handle to the console's standard input. Used internally during initialization. }
    StdInHandle: THandle;

    {*
      The main execution loop of the thread.
      Allocates the console, sets up standard I/O handles, and continuously calls @code(ReadConsole()) to capture user input.
    }
    procedure Execute; override;

  public
    {* Reference to the component implementing @link(IConsoleInputHandler). }
    property Owner: IConsoleInputHandler read FOwner;
    {*
      Initializes the console environment.
      Calls @code(AllocConsole) and sets up the standard input, output, and error handles.
      Platform: Windows
    }

    procedure CSInit;
    {*
      Writes the specified string to the console's standard output without a line break.
      @param S The string to write.
    }

    {*
      Sets whether console output is blocked.
      @param(ABlock If True, subsequent console write operations are ignored.)
    }
    procedure CSBlockWrite(const ABlock: Boolean);

    {*
      Checks if console output is currently blocked.
      @return True if console writing is blocked; otherwise, False.
    }
    function CSIsWriteBlocked: Boolean;

    {*
      Writes the specified string to the console's standard output without a line break.
      @param(S The string to write.)
    }
    procedure CSWrite(const S: string);

    {*
      Writes the specified string to the console's standard output followed by a line break.
      @param(S The string to write.)
    }

    procedure CSWriteLn(const S: string);

    {*
      Writes a string to the console and optionally displays an input prompt.
      This is the detailed overload, allowing control over prefix and prompt display.
      @param(S The message string to display before the input prompt.)
      @param(pre If True, prefixes the message with ': '.)
      @param(post If True, displays the input prompt '> ' after the message.)
    }
    procedure CSInput(const S: String; const pre: Boolean; const post: Boolean); overload;

    {*
      Writes a string to the console, prefixes it with ': ', and displays the input prompt '> '.
      Default overload for standard console interaction.
      @param(S The message string to display before the input prompt.)
    }
    procedure CSInput(const S: String); overload;

    {*
      Writes a timestamped log entry to the console using UTC time.
      @param(level The log level to use @link(TLevelLog).)
      @param(MessageString The log message content.)
    }
    procedure CSWriteLogEntryUTC(level: TLevelLog; const MessageString: String);

    {*
      Shows the console window.
      Platform: Windows
      @seeAlso(CSHide)
    }
    procedure CSShow; overload;

    {*
      Shows the console window.
      Platform: Windows
      @param(MainForm The main form to associate with the console window.)
      @seeAlso(CSHide)
    }
    procedure CSShow(MainForm: TForm); overload;

    {*
      Shows the console window.
      Platform: Windows
      @param(Mode The position mode for the console window.)
      @param(MainForm The main form to associate with the console window.)
      @param(MonitorIndex The index of the monitor to use for positioning the console window.)
      @seeAlso(CSHide)
    }
    procedure CSShow(Mode: TConsolePosMode; MainForm: TForm; MonitorIndex: Integer = 0); overload;

    {*
      Hides the console window.
      Platform: Windows
      @seeAlso(CSShow)
    }
    procedure CSHide;

    {*
      Disables the close button (X) on the console window's title bar.
      This prevents the user from closing the console using the standard window controls, allowing the managing application to control the console's lifecycle.
      Platform: Windows
      @seeAlso(CSEnableCloseButton)
      @note(TODO: Keyboard shortcuts for closing the console window are not yet implemented.)
    }
    procedure CSDisableCloseButton;

    {*
      Enables the close button (X) on the console window's title bar.
      Platform: Windows
      @seeAlso(CSDisableCloseButton)
    }
    procedure CSEnableCloseButton;

    {*
      Brings the console window to the foreground.
      Platform: Windows
    }
    procedure CSSetForegroundWindow;

    {*
      Logs a message with the specified log level.
      @param(level The log level to use @link(TLevelLog).)
      @param(Message The main log message.)
    }
    procedure MessageInfoLog(level: TLevelLog;  Message: String); overload;

    {*
      Logs a message with the specified log level and additional info.
      @param(level The log level to use @link(TLevelLog).)
      @param(Message The main log message.)
      @param(Info Additional information to include in the log entry.)
    }
    procedure MessageInfoLog(level: TLevelLog; Message: String; Info: String); overload;

    {*
      Logs a notice-level message.
      @param(Message The log message.)
    }
    procedure NoticeLog(Message: String); overload;

    {*
      Logs a notice-level message with additional info.
      @param(Message The main log message.)
      @param(Info Additional information to include in the log entry.)
    }
    procedure NoticeLog(Message: String; Info: String); overload;

    {*
      Logs a warning-level message.
      @param(Message The log message.)
    }
    procedure WarningLog(Message: String); overload;

    {*
      Logs a warning-level message with additional info.
      @param(Message The main log message.)
      @param(Info Additional information to include in the log entry.)
    }
    procedure WarningLog(Message: String; Info: String); overload;

    {*
      Logs an error-level message.
      @param(Message The log message.)
    }
    procedure ErrorLog(Message: String); overload;

    {*
      Logs an error-level message with additional info.
      @param(Message The main log message.)
      @param(Info Additional information to include in the log entry.)
    }
    procedure ErrorLog(Message: String; Info: String); overload;

    {*
      Logs an info-level message.
      @param(Message The log message.)
    }
    procedure InfoLog(Message: String); overload;

    {*
      Logs an info-level message with additional info.
      @param(Message The main log message.)
      @param(Info Additional information to include in the log entry.)
    }
    procedure InfoLog(Message: String; Info: String); overload;

    {*
      Logs a debug-level message.
      @param(Message The log message.)
    }
    procedure DebugLog(Message: String); overload;

    {*
      Logs a debug-level message with additional info.
      @param(Message The main log message.)
      @param(Info Additional information to include in the log entry.)
    }
    procedure DebugLog(Message: String; Info: String); overload;

    {*
      Logs a general message.
      @param(Message The log message.)
    }
    procedure Log(Message: String); overload;

    {*
      Logs a general message with additional info.
      @param(Message The main log message.)
      @param(Info Additional information to include in the log entry.)
    }
    procedure Log(Message: String; Info: String); overload;



    {*
      Creates and initializes the console reader thread without a preface message.
      @param(AOwner The object that implements @link(IConsoleInputHandler) to receive input.)
    }
    constructor Create(AOwner: IConsoleInputHandler); overload;

    {*
      Creates and initializes the console reader thread with an initial preface message.
      @param(AOwner The object that implements @link(IConsoleInputHandler) to receive input.)
      @param(Preface A string displayed at console startup.)
    }
    constructor Create(AOwner: IConsoleInputHandler; Preface: String); overload;

    {*
      Creates and initializes the console reader thread with a preface and option to store output.
      @param(AOwner The object that implements @link(IConsoleInputHandler) to receive input.)
      @param(Preface A string displayed at console startup.)
      @param(AStoreText If True, all console output is stored internally in @code(FStoredText).)
    }
    constructor Create(AOwner: IConsoleInputHandler; Preface: String; AStoreText: Boolean); overload;

    {*
      Destroys the thread and frees the console resource.
      Calls @code(FreeConsole) before inherited destruction.
    }
    destructor Destroy; override;
  end;



implementation



{ TConsoleReaderThread }

procedure TConsoleReaderThread.CSInit;
var
  hOut, hErr: THandle;
begin
  AllocConsole;

  hOut := CreateFile('CONOUT$', GENERIC_WRITE, FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
  if hOut <> INVALID_HANDLE_VALUE then
  begin
    SetStdHandle(STD_OUTPUT_HANDLE, hOut);
    AssignFile(Output, 'CONOUT$');
    Rewrite(Output);
  end;

  hErr := CreateFile('CONOUT$', GENERIC_WRITE, FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
  if hErr <> INVALID_HANDLE_VALUE then
  begin
    SetStdHandle(STD_ERROR_HANDLE, hErr);
    AssignFile(ErrOutput, 'CONOUT$');
    Rewrite(ErrOutput);
  end;

  StdInHandle := CreateFile('CONIN$', GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
  if StdInHandle <> INVALID_HANDLE_VALUE then
    SetStdHandle(STD_INPUT_HANDLE, StdInHandle);
end;



procedure TConsoleReaderThread.CSBlockWrite(const ABlock: Boolean);
begin
  FBlockWrite := ABlock;
end;



function TConsoleReaderThread.CSIsWriteBlocked: Boolean;
begin
  Result := FBlockWrite;
end;



procedure TConsoleReaderThread.CSWriteLn(const S: String);
begin
  if not FBlockWrite then
  begin
    WriteLn(S);
    Flush(Output);
  end;
  if FStoreText then
    FStoredText += S + LineEnding;
end;



procedure TConsoleReaderThread.CSWrite(const S: String);
begin
  if not FBlockWrite then
  begin
    Write(S);
    Flush(Output);
  end;
  if FStoreText then
    FStoredText += S;
end;



procedure TConsoleReaderThread.CSInput(const S: String; const pre: Boolean; const post: Boolean);
begin
  if not String.IsNullOrWhiteSpace(S) then
    if pre then
    begin
      CSWriteLn(': ' + S);
    end else
        CSWriteLn(S);
  if post then
    CSWrite('> ');
end;



procedure TConsoleReaderThread.CSInput(const S: String);
begin
  CSInput(S, True, True);
end;



procedure TConsoleReaderThread.CSWriteLogEntryUTC(level: TLevelLog; const MessageString: String);
var
  LocalDateTime: TDateTime;
  UTCDateTime: TDateTime;
  FormattedDateTime: String;
  Out: String;
begin
  LocalDateTime := Now;
  UTCDateTime := LocalTimeToUniversal(LocalDateTime);
  FormattedDateTime := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz"Z"', UTCDateTime);
  Out := '<' + FormattedDateTime + '> ['+ LevelLogArray[level] + '] ' + MessageString;

  CSInput(Out, False, True);
end;



procedure TConsoleReaderThread.CSShow;
var
  h: HWND;
begin
  h := GetConsoleWindow;
  if h <> 0 then
  begin
    ShowWindow(h, SW_SHOW);
  end;
end;



procedure TConsoleReaderThread.CSShow(MainForm: TForm);
var
  hConsole: HWND;
  ConsoleRect: TRect;
  Monitor: TMonitor;
  NewX, NewY: Integer;
  CW, CH: Integer;
begin
  hConsole := GetConsoleWindow;
  if hConsole <> 0 then
  begin
    ConsoleRect := Default(TRect);
    Monitor := Screen.MonitorFromWindow(MainForm.Handle);

    GetWindowRect(hConsole, ConsoleRect);
    CW := ConsoleRect.Right - ConsoleRect.Left;
    CH := ConsoleRect.Bottom - ConsoleRect.Top;

    //NewX := Monitor.Left + (Monitor.Width - CW) div 2;
    //NewY := Monitor.Top + (Monitor.Height - CH) div 2;
    // WorkareaRect per evitare la barra delle applicazioni
    NewX := Monitor.WorkareaRect.Left + (Monitor.WorkareaRect.Width - CW) div 2;
    NewY := Monitor.WorkareaRect.Top + (Monitor.WorkareaRect.Height - CH) div 2;

    SetWindowPos(hConsole, 0, NewX, NewY, 0, 0, SWP_NOSIZE or SWP_NOZORDER);

    ShowWindow(hConsole, SW_SHOW);
  end;
end;



procedure TConsoleReaderThread.CSShow(Mode: TConsolePosMode; MainForm: TForm; MonitorIndex: Integer = 0);
var
  hConsole: HWND;
  Monitor: TMonitor;
  R: TRect;
  NewX, NewY, CW, CH: Integer;
  TargetIndex: Integer;
begin
  R := Default(TRect);
  hConsole := GetConsoleWindow;
  if hConsole = 0 then Exit;

  if Mode = cpmDefault then
  begin
    ShowWindow(hConsole, SW_SHOW);
    Exit;
  end;

  if Mode = cpmFollowMain then
    Monitor := Screen.MonitorFromWindow(MainForm.Handle)
  else
  begin
    if (MonitorIndex >= 0) and (MonitorIndex < Screen.MonitorCount) then
      TargetIndex := MonitorIndex
    else
      TargetIndex := 0;

    Monitor := Screen.Monitors[TargetIndex];
  end;

  GetWindowRect(hConsole, R);
  CW := R.Right - R.Left;
  CH := R.Bottom - R.Top;

  NewX := Monitor.WorkareaRect.Left + (Monitor.WorkareaRect.Width - CW) div 2;
  NewY := Monitor.WorkareaRect.Top + (Monitor.WorkareaRect.Height - CH) div 2;

  SetWindowPos(hConsole, 0, NewX, NewY, 0, 0, SWP_NOSIZE or SWP_NOZORDER);
  ShowWindow(hConsole, SW_SHOW);
end;



procedure TConsoleReaderThread.CSHide;
var
  h: HWND;
begin
  h := GetConsoleWindow;
  if h <> 0 then
  begin
    ShowWindow(h, SW_HIDE);
  end;
end;



procedure TConsoleReaderThread.CSDisableCloseButton;
var
  h: HWND;
  hMenu: Windows.HMENU;
begin
  h := GetConsoleWindow;
  if h <> 0 then
  begin
    hMenu := GetSystemMenu(h, False);
    if hMenu <> 0 then
    begin
      DeleteMenu(hMenu, SC_CLOSE, MF_BYCOMMAND);
      DrawMenuBar(h);
    end;
  end;
end;



procedure TConsoleReaderThread.CSEnableCloseButton;
var
  h: HWND;
  hMenu: Windows.HMENU;
begin
  h := GetConsoleWindow;
  if h <> 0 then
  begin
    hMenu := GetSystemMenu(h, False);
    if hMenu <> 0 then
    begin
      EnableMenuItem(hMenu, SC_CLOSE, MF_BYCOMMAND or MF_ENABLED);
      DrawMenuBar(h);
    end;
  end;
end;



procedure TConsoleReaderThread.CSSetForegroundWindow;
var
  hConsoleWnd: THandle;
begin
  hConsoleWnd := GetConsoleWindow;
  if hConsoleWnd <> 0 then
    SetForegroundWindow(hConsoleWnd);
end;



procedure TConsoleReaderThread.MessageInfoLog(level: TLevelLog; Message: String);
begin
  CSWriteLogEntryUTC(level, '<' + Message + '>');
end;



procedure TConsoleReaderThread.MessageInfoLog(level: TLevelLog; Message: String;  Info: String);
begin
  CSWriteLogEntryUTC(level, '<' + Message + '>' + ' ' + Info);
end;



procedure TConsoleReaderThread.NoticeLog(Message: String);
begin
  MessageInfoLog(csDebugLog, Message);
end;



procedure TConsoleReaderThread.NoticeLog(Message: String; Info: String);
begin
  MessageInfoLog(csDebugLog, Message, Info);
end;



procedure TConsoleReaderThread.WarningLog(Message: String);
begin
  MessageInfoLog(csWarningLog, Message);
end;



procedure TConsoleReaderThread.WarningLog(Message: String; Info: String);
begin
  MessageInfoLog(csWarningLog, Message, Info);
end;



procedure TConsoleReaderThread.ErrorLog(Message: String);
begin
  MessageInfoLog(csErrorLog, Message);
end;



procedure TConsoleReaderThread.ErrorLog(Message: String; Info: String);
begin
  MessageInfoLog(csErrorLog, Message, Info);
end;



procedure TConsoleReaderThread.InfoLog(Message: String);
begin
  MessageInfoLog(csInfoLog, Message);
end;



procedure TConsoleReaderThread.InfoLog(Message: String; Info: String);
begin
  MessageInfoLog(csInfoLog, Message, Info);
end;



procedure TConsoleReaderThread.DebugLog(Message: String);
begin
  MessageInfoLog(csDebugLog, Message);
end;



procedure TConsoleReaderThread.DebugLog(Message: String; Info: String);
begin
  MessageInfoLog(csDebugLog, Message, Info);
end;



procedure TConsoleReaderThread.Log(Message: String);
begin
  MessageInfoLog(csLog, Message);
end;



procedure TConsoleReaderThread.Log(Message: String; Info: String);
begin
  MessageInfoLog(csLog, Message, Info);
end;



constructor TConsoleReaderThread.Create(AOwner: IConsoleInputHandler; Preface: String; AStoreText: Boolean);
begin
  inherited Create(False);

  FStoreText := AStoreText;
  FStoredText := '';

  StdInHandle := INVALID_HANDLE_VALUE;
  FreeOnTerminate := False;
  FOwner := AOwner;

  CSInit;

  if not String.IsNullOrWhiteSpace(Preface) then
    CSWriteLn(Preface);
  CSInput('');

  FStdInHandle := StdInHandle;

  CSDisableCloseButton;
end;



constructor TConsoleReaderThread.Create(AOwner: IConsoleInputHandler; Preface: String);
begin
  Create(AOwner, Preface, False);
end;


constructor TConsoleReaderThread.Create(AOwner: IConsoleInputHandler);
begin
  Create(AOwner, '');
end;



destructor TConsoleReaderThread.Destroy;
var
  LogPath: string;
  LogList: TStringList;
begin
  FreeConsole;

  if FStoreText and (FStoredText <> '') then
  begin
    LogPath := ExtractFilePath(ParamStr(0)) + 'console.log';   
    LogList := TStringList.Create;
    try
      LogList.Text := FStoredText;
      try
        LogList.SaveToFile(LogPath);
      except
        on E: Exception do
          ; // ignore
      end;
    finally
      LogList.Free;
    end;
  end;

  inherited Destroy;
end;



// TODO: seealso ReadConsoleInput in redef.inc
procedure TConsoleReaderThread.Execute;
var
  Buffer: array[0..1023] of Char;
  CharsRead: DWORD;
  S: string;
begin
  CharsRead := 0;
  Initialize(Buffer); // rtl
  Initialize(S); // rtl

  while (not Terminated) do
  begin
    if FStdInHandle = INVALID_HANDLE_VALUE then
      Break;

    FillChar(Buffer, SizeOf(Buffer), 0);

    if ReadConsole(FStdInHandle, @Buffer, Length(Buffer), CharsRead, nil) then
    begin
      if CharsRead > 0 then
      begin
        SetLength(S, CharsRead);
        Move(Buffer, S[1], CharsRead * SizeOf(Char));

        while (Length(S) > 0) and (S[Length(S)] in [#13, #10]) do
          SetLength(S, Length(S) - 1);

        if S <> '' then
        begin
          FLine := S;
          if not Terminated then
            TThread.Queue(Self, @DeliverLine);
        end
        else begin
          FLine := S;
          if not Terminated then
            TThread.Queue(Self, @DeliverLine);
        end;
      end;
    end
    else
    begin
      if GetLastError() = ERROR_INVALID_HANDLE then
        Break;
      Sleep(10);
      Continue;
    end;
  end;
end;



procedure TConsoleReaderThread.DeliverLine;
begin
  FOwner.ConsoleInputExecute(FLine);
end;



initialization


finalization


end.

