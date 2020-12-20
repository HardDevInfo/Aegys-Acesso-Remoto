unit uPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer,
  IdContext, IdServerIOHandler, IdServerIOHandlerSocket, IdServerIOHandlerStack,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView;

Type
 TThreadConnection = Record
  Main,
  Target : TIdContext;
End;

Type
 TClientSetings = Class(TObject)
  ID,
  Group,
  Machine,
  MAC, HD,
  LastPassword,
  IP,
  Maq,
  TargetID,
  Password,
  TargetPassword,
  InsertTargetID  : AnsiString;
  ThreadID        : Cardinal;
  StartPing,
  EndPing         : Integer;
  lItem,
  lItem2          : TListItem;
  aMain,
  aDesktop,
  aOthers         : TThreadConnection;
End;
PCliente = ^TClientSetings;

type
  TfServerControl = class(TForm)
    idTCPMain: TIdTCPServer;
    idTCPDesktop: TIdTCPServer;
    idOther: TIdTCPServer;
    IdSIOHSConnection: TIdServerIOHandlerStack;
    IdSIOHSDesktop: TIdServerIOHandlerStack;
    IdSIOHSOther: TIdServerIOHandlerStack;
    procedure idTCPMainConnect(AContext: TIdContext);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure idTCPMainDisconnect(AContext: TIdContext);
    procedure idTCPMainExecute(AContext: TIdContext);
  private
    { Private declarations }
   FConexoes : TList; //Lista de Peers Conectados
  public
    { Public declarations }
  end;

var
  fServerControl: TfServerControl;

implementation

{$R *.fmx}

procedure TfServerControl.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 idTCPMain.Active    := False;
 idTCPDesktop.Active := False;
 idOther.Active      := False;
 FreeAndNil(FConexoes);
 fServerControl := Nil;
 Release;
end;

procedure TfServerControl.FormCreate(Sender: TObject);
begin
 FConexoes := TList.Create;
end;

procedure TfServerControl.idTCPMainConnect(AContext: TIdContext);
Var
 ClienteNovo : PCliente;
 vDelItem : Integer;
begin
 GetMem(ClienteNovo, Sizeof(TClientSetings));
 ClienteNovo^              := TClientSetings.Create;
 ClienteNovo^.aMain.Main   := AContext;
 ClienteNovo^.aMain.Target := Nil;
 AContext.Data             := ClienteNovo^;
 FConexoes.Add(ClienteNovo);
end;

procedure TfServerControl.idTCPMainDisconnect(AContext: TIdContext);
Var
 Cliente  : PCliente;
begin
 Cliente       := PCliente(AContext.Data);
 FConexoes.Remove(Cliente);
 AContext.Data := Nil;
 FreeMem(Cliente, SizeOf(TClientSetings));
end;

procedure TfServerControl.idTCPMainExecute(AContext: TIdContext);
 Function InCommands(s : AnsiString) : Boolean;
 Begin
  Result := (Pos('<|PONG|>', Uppercase(s)) > 0)            or (Pos('<|MAINSOCKET|>', Uppercase(s)) > 0)     or
            (Pos('<|DESKTOPSOCKET|>', Uppercase(s)) > 0)   or (Pos('<|KEYBOARDSOCKET|>', Uppercase(s)) > 0) or
            (Pos('WRITEOK', Uppercase(s)) > 0)             or (Pos('<|FINDID|>', Uppercase(s)) > 0)         or
            (Pos('<|CHECKIDPASSWORD|>', Uppercase(s)) > 0) or (Pos('<|RELATION|>', Uppercase(s)) > 0)       or
            (Pos('<|REDIRECT|>', Uppercase(s)) > 0)        or (Pos('<$INITSTREAM$>', Uppercase(s)) > 0);
 End;
Var
 vLine2,
 vLine  : AnsiString;
begin
 TClientSetings(AContext.Data).aMain.Main.Connection.IOHandler.CheckForDisconnect;
 If TClientSetings(AContext.Data).aMain.Main.Connection.Connected Then
  Begin
   vLine := TClientSetings(AContext.Data).aMain.Main.Connection.IOHandler.ReadLn;
   If (Pos('<|MAINSOCKET|>', vLine) > 0) Then
    Begin
     If (Pos('<|GROUP|>', vLine) > 0) Then
      Begin
       // Get the Group
       vLine2 := vLine;
       Delete(vLine2, 1, Pos('<|MAINSOCKET|>', vLine) + 22);
       TClientSetings(AContext.Data).Group := vLine2;
       TClientSetings(AContext.Data).Group := Copy(vLine2, 1, Pos('<<|', vLine2) - 1);
       // Get the PC Name
       vLine2 := vLine;
       Delete(vLine2, 1, Pos('<|MACHINE|>', vLine)+ 10);
       TClientSetings(AContext.Data).Machine := vLine2;
       TClientSetings(AContext.Data).Machine := Copy(vLine2, 1, Pos('<<|', vLine2) - 1);
       // Get the MAC Adress
       vLine2 := vLine;
       Delete(vLine2, 1, Pos('<|MAC|>', vLine)+ 6);
       TClientSetings(AContext.Data).MAC := vLine2;
       TClientSetings(AContext.Data).MAC := Copy(vLine2, 1, Pos('<<|', vLine2) - 1);
       // Get the HD Adress
       vLine2 := vLine;
       Delete(vLine2, 1, Pos('<|HD|>', vLine)+ 5);
       TClientSetings(AContext.Data).HD := vLine2;
       TClientSetings(AContext.Data).HD := Copy(vLine2, 1, Pos('<<|', vLine2) - 1);
       // Get the HD Adress
       vLine2 := vLine;
       Delete(vLine2, 1, Pos('<|LASTPASSWORD|>', vLine)+ 15);
       TClientSetings(AContext.Data).LastPassword := vLine2;
       TClientSetings(AContext.Data).LastPassword := Copy(vLine2, 1, Pos('<<|', vLine2) - 1);
      End;
//     AddItems(AContext);
     TClientSetings(AContext.Data).lItem := frm_Main.Connections_ListView.FindCaption(0, IntToStr(TClientSetings(AContext.Data).AThread_Main.Binding.Handle), false, true, false);
     TClientSetings(AContext.Data).lItem.SubItems.Objects[0] := TClientSetings(AContext.Data);
     TClientSetings(AContext.Data).AThread_Main.Connection.Socket.Write('<|ID|>' + TClientSetings(AContext.Data).ID + '<|>' + TClientSetings(AContext.Data).Password + '<<|');
    End;

  End;
end;

end.