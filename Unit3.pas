unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  TForm3 = class(TForm)
    Image1: TImage;
    Panel1: TPanel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

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
procedure TForm3.FormCreate(Sender: TObject);
var WindowRgn: HRGN;v:string;f:TextFile;l:real;
begin
BorderStyle := bsNone;
  ClientWidth := Image1.Picture.Bitmap.Width;
  ClientHeight := Image1.Picture.Bitmap.Height;
  WindowRgn := CreateRgnFromBitmap(Image1.Picture.Bitmap);
  SetWindowRgn(Handle, WindowRgn, True);
end;

end.
