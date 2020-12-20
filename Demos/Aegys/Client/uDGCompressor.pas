unit uDGCompressor;

interface

// Author: Dorin Duminica
//
// Scope: file/stream compression/decompression and encryption/decryption
//
// License: free for commercial or private use

uses
  SysUtils,
  Windows,
  Classes,
  zlib;

const
  CKILO_BYTE = 1024;
  // default buffer //
  CBUFFER_SIZE = 35 * CKILO_BYTE;

  // cipher base class //
  // the child classes will HAVE to implement the Encrypt/Decrypt  //
  // methods based on the parameters defined bellow  //
type
  TDGCipherBase = class(TObject)
  public
    procedure EncryptData(const InData: Pointer; const InSize: Integer;
      out OutData: Pointer; out OutSize: Integer); virtual; abstract;
    procedure DecryptData(const InData: Pointer; const InSize: Integer;
      out OutData: Pointer; out OutSize: Integer); virtual; abstract;
  end;

  // before each compressed block the following structure will be written  //
type
  TDGBlockDesc = record
    // initial size of the block, before compresstion  //
    InitialSize: Integer;
    // size of the compressed block in stream  //
    Size: Integer;
  end; // TDGBlockDesc = record

const
  szDGBlockDesc = SizeOf(TDGBlockDesc);

type
  // each time a block of data is processed  //
  TDGProgressEvent = procedure(const Progress, ProgressMax: Integer) of Object;

  // before/after compress/decompress events //
  TDGCompressorEvent = procedure(const InFileName, OutFileName: string;
    const InSize, OutSize: Int64) of Object;

  // when a block's decompressed size is different than initial size //
  // this type of event will be fired if assigned  //
  TDGDecompressFailEvent = procedure(const BlockDesc: TDGBlockDesc;
    const InBuffer, OutBuffer: Pointer; const InSize, OutSize: Integer)
    of Object;

  // the compress/decompress class //s
type
  TDGCompressor = class(TObject)
  private
    FInStreamSize: Int64;
    FOutStreamSize: Int64;
    FBufferSize: Integer;
    FCipher: TDGCipherBase;
    FOnProgress: TDGProgressEvent;
    FOnAfterCompress: TDGCompressorEvent;
    FOnBeforeCompress: TDGCompressorEvent;
    FOnAfterDecompress: TDGCompressorEvent;
    FOnBeforeDecompress: TDGCompressorEvent;
    FOnDecompressFail: TDGDecompressFailEvent;
  public
    constructor Create;
  public
    procedure CompressFile(const InFileName, OutFileName: string);
    procedure DecompressFile(const InFileName, OutFileName: string);
    procedure CompressStream(const InStream, OutStream: TStream);
    procedure DecompressStream(const InStream, OutStream: TStream);
  published
    // properties  //
    property BufferSize: Integer read FBufferSize write FBufferSize;
    property Cipher: TDGCipherBase read FCipher write FCipher;
    property InStreamSize: Int64 read FInStreamSize;
    property OutStreamSize: Int64 read FOutStreamSize;
    // events  //
    property OnAfterCompress: TDGCompressorEvent read FOnAfterCompress
      write FOnAfterCompress;
    property OnBeforeCompress: TDGCompressorEvent read FOnBeforeCompress
      write FOnBeforeCompress;
    property OnAfterDecompress: TDGCompressorEvent read FOnAfterDecompress
      write FOnAfterDecompress;
    property OnBeforeDecompresss: TDGCompressorEvent read FOnBeforeDecompress
      write FOnBeforeDecompress;
    property OnDecompressFail: TDGDecompressFailEvent read FOnDecompressFail
      write FOnDecompressFail;
    property OnProgress: TDGProgressEvent read FOnProgress write FOnProgress;
  end;

implementation

{ TDGCompressor }

procedure TDGCompressor.CompressFile(const InFileName, OutFileName: string);
var
  LInFileStream: TFileStream;
  LOutFileStream: TFileStream;
begin
  // create TFileStream instances  //
  LInFileStream := TFileStream.Create(InFileName, fmOpenRead or
    fmShareDenyNone);
  LOutFileStream := TFileStream.Create(OutFileName,
    fmCreate or fmShareDenyNone);
  // set the position of LInFileStream to the begining
  LInFileStream.Position := 0;
  // call OnBeforeCompress event if assigned //
  if Assigned(FOnBeforeCompress) then
    FOnBeforeCompress(InFileName, OutFileName, LInFileStream.Size,
      LOutFileStream.Size);
  try
    // attempt to compress stream  //
    CompressStream(LInFileStream, LOutFileStream);
  finally
    // free objects  //
    FreeAndNil(LInFileStream);
    FreeAndNil(LOutFileStream);
  end; // tryf
  // call OnAfterCompress event if assigned  //
  if Assigned(FOnAfterCompress) then
    FOnAfterCompress(InFileName, OutFileName, LInFileStream.Size,
      LOutFileStream.Size);
end;

procedure TDGCompressor.CompressStream(const InStream, OutStream: TStream);

  function ThereAreBytes: Boolean;
  begin
    Result := (InStream.Position < InStream.Size) and
      ((InStream.Size - InStream.Position) > 0);
  end; // function ThereAreBytes: Boolean;

var
  LInBuffer: Pointer;
  LOutBuffer: Pointer;
  LWriteBuffer: Pointer;
  LBlockDesc: TDGBlockDesc;
  LProgress: Integer;
  LWriteSize: Integer;
  LReadBytes: Integer;
  LProgressMax: Integer;
  LCompressedSize: Integer;
begin
  // store the size of the InStream
  FInStreamSize := InStream.Size;
  // allocate memory for the read buffer //
  LInBuffer := AllocMem(BufferSize);
  // initalize progress  //
  LProgress := 0;
  // set the max progress  //
  LProgressMax := InStream.Size;
  // while we have bytes in InStream that are not compressed //
  while ThereAreBytes do
  begin
    // attempt to read the BufferSize number of bytes from InStream  //
    LReadBytes := InStream.Read(LInBuffer^, BufferSize);
    // compress the read bytes based on LReadBytes variable which holds
    // the actual number of read bytes from InStream
    ZCompress(LInBuffer, LReadBytes, LOutBuffer, LCompressedSize);
    // if we don't have a cipher assigned
    if NOT Assigned(FCipher) then
    begin
      // set the reference to LOutBuffer
      LWriteBuffer := LOutBuffer;
      // copy the size of the buffer
      LWriteSize := LCompressedSize;
    end
    else
      // we have a cipher assigned, this means that we need to
      // call the default EncryptData method which will encrypt our
      // compressed data
      FCipher.EncryptData(LOutBuffer, LCompressedSize, LWriteBuffer,
        LWriteSize);
    // set the inital size of the block, we check it on decompress
    LBlockDesc.InitialSize := LReadBytes;
    // set the number of bytes that we have compressed and/or encrypted
    LBlockDesc.Size := LWriteSize;
    // write the block descriptor
    OutStream.WriteBuffer(LBlockDesc, szDGBlockDesc);
    // write the block data
    OutStream.WriteBuffer(LWriteBuffer^, LWriteSize);
    // free memory from LOutBuffer
    FreeMem(LOutBuffer);
    // free memory from LWriteBuffer only if a cipher is assigned
    if Assigned(FCipher) then
      FreeMem(LWriteBuffer);
    // increment the progress by the number of read bytes
    Inc(LProgress, LReadBytes);
    // update the size of the OutStream
    FOutStreamSize := OutStream.Size;
    // if the OnProgress event is assigned then call it by passing
    // the current progress and the maximum progress
    if Assigned(FOnProgress) then
      FOnProgress(LProgress, LProgressMax);
  end; // while ThereAreBytes do begin
  // free memory from LInBuffer
  FreeMem(LInBuffer, BufferSize);
end;

constructor TDGCompressor.Create;
begin
  // initialize default values //
  FBufferSize := CBUFFER_SIZE;
  FInStreamSize := 0;
  FOutStreamSize := 0;
end;

