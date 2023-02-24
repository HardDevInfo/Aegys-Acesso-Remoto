unit uFormConexao;

{
   Aegys Remote Access Project.
  Criado por XyberX (Gilbero Rocha da Silva), o Aegys Remote Access Project tem como objetivo o uso de Acesso remoto
  Gratuito para utiliza��o de pessoas em geral.
   O Aegys Remote Access Project tem como desenvolvedores e mantedores hoje

  Membros do Grupo :

  XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
  Wendel Fassarela           - Devel and Admin
  Mobius One                 - Devel, Tester and Admin.
  Gustavo                    - Devel and Admin.
  Roniery                    - Devel and Admin.
  Alexandre Abbade           - Devel and Admin.
  e Outros como voc�, venha participar tamb�m.
}

interface

uses
  System.SysUtils, System.Types,       System.UITypes,            System.Classes,
  System.Variants, System.Actions,     System.Win.ScktComp,       System.Messaging,
  FMX.Types,       FMX.Controls,       Vcl.Forms,                 FMX.Dialogs,
  FMX.Edit,        FMX.Objects,        FMX.Controls.Presentation, FMX.Layouts,
  FMX.Ani,         FMX.TabControl,     FMX.ListBox, FMX.Menus,    FMX.StdCtrls,
  uAegysBase,      uAegysDataTypes,    uFunctions, CCR.Clipboard, windows, shellapi,
  Messages,        uSQLiteConfig,      uAegysConsts,              uAegysClientMotor,
  FireDAC.UI.Intf, FireDAC.FMXUI.Wait, FireDAC.Stan.Intf,         FireDAC.Comp.UI,
  FMX.Forms,       FMX.ActnList,       uAegysBufferPack,          FMX.Graphics;

