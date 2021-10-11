unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvSlider, ExtCtrls,MMSystem, MPlayer, StdCtrls, JvWinampLabel,
  ShellApi,ComObj,activex, FileCtrl,Registry, Menus;
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
  TForm1 = class(TForm)
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    TrackBar1: TJvSlider;
    Timer1: TTimer;
    Image4: TImage;
    Image5: TImage;
    TrackBar2: TJvSlider;
    w1: TJvWinampLabel;
    w2: TJvWinampLabel;
    Image6: TImage;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    Edit1: TEdit;
    Edit2: TEdit;
    Image7: TImage;
    PopupMenu2: TPopupMenu;
    RestoreItem: TMenuItem;
    procedure Image2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image4Click(Sender: TObject);
    procedure Image3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image3MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image5MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image5MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TrackBar2Changed(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TrackBar1Changed(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image6MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image6MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure N2Click(Sender: TObject);
    procedure Image7Click(Sender: TObject);
    procedure RestoreItemClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  Dragging: Boolean;
    OldLeft, OldTop: Integer;
  ShownOnce: Boolean;
  public
     procedure WMICON(var msg: TMessage); message WM_MYICONNOTIFY;
    procedure WMSYSCOMMAND(var msg: TMessage);message WM_SYSCOMMAND;
    procedure RestoreMainForm;
    procedure HideMainForm;
    procedure CreateTrayIcon(n:Integer);
    procedure DeleteTrayIcon(n:Integer);
    { Public declarations }
  end;

var
  Form1: TForm1;
  p:integer;
  s:integer;
   Path: String;
  o:integer;
  c:integer;
  r:string;
  FileName: string;  // имя или маска искомого файла
   cDir: string;
   n: integer;
  Reg: TRegistry;
  list:integer;
  implementation

uses Unit2;

{$R *.dfm}
 procedure TForm1.WMICON(var msg: TMessage);
var P : TPoint;
begin
 case msg.LParam of
 WM_LBUTTONDOWN:
  begin
   GetCursorPos(p);
   SetForegroundWindow(Application.MainForm.Handle);
   PopupMenu2.Popup(P.X, P.Y);
  end;
 WM_LBUTTONDBLCLK : RestoreItemClick(Self);
 end;
end;

procedure TForm1.WMSYSCOMMAND(var msg: TMessage);
begin
 inherited;
 if (Msg.wParam=SC_MINIMIZE) then restoreItemClick(Self);
end;


procedure TForm1.HideMainForm;
begin
  Application.ShowMainForm := False;
  ShowWindow(Application.Handle, SW_HIDE);
  ShowWindow(Application.MainForm.Handle, SW_HIDE);
end;

procedure TForm1.RestoreMainForm;
var i,j : Integer;
begin
  Application.ShowMainForm := True;
  ShowWindow(Application.Handle, SW_RESTORE);
  ShowWindow(Application.MainForm.Handle, SW_RESTORE);
  if not ShownOnce then
  begin
    for I := 0 to Application.MainForm.ComponentCount -1 do
      if Application.MainForm.Components[I] is TWinControl then
        with Application.MainForm.Components[I] as TWinControl do
          if Visible then
          begin
            ShowWindow(Handle, SW_SHOWDEFAULT);
            for J := 0 to ComponentCount -1 do
              if Components[J] is TWinControl then
                ShowWindow((Components[J] as TWinControl).Handle, SW_SHOWDEFAULT);
          end;
    ShownOnce := True;
  end;

end;

procedure TForm1.CreateTrayIcon(n:Integer);
var nidata : TNotifyIconData;
begin
 with nidata do
  begin
   cbSize := SizeOf(TNotifyIconData);
   Wnd := Self.Handle;
   uID := 1;
   uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
   uCallBackMessage := WM_MYICONNOTIFY;
   hIcon := Application.Icon.Handle;
   StrPCopy(szTip,Application.Title);
  end;
  Shell_NotifyIcon(NIM_ADD, @nidata);
end;

procedure TForm1.DeleteTrayIcon(n:Integer);
var nidata : TNotifyIconData;
begin
 with nidata do
  begin
   cbSize := SizeOf(TNotifyIconData);
   Wnd := Self.Handle;
   uID := 1;
  end;
  Shell_NotifyIcon(NIM_DELETE, @nidata);
end;
procedure TForm1.FormDestroy(Sender: TObject);
begin
 DeleteTrayIcon(1);
end;

procedure TForm1.RestoreItemClick(Sender: TObject);
begin
 RestoreMainForm;
 DeleteTrayIcon(1);
 RestoreItem.Enabled := False;

end;


procedure Find;
var
   SearchRec: TSearchRec; // информация о файле или каталоге
begin
   GetDir(0,cDir); // получить имя текущего каталога
   if cDir[length(cDir)] <> '\' then cDir := cDir+'\';
   if FindFirst(FileName, faArchive,SearchRec) = 0 then
repeat
   if (SearchRec.Attr and faAnyFile) = SearchRec.Attr then
begin
   Form2.ListBox1.Items.Add(cDir +  SearchRec.Name);
   n := n + 1;
end;
   until FindNext(SearchRec) <> 0;

// обработка подкаталогов текущего каталога
   if FindFirst('*', faDirectory, SearchRec) = 0 then
repeat
   if (SearchRec.Attr and faDirectory) = SearchRec.Attr then
begin
// каталоги .. и . тоже каталоги,
// но в них входить не надо !!!
   if SearchRec.Name[1] <> '.' then
begin
   ChDir(SearchRec.Name);// войти в каталог
   Find; // выполнить поиск в подкаталоге
   ChDir('..');// выйти из каталога
end;
end;
   until FindNext(SearchRec) <> 0;
end;

// возвращает каталог, выбранный пользователем
function GetPath(mes: string):string;
var
  Root: string;      // корневой каталог
  pwRoot : PWideChar;
  Dir: string;
begin
  Root := ''; // корневой каталог - папка Рабочий стол
  GetMem(pwRoot, (Length(Root)+1) * 2);
  pwRoot := StringToWideChar(Root,pwRoot,MAX_PATH*2);
  if SelectDirectory(mes, pwRoot, Dir)
  then
  if length(Dir) = 2  // пользователь выбрал корневой каталог
  then GetPath := Dir+'\'
  else GetPath := Dir
  else
  GetPath := '';
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
procedure TForm1.Image2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
image2.Picture.LoadFromFile('.\play2.bmp');
end;

procedure TForm1.Image2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  begin
if edit1.Text='1' then
  begin
 s:=1;
 image2.Picture.LoadFromFile('.\play1.bmp');
 end
else
begin
form2.mediaplayer1.play;
SetMPVolume(form2.MediaPlayer1, TrackBar2.Position);
image2.Picture.LoadFromFile('.\play2.bmp');
image3.Picture.LoadFromFile('.\stop1.bmp');
edit1.Text:='1';
edit2.Text:='2';

end;
end;
procedure TForm1.FormCreate(Sender: TObject);
var WindowRgn: HRGN;v:string;f:TextFile;l:real;
begin
BorderStyle := bsNone;
  ClientWidth := Image1.Picture.Bitmap.Width;
  ClientHeight := Image1.Picture.Bitmap.Height;
  WindowRgn := CreateRgnFromBitmap(Image1.Picture.Bitmap);
  SetWindowRgn(Handle, WindowRgn, True);
  edit1.Text:='1';
  edit2.Text:='1';
  s:=1;
  o:=1;
  c:=1;
  list:=1;
begin
Reg := TRegistry.Create;
  Reg.RootKey := HKEY_CLASSES_ROOT;
  Reg.OpenKey('.mp3' , True);
  Reg.WriteString('', 'mp3file');
  Reg.CloseKey;
  Reg.CreateKey('mp3'+'Burich-Caeser');
  Reg.OpenKey('mp3file\DefaultIcon', True);
  Reg.WriteString('', Application.ExeName+ ',0');
  Reg.CloseKey;
  Reg.OpenKey('mp3file\shell\open\command', True);
  Reg.WriteString('', Application.ExeName + ' "%1"');
  Reg.OpenKey('mp3file\shell\play\command', True);
  Reg.WriteString('', Application.ExeName + ' "%1"');
  Reg.CloseKey;
  Reg.Free;
  begin
  v:='.\param';
  assignfile(f,v);
  reset(f,v);
  readln(f,v);
  trackbar2.Position:=strtoint(v);
  closefile(f);
  l:=round(trackbar2.position/10);
  w2.Text:=floattostr(l);
  SnapBuffer:=10;
  end;
  end;
  end;
  procedure TForm1.Timer1Timer(Sender: TObject);
Var
procent:longint;
begin
if form2.MediaPlayer1.FileName<>'' then
begin
procent:=Round(1000*form2.MediaPlayer1.Position/form2.MediaPlayer1.Length);
TrackBar1.Position:=Procent;
end;

end;
procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if button=mbLeft then
    begin
      Dragging := True;
      OldLeft := X;
      OldTop := Y;
      end;
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
if Dragging then
    begin
    form1.Left := Left+X-OldLeft;
     form1.Top := Top+Y-OldTop;
    form2.Left:=form1.left;
    form2.Top:=form1.Top+116;
        end;
end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 Dragging := false;
end;

procedure TForm1.Image4Click(Sender: TObject);
begin
form1.Close;
end;

procedure TForm1.Image3MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
image3.Picture.LoadFromFile('.\stop2.bmp');
end;

procedure TForm1.Image3MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if edit2.Text='1' then
begin
image3.Picture.LoadFromFile('.\stop1.bmp');
end
else
begin
form2.mediaplayer1.Pause;
image2.Picture.LoadFromFile('.\play1.bmp');
edit1.Text:='2';
edit2.Text:='1';
end;

end;
procedure TForm1.Image5MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
image5.Picture.LoadFromFile('.\close.bmp');
end;

procedure TForm1.Image5MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var    Pat: string;  a,k,h,s:string; f:TextFile;
   SOUNDPATCH:string;
   SearchRec: TSearchRec;
begin
   Pat := GetPath('Выберите папку');
   if Pat <> ''
   then  r:= Pat;
begin
a:='.\Mic';
assignfile(f,a);
rewrite(f);
k:=r+'\';
writeln(f,k);
closefile(f);
SOUNDPATCH:=r;
form2.Edit1.Text:=r;
begin
   Form2.ListBox1.Clear;
   if FindFirst(SOUNDPATCH+'\'+'*.mp3', faAnyFile, SearchRec)
   and FindFirst(SOUNDPATCH+'\'+'*.wma', faAnyFile, SearchRec)
   and FindFirst(SOUNDPATCH+'\'+'*.mpg', faAnyFile, SearchRec)
   and FindFirst(SOUNDPATCH+'\'+'*.mp3', faAnyFile, SearchRec)=0 then

begin

    Form2.ListBox1.Items.Add(SearchRec.Name);
    while (FindNext(SearchRec) = 0) do
    Form2.ListBox1.Items.Add(SearchRec.Name);
    image5.Picture.LoadFromFile('.\open.bmp');
    if FindFirst(SOUNDPATCH+'\'+'*.wma', faAnyFile, SearchRec)
    and FindFirst(SOUNDPATCH+'\'+'*.mp3', faAnyFile, SearchRec)
    and FindFirst(SOUNDPATCH+'\'+'*.mpg', faAnyFile, SearchRec)
    and FindFirst(SOUNDPATCH+'\'+'*.wma', faAnyFile, SearchRec) =0 then
begin
    Form2.ListBox1.Items.Add(SearchRec.Name);
    while (FindNext(SearchRec) = 0) do
    Form2.ListBox1.Items.Add(SearchRec.Name);
    image5.Picture.LoadFromFile('.\open.bmp');
    if FindFirst(SOUNDPATCH+'\'+'*.mpg', faAnyFile, SearchRec)
    and FindFirst(SOUNDPATCH+'\'+'*.wma', faAnyFile, SearchRec)
    and FindFirst(SOUNDPATCH+'\'+'*.mpg', faAnyFile, SearchRec)
    and FindFirst(SOUNDPATCH+'\'+'*.mpg', faAnyFile, SearchRec) =0 then
begin
    Form2.ListBox1.Items.Add(SearchRec.Name);
    while (FindNext(SearchRec) = 0) do
    Form2.ListBox1.Items.Add(SearchRec.Name);
    image5.Picture.LoadFromFile('.\open.bmp');
begin
form1.Edit1.Text:='1';
form1.image2.Picture.LoadFromFile('.\play2.bmp');
form1.Edit2.Text:='2';
h:=form2.Edit1.Text;
s:=h+'\'+form2.ListBox1.Items[0];
form2.MediaPlayer1.Filename := s;
form2.MediaPlayer1.Open;
sleep(300);
form2.MediaPlayer1.Play;
SetMPVolume(form2.MediaPlayer1, form1.TrackBar2.Position);
w1.Text:=form2.ListBox1.Items[0];
end;
end;
end;
end;

end;

end;
end;
procedure TForm1.TrackBar2Changed(Sender: TObject);
var h:real;
begin
h:=round(trackBar2.Position/10);
w2.Text:=floattostr(h);
SetMPVolume(form2.MediaPlayer1, TrackBar2.Position);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var m:string;f:textfile;
begin
m:='.\param';
assignfile(f,m);
rewrite(f);
writeln(f,inttostr(trackbar2.Position));
closefile(f);
form2.Close;
w1.Free;
w2.Free;
end;
procedure TForm1.TrackBar1Changed(Sender: TObject);
var m,v:real;d:integer;f:string;
begin
form2.MediaPlayer1.Pause;
m:=(form2.MediaPlayer1.Length/1000);
v:=round(M*Trackbar1.Position);
f:=floattostr(v);
d:=strtoint(f);
form2.Mediaplayer1.Position:=d;
form2.mediaplayer1.Play;
end;

procedure TForm1.FormShow(Sender: TObject);
var
  Str,int: String;
  i: Integer;
begin

  if (ParamCount > 0) then
    begin
      Str := ParamStr(1);
      for i :=2 to ParamCount do
        begin
          int := Str + ' ' +ParamStr(i);
        end;
      form2.Edit1.Text:=int;
      Form2.ListBox1.Items.Add(Str);
      w1.Text:=str;
      form2.MediaPlayer1.FileName := Str;
      form2.MediaPlayer1.Open;
      sleep(1000);
      form1.image2.Picture.LoadFromFile('.\play2.bmp');
      form2.MediaPlayer1.play;
      SetMPVolume(form2.MediaPlayer1, TrackBar2.Position);
   end;

end;
procedure TForm1.Image6MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
image6.Picture.LoadFromFile('.\list2.bmp');
end;

procedure TForm1.Image6MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if list=1 then
begin
form2.Left:=form1.Left;
form2.Top:=form1.Top+116;
form2.Show;
image6.Picture.LoadFromFile('.\list.bmp');
end
else
begin
image6.Picture.LoadFromFile('.\list.bmp');
form2.Left:=form1.Left;
form2.Top:=form1.Top+116;
form2.AlphaBlend:=true;
form2.AlphaBlendValue:=255;
end;

end;
procedure TForm1.N2Click(Sender: TObject);
begin
if n2.Caption='Поверх всех окон(Да).' then
begin
form1.FormStyle:=fsnormal;
form2.FormStyle:=fsnormal;
n2.Caption:='Поверх всех окон(Нет).';
end
else
begin
form1.FormStyle:=fsstayontop;
form2.FormStyle:=fsstayontop;
n2.Caption:='Поверх всех окон(Да).';
end;
end;
procedure TForm1.Image7Click(Sender: TObject);
begin
HideMainForm;
 CreateTrayIcon(1);
form2.AlphaBlend:=true;
form2.AlphaBlendValue:=0;
list:=2;
 RestoreItem.Enabled := True;
end;









end.

