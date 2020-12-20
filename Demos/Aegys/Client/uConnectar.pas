unit uConnectar;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls;

type
  TfConnectar = class(TForm)
    pbDados: TProgressBar;
    tAnimation: TTimer;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure tAnimationTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fConnectar: TfConnectar;

implementation

{$R *.dfm}

procedure TfConnectar.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  tAnimation.Enabled := False;
end;

procedure TfConnectar.FormCreate(Sender: TObject);
begin
  tAnimation.Enabled := True;
end;

procedure TfConnectar.tAnimationTimer(Sender: TObject);
Begin
  tAnimation.Enabled := False;
  pbDados.Position := 0;
  TThread.CreateAnonymousThread(
    Procedure
    Var
      I: Integer;
    Begin
      For I := 0 To 99 Do
        pbDados.Position := I;
    End).Start;
  tAnimation.Enabled := Self <> Nil;
End;

end.