type
  TFormConexao = class(TForm)
    lyHeader: TLayout;
    PhLogo: TPath;
    LSubTitle: TLabel;
    Layout2: TLayout;
    LTitle: TLabel;
    Layout3: TLayout;
    lyMachineID: TLayout;
    RMachineID: TRectangle;
    LlyMachineIDCaption: TLabel;
    LMachineID: TLabel;
    Layout6: TLayout;
    PhMachineIDCopy: TPath;
    sbMachineIDCopy: TSpeedButton;
    lyGuestID: TLayout;
    RGuestID: TRectangle;
    LlyGuestIDCaption: TLabel;
    Layout10: TLayout;
    EGuestID: TEdit;
    lyConnect: TLayout;
    btnConectar: TRoundRect;
    LbtnConectar: TLabel;
    aniBtnLogin: TFloatAnimation;
    ActionList1: TActionList;
    actConnect: TAction;
    lyStatus: TLayout;
    PhStatus: TPath;
    LStatus: TLabel;
    tmrIntervalo: TTimer;
    tmrClipboard: TTimer;
    actCopyID: TAction;
    actCopyPassword: TAction;
    Layout4: TLayout;
    sbPasteID: TSpeedButton;
    PhPasteID: TPath;
    actPasteID: TAction;
    LVersion: TLabel;
    phOptions: TPath;
    sbOptions: TSpeedButton;
    lyQuality: TLayout;
    rQuality: TRectangle;
    LlyResolutionCaption: TLabel;
    cbQuality: TComboBox;
    lyPassword: TLayout;
    RPassword: TRectangle;
    LlyPasswordCaption: TLabel;
    Layout8: TLayout;
    LPassword: TLabel;
    sbPasswordCopy: TSpeedButton;
    PhPasswordCopy: TPath;
    Pm_systemtray: TPopupMenu;
    MenuItem1: TMenuItem;
    TmrSystemTray: TTimer;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure actPasteIDExecute(Sender: TObject);
    procedure actConnectExecute(Sender: TObject);
    procedure actCopyIDExecute(Sender: TObject);
    procedure actCopyPasswordExecute(Sender: TObject);
    procedure tmrClipboardTimer(Sender: TObject);
    procedure tmrIntervaloTimer(Sender: TObject);
    procedure EGuestIDTyping(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sbOptionsClick(Sender: TObject);
    procedure TmrSystemTrayTimer(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure FormShow(Sender: TObject);
  private
    Position,
    MousePosX,
    MousePosY         : Integer;
    aPackList         : TPackList;
    Locale            : TLocale;
    aConnection,
    aMonitor,
    vOldClipboardFile,
    vOldClipboardText : String;
    TrayWnd           : HWND;
    TrayIconData      : TNotifyIconData;
    BInputsBlock,
    TrayIconAdded,
    vVisualizador,
    isvisible         : Boolean;
    SendDataThread,                       //Envio de Desktop
    SendCommandEvents : TAegysMotorThread;//Envio de Comandos
    Function  MascaraID              (AText,
                                      AMascara          : String) : String;
    procedure Translate;
    procedure SetColors;
    function  ClipboardGetAsFile                        : String;
    procedure TrayWndProc            (Var Message       : TMessage);
    procedure ShowAppOnTaskbar;
    procedure HideApponTaskbar;
    procedure SetTrayIcon;
    procedure OnBeforeConnect        (Sender            : TObject;
                                      Var WelcomeString : String);
    procedure OnConnect              (Sender            : TObject);
    procedure OnServerLogin          (Sender            : TObject);
    procedure OnDisconnect           (Sender            : TObject);
    procedure OnBeginTransactionError(Connection        : String);
    procedure OnBeginTransaction     (Connection        : String;
                                      Var ClientID,
                                      Alias             : String);
    procedure On�ncommingConnect     (Connection        : String;
                                      Var ClientID,
                                      ClientPassword,
                                      Alias             : String);
    procedure OnAccessGranted        (Connection        : String;
                                      Var ClientID,
                                      ClientPassword,
                                      Alias             : String);
    procedure OnPeerConnected        (Connection        : String;
                                      Var ClientID,
                                      ClientPassword,
                                      Alias             : String);
    procedure OnPeerDisconnected     (Connection        : String;
                                      Var ClientID,
                                      ClientPassword,
                                      Alias             : String);
    function  OnPulseData            (aPack             : TAegysBytes;
                                      CommandType       : TCommandType = tctScreenCapture): Boolean;
    procedure OnProcessData;
    procedure OnScreenCapture        (Connection,
                                      ID, Command       : String;
                                      aBuf              : TAegysBytes);
    procedure OnKeyboardCapture      (Connection,
                                      ID,
                                      Command           : String);
    procedure OnMouseCapture         (Connection,
                                      ID,
                                      Command           : String);
    procedure KillThreads;
    procedure ExecuteCommand         (aLine             : String);
  public
    Procedure Kick;
    procedure SetPeerDisconnected;
    procedure LimparConexao;
    procedure MudarStatusConexao     (AStatus           : Integer;
                                      AMensagem         : String);
    procedure SetOffline;
    procedure SetOnline;
    procedure SetSockets;
  end;

var
  FormConexao        : TFormConexao;
  Conexao            : TAegysClient;
  Bblockinput        : Boolean;
  vResolucaoLargura,
  vResolucaoAltura,
  CF_FILE            : Integer;
  mx, my             : Single;

const
  WM_ICONTRAY = WM_USER + 1;

implementation

{$R *.fmx}

uses uFormTelaRemota,  uFileTransfer,    uFormChat,        FMX.Clipboard,
     System.IOUtils,   System.Rtti,      uLibClass,        uConstants,
     BCrypt,           System.DateUtils, FMX.Platform.Win, uFormConfig,
     StreamManager,    uFormSenha,       uSendKeyClass;


Procedure TFormConexao.ExecuteCommand(aLine : String);
Var
 aTempID,
 BufferTemp     : String;
 InicioPalavra,
 TamanhoPalavra : Integer;
Begin
 If aLine.Contains(cShowMouse)    Then
  vMostrarMouse := True;
 If aLine.Contains(cHideMouse)    Then
  vMostrarMouse := False;
 If aLine.Contains(cBlockInput)   Then
  Begin
   BInputsBlock := True;
   Blockinput(BInputsBlock);
  End;
 If aLine.Contains(cUnBlockInput) Then
  Begin
   BInputsBlock := False;
   Blockinput(BInputsBlock);
  End;
 Position := Pos(cMousePos, aLine);
 If Position > 0 then
  Begin
   BufferTemp := aLine;
   Delete(BufferTemp, InitStrPos, Position + Length(cMousePos));
   Position := Pos(cSeparatorTag, BufferTemp);
   aTempID  := aMonitor;
   If Trim(aTempID) = '' Then
    aTempID := '0';
   MousePosX := Vcl.Forms.Screen.Monitors[StrToInt(aTempID)].Left + StrToInt(Copy(BufferTemp, InitStrPos, Position - 1));
   Delete(BufferTemp, InitStrPos, Position + 2);
   MousePosY := Vcl.Forms.Screen.Monitors[StrToInt(aTempID)].Top  + StrToInt(Copy(BufferTemp, InitStrPos, Pos(cEndTag, BufferTemp) - 1));
   If aLine.Contains(cBlockInput) then
    Begin
     BlockInput(False);
     SetCursorPos(MousePosX, MousePosY);
     ProcessMessages;
     BlockInput(True);
    End
   Else
    SetCursorPos(MousePosX, MousePosY);
  End;
 Position := Pos(cMouseClickLeftDown, aLine);
 If Position > 0 then
  Begin
   aTempID   := aMonitor;
   If Trim(aTempID) = '' Then
    aTempID := '0';
   BufferTemp := aLine;
   Delete(BufferTemp, InitStrPos, Position + Length(cMouseClickLeftDown));
   Position   := Pos(cSeparatorTag, BufferTemp);
   MousePosX  := Vcl.Forms.Screen.Monitors[StrToInt(aTempID)].Left + StrToInt(Copy(BufferTemp, InitStrPos, Position - 1));
   Delete(BufferTemp, 1, Position + 2);
   MousePosY := Vcl.Forms.Screen.Monitors[StrToInt(aTempID)].Top + StrToInt(Copy(BufferTemp, InitStrPos, Pos(cEndTag, BufferTemp) - 1));
   If aLine.Contains(cBlockInput) Then
    Begin
     BlockInput(false);
     SetCursorPos(MousePosX, MousePosY);
     Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
     ProcessMessages;
     BlockInput(true);
    End
   Else
    Begin
     SetCursorPos(MousePosX, MousePosY);
     Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
    End;
  End;
 Position := Pos(cMouseClickLeftUp, aLine);
 If Position > 0 then
  Begin
   aTempID   := aMonitor;
   If Trim(aTempID) = '' Then
    aTempID := '0';
   BufferTemp := aLine;
   Delete(BufferTemp, InitStrPos, Position + Length(cMouseClickLeftUp));
   Position := Pos(cSeparatorTag, BufferTemp);
   MousePosX := Vcl.Forms.Screen.Monitors[StrToInt(aTempID)].Left + StrToInt(Copy(BufferTemp, InitStrPos, Position - 1));
   Delete(BufferTemp, 1, Position + 2);
   MousePosY := Vcl.Forms.Screen.Monitors[StrToInt(aTempID)].Top + StrToInt(Copy(BufferTemp, InitStrPos, Pos(cEndTag, BufferTemp) - 1));
   If aLine.Contains(cBlockInput) then
    Begin
     BlockInput(false);
     SetCursorPos(MousePosX, MousePosY);
     Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
     ProcessMessages;
     blockinput(true);
    End
   Else
    Begin
     SetCursorPos(MousePosX, MousePosY);
     Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
    End;
  End;
 Position := Pos(cMouseClickRightDown, aLine);
 If Position > 0 Then
  Begin
   aTempID   := aMonitor;
   If Trim(aTempID) = '' Then
    aTempID := '0';
   BufferTemp := aLine;
   Delete(BufferTemp, InitStrPos, Position + Length(cMouseClickRightDown));
   Position := Pos(cSeparatorTag, BufferTemp);
   MousePosX := Vcl.Forms.Screen.Monitors[StrToInt(aTempID)].Left + StrToInt(Copy(BufferTemp, InitStrPos, Position - 1));
   Delete(BufferTemp, InitStrPos, Position + 2);
   MousePosY := Vcl.Forms.Screen.Monitors[StrToInt(aTempID)].Top + StrToInt(Copy(BufferTemp, InitStrPos, Pos(cEndTag, BufferTemp) - 1));
   If aLine.Contains(cBlockInput) Then
    Begin
     BlockInput(false);
     SetCursorPos(MousePosX, MousePosY);
     Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
     ProcessMessages;
     Blockinput(true);
    End
   Else
    Begin
     SetCursorPos(MousePosX, MousePosY);
     Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
    End;
  End;
 Position := Pos(cMouseClickRightUp, aLine);
 If Position > 0 Then
  Begin
   aTempID   := aMonitor;
   If Trim(aTempID) = '' Then
    aTempID := '0';
   BufferTemp := aLine;
   Delete(BufferTemp, InitStrPos, Position + Length(cMouseClickRightUp));
   Position := Pos(cSeparatorTag, BufferTemp);
   MousePosX := Vcl.Forms.Screen.Monitors[StrToInt(aTempID)].Left + StrToInt(Copy(BufferTemp, InitStrPos, Position - 1));
   Delete(BufferTemp, InitStrPos, Position + 2);
   MousePosY := Vcl.Forms.Screen.Monitors[StrToInt(aTempID)].Top + StrToInt(Copy(BufferTemp, InitStrPos, Pos(cEndTag, BufferTemp) - 1));
   If aLine.Contains(cBlockInput) then
    Begin
     BlockInput(false);
     SetCursorPos(MousePosX, MousePosY);
     Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
     ProcessMessages;
     BlockInput(true);
    End
   Else
    Begin
     SetCursorPos(MousePosX, MousePosY);
     Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
    End;
  End;
 Position := Pos(cMouseClickMiddleDown, aLine);
 If Position > 0 Then
  Begin
   aTempID   := aMonitor;
   If Trim(aTempID) = '' Then
    aTempID := '0';
   BufferTemp := aLine;
   Delete(BufferTemp, InitStrPos, Position + Length(cMouseClickMiddleDown));
   Position := Pos(cSeparatorTag, BufferTemp);
   MousePosX := Vcl.Forms.Screen.Monitors[StrToInt(aTempID)].Left + StrToInt(Copy(BufferTemp, InitStrPos, Position - 1));
   Delete(BufferTemp, InitStrPos, Position + 2);
   MousePosY := Vcl.Forms.Screen.Monitors[StrToInt(aTempID)].Top + StrToInt(Copy(BufferTemp, InitStrPos,  Pos(cEndTag, BufferTemp) - 1));
   If aLine.Contains(cBlockInput) Then
    Begin
     BlockInput(false);
     SetCursorPos(MousePosX, MousePosY);
     Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MIDDLEDOWN, 0, 0, 0, 0);
     ProcessMessages;
     BlockInput(true);
    End
   Else
    Begin
     SetCursorPos(MousePosX, MousePosY);
     Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MIDDLEDOWN, 0, 0, 0, 0);
    End;
  End;
 Position := Pos(cMouseClickMiddleUp, aLine);
 If Position > 0 Then
  Begin
   aTempID   := aMonitor;
   If Trim(aTempID) = '' Then
    aTempID := '0';
   BufferTemp := aLine;
   Delete(BufferTemp, InitStrPos, Position + Length(cMouseClickMiddleUp));
   Position := Pos(cSeparatorTag, BufferTemp);
   MousePosX := Vcl.Forms.Screen.Monitors[StrToInt(aTempID)].Left + StrToInt(Copy(BufferTemp, InitStrPos, Position - 1));
   Delete(BufferTemp, InitStrPos, Position + 2);
   MousePosY := Vcl.Forms.Screen.Monitors[StrToInt(aTempID)].Top  + StrToInt(Copy(BufferTemp, InitStrPos, Pos(cEndTag, BufferTemp) - 1));
   If aLine.Contains(cBlockInput) Then
    Begin
     BlockInput(false);
     SetCursorPos(MousePosX, MousePosY);
     Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MIDDLEUP, 0, 0, 0, 0);
     ProcessMessages;
     BlockInput(true);
    End
   Else
    Begin
     SetCursorPos(MousePosX, MousePosY);
     Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MIDDLEUP, 0, 0, 0, 0);
    End;
  End;
 Position := Pos(cWheelMouse, aLine);
 If Position > 0 then
  Begin
   BufferTemp := aLine;
   Delete(BufferTemp, InitStrPos, Position + Length(cWheelMouse));
   BufferTemp := Copy(BufferTemp, InitStrPos, Pos(cEndTag, BufferTemp) - 1);
   If aLine.Contains(cBlockInput) Then
    Begin
     BlockInput(false);
     Mouse_Event(MOUSEEVENTF_WHEEL, 0, 0, DWORD(StrToInt(BufferTemp)), 0);
     ProcessMessages;
     BlockInput(true);
    End
   Else
    Mouse_Event(MOUSEEVENTF_WHEEL, 0, 0, DWORD(StrToInt(BufferTemp)), 0);
  End;
 Bblockinput := aLine.Contains(cBlockInput);
 If Bblockinput Then
  Begin
   InicioPalavra  := pos(cBlockInput, aLine);
   TamanhoPalavra := Length(cBlockInput);
   If InicioPalavra > 0          Then
    Delete(aLine, InicioPalavra, TamanhoPalavra);
   BlockInput(false);
  End;
 If aLine.Contains(cAltDown)     Then
  Begin
   aLine := StringReplace(aLine, cAltDown, '', [rfReplaceAll]);
   keybd_event(18, 0, 0, 0);
  End;
 If aLine.Contains(cAltUp)       Then
  Begin
   aLine := StringReplace(aLine, cAltUp, '', [rfReplaceAll]);
   keybd_event(18, 0, KEYEVENTF_KEYUP, 0);
  End;
 If aLine.Contains(cCtrlDown)    Then
  Begin
   aLine := StringReplace(aLine, cCtrlDown, '', [rfReplaceAll]);
   keybd_event(17, 0, 0, 0);
  End;
 If aLine.Contains(cCtrlUp) Then
  Begin
   aLine := StringReplace(aLine, cCtrlUp, '', [rfReplaceAll]);
   keybd_event(17, 0, KEYEVENTF_KEYUP, 0);
  End;
 If aLine.Contains(cShiftDown) then
  Begin
   aLine := StringReplace(aLine, cShiftDown, '', [rfReplaceAll]);
   keybd_event(16, 0, 0, 0);
  End;
 If aLine.Contains(cShiftUp) then
  Begin
   aLine := StringReplace(aLine, cShiftUp, '', [rfReplaceAll]);
   keybd_event(16, 0, KEYEVENTF_KEYUP, 0);
  End;
 If aLine.Contains('?') Then
  Begin
   If GetKeyState(VK_SHIFT) < 0 Then
    Begin
     keybd_event(16, 0, KEYEVENTF_KEYUP, 0);
     SendKeys(PWideChar(aLine), False);
     keybd_event(16, 0, 0, 0);
    End;
  End
 Else
  SendKeys(PWideChar(aLine), False);
 BlockInput(Bblockinput);
