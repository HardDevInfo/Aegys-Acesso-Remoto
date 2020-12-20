unit uScanlineComparer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Graphics,
  Forms;

Const
  TNeutroColor = 255;

Type
  TRGBTriple = Packed Record
    B: Byte;
    G: Byte;
    R: Byte;
  End;

Type
  PRGBTripleArray = ^TRGBTripleArray;
  TRGBTripleArray = Array [0 .. 4095] of TRGBTriple;

Procedure GenerateComparer(Source, Dest: tBitmap; Var Compared: tBitmap;
  PixelFormat: TPixelFormat = pf24bit);
Procedure RecoveryComparer(Source, Dest: tBitmap; Var Compared: tBitmap;
  PixelFormat: TPixelFormat = pf24bit);

implementation

Procedure GenerateComparer(Source, Dest: tBitmap; Var Compared: tBitmap;
  PixelFormat: TPixelFormat = pf24bit);
Var
  A, X: Integer;
  SourcePixel, DestPixel, ComparedPixel: PRGBTripleArray;
  Rect: TRect;
  vCompared: Boolean;
Begin
  vCompared := False;
  Rect.Top := 0;
  Rect.Left := 0;
  Rect.Right := Source.Width;
  Rect.Bottom := Source.Height;
  Dest.PixelFormat := Source.PixelFormat;
  Compared.SetSize(Source.Width, Source.Height);
  Compared.Canvas.FillRect(Rect);
  Compared.PixelFormat := Source.PixelFormat;
  If (Source.Width <> Dest.Width) Or (Source.Height <> Dest.Height) Then
    Dest.SetSize(Source.Width, Source.Height);
  For A := 0 To Source.Height - 1 Do
  Begin
    // Aqui pego o endere�o da linha
    SourcePixel := Source.ScanLine[A];
    DestPixel := Dest.ScanLine[A];
    ComparedPixel := Compared.ScanLine[A];
    For X := 0 To Source.Width - 1 Do
    Begin
      Try
        // Compara os Scanlines
        If (SourcePixel[X].B <> DestPixel[X].B) Or
          (SourcePixel[X].R <> DestPixel[X].R) Or
          (SourcePixel[X].G <> DestPixel[X].G) Then
        Begin
          vCompared := True;
          ComparedPixel[X].R := DestPixel[X].R;
          ComparedPixel[X].G := DestPixel[X].G;
          ComparedPixel[X].B := DestPixel[X].B;
        End
        Else
        Begin
          ComparedPixel[X].R := TNeutroColor;
          ComparedPixel[X].G := 0;
          ComparedPixel[X].B := TNeutroColor;
        End;
      Except

      End;
{$IFDEF MSWINDOWS}
{$IFNDEF FMX}Application.Processmessages;
{$ELSE}FMX.Forms.TApplication.Processmessages; {$ENDIF}
{$ENDIF}
    End;
  End;
  Dest.PixelFormat := PixelFormat;
  If Not vCompared Then
    Dest.FreeImage;
End;

Procedure RecoveryComparer(Source, Dest: tBitmap; Var Compared: tBitmap;
  PixelFormat: TPixelFormat = pf24bit);
Var
  A, X: Integer;
  SourcePixel, DestPixel, ComparedPixel: PRGBTripleArray;
  Rect: TRect;
  Function DiffAllAlpha(Value: TRGBTriple): Boolean;
  Begin
    Result := (Value.R = TNeutroColor) And (Value.G = 0) And
      (Value.B = TNeutroColor);
  End;

Begin
  Rect.Top := 0;
  Rect.Left := 0;
  Rect.Right := Source.Width;
  Rect.Bottom := Source.Height;
  Dest.PixelFormat := Source.PixelFormat;
  Compared.Assign(Dest);
  Compared.PixelFormat := Source.PixelFormat;
  If (Source.Width <> Dest.Width) Or (Source.Height <> Dest.Height) Then
    Dest.SetSize(Source.Width, Source.Height);
  For A := 0 To Source.Height - 1 Do
  Begin
    // Aqui pego o endere�o da linha
    SourcePixel := Source.ScanLine[A];
    DestPixel := Dest.ScanLine[A];
    ComparedPixel := Compared.ScanLine[A];
    For X := 0 To Source.Width - 1 Do
    Begin
      Try
        // Compara os Scanlines
        If Not DiffAllAlpha(SourcePixel[X]) Then
        Begin
          ComparedPixel[X].R := SourcePixel[X].R;
          ComparedPixel[X].G := SourcePixel[X].G;
          ComparedPixel[X].B := SourcePixel[X].B;
        End;
      Except

      End;
{$IFDEF MSWINDOWS}
{$IFNDEF FMX}Application.Processmessages;
{$ELSE}FMX.Forms.TApplication.Processmessages; {$ENDIF}
{$ENDIF}
    End;
  End;
  Compared.PixelFormat := PixelFormat;
End;

end.