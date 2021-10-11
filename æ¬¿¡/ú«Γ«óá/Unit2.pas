unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,SHELLAPI,MMSystem,JvSlider,Tlhelp32, MPlayer;
 const
 MCI_SETAUDIO = $0873;
 MCI_DGV_SETAUDIO_VOLUME = $4002;
 MCI_DGV_SETAUDIO_ITEM = $00800000;
 MCI_DGV_SETAUDIO_VALUE = $01000000;
 MCI_DGV_STATUS_VOLUME = $4019;
 WM_MYICONNOTIFY = WM_USER + 123;
type
 MCI_DGV_SETAUDIO_PARMS = record
   dwCallback: DWORD;
   dwItem: DWORD;
   dwValue: DWORD;
   dwOver: DWORD;
   lpstrAlgorithm: PChar;
   lpstrQuality: PChar;
 end;

type
 MCI_STATUS_PARMS = record
   dwCallback: DWORD;
   dwReturn: DWORD;
   dwItem: DWORD;
   dwTrack: DWORD;
 end;
  type
  TForm2 = class(TForm)
    Image1: TImage;
    ListBox1: TListBox;
    Edit1: TEdit;
    MediaPlayer1: TMediaPlayer;
    Image2: TImage;
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListBox1DblClick(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure MediaPlayer1Notify(Sender: TObject);
  private

     Dragging: Boolean;
    OldLeft, OldTop: Integer;
    { Private declarations }
      public
    { Public declarations }
  end;

var
  Form2: TForm2;
  s:string;
  p:integer;
implementation

uses Unit1;

{$R *.dfm}
function CreateRgnFromBitmap(rgnBitmap: TBitmap): HRGN;
var
  TransColor: TColor;
  i, j: Integer;
  i_width, i_height: Integer;
  i_left, i_right: Integer;
  rectRgn: HRGN;

begin
  Result := 0;
 i_width := rgnBitmap.Width;
 i_height := rgnBitmap.Height;
 transColor := rgnBitmap.Canvas.Pixels[0, 0];

 for i := 0 to i_height - 1 do
   begin  i_left := -1;

   for j := 0 to i_width - 1 do
     begin
       if i_left < 0 then
         begin
           if rgnBitmap.Canvas.Pixels[j, i] <> transColor then
             i_left := j;
           end
         else
           if rgnBitmap.Canvas.Pixels[j, i] = transColor then
             begin
               i_right := j;
               rectRgn := CreateRectRgn(i_left, i, i_right, i + 1);
               if Result = 0 then
                 Result := rectRgn
               else
                 begin
                   CombineRgn(Result, Result, rectRgn, RGN_OR);
                   DeleteObject(rectRgn);
                 end;
               i_left := -1;
             end;
           end;
         if i_left >= 0 then
           begin
             rectRgn := CreateRectRgn(i_left, i, i_width, i+1);
             if Result = 0 then
                 Result := rectRgn
               else
                 begin
                   CombineRgn(Result, Result, rectRgn, RGN_OR);
                   DeleteObject(rectRgn);
                 end;
               end;
             end;
end;
 procedure SetMPVolume(MP: TMediaPlayer; Volume: Integer);
 { Volume: 0 - 1000 }
var
 p: MCI_DGV_SETAUDIO_PARMS;
begin
 { Volume: 0 - 1000 }
 p.dwCallback := 0;
 p.dwItem := MCI_DGV_SETAUDIO_VOLUME;
 p.dwValue := Volume;
 p.dwOver := 0;
 p.lpstrAlgorithm := nil;
 p.lpstrQuality := nil;
 mciSendCommand(MP.DeviceID, MCI_SETAUDIO,
   MCI_DGV_SETAUDIO_VALUE or MCI_DGV_SETAUDIO_ITEM, Cardinal(@p));
end;
procedure TForm2.FormCreate(Sender: TObject);
var WindowRgn: HRGN;
begin
BorderStyle := bsNone;
  ClientWidth := Image1.Picture.Bitmap.Width;
  ClientHeight := Image1.Picture.Bitmap.Height;
  WindowRgn := CreateRgnFromBitmap(Image1.Picture.Bitmap);
  SetWindowRgn(Handle, WindowRgn, True);
  SnapBuffer:=10;
  end;

procedure TForm2.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if button=mbLeft then
    begin
      Dragging := True;
      OldLeft := X;
      OldTop := Y;
    end;
end;

procedure TForm2.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
if Dragging then
    begin
      Left := Left+X-OldLeft;
      Top := Top+Y-OldTop;
    end;
end;

procedure TForm2.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
Dragging := false;
end;

procedure TForm2.ListBox1DblClick(Sender: TObject);
var   h:string;
begin
form1.Edit1.Text:='1';
form1.image2.Picture.LoadFromFile('.\play2.bmp');
form1.image3.Picture.LoadFromFile('.\stop1.bmp');
form1.Edit2.Text:='2';
h:=Edit1.Text;
s:=h+'\'+ListBox1.Items[ListBox1.itemIndex];
MediaPlayer1.Filename := s;
MediaPlayer1.Open;
sleep(300);
MediaPlayer1.Play;
SetMPVolume(MediaPlayer1, form1.TrackBar2.Position);
form1.w1.Text:=ListBox1.Items[ListBox1.itemIndex];
p:=ListBox1.itemIndex;
end;

procedure TForm2.Image2Click(Sender: TObject);
begin
form2.AlphaBlend:=true;
form2.AlphaBlendValue:=0;
list:=2;
end;

procedure TForm2.MediaPlayer1Notify(Sender: TObject);
var a:integer; SOUNDPATCH,s,l:string;
begin
with MediaPlayer1 do
    if NotifyValue = nvSuccessful then 
      begin 
     l:=(ListBox1.Items[p+1]);
s:=edit1.Text+'\'+l;
MediaPlayer1.Filename := s;
MediaPlayer1.Open;
sleep(300);
MediaPlayer1.Play;
SetMPVolume(MediaPlayer1,form1.TrackBar2.Position);
Notify := True;
Play;


end;
end;

end.
