unit ImageCapture;

interface

uses
  Windows, SysUtils, Graphics, Forms,
  Direct3D9, DirectDraw, Classes, IdGlobal,
  Contnrs, SyncObjs, DateUtils, JPeg, resizeunit;

Const
  CAPTUREBLT = $40000000;
  TVideoMode = 1024;

Type
  TEventExec = Procedure(Value: String);
  TRGBArray = ARRAY [0 .. 32767] OF TRGBTriple;
  pRGBArray = ^TRGBArray;

Type
  TDataIn = Class(TObject)
  Private
    vReaded: Boolean;
    vValue: String;
    vGeralEncode: IIdTextEncoding;
  Public
    Property Value: String Read vValue Write vValue;
    Property Readed: Boolean Read vReaded Write vReaded;
    Function GetValue: String;
    Constructor Create(Encode: IIdTextEncoding);
    Destructor Destroy; Override;
  End;

Type
  TDataList = TObjectList;

Type
  TProcessDataThread = Class(TThread)
  Protected
    vProcessMessages, vKill: Boolean;
    vDataList: TDataList;
    vExecFunction: TEventExec;
    FTerminateEvent: TEvent;
    vParentWindow: TObject;
    vMilisExec: Word;
    vGeralEncode: IIdTextEncoding;
    Procedure Kill;
    Procedure Execute; Override;
    Procedure DeleteItem(Index: Integer);
  Private

  Public
    Property ExecFunction: TEventExec Read vExecFunction Write vExecFunction;
    Property ProcessMessages: Boolean Read vProcessMessages
      Write vProcessMessages;
    Destructor Destroy; Override;
    Constructor Create(ParentWindow: TComponent; Encode: IIdTextEncoding);
    Procedure AddPack(Const Value: String);
  End;

Type
  TProcessData = Class(TComponent)
  Private
    vOwnerForm, vOwner: TComponent;
    vExecFunction: TEventExec;
    vProcessReceiveData: TProcessDataThread;
    vProcessMessages, vActive: Boolean;
    vGeralEncode: IIdTextEncoding;
    Procedure SetExecFunction(Value: TEventExec);
    Procedure SetOwnerForm(Value: TComponent);
    Procedure SetProcessMessages(Value: Boolean);
    Procedure SetActive(Value: Boolean);
  Public
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;
    Procedure AddPack(Const Value: String);
    Property OwnerForm: TComponent Read vOwnerForm Write SetOwnerForm;
    Property ExecFunction: TEventExec Read vExecFunction Write SetExecFunction;
    Property Encode: IIdTextEncoding Read vGeralEncode Write vGeralEncode;
    Property Active: Boolean Read vActive Write SetActive;
    Property ProcessMessages: Boolean Read vProcessMessages
      Write SetProcessMessages;
  End;

Type
  TCatchType = (ctWinapi = 0, ctDirectX = 1, ctDDraw);

  TImageCatcher = Class
  Private
    FBitmap: TBitmap; // TFastDIB;
    FCatchType: TCatchType;
    FTargetHandle: HWND;
    vPixelFormat: TPixelFormat;
    procedure GetTargetRect(Out Rect: TRect);
    procedure GetDDrawData;
    procedure GetDirectXData;
    procedure GetWinapiData;
    procedure GetTargetDimensions(Out w, h: Integer);
    procedure GetTargetPosition(Out left, top: Integer);
    Procedure SetTargetHandle(Handle: HWND);
    Procedure ActivateTarget;
  Public
    Constructor Create;
    Procedure Reset;
    Destructor Destroy; Override;
    Procedure GetScreenShot;
    Property Bitmap: TBitmap Read FBitmap Write FBitmap; // TFastDIB
    Property CatchType: TCatchType Read FCatchType Write FCatchType;
    Property TargetHandle: HWND Read FTargetHandle Write SetTargetHandle;
    Property PixelFormat: TPixelFormat Read vPixelFormat Write vPixelFormat;
  End;

Implementation

Uses Form_Main;

{ TImageCather }

Destructor TProcessData.Destroy;
Begin
  SetActive(False);
  Inherited;
End;

Procedure TProcessData.AddPack(Const Value: String);
Begin
  If vProcessReceiveData <> Nil Then
    vProcessReceiveData.AddPack(Value);
End;

Procedure TProcessData.SetActive(Value: Boolean);
Begin
  If (vProcessReceiveData <> Nil) Then
  Begin
    Try
      vProcessReceiveData.Kill;
    Except
    End;
    WaitForSingleObject(vProcessReceiveData.Handle, 100);
    vProcessReceiveData := Nil;
    FreeAndNil(vProcessReceiveData);
    vActive := False;
  End;
  If (Value) Then
  Begin
    Try
      vProcessReceiveData := TProcessDataThread.Create(vOwnerForm,
        vGeralEncode);
      vProcessReceiveData.vExecFunction := vExecFunction;
      vProcessReceiveData.ProcessMessages := vProcessMessages;
      vProcessReceiveData.Resume;
      vActive := Value;
    Except

    End;
  End;
End;

Procedure TProcessData.SetProcessMessages(Value: Boolean);
Begin
  vProcessMessages := Value;
  If vProcessReceiveData <> Nil Then
    vProcessReceiveData.ProcessMessages := vProcessMessages;
End;

Procedure TProcessData.SetOwnerForm(Value: TComponent);
Begin
  vOwnerForm := Value;
  If vProcessReceiveData <> Nil Then
    vProcessReceiveData.vParentWindow := vOwnerForm;
End;

Procedure TProcessData.SetExecFunction(Value: TEventExec);
Begin
  vExecFunction := Value;
  If vProcessReceiveData <> Nil Then
    vProcessReceiveData.ExecFunction := vExecFunction;
End;

Constructor TProcessData.Create(AOwner: TComponent);
Begin
  Inherited;
  vOwner := AOwner;
  vProcessReceiveData := Nil;
  vGeralEncode := IndyTextEncoding_UTF8;
  vProcessMessages := False;
End;

Constructor TProcessDataThread.Create(ParentWindow: TComponent;
  Encode: IIdTextEncoding);
Begin
  Inherited Create(False);
  vMilisExec := 5;
  FTerminateEvent := TEvent.Create(Nil, True, False, 'VideoEvent');
  vParentWindow := ParentWindow;
  vDataList := TDataList.Create;
  vGeralEncode := Encode;
  vProcessMessages := False;
  Priority := tpLowest;
End;

Function TDataIn.GetValue: String;
Begin
  Result := vValue;
End;

Constructor TDataIn.Create(Encode: IIdTextEncoding);
Begin
  Inherited Create;
  vGeralEncode := Encode;
  vReaded := False;
End;

Destructor TDataIn.Destroy;
Begin
  SetLength(vValue, 0);
  Inherited;
End;

Destructor TProcessDataThread.Destroy;
  Procedure DeleteElements;
  Var
    I: Integer;
  Begin
    Try
      System.TMonitor.Enter(vDataList);
      For I := 0 To vDataList.Count - 1 Do
        vDataList.Delete(I);
    Finally
      System.TMonitor.PulseAll(vDataList);
      System.TMonitor.Exit(vDataList);
    End;
  End;

Begin
  FTerminateEvent.SetEvent;
  DeleteElements;
  vDataList.Free;
  FTerminateEvent.Free;
  Inherited;
End;

Procedure TProcessDataThread.Execute;
Var
  vExec: TDateTime;
  vNotEnter: Boolean;
  vTempBuffer: String;
Begin
  vExec := Now;
  vNotEnter := False;
  While (Not Terminated) And (Not(vKill)) Do
  Begin
    If Not(vNotEnter) And (vDataList.Count > 0) Then
    Begin
      vNotEnter := True;
      If Not TDataIn(vDataList[0]).Readed Then
      Begin
        If (MilliSecondsBetween(Now, vExec) > vMilisExec) Then
        Begin
          TDataIn(vDataList[0]).Readed := True;
          vTempBuffer := TDataIn(vDataList[0]).GetValue;
          DeleteItem(0);
          vExec := Now;
          If Assigned(vExecFunction) Then
          Begin
            If vProcessMessages Then
            Begin
              Synchronize(
                Procedure
                Begin
                  vExecFunction(vTempBuffer);
                End);
            End
            Else
              vExecFunction(vTempBuffer);
          End;
{$IFDEF MSWINDOWS}
{$IFNDEF FMX}Application.ProcessMessages;
{$ELSE}FMX.Forms.TApplication.ProcessMessages; {$ENDIF}
{$ENDIF}
        End;
      End;
      vNotEnter := False;
    End;
    FTerminateEvent.WaitFor(1);
  End;
End;

Procedure TProcessDataThread.DeleteItem(Index: Integer);
Begin
  If Not((vDataList.Count - 1 < Index) Or (vDataList.Count = 0)) Then
  Begin
    Try
      System.TMonitor.Enter(vDataList);
      vDataList.Delete(Index);
    Finally
      System.TMonitor.PulseAll(vDataList);
      System.TMonitor.Exit(vDataList);
    End;
  End;
End;

Procedure TProcessDataThread.Kill;
Begin
  vKill := True;
  If FTerminateEvent <> Nil Then
    FTerminateEvent.SetEvent;
  Terminate;
End;

Procedure TProcessDataThread.AddPack(Const Value: String);
Var
  vTDataIn: TDataIn;
Begin
  Try
    System.TMonitor.Enter(vDataList);
    vTDataIn := TDataIn.Create(vGeralEncode);
    vTDataIn.vValue := Value;
    vDataList.Add(vTDataIn);
  Finally
    System.TMonitor.PulseAll(vDataList);
    System.TMonitor.Exit(vDataList);
  End;
End;

procedure TImageCatcher.ActivateTarget;
Begin
  SetForegroundWindow(TargetHandle);
End;

Constructor TImageCatcher.Create;
Begin
  Reset;
  FBitmap := TBitmap.Create; // TFastDIB.Create;
  // FBitmap.UseGDI := False;
  FCatchType := ctDDraw;
  vPixelFormat := pf8bit;
End;

Destructor TImageCatcher.Destroy;
Begin
  FreeAndNil(FBitmap);
  inherited;
End;

procedure TImageCatcher.GetDDrawData;
Var
  DDSCaps: TDDSCaps;
  DesktopDC: HDC;
  DirectDraw: IDirectDraw;
  Surface: IDirectDrawSurface;
  SurfaceDesc: TDDSurfaceDesc;
  x, y, w, h: Integer;
Begin
  GetTargetDimensions(w, h);
  GetTargetPosition(x, y);
  If DirectDrawCreate(Nil, DirectDraw, Nil) = DD_OK Then
  Begin
    If DirectDraw.SetCooperativeLevel(GetDesktopWindow, DDSCL_EXCLUSIVE Or
      DDSCL_FULLSCREEN Or DDSCL_ALLOWREBOOT) = DD_OK Then
    Begin
      FillChar(SurfaceDesc, SizeOf(SurfaceDesc), 0);
      SurfaceDesc.dwSize := SizeOf(SurfaceDesc);
      SurfaceDesc.dwFlags := DDSD_CAPS;
      SurfaceDesc.DDSCaps.dwCaps := DDSCAPS_PRIMARYSURFACE;
      SurfaceDesc.dwBackBufferCount := 0;
      If DirectDraw.CreateSurface(SurfaceDesc, Surface, Nil) = DD_OK Then
      Begin
        If Surface.GetDC(DesktopDC) = DD_OK Then
        Begin
          Try
            // Bitmap.SetSize(Screen.Width, Screen.Height, 24);
            Bitmap.Width := Screen.Width;
            Bitmap.Height := Screen.Height;
            BitBlt(Bitmap.Handle, 0, 0, w, h, DesktopDC, x, y, SRCCOPY);
          Finally
            Surface.ReleaseDC(DesktopDC);
            Bitmap.PixelFormat := vPixelFormat;
          End;
        End;
      End;
    End;
  End;
End;

procedure TImageCatcher.GetDirectXData;
Var
  BitsPerPixel: Byte;
  pD3D: IDirect3D9;
  pSurface: IDirect3DSurface9;
  g_pD3DDevice: IDirect3DDevice9;
  D3DPP: TD3DPresentParameters;
  ARect: TRect;
  LockedRect: TD3DLockedRect;
  BMP: TBitmap;
  I, p, x, y, w, h: Integer;