End;

Procedure TFormConexao.LimparConexao;
Begin
  vResolucaoLargura := 986;
  vResolucaoAltura  := 600;
  vVisualizador     := False;
  vOldClipboardText := '';
  If Assigned(FormTelaRemota) Then
   FreeAndNil(FormTelaRemota);
  If Assigned(fFileTransfer) Then
   FreeAndNil(fFileTransfer);
  If Assigned(FormChat) Then
   FreeAndNil(FormChat);
End;

Procedure TFormConexao.tmrClipboardTimer(Sender: TObject);
Var

  FileStream: TFileStream;
  s, FileName: string;
  ClipFormat: TClipboardFormat;
  aFileStream : TAegysBytes;
Begin
  tmrClipboard.Enabled := vVisualizador;
  try

    if Clipboard.HasText then
    begin
      if (vOldClipboardText <> Clipboard.AsText) Then
      Begin
        vOldClipboardText := Clipboard.AsText;
        Conexao.SendMessage(EGuestID.Text, '<|CLIPBOARD|>' + vOldClipboardText + '<|END|>', tctClipBoard);
      End;
    end
    else
    begin
      for s in Clipboard.GetFileNames do
      begin
        if s <> '' then
          if (vOldClipboardFile <> s) And (FileExists(s)) Then
          begin
            FileStream := TFileStream.Create(s, fmOpenRead);
            Try
             FileName := ExtractFileName(s);
             vOldClipboardFile := s;
             Conexao.SendMessage(EGuestID.Text, '<|DIRECTORYTOSAVE|>' + FileName + '<|><|SIZE|>' + intToStr(FileStream.Size) + '<|END|>', tctFileTransfer);
             FileStream.Position := 0;
             FileStream.Read(aFileStream, FileStream.Size);
             Conexao.SendBytes(EGuestID.Text, aFileStream);
             Processmessages;
            Finally
             SetLength(aFileStream, 0);
             FreeAndNil(FileStream);
            End;
          end;
      end;
    end;
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;

end;

procedure TFormConexao.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(Conexao) then
    FreeAndNil(Conexao);
  Application.Terminate;
end;

procedure TFormConexao.FormCreate(Sender: TObject);
var
  CFG: TSQLiteConfig;
begin
  CF_FILE := RegisterClipboardFormat('FileName');
  // inicializando os objetos
  Locale := TLocale.Create;
  Conexao := TAegysClient.Create(Self);
  // --------------------------
  SetColors;
  SetOffline;
  Translate;
  isvisible := True;
  // load confg
  CFG := TSQLiteConfig.Create;
  try
    lyGuestID.Visible := not StrToIntDef(CFG.getValue(QUICK_SUPPORT), 0)
      .ToBoolean;
    lyConnect.Visible := not StrToIntDef(CFG.getValue(QUICK_SUPPORT), 0)
      .ToBoolean;
    lyQuality.Visible := not StrToIntDef(CFG.getValue(QUICK_SUPPORT), 0)
      .ToBoolean;
  finally
    CFG.DisposeOf;
  end;
 aPackList         := TPackList.Create;
 SendDataThread    := Nil;
 SendCommandEvents := Nil;
 Position          := 0;
 MousePosX         := 0;
 MousePosY         := 0;
end;

procedure TFormConexao.FormDestroy(Sender: TObject);
begin
 FreeAndNil(aPackList);
 Locale.DisposeOf;
end;

procedure TFormConexao.FormMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Single);
begin
  mx := X;
  my := Y;
end;

procedure TFormConexao.FormShow(Sender: TObject);
var
  CFG: TSQLiteConfig;
begin
  CFG := TSQLiteConfig.Create;
  try
    if StrToIntDef(CFG.getValue(ENABLE_SYSTRAY), 0).ToBoolean then
      if isvisible then
        SetTrayIcon;
  finally
    CFG.DisposeOf;
  end;
end;

procedure TFormConexao.HideApponTaskbar;
var
  hAppWnd: HWND;
  ExStyle: LONG_PTR;
begin
  hAppWnd := FMX.Platform.Win.ApplicationHWND();
  ShowWindow(hAppWnd, SW_HIDE);
  ExStyle := GetWindowLongPtr(hAppWnd, GWL_EXSTYLE);
  SetWindowLongPtr(hAppWnd, GWL_EXSTYLE, (ExStyle and WS_EX_APPWINDOW) or
    WS_EX_TOOLWINDOW);
  // ShowWindow(hAppWnd, SW_SHOW);
end;

function TFormConexao.MascaraID(AText, AMascara: string): string;
var
  i: Integer;
begin
  for i := 1 to Length(AText) do
  begin
    if (AMascara[i] = '9') and not(AText[i] in ['0' .. '9']) and
      (Length(AText) = Length(AMascara) + 1) then
      Delete(AText, i, 1);
    if (AMascara[i] <> '9') and (AText[i] in ['0' .. '9']) then
      Insert(AMascara[i], AText, i);
  end;
  Result := AText;
end;

procedure TFormConexao.MudarStatusConexao(AStatus: Integer; AMensagem: string);
var
  cColor: TAlphaColor;
begin
  case AStatus of
    1:
      cColor := TAlphaColorRec.Yellow;
    2:
      cColor := $FFED3237;
    3:
      cColor := TAlphaColorRec.Mediumseagreen;
  end;
  PhStatus.Fill.Color := cColor;
  PhStatus.Tag := AStatus;
  LStatus.Text := AMensagem;
//  SetOnline;
end;

procedure TFormConexao.sbOptionsClick(Sender: TObject);
begin
  Application.CreateForm(TfConfig, fConfig);
  fConfig.show;
  fConfig.CallBackConfig := Translate;
end;

procedure TFormConexao.actPasteIDExecute(Sender: TObject);
begin
  EGuestID.Text := MascaraID(TRDLib.ColarTexto, '99-999-999');
  EGuestID.GoToTextEnd;
end;

function TFormConexao.ClipboardGetAsFile: string;
var
  Data: THandle;
begin
  Clipboard.Open;
  Data := GetClipboardData(CF_FILE);
  try
    if Data <> 0 then
      Result := PChar(GlobalLock(Data))
    else
      Result := '';
  finally
    if Data <> 0 then
      GlobalUnlock(Data);
    Clipboard.Close;
  end;
end;

procedure TFormConexao.actConnectExecute(Sender: TObject);
begin
  If LbtnConectar.Enabled Then
  Begin
    If not(LlyGuestIDCaption.Text = '   -   -   ') then
    begin
      if (LlyGuestIDCaption.Text = Conexao.SessionID) then
        MessageBox(0, Locale.GetLocaleDlg(DLGS, 'ErrorSelfConnect'),
          Locale.GetLocaleDlg(DLGS, 'RemoteSupport'),
          MB_ICONASTERISK + MB_TOPMOST)
      else
      begin
        LbtnConectar.Enabled := False;
        Conexao.SendCommand(cFindID + EGuestID.Text);
        btnConectar.Enabled := False;
        MudarStatusConexao(1, Locale.GetLocale(MSGS, 'SearchingID'));
      end;
    end;
  End;
end;

procedure TFormConexao.actCopyIDExecute(Sender: TObject);
begin
  TRDLib.CopiarTexto(LMachineID.Text);
end;

procedure TFormConexao.actCopyPasswordExecute(Sender: TObject);
begin
  TRDLib.CopiarTexto(LPassword.Text)
end;

procedure TFormConexao.Translate;
begin
  self.Caption := Locale.GetLocale(FRMS, 'MainTitle');
  LSubTitle.Text := Locale.GetLocale(FRMS, 'MainSubTitle');
  LVersion.Text := Format(Locale.GetLocale(MAIN, 'Version'),
    [TRDLib.GetAppVersionStr]);
  LlyMachineIDCaption.Text := Locale.GetLocale(FRMS, 'MainMachineID');
  LlyPasswordCaption.Text := Locale.GetLocale(FRMS, 'MainPassword');
  LlyGuestIDCaption.Text := Locale.GetLocale(FRMS, 'MainGuestID');
  LlyResolutionCaption.Text := Locale.GetLocale(FRMS, 'MainResolution');
  LbtnConectar.Text := Locale.GetLocale(FRMS, 'MainConnectButton');
  Locale.GetLocale(cbQuality, tcbQuality);
  SetSockets;

end;

procedure TFormConexao.TrayWndProc(var Message: TMessage);
begin
  if Message.MSG = WM_ICONTRAY then
  begin
    case Message.LParam of
      WM_LBUTTONDOWN:
        begin
          if not isvisible then
            self.show; // If u use some frmMain.hide
          SetForegroundWindow(FmxHandleToHWND(FormConexao.Handle));
          if TrayIconAdded then
          begin
            // Shell_NotifyIcon(NIM_DELETE, @TrayIconData);
            TrayIconAdded := False;
            ShowAppOnTaskbar;
          end;
        end;
      // WM_RBUTTONDOWN: ShowMessage('RolePlay , but can be a PopUpMenu');
    end;
  end
  else
    Message.Result := DefWindowProc(TrayWnd, Message.MSG, Message.WParam,
      Message.LParam);
end;

procedure TFormConexao.SetColors;
begin
  RGuestID.Fill.Color := SECONDARY_COLOR;
  RMachineID.Fill.Color := SECONDARY_COLOR;
  rQuality.Fill.Color := SECONDARY_COLOR;
  RPassword.Fill.Color := SECONDARY_COLOR;
  PhLogo.Fill.Color := PRIMARY_COLOR;
  phOptions.Fill.Color := PRIMARY_COLOR;
  btnConectar.Fill.Color := PRIMARY_COLOR;
end;

procedure TFormConexao.SetOffline;
begin
  LMachineID.Text      := Locale.GetLocale(MSGS, 'Offline');
  LPassword.Text       := LMachineID.Text;
  btnConectar.Enabled  := False;
  LbtnConectar.Enabled := btnConectar.Enabled;
  tmrIntervalo.Enabled := False;
  tmrClipboard.Enabled := False;
  MudarStatusConexao(1, 'Offline');
end;


Procedure TFormConexao.Kick;
Begin
 Conexao.DisconnectAllPeers;
End;

Procedure TFormConexao.KillThreads;
Begin
 If Assigned(SendDataThread) Then //Thread da Area de Trabalho
  Begin
   Try
    SendDataThread.Kill;
   Except
   End;
   {$IFDEF FPC}
    WaitForThreadTerminate(SendDataThread.Handle, 100);
   {$ELSE}
    {$IF Not Defined(HAS_FMX)}
     WaitForSingleObject  (SendDataThread.Handle, 100);
    {$IFEND}
   {$ENDIF}
   FreeAndNil(SendDataThread);
  End;
 If Assigned(SendCommandEvents) Then //Thread de Comandos
  Begin
   Try
    SendCommandEvents.Kill;
   Except
   End;
   {$IFDEF FPC}
    WaitForThreadTerminate(SendCommandEvents.Handle, 100);
   {$ELSE}
    {$IF Not Defined(HAS_FMX)}
     WaitForSingleObject  (SendCommandEvents.Handle, 100);
    {$IFEND}
   {$ENDIF}
   FreeAndNil(SendCommandEvents);
  End;
End;

procedure TFormConexao.SetPeerDisconnected;
begin
  Kick;
  KillThreads;
  btnConectar.Enabled  := True;
  LbtnConectar.Enabled := btnConectar.Enabled;
  tmrIntervalo.Enabled := False;
  tmrClipboard.Enabled := False;
  MudarStatusConexao(1, 'Peer Disconnected');
end;

procedure TFormConexao.SetOnline;
begin
  LMachineID.Text      := Conexao.SessionID;
  LPassword.Text       := Conexao.SessionPWD;
  btnConectar.Enabled  := True;
  LbtnConectar.Enabled := btnConectar.Enabled;
  MudarStatusConexao(3, 'Online');
end;

Function SerialNumHardDisk(FDrive : String): String;
Var
 Serial,
 DirLen,
 Flags   : DWORD;
 DLabel  : Array [0 .. 11] of Char;
Begin
 Try
  GetVolumeInformation(PChar(Copy(FDrive, 1, 1) + ':\'), DLabel, 12, @Serial, DirLen, Flags, nil, 0);
  Result := IntToHex(Serial, 8);
 Except
  Result := '';
 End;
End;

Function MacAddress : String;
Var
 Lib    : Cardinal;
 Func   : Function(GUID: PGUID): longint; Stdcall;
 GUID1,
 GUID2  : TGUID;
Begin
 Result := '';
 Lib := LoadLibrary('rpcrt4.dll');
 If Lib <> 0 Then
  Begin
   @Func := GetProcAddress(Lib, 'UuidCreateSequential');
   If assigned(Func) Then
    Begin
     If (Func(@GUID1) = 0) And
        (Func(@GUID2) = 0) And
        (GUID1.D4[2] = GUID2.D4[2]) And
        (GUID1.D4[3] = GUID2.D4[3]) And
        (GUID1.D4[4] = GUID2.D4[4]) And
        (GUID1.D4[5] = GUID2.D4[5]) And
        (GUID1.D4[6] = GUID2.D4[6]) And
        (GUID1.D4[7] = GUID2.D4[7]) Then
      Result := IntToHex(GUID1.D4[2], 2) + '-' +
                IntToHex(GUID1.D4[3], 2) + '-' +
                IntToHex(GUID1.D4[4], 2) + '-' +
                IntToHex(GUID1.D4[5], 2) + '-' +
                IntToHex(GUID1.D4[6], 2) + '-' +
                IntToHex(GUID1.D4[7], 2);
    End;
  End;
End;

Procedure TFormConexao.OnBeforeConnect(Sender            : TObject;
                                       Var WelcomeString : String);
Var
 vDrive : String;
Begin
 vDrive        := Uppercase(Copy(ParamStr(0), 1, 1));
 Welcomestring := MacAddress + '|' + SerialNumHardDisk(vDrive);
End;

procedure TFormConexao.OnServerLogin(Sender: TObject);
begin
 SetOnline;
end;

procedure TFormConexao.OnConnect(Sender: TObject);
begin
 //SetOnline;
end;

procedure TFormConexao.OnBeginTransaction(Connection        : String;
                                          Var ClientID,
                                          Alias             : String);
Begin
 If Not Assigned(FormSenha) Then
  FormSenha := TFormSenha.Create(Self);
 FormSenha.Showmodal;
End;

procedure TFormConexao.OnBeginTransactionError(Connection : String);
Begin
 SetOnline;
 MudarStatusConexao(2, Format('Id "%s" not found...', [Connection]));
End;

procedure TFormConexao.OnDisconnect(Sender: TObject);
begin
 SetOffline;
end;

Procedure TFormConexao.OnKeyboardCapture (Connection,
                                          ID,
                                          Command           : String);
Begin
 OnMouseCapture(Connection, ID, Command);
End;

Procedure TFormConexao.OnMouseCapture    (Connection,
                                          ID,
                                          Command           : String);
Begin
 ExecuteCommand(Command);
End;

Procedure TFormConexao.On�ncommingConnect(Connection        : String;
                                          Var ClientID,
                                          ClientPassword,
                                          Alias             : String);
Begin
 MudarStatusConexao(1, Format('�ncommingConnect "%s"...', [Connection]));
End;

Function TFormConexao.OnPulseData(aPack       : TAegysBytes;
                                  CommandType : TCommandType = tctScreenCapture) : Boolean;
Begin
 Result := Conexao.Active;
 If Result Then
  Begin
   If CommandType = tctScreenCapture Then
    Conexao.SendBytes(aConnection, aPack, CommandType)
   Else
    Conexao.SendCommand(aConnection, aPack);
  End;
 Processmessages;
End;

Procedure TFormConexao.OnProcessData;
Var
 aPackClass  : TPackClass;
 aBytes      : TAegysBytes;
 aScreenShot : TStream;
 Function aCapture : TStream;
 Begin
  Result := TMemoryStream.Create;
  Try
   GetScreenToMemoryStream(True, TMemoryStream(Result));
  Finally
   Result.Position := 0;
  End;
 End;
Begin
 aScreenShot             := aCapture;
 Try
  SetLength(aBytes, aScreenShot.Size);
  aScreenShot.Read(aBytes[0], Length(aBytes));
  Conexao.SendBytes(aBytes, True);
  Processmessages;
 Finally
  FreeAndNil(aScreenShot);
 End;
End;

Procedure TFormConexao.OnAccessGranted(Connection        : String;
                                       Var ClientID,
                                       ClientPassword,
                                       Alias             : String); //tela remota
Begin
 Try
  If Not Assigned(FormTelaRemota) Then
   FormTelaRemota                 := TFormTelaRemota.Create(Self);
  FormTelaRemota.Caption          := Format(cCaptureTitle, [Connection, ClientID]);
  FormTelaRemota.Connection       := Connection;
  aConnection                     := FormTelaRemota.Connection;
  FormTelaRemota.Show;
  SendCommandEvents               := TAegysMotorThread.Create(FormTelaRemota.aPackList);
  SendCommandEvents.OnPulseData   := OnPulseData;
  SendCommandEvents.Resume;
 Finally

 End;
End;

Procedure TFormConexao.OnPeerConnected(Connection        : String;
                                       Var ClientID,
                                       ClientPassword,
                                       Alias             : String); //Captura de tela
Begin
 SendDataThread                := TAegysMotorThread.Create(aPackList);
 aConnection                   := Connection;
 Try
  SendDataThread.OnProcessData := OnProcessData;
  SendDataThread.OnPulseData   := OnPulseData;
  SendDataThread.Resume;
 Finally

 End;
End;

Procedure TFormConexao.OnPeerDisconnected(Connection        : String;
                                          Var ClientID,
                                          ClientPassword,
                                          Alias             : String); //Captura de tela
Begin
 SetPeerDisconnected;
End;

Procedure TFormConexao.OnScreenCapture(Connection,
                                       ID,
                                       Command         : String;
                                       aBuf            : TAegysBytes);
Var
 vStream : TMemoryStream;
Begin
 If Assigned(FormTelaRemota) Then
  Begin
   vStream := TMemoryStream.Create;
   Try
    vStream.Write(aBuf[0], Length(aBuf));
    vStream.Position := 0;
    FormTelaRemota.imgTelaRemota.Fill.Bitmap.Bitmap.LoadFromStream(vStream);
   Finally
    FreeAndNil(vStream);
   End;
  End;
End;

Procedure TFormConexao.SetSockets;
Var
 CFG : TSQLiteConfig;
 host : string;
Begin
 CFG := TSQLiteConfig.Create;
 Try
  If SERVIDOR <> '' Then
   host := SERVIDOR
  Else
   host := iif(CFG.getValue(SERVER) = '', '0.0.0.0', CFG.getValue(SERVER));
  Conexao.Disconnect;
  Conexao.OnBeforeConnect         := OnBeforeConnect;
  Conexao.OnConnect               := OnConnect;
  Conexao.OnDisconnect            := OnDisconnect;
  Conexao.OnServerLogin           := OnServerLogin;
  Conexao.OnBeginTransactionError := OnBeginTransactionError;
  Conexao.OnBeginTransaction      := OnBeginTransaction;
  Conexao.On�ncommingConnect      := On�ncommingConnect;
  Conexao.OnAccessGranted         := OnAccessGranted;
  Conexao.OnPeerConnected         := OnPeerConnected;
  Conexao.OnPeerDisconnected      := OnPeerDisconnected;
  Conexao.OnScreenCapture         := OnScreenCapture;
  Conexao.OnKeyboardCapture       := OnKeyboardCapture;
  Conexao.OnMouseCapture          := OnMouseCapture;
  Conexao.Host                    := Host;
  Conexao.Port                    := PORTA;
  Sleep(FOLGAPROCESSAMENTO);
  Conexao.Connect;
 Finally
  CFG.DisposeOf;
 End;
End;

procedure TFormConexao.SetTrayIcon;
begin
  HideApponTaskbar;
  TrayWnd := AllocateHWnd(TrayWndProc); // Alocate the wndProc
  with TrayIconData do
  begin // Instaciate
    cbSize := SizeOf;
    Wnd := TrayWnd;
    uID := 1;
    uFlags := NIF_MESSAGE + NIF_ICON + NIF_TIP;
    uCallbackMessage := WM_ICONTRAY;
    hIcon := GetClassLong(FmxHandleToHWND(self.Handle), GCL_HICONSM);
    StrPCopy(szTip, 'Aegys Remote Acess');
  end;
  // creating the icon
  if not TrayIconAdded then
    TrayIconAdded := Shell_NotifyIcon(NIM_ADD, @TrayIconData);
  if self.Visible then
  begin
    self.Hide;
    isvisible := False;
  end;
end;

procedure TFormConexao.ShowAppOnTaskbar;
var
  hAppWnd: HWND;
  ExStyle: LONG_PTR;
begin
  hAppWnd := FMX.Platform.Win.ApplicationHWND();
  ShowWindow(hAppWnd, SW_HIDE);
  ExStyle := GetWindowLongPtr(hAppWnd, GWL_EXSTYLE);
  SetWindowLongPtr(hAppWnd, GWL_EXSTYLE, (ExStyle and WS_EX_TOOLWINDOW) or
    WS_EX_APPWINDOW);
  ShowWindow(hAppWnd, SW_SHOW);
end;

procedure TFormConexao.TmrSystemTrayTimer(Sender: TObject);
begin
  // TmrSystemTray.Enabled := False;
  // if systemtray then
  // self.Hide;
end;

procedure TFormConexao.EGuestIDTyping(Sender: TObject);
begin
  TEdit(Sender).Text := MascaraID(TEdit(Sender).Text, '99-999-999');
  TEdit(Sender).GoToTextEnd;
end;

Procedure TFormConexao.tmrIntervaloTimer(Sender: TObject);
Begin
 If (Conexao.SessionTime > INTERVALOCONEXAO) Then
  Begin
   If (FormTelaRemota.Visible) Then
    FormTelaRemota.Close
   Else
    Begin
     SetOffline;
     Conexao.Disconnect;
     SetSockets;
    End;
  End;
 Conexao.SessionTime := Conexao.SessionTime + 1;
End;

end.