procedure TDGCompressor.DecompressFile(const InFileName, OutFileName: string);
var
  LInFileStream: TFileStream;
  LOutFileStream: TFileStream;
begin
  // create TFileStream instances  //
  LInFileStream := TFileStream.Create(InFileName, fmOpenRead or
    fmShareDenyNone);
  LOutFileStream := TFileStream.Create(OutFileName,
    fmCreate or fmShareDenyNone);
  // call OnBeforeDecompress event if assigned //
  if Assigned(FOnBeforeDecompress) then
    FOnBeforeDecompress(InFileName, OutFileName, LInFileStream.Size,
      LOutFileStream.Size);
  // attempt to decompress stream  //
  try
    DecompressStream(LInFileStream, LOutFileStream);
  finally
    // free objects  //
    FreeAndNil(LInFileStream);
    FreeAndNil(LOutFileStream);
  end; // tryf
  // call OnAfterDecompress event if assigned  //
  if Assigned(FOnAfterDecompress) then
    FOnAfterDecompress(InFileName, OutFileName, LInFileStream.Size,
      LOutFileStream.Size);
end;

procedure TDGCompressor.DecompressStream(const InStream, OutStream: TStream);

  function ThereAreBytes: Boolean;
  begin
    Result := (InStream.Position < InStream.Size) and
      ((InStream.Size - InStream.Position) > 0);
  end; // function ThereAreBytes: Boolean;

var
  LInBuffer: Pointer;
  LOutBuffer: Pointer;
  LWriteBuffer: Pointer;
  LBlockDesc: TDGBlockDesc;
  LProgress: Integer;
  LWriteSize: Integer;
  LReadBytes: Integer;
  LProgressMax: Integer;
  LDecompressedSize: Integer;
begin
  // store the size of the InStream
  FInStreamSize := InStream.Size;
  // allocate memory for the read buffer //
  LInBuffer := AllocMem(BufferSize);
  // initalize progress  //
  LProgress := 0;
  // set the max progress  //
  LProgressMax := InStream.Size;
  // while we have bytes in InStream ... //
  while ThereAreBytes do
  begin
    // read the block descriptor from stream
    InStream.ReadBuffer(LBlockDesc, szDGBlockDesc);
    // attempt to read the number of bytes in the block descriptor
    LReadBytes := InStream.Read(LInBuffer^, LBlockDesc.Size);
    // if we don't have a cipher assigned  ///
    if NOT Assigned(FCipher) then
    begin
      // decompress the buffer //
      ZDecompress(LInBuffer, LReadBytes, LOutBuffer, LDecompressedSize);
      // set reference to LOutBuffer //
      LWriteBuffer := LOutBuffer;
      // copy the number of bytes  //
      LWriteSize := LDecompressedSize;
    end
    else
    begin
      // we have a cipher assigned, we first decrypt data  //
      FCipher.DecryptData(LInBuffer, LReadBytes, LOutBuffer, LDecompressedSize);
      // and then decompress it  //
      ZDecompress(LOutBuffer, LDecompressedSize, LWriteBuffer, LWriteSize);
    end; // if NOT Assigned(FCipher) then begin
    // check if initial size is equal to current (decrypted and) decompressed size //
    if LBlockDesc.InitialSize <> LWriteSize then
      if Assigned(FOnDecompressFail) then
        FOnDecompressFail(LBlockDesc, LInBuffer, LWriteBuffer, LReadBytes,
          LWriteSize);
    OutStream.WriteBuffer(LWriteBuffer^, LWriteSize);
    FreeMem(LOutBuffer);
    if Assigned(FCipher) then
      FreeMem(LWriteBuffer);
    Inc(LProgress, LReadBytes + szDGBlockDesc);
    // update the size of the OutStream
    FOutStreamSize := OutStream.Size;
    // if the OnProgress event is assigned then call it by passing
    // the current progress and the maximum progress
    if Assigned(FOnProgress) then
      FOnProgress(LProgress, LProgressMax);
  end; // while ThereAreBytes do begin
  // free memory from LInBuffer
  FreeMem(LInBuffer, BufferSize);
end;

end.