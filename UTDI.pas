unit UTDI;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, UxTheme, Themes, System.Math;

type
  TTDI = class
    private
      PageControl1: TPageControl;
      FCloseButtonsRect: array of TRect;
      FCloseButtonMouseDownIndex: Integer;
      FCloseButtonShowPushed: Boolean;

      procedure PageControl1DrawTab(Control: TCustomTabControl; TabIndex: Integer;
        const Rect: TRect; Active: Boolean);
      procedure PageControl1MouseDown(Sender: TObject; Button: TMouseButton;
        Shift: TShiftState; X, Y: Integer);
      procedure PageControl1MouseMove(Sender: TObject; Shift: TShiftState; X,
        Y: Integer);
      procedure PageControl1MouseLeave(Sender: TObject);
      procedure PageControl1MouseUp(Sender: TObject; Button: TMouseButton;
        Shift: TShiftState; X, Y: Integer);
      procedure SetFCloseButtonsRect;
      function RetornarFormulario(AIndice: Integer): TForm;
      procedure FecharTabSheet(AIndice: Integer);
      function AtivarTabSheet(AForm: TFormClass): TTabSheet;
    public
      constructor Create(AParent: TWinControl);
      destructor Destroy; override;

      procedure AddPage(AForm: TFormClass);
      procedure FecharTodasTabSheet;
  end;

implementation

{ TTDI }

procedure TTDI.AddPage(AForm: TFormClass);
var
  TabSheet, Previous: TTabSheet;
  Form: TForm;
begin
  Previous := PageControl1.ActivePage;
  PageControl1.ActivePage := AtivarTabSheet(AForm);

  if PageControl1.ActivePage <> Nil then
    Exit;

  TabSheet := TTabSheet.Create(PageControl1);
  TabSheet.PageControl := PageControl1;

  PageControl1.Visible := PageControl1.PageCount > 0;

  Form := TFormClass(AForm).Create(TabSheet);
  Form.Parent := TabSheet;
  Form.Align := alClient;
  Form.BorderStyle := bsNone;
  TabSheet.Caption := Form.Caption;
  Form.Show;

  SetFCloseButtonsRect;
end;

function TTDI.AtivarTabSheet(AForm: TFormClass): TTabSheet;
var
  i: Integer;
begin
  Result := Nil;

  i := 0;

  if PageControl1.ActivePage <> Nil then
    if RetornarFormulario(PageControl1.ActivePageIndex) is AForm then
      i := PageControl1.ActivePageIndex;

  for i := i to Pred(PageControl1.PageCount) do
    if RetornarFormulario(i) is AForm then
    begin
      Result := PageControl1.Pages[i];

      if not (PageControl1.ActivePage = Result) then
        Break;
    end;
end;

constructor TTDI.Create(AParent: TWinControl);
begin
  PageControl1 := TPageControl.Create(AParent);
  PageControl1.OnDrawTab := PageControl1DrawTab;
  PageControl1.OnMouseDown := PageControl1MouseDown;
  PageControl1.OnMouseMove := PageControl1MouseMove;
  PageControl1.OnMouseLeave := PageControl1MouseLeave;
  PageControl1.OnMouseUp := PageControl1MouseUp;

  PageControl1.Name := 'PageControl1';
  PageControl1.Parent := AParent;
  PageControl1.Align := alClient;
  PageControl1.TabWidth := 150;
  PageControl1.OwnerDraw := True;
end;

destructor TTDI.Destroy;
begin
  FreeAndNil(PageControl1);
  inherited;
end;

procedure TTDI.FecharTabSheet(AIndice: Integer);
var
  Form: TForm;
begin
  Form := RetornarFormulario(AIndice);
  if Form <> Nil then
  begin
    Form.Close;
    if not Form.Visible then
      Form.Free;

    if RetornarFormulario(AIndice) = Nil then
    begin
      PageControl1.ActivePage := Nil;
      PageControl1.Pages[AIndice].Free;
    end;
  end;

  PageControl1.Visible := PageControl1.PageCount > 0;
end;

procedure TTDI.FecharTodasTabSheet;
var
  i: Integer;
begin
  for i := PageControl1.PageCount - 1 downto 0 do
    FecharTabSheet(i);
end;

procedure TTDI.PageControl1DrawTab(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
var
  CloseBtnSize: Integer;
  PageControl: TPageControl;
  TabCaption: TPoint;
  CloseBtnRect: TRect;
  CloseBtnDrawState: Cardinal;
  CloseBtnDrawDetails: TThemedElementDetails;
begin
  PageControl := Control as TPageControl;

  if InRange(TabIndex, 0, Length(FCloseButtonsRect) - 1) then
  begin
    CloseBtnSize := 14;
    TabCaption.Y := Rect.Top + 3;

    if Active then
    begin
      CloseBtnRect.Top := Rect.Top + 4;
      CloseBtnRect.Right := Rect.Right - 5;
      TabCaption.X := Rect.Left + 6;
    end
    else
    begin
      CloseBtnRect.Top := Rect.Top + 3;
      CloseBtnRect.Right := Rect.Right - 5;
      TabCaption.X := Rect.Left + 3;
    end;

    CloseBtnRect.Bottom := CloseBtnRect.Top + CloseBtnSize;
    CloseBtnRect.Left := CloseBtnRect.Right - CloseBtnSize;
    FCloseButtonsRect[TabIndex] := CloseBtnRect;

    PageControl.Canvas.FillRect(Rect);
    PageControl.Canvas.TextOut(TabCaption.X, TabCaption.Y, PageControl.Pages[TabIndex].Caption);

    if not UseThemes then
    begin
      if (FCloseButtonMouseDownIndex = TabIndex) and FCloseButtonShowPushed then
        CloseBtnDrawState := DFCS_CAPTIONCLOSE + DFCS_PUSHED
      else
        CloseBtnDrawState := DFCS_CAPTIONCLOSE;

      DrawFrameControl(PageControl.Canvas.Handle,
        FCloseButtonsRect[TabIndex], DFC_CAPTION, CloseBtnDrawState);
    end
    else
    begin
      Dec(FCloseButtonsRect[TabIndex].Left);

      if (FCloseButtonMouseDownIndex = TabIndex) and FCloseButtonShowPushed then
        CloseBtnDrawDetails := ThemeServices.GetElementDetails(twCloseButtonPushed)
      else
        CloseBtnDrawDetails := ThemeServices.GetElementDetails(twCloseButtonNormal);

      ThemeServices.DrawElement(PageControl.Canvas.Handle, CloseBtnDrawDetails,
        FCloseButtonsRect[TabIndex]);
    end;
  end;
end;

procedure TTDI.PageControl1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  PageControl: TPageControl;
begin
  PageControl := Sender as TPageControl;

  if Button = mbLeft then
  begin
    for I := 0 to Length(FCloseButtonsRect) - 1 do
    begin
      if PtInRect(FCloseButtonsRect[I], Point(X, Y)) then
      begin
        FCloseButtonMouseDownIndex := I;
        FCloseButtonShowPushed := True;
        PageControl.Repaint;
      end;
    end;
  end;
end;

procedure TTDI.PageControl1MouseLeave(Sender: TObject);
var
  PageControl: TPageControl;
begin
  PageControl := Sender as TPageControl;
  FCloseButtonShowPushed := False;
  PageControl.Repaint;
end;

procedure TTDI.PageControl1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  PageControl: TPageControl;
  Inside: Boolean;
begin
  PageControl := Sender as TPageControl;

  if (ssLeft in Shift) and (FCloseButtonMouseDownIndex >= 0) then
  begin
    Inside := PtInRect(FCloseButtonsRect[FCloseButtonMouseDownIndex], Point(X, Y));

    if FCloseButtonShowPushed <> Inside then
    begin
      FCloseButtonShowPushed := Inside;
      PageControl.Repaint;
    end;
  end;
end;

procedure TTDI.PageControl1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  PageControl: TPageControl;
begin
  PageControl := Sender as TPageControl;

  if (Button = mbLeft) and (FCloseButtonMouseDownIndex >= 0) then
  begin
    if PtInRect(FCloseButtonsRect[FCloseButtonMouseDownIndex], Point(X, Y)) then
    begin
      ShowMessage('Button ' + IntToStr(FCloseButtonMouseDownIndex + 1) + ' pressionado!');

      FecharTabSheet(PageControl1.ActivePageIndex);

      FCloseButtonMouseDownIndex := -1;
      PageControl.Repaint;
    end;
  end;
end;

function TTDI.RetornarFormulario(AIndice: Integer): TForm;
begin
  Result := Nil;

  if PageControl1.PageCount > AIndice then
    with PageControl1.Pages[AIndice] do
      if ComponentCount > 0 then
        if Components[0] is TForm then
          Result := TForm(Components[0]);
end;

procedure TTDI.SetFCloseButtonsRect;
var
  I: Integer;
begin
  SetLength(FCloseButtonsRect, PageControl1.PageCount);
  FCloseButtonMouseDownIndex := -1;

  for I := 0 to Length(FCloseButtonsRect) - 1 do
  begin
    FCloseButtonsRect[I] := Rect(0, 0, 0, 0);
  end;
end;

end.