Begin
  GetTargetDimensions(w, h);
  GetTargetPosition(x, y);
  BitsPerPixel := 32;
  FillChar(D3DPP, SizeOf(D3DPP), 0);
  With D3DPP Do
  Begin
    Windowed := True;
    Flags := D3DPRESENTFLAG_LOCKABLE_BACKBUFFER;
    SwapEffect := D3DSWAPEFFECT_DISCARD;
    BackBufferWidth := Screen.Width;
    BackBufferHeight := Screen.Height;
    BackBufferFormat := D3DFMT_X8R8G8B8;
  End;
  pD3D := Direct3DCreate9(D3D_SDK_VERSION);
  pD3D.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, GetDesktopWindow,
    D3DCREATE_SOFTWARE_VERTEXPROCESSING, @D3DPP, g_pD3DDevice);
  g_pD3DDevice.CreateOffscreenPlainSurface(Screen.Width, Screen.Height,
    D3DFMT_A8R8G8B8, D3DPOOL_SCRATCH, pSurface, nil);
  g_pD3DDevice.GetFrontBufferData(0, pSurface);
  ARect := Screen.DesktopRect;
  pSurface.LockRect(LockedRect, @ARect, D3DLOCK_NO_DIRTY_UPDATE or
    D3DLOCK_NOSYSLOCK or D3DLOCK_READONLY);
  BMP := TBitmap.Create;
  BMP.Width := Screen.Width;
  BMP.Height := Screen.Height;
  Case BitsPerPixel of
    8:
      BMP.PixelFormat := pf8bit;
    16:
      BMP.PixelFormat := pf16bit;
    24:
      BMP.PixelFormat := pf24bit;
    32:
      BMP.PixelFormat := pf32bit;
  End;
  p := Cardinal(LockedRect.pBits);
  For I := 0 To Screen.Height - 1 Do
  Begin
    CopyMemory(BMP.ScanLine[I], Ptr(p), Screen.Width * BitsPerPixel div 8);
    p := p + LockedRect.Pitch;
  End;
  Bitmap.Assign(BMP);
  Bitmap.PixelFormat := vPixelFormat;
  FreeAndNil(BMP);
  pSurface.UnlockRect;
End;

Procedure TImageCatcher.GetScreenShot;
Begin
  Case CatchType Of
    ctWinapi:
      GetWinapiData;
    ctDirectX:
      GetDirectXData;
    ctDDraw:
      GetDDrawData;
  End;
End;

procedure TImageCatcher.GetTargetDimensions(Out w, h: Integer);
Begin
  w := GetSystemMetrics(SM_CXSCREEN);
  h := GetSystemMetrics(SM_CYSCREEN);
End;

Procedure TImageCatcher.SetTargetHandle(Handle: HWND);
Begin
  FTargetHandle := Handle;
  ActivateTarget;
End;

procedure TImageCatcher.GetTargetPosition(out left, top: Integer);
Var
  Rect: TRect;
Begin
  GetTargetRect(Rect);
  left := Rect.left;
  top := Rect.top;
End;

procedure TImageCatcher.GetTargetRect(out Rect: TRect);
Begin
  GetWindowRect(TargetHandle, Rect);
End;

Procedure TImageCatcher.Reset;
Begin
  CatchType := ctWinapi;
  TargetHandle := 0;
End;

Procedure SetJPGCompression(ACompression: Integer; BMP: TBitmap;
const AOutFile: string);
Var
  iCompression: Integer;
  oJPG: TJPegImage;
begin
  // Force Compression to range 1..100
  iCompression := abs(ACompression);
  if iCompression = 0 then
    iCompression := 1;
  if iCompression > 100 then
    iCompression := 100;

  // Create Jpeg and Bmp work classes
  oJPG := TJPegImage.Create;
  oJPG.Assign(BMP);
  // Do the Compression and Save New File
  oJPG.CompressionQuality := iCompression;
  oJPG.Compress;
  oJPG.PixelFormat := jf8bit; // jf24bit
  oJPG.SaveToFile(AOutFile);

  // Clean Up
  oJPG.Free;
End;

procedure Scale2x(Input: TBitmap; var OutPut: TBitmap);
Type
  TRGBTripleArray = array [0 .. 8191] of Windows.TRGBTriple;
  PRGBTripleArray = ^TRGBTripleArray;
Var
  A, B, C, D, p, P0, P1, P2, P3: PRGBTriple;
  iw, ih, iCol, iRow: Integer;
  pbaPrevRow, pbaRow, pbaNextRow: PRGBTripleArray;
  pbaOut1stRow, pbaOut2ndRow: PRGBTripleArray;
  Function NormalizeX(x: Integer): Integer;
  Begin
    If x < 0 Then
      Result := 0
    Else If x >= iw Then
      Result := iw - 1
    Else
      Result := x;
  End;

Begin
  // +---+---+---+
  // | | A | | +----+----+
  // +---+---+---+ ----> | P0 | P1 |
  // | D | P | B | +----+----+
  // +---+---+---+ ----> | P2 | P3 |
  // | | C | | +----+----+
  // +---+---+---+
  iw := Input.Width;
  ih := Input.Height;
  OutPut.Width := iw * 2;
  OutPut.Height := ih * 2;
  If OutPut.PixelFormat <> pf24bit Then
    OutPut.PixelFormat := pf24bit;
  For iRow := 0 To ih - 1 Do
  Begin
    If iRow = 0 Then
      pbaPrevRow := Input.ScanLine[0]
    Else
      pbaPrevRow := Input.ScanLine[iRow - 1];
    pbaRow := Input.ScanLine[iRow];
    If iRow = ih - 1 Then
      pbaNextRow := Input.ScanLine[ih - 1]
    Else
      pbaNextRow := Input.ScanLine[iRow + 1];
    For iCol := 0 To iw - 1 Do
    Begin
      A := @pbaPrevRow[iCol];
      B := @pbaRow[NormalizeX(iCol + 1)];
      C := @pbaNextRow[iCol];
      D := @pbaRow[NormalizeX(iCol - 1)];
      p := @pbaRow[iCol];
      P0 := p;
      P1 := p;
      P2 := p;
      P3 := p;
      If (Not CompareMem(A, C, 3)) And (Not CompareMem(B, D, 3)) Then
      Begin
        If CompareMem(A, D, 3) Then
          P0 := A;
        If CompareMem(A, B, 3) Then
          P1 := A;
        If CompareMem(C, D, 3) Then
          P2 := C;
        If CompareMem(C, B, 3) Then
          P3 := C;
      End;
      pbaOut1stRow := OutPut.ScanLine[iRow * 2];
      pbaOut2ndRow := OutPut.ScanLine[iRow * 2 + 1];
      pbaOut1stRow[iCol * 2] := P0^;
      pbaOut1stRow[iCol * 2 + 1] := P1^;
      pbaOut2ndRow[iCol * 2] := P2^;
      pbaOut2ndRow[iCol * 2 + 1] := P3^;
    End;
  End;
End;

procedure SmoothResize(abmp: TBitmap; NuWidth, NuHeight: Integer);
var
  xscale, yscale: Single;
  sfrom_y, sfrom_x: Single;
  ifrom_y, ifrom_x: Integer;
  to_y, to_x: Integer;
  weight_x, weight_y: array [0 .. 1] of Single;
  weight: Single;
  new_red, new_green: Integer;
  new_blue: Integer;
  total_red, total_green: Single;
  total_blue: Single;
  ix, iy: Integer;
  bTmp: TBitmap;
  sli, slo: pRGBArray;
  { pointers for scanline access }
  liPByte, loPByte, p: PByte;
  { offset increment }
  liSize, loSize: Integer;
begin
  abmp.PixelFormat := pf24bit;
  bTmp := TBitmap.Create;
  bTmp.PixelFormat := pf24bit;
  bTmp.Width := NuWidth;
  bTmp.Height := NuHeight;
  xscale := bTmp.Width / (abmp.Width - 1);
  yscale := bTmp.Height / (abmp.Height - 1);
  liPByte := abmp.ScanLine[0];
  liSize := Integer(abmp.ScanLine[1]) - Integer(liPByte);
  loPByte := bTmp.ScanLine[0];
  loSize := Integer(bTmp.ScanLine[1]) - Integer(loPByte);
  for to_y := 0 to bTmp.Height - 1 do
  begin
    sfrom_y := to_y / yscale;
    ifrom_y := Trunc(sfrom_y);
    weight_y[1] := sfrom_y - ifrom_y;
    weight_y[0] := 1 - weight_y[1];
    for to_x := 0 to bTmp.Width - 1 do
    begin
      sfrom_x := to_x / xscale;
      ifrom_x := Trunc(sfrom_x);
      weight_x[1] := sfrom_x - ifrom_x;
      weight_x[0] := 1 - weight_x[1];
      total_red := 0.0;
      total_green := 0.0;
      total_blue := 0.0;
      for ix := 0 to 1 do
      begin
        for iy := 0 to 1 do
        begin
          p := liPByte;
          Inc(p, liSize * (ifrom_y + iy));
          sli := pRGBArray(p);
          new_red := sli[ifrom_x + ix].rgbtRed;
          new_green := sli[ifrom_x + ix].rgbtGreen;
          new_blue := sli[ifrom_x + ix].rgbtBlue;
          weight := weight_x[ix] * weight_y[iy];
          total_red := total_red + new_red * weight;
          total_green := total_green + new_green * weight;
          total_blue := total_blue + new_blue * weight;
        end;
      end;
      p := loPByte;
      Inc(p, loSize * to_y);
      slo := pRGBArray(p);
      slo[to_x].rgbtRed := Round(total_red);
      slo[to_x].rgbtGreen := Round(total_green);
      slo[to_x].rgbtBlue := Round(total_blue);
    end;
  end;
  abmp.Width := bTmp.Width;
  abmp.Height := bTmp.Height;
  abmp.Canvas.Draw(0, 0, bTmp);
  bTmp.Free;
End;

Procedure TImageCatcher.GetWinapiData;
Const
  DefaultWindowStation = 'WinSta0';
  DefaultDesktop = 'Default';
  CAPTUREBLT = $40000000;
  WINSTA_ALL_ACCESS = $0000037F;
Var
  Cursorx, Cursory, w, h: Integer;
  hdcScreen, hdcCompatible: HDC;
  hbmScreen: HBITMAP;
  BitmapTemp: TBitmap;
  mp, DrawPos: TPoint;
  MyCursor: TIcon;
  hld: HWND;
  Threadld: dword;
  pIconInfo: TIconInfo;
Begin
  GetTargetDimensions(w, h);
  Try
    hdcScreen := CreateDC('DISPLAY', Nil, Nil, Nil);
    hdcCompatible := CreateCompatibleDC(hdcScreen);
    hbmScreen := CreateCompatibleBitmap(hdcScreen,
      GetDeviceCaps(hdcScreen, HORZRES), GetDeviceCaps(hdcScreen, VERTRES));
    Try
      SelectObject(hdcCompatible, hbmScreen);
      // SetBkColor(hdcCompatible, clBlack);
      Bitmap.Height := h;
      Bitmap.Width := w;
      Bitmap.Handle := hbmScreen;
      Bitmap.Canvas.Lock;
      BitBlt(hdcCompatible, 0, 0, Bitmap.Width, Bitmap.Height, hdcScreen, 0, 0,
        SRCCOPY Or CAPTUREBLT);
    Finally
      Bitmap.Canvas.Unlock;
      ReleaseDC(hdcScreen, hdcCompatible);
      DeleteDC(hdcScreen);
      DeleteDC(hdcCompatible);
    End;
    If MouseCaptureC Then
    Begin
      GetCursorPos(DrawPos);
      MyCursor := TIcon.Create;
      GetCursorPos(mp);
      hld := WindowFromPoint(mp);
      Threadld := GetWindowThreadProcessId(hld, nil);
      AttachThreadInput(GetCurrentThreadId, Threadld, True);
      MyCursor.Handle := Getcursor();
      AttachThreadInput(GetCurrentThreadId, Threadld, False);
      GetIconInfo(MyCursor.Handle, pIconInfo);
      Cursorx := DrawPos.x - Round(pIconInfo.xHotspot);
      Cursory := DrawPos.y - Round(pIconInfo.yHotspot);
      Bitmap.Canvas.Draw(Cursorx, Cursory, MyCursor);
      DeleteObject(pIconInfo.hbmColor);
      DeleteObject(pIconInfo.hbmMask);
      MyCursor.ReleaseHandle;
      FreeAndNil(MyCursor);
    End;
  Finally
    Case vPixelFormat Of
      pf1bit, pf4bit, pf8bit:
        Begin
          SmoothResize(FBitmap, TVideoMode,
            Trunc(TVideoMode / FBitmap.Width * FBitmap.Height));
          Bitmap.PixelFormat := vPixelFormat;
        End;
      pf15bit, pf16bit:
        Bitmap.PixelFormat := pf8bit;
      pf24bit, pf32bit:
        Bitmap.PixelFormat := pf24bit;
    End;
  End;
End;

end.