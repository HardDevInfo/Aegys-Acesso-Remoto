unit Form_ShareFiles;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes,
  System.Generics.Collections, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.ImgList, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons,
  System.ImageList,
  IdTCPClient, Vcl.Shell.ShellCtrls, uIconsAssoc, uFilesFoldersOP,
  uUDPSuperComponents;

Type
  TIconIndex = Packed Record
    Index: Integer;
    Extension: String;
  End;

Type
  TIconsIndex = Tlist;

type
  Tfrm_ShareFiles = class(TForm)
    ImageList1: TImageList;
    Menu_Panel: TPanel;
    UploadProgress_Label: TLabel;
    DownloadProgress_Label: TLabel;
    Upload_ProgressBar: TProgressBar;
    Download_ProgressBar: TProgressBar;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    SizeDownload_Label: TLabel;
    SizeUpload_Label: TLabel;
    ShareFiles_ListView: TListView;
    cbLocalDrivers: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    lNomeComputadorLocal: TLabel;
    Label3: TLabel;
    lNomeComputadorRemoto: TLabel;
    cbRemoteDrivers: TComboBox;
    Label5: TLabel;
    Download_BitBtn: TBitBtn;
    Upload_BitBtn: TBitBtn;
    lvShellTreeLocal: TListView;
    procedure FormShow(Sender: TObject);
    procedure Directory_EditKeyPress(Sender: TObject; var Key: Char);
    procedure ShareFiles_ListViewDblClick(Sender: TObject);
    procedure ShareFiles_ListViewKeyPress(Sender: TObject; var Key: Char);
    procedure Download_BitBtnClick(Sender: TObject);
    procedure Upload_BitBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure cbLocalDriversDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cbLocalDriversChange(Sender: TObject);
    procedure cbRemoteDriversDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cbRemoteDriversChange(Sender: TObject);
    procedure lvShellTreeLocalDblClick(Sender: TObject);
    procedure lvShellTreeLocalDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ShareFiles_ListViewDragOver(Sender, Source: TObject;
      X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure lvShellTreeLocalDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ShareFiles_ListViewDragDrop(Sender, Source: TObject;
      X, Y: Integer);
  private
    vFreeForClose: Boolean;
    vIconsIndex: TIconsIndex;
    ShellProps: TShellProps;
    vDirectory_Local, vDirectory_Edit: String;
    procedure WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo);
      message WM_GETMINMAXINFO;
    procedure GoToDirectory(Directory: String);
    procedure EnterInDirectory;
    Procedure EnterLocalDir;
    Procedure ChangeLocalDir;
    { Private declarations }
  public
    { Public declarations }
    FileStream: TFileStream;
    Function GetIcon(FileName: String): Integer;
    Procedure RenewDir;
    Property IconsIndex: TIconsIndex Read vIconsIndex;
    Property FreeForClose: Boolean Read vFreeForClose Write vFreeForClose;
    Property Directory_Edit: String Read vDirectory_Edit Write vDirectory_Edit;
  end;

Var
  frm_ShareFiles: Tfrm_ShareFiles;

implementation

{$R *.dfm}

Uses
  Form_Main, Form_RemoteScreen;

Function MemoryStreamToString(M: TMemoryStream): AnsiString;
Begin
  SetString(Result, PAnsiChar(M.Memory), M.Size);
End;

Procedure Tfrm_ShareFiles.cbLocalDriversChange(Sender: TObject);
begin
  If cbLocalDrivers.ItemIndex > -1 Then
  Begin
    ShellProps.Folder := Trim(cbLocalDrivers.Items[cbLocalDrivers.ItemIndex]);
    vDirectory_Local := ShellProps.Folder;
  End;
end;

Procedure Tfrm_ShareFiles.cbLocalDriversDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
Var
  ComboBox: TComboBox;
  bitmap: TBitmap;
Begin
  ComboBox := (Control as TComboBox);
  bitmap := TBitmap.Create;
  Try
    ImageList1.GetBitmap(2, bitmap);
    With ComboBox.Canvas Do
    Begin
      FillRect(Rect);
      If bitmap.Handle <> 0 Then
        Draw(Rect.Left + 2, Rect.Top, bitmap);
      Rect := Bounds(Rect.Left + ComboBox.ItemHeight + 2, Rect.Top,
        Rect.Right - Rect.Left, Rect.Bottom - Rect.Top);
      DrawText(Handle, PChar(ComboBox.Items[Index]),
        length(ComboBox.Items[index]), Rect, DT_VCENTER + DT_SINGLELINE);
    End;
  Finally
    bitmap.Free;
  End;
End;

Procedure Tfrm_ShareFiles.cbRemoteDriversChange(Sender: TObject);
begin
  If cbRemoteDrivers.ItemIndex > -1 Then
  Begin
    vDirectory_Edit := Trim(cbRemoteDrivers.Items[cbRemoteDrivers.ItemIndex]);
    GoToDirectory(vDirectory_Edit);
  End;
end;

Procedure Tfrm_ShareFiles.cbRemoteDriversDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
Var
  ComboBox: TComboBox;
  bitmap: TBitmap;
Begin
  ComboBox := (Control as TComboBox);
  bitmap := TBitmap.Create;
  Try
    ImageList1.GetBitmap(2, bitmap);
    With ComboBox.Canvas Do
    Begin
      FillRect(Rect);
      If bitmap.Handle <> 0 Then
        Draw(Rect.Left + 2, Rect.Top, bitmap);
      Rect := Bounds(Rect.Left + ComboBox.ItemHeight + 2, Rect.Top,
        Rect.Right - Rect.Left, Rect.Bottom - Rect.Top);
      DrawText(Handle, PChar(ComboBox.Items[Index]),
        length(ComboBox.Items[index]), Rect, DT_VCENTER + DT_SINGLELINE);
    End;
  Finally
    bitmap.Free;
  End;
End;

Procedure Tfrm_ShareFiles.ChangeLocalDir;
Var
  I: Integer;
  L: TListItem;
Begin
  lvShellTreeLocal.Items.Clear;
  L := lvShellTreeLocal.Items.Add;
  L.Caption := '..';
  L.ImageIndex := 0;
  For I := 0 To ShellProps.FilesCount - 1 do
  Begin
    L := lvShellTreeLocal.Items.Add;
    L.Caption := ShellProps.Files[I].FileName;
    If ShellProps.Files[I].FileType <> fpDir Then
    Begin
      L.ImageIndex := GetIcon(ShellProps.Folder + ShellProps.Files[I].FileName);
      L.SubItems.Add(frm_Main.GetSize(ShellProps.Files[I].FileSize));
      L.SubItems.Add(ShellProps.Files[I].FileTypeDesc);
      L.SubItems.Add(FormatDateTime('dd/mm/yyyy hh:mm:ss',
        ShellProps.Files[I].LastWrite));
    End
    Else
      L.ImageIndex := 1;
  End;
End;

procedure Tfrm_ShareFiles.GoToDirectory(Directory: String);
Var
  PeerConnected: TPeerConnected;
Begin
  // Directory_Edit.Enabled := false;
  If length(Directory) > 0 Then
  Begin
    If Not(Directory[length(Directory)] = '\') Then
      Directory := Directory + '\';
    vDirectory_Edit := Directory;
    PeerConnected := frm_Main.ipPSFilesClient.GetActivePeer;
    If PeerConnected <> Nil Then
      frm_Main.ipPSFilesClient.SendBuffer
        (frm_Main.ipPSFilesClient.GetIpSend(PeerConnected), PeerConnected.Port,
        '<|GETFOLDERS|>' + vDirectory_Edit + frm_Main.CommandEnd);
  End;
End;

Procedure Tfrm_ShareFiles.EnterLocalDir;
Var
  Directory: String;
Begin
  If (lvShellTreeLocal.ItemIndex = -1) Then
    Exit;
  If (lvShellTreeLocal.Selected.ImageIndex = 0) Or
    (lvShellTreeLocal.Selected.ImageIndex = 1) Then
  Begin
    If (lvShellTreeLocal.Selected.Caption = '..') Then
    Begin
      Directory := vDirectory_Local;
      Delete(Directory, length(Directory), length(Directory));
      vDirectory_Local := ExtractFilePath(Directory + '..');
    End
    Else
      vDirectory_Local := vDirectory_Local +
        lvShellTreeLocal.Selected.Caption + '\';
    ShellProps.Folder := IncludeTrailingPathDelimiter(vDirectory_Local);
  End;
End;

procedure Tfrm_ShareFiles.lvShellTreeLocalDblClick(Sender: TObject);
begin
  EnterLocalDir;
end;

Procedure Tfrm_ShareFiles.lvShellTreeLocalDragDrop(Sender, Source: TObject;
  X, Y: Integer);
begin
  Download_BitBtn.OnClick(Download_BitBtn);
end;

procedure Tfrm_ShareFiles.lvShellTreeLocalDragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Source is TListView;
end;

Procedure Tfrm_ShareFiles.RenewDir;
Begin
  ShellProps.Folder := vDirectory_Local;
End;

procedure Tfrm_ShareFiles.Download_BitBtnClick(Sender: TObject);
Var
  PeerConnected: TPeerConnected;
Begin
  frm_Main.CancelOPSendFile := False;
  frm_Main.StopSendFile := False;
  If (ShareFiles_ListView.ItemIndex = -1) Then
    Exit;
  If Not(ShareFiles_ListView.Selected.ImageIndex = 0) And
    Not(ShareFiles_ListView.Selected.ImageIndex = 1) Then
  Begin
    frm_Main.SendingFile := False;
    // SaveDialog1.FileName := ShareFiles_ListView.Selected.Caption;
    frm_Main.DirectoryToSaveFile := IncludeTrailingPathDelimiter
      (vDirectory_Local) + ShareFiles_ListView.Selected.Caption;
    PeerConnected := frm_Main.ipPSFilesClient.GetActivePeer;
    If PeerConnected <> Nil Then
      frm_Main.ipPSFilesClient.SendBuffer
        (frm_Main.ipPSFilesClient.GetIpSend(PeerConnected), PeerConnected.Port,
        '<|REDIRECT|><|DOWNLOADFILE|>' + vDirectory_Edit +
        ShareFiles_ListView.Selected.Caption + frm_Main.CommandEnd);
    Download_BitBtn.Enabled := False;
    {
      SaveDialog1.Filter   := 'File (*' + ExtractFileExt(ShareFiles_ListView.Selected.Caption) + ')|*' + ExtractFileExt(ShareFiles_ListView.Selected.Caption);
      If (SaveDialog1.Execute) Then
      Begin
      frm_Main.DirectoryToSaveFile := SaveDialog1.FileName; // + ExtractFileExt(ShareFiles_ListView.Selected.Caption);
      frm_Main.ipPSMain_Socket.DataToSend('<|REDIRECT|><|DOWNLOADFILE|>' + vDirectory_Edit + ShareFiles_ListView.Selected.Caption + frm_Main.CommandEnd);
      Download_BitBtn.Enabled := false;
      End;
    }
  End;
  // Close;
End;

Function Tfrm_ShareFiles.GetIcon(FileName: String): Integer;
Var
  Icon: TIcon;
  vIconIndex, I, A: Integer;
  FileExt: String;
  SmallIcon: HICON;
  IconIndex: ^TIconIndex;
Begin
  Result := -1;
  FileExt := UpperCase(ExtractFileExt(FileName));
  Try
    For I := 0 to vIconsIndex.Count - 1 Do
    Begin
      If FileExt = TIconIndex(vIconsIndex[I]^).Extension Then
      Begin
        Result := TIconIndex(vIconsIndex[I]^).Index;
        Break;
      End;
    End;
    GetAssociatedIcon(FileName, @SmallIcon);
    vIconIndex := -1;
    If SmallIcon <> 0 Then
    Begin
      Icon := TIcon.Create;
      Icon.Handle := SmallIcon;
      vIconIndex := ImageList1.AddIcon(Icon);
      FreeAndNil(Icon);
      New(IconIndex);
      IconIndex^.Extension := FileExt;
      IconIndex^.Index := ImageList1.Count - 1;
      vIconsIndex.Add(IconIndex);
      Result := IconIndex^.Index;
    End;
    Result := vIconIndex;
  Finally
  End;
End;

Procedure Tfrm_ShareFiles.EnterInDirectory;
Var
  Directory: String;
Begin
  If (ShareFiles_ListView.ItemIndex = -1) Then
    Exit;
  If (ShareFiles_ListView.Selected.ImageIndex = 0) Or
    (ShareFiles_ListView.Selected.ImageIndex = 1) Then
  Begin
    If (ShareFiles_ListView.Selected.Caption = '..') Then
    Begin
      Directory := vDirectory_Edit;
      Delete(Directory, length(Directory), length(Directory));
      vDirectory_Edit := ExtractFilePath(Directory + '..');
    End
    Else
      vDirectory_Edit := vDirectory_Edit +
        ShareFiles_ListView.Selected.Caption + '\';
    GoToDirectory(vDirectory_Edit);
  End;
End;

procedure Tfrm_ShareFiles.ShareFiles_ListViewDblClick(Sender: TObject);
Begin
  EnterInDirectory;
End;

procedure Tfrm_ShareFiles.ShareFiles_ListViewDragDrop(Sender, Source: TObject;
  X, Y: Integer);
begin
  Upload_BitBtn.OnClick(Upload_BitBtn);
end;

procedure Tfrm_ShareFiles.ShareFiles_ListViewDragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Source is TListView;
end;

procedure Tfrm_ShareFiles.ShareFiles_ListViewKeyPress(Sender: TObject;
  var Key: Char);
Begin
  If (Key = #13) Then
    EnterInDirectory;
End;

procedure Tfrm_ShareFiles.Upload_BitBtnClick(Sender: TObject);
Var
  PeerConnected: TPeerConnected;
  FileName: String;
Begin
  If (lvShellTreeLocal.ItemIndex = -1) Then
    Exit;
  If Not(lvShellTreeLocal.Selected.ImageIndex = 0) And
    Not(lvShellTreeLocal.Selected.ImageIndex = 1) Then
  Begin
    frm_Main.CancelOPSendFile := False;
    frm_Main.StopSendFile := False;
    // OpenDialog1.FileName := '';
    FileName := IncludeTrailingPathDelimiter(vDirectory_Local) +
      lvShellTreeLocal.Selected.Caption;
    frm_Main.SendingFile := True;
    FileStream := TFileStream.Create(FileName, fmOpenRead);
    FileName := ExtractFileName(FileName);
    frm_Main.FileSize := FileStream.Size;
    Upload_ProgressBar.Max := FileStream.Size;
    Upload_ProgressBar.Position := 0;
    PeerConnected := frm_Main.ipPSFilesClient.GetActivePeer;
    If PeerConnected <> Nil Then
      frm_Main.ipPSFilesClient.SendBuffer
        (frm_Main.ipPSFilesClient.GetIpSend(PeerConnected), PeerConnected.Port,
        '<|DIRECTORYTOSAVE|>' + vDirectory_Edit + FileName + '<|><|SIZE|>' +
        intToStr(FileStream.Size) + frm_Main.CommandEnd);
    FileStream.Position := 0;
    Upload_BitBtn.Enabled := False;
    SendStreamF(frm_Main.ipPSFilesClient, FileStream, True);
    FreeAndNil(FileStream);
    GoToDirectory(vDirectory_Edit);
    MessageBox(Self.Handle, 'Upload completo!',
      'Aegys - Compartilhamento de Arquivos', 64);
    {
      If (OpenDialog1.Execute) Then
      Begin
      frm_Main.SendingFile := True;
      FileStream := TFileStream.Create(OpenDialog1.FileName, fmOpenRead);
      FileName := ExtractFileName(OpenDialog1.FileName);
      frm_Main.FileSize := FileStream.Size;
      Upload_ProgressBar.Max      := FileStream.Size;
      Upload_ProgressBar.Position := 0;
      frm_Main.ipPSFilesClient.Write('<|DIRECTORYTOSAVE|>' + vDirectory_Edit + FileName + '<|><|SIZE|>' + intToStr(FileStream.Size) + frm_Main.CommandEnd);
      FileStream.Position         := 0;
      Upload_BitBtn.Enabled       := false;
      SendStreamF(frm_Main.ipPSFilesClient, FileStream, True);
      FreeAndNil(FileStream);
      GoToDirectory(vDirectory_Edit);
      MessageBox(Self.Handle, 'Upload completo!', 'Aegys - Compartilhamento de Arquivos', 64)
      End;
    }
    // Close;
  End;
End;

procedure Tfrm_ShareFiles.Directory_EditKeyPress(Sender: TObject;
  var Key: Char);
Begin
  If (Key = #13) then
  Begin
    GoToDirectory(vDirectory_Edit);
    Key := #0;
  End;
End;

Procedure Tfrm_ShareFiles.FormClose(Sender: TObject; var Action: TCloseAction);
Begin
  frm_ShareFiles := Nil;
  FreeAndNil(vIconsIndex);
  FreeAndNil(ShellProps);
  Release;
End;

procedure Tfrm_ShareFiles.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := vFreeForClose;
  If Not(CanClose) Then
    Self.Visible := False;
end;

Procedure Tfrm_ShareFiles.FormCreate(Sender: TObject);
Begin
  // Separate Window
  SetWindowLong(Handle, GWL_EXSTYLE, WS_EX_APPWINDOW);
  vIconsIndex := TIconsIndex.Create;
  ShellProps := TShellProps.Create;
  ShellProps.OnAfterChangeDir := ChangeLocalDir;
End;

procedure Tfrm_ShareFiles.FormShow(Sender: TObject);
Var
  I: Integer;
  PeerConnected: TPeerConnected;
Begin
  cbLocalDrivers.Items.Clear;
  For I := 0 To ShellProps.Drivers.Count - 1 do
    cbLocalDrivers.Items.Add(' ' + ShellProps.Drivers[I]);
  If cbLocalDrivers.Items.Count > 0 Then
  Begin
    cbLocalDrivers.ItemIndex := 0;
    cbLocalDrivers.OnChange(cbLocalDrivers);
  End;
  lNomeComputadorLocal.Caption := ShellProps.LocalStation;
  frm_Main.ExecMethod(
    Procedure
    Begin
      PeerConnected := frm_Main.ipPSFilesClient.GetActivePeer;
      If PeerConnected <> Nil Then
        frm_Main.ipPSFilesClient.SendBuffer(frm_Main.ipPSFilesClient.GetIpSend
          (PeerConnected), PeerConnected.Port,
          '<|GETDRIVERS|>' + frm_Main.CommandEnd);
    End, True);
End;

procedure Tfrm_ShareFiles.WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo);
{ sets Size-limits for the Form }
Var
  MinMaxInfo: PMinMaxInfo;
Begin
  inherited;
  MinMaxInfo := Message.MinMaxInfo;
  MinMaxInfo^.ptMinTrackSize.X := 515; // Minimum Width
  MinMaxInfo^.ptMinTrackSize.Y := 460; // Minimum Height
End;

end.