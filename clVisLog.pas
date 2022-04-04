UNIT clVisLog;

{=============================================================================================================
  Visual Log
   CubicDesign
   2021.10.23
   See Copyright.txt

   The new log (based on TStringGrid)
   Drop a TVisLog on your form. Pass its RamLog property as reference to all TCube objects when I need to log stuff.

   Hint: http://stackoverflow.com/questions/11719454/why-dont-child-controls-of-a-tstringgrid-work-properly

   Tester: c:\MyProjects\Project Testers\NEW LOG tester\
=============================================================================================================}

{TODO 3: Sort lines by criticality (all errors together, all warnings together, etc) }
{TODO 3: Let user show/hide grid lines}

INTERFACE

USES
   Winapi.Messages, System.SysUtils, Winapi.Windows, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.StdCtrls, vcl.Forms, Vcl.Grids,
   clVisLogLines, clVisLogRam, clVisLogUtils;

//BUG: ScrollBars not working!

TYPE
  TVisLog = class(TStringGrid)
   private
     Initialized: Boolean;
     FVerbFilter: TLogVerb;
     FAutoScroll: Boolean;
     FInsertTime: Boolean;
     FInsertDate: Boolean;
     FLogError  : TNotifyEvent;
     FLogWarn   : TNotifyEvent;
     ScrollBar  : TScrollBar;
     FRamLog    : TVisRamLog;
     procedure BottomRow(CurAvaRow: Integer);
     procedure WMCommand(var AMessage: TWMCommand); message WM_COMMAND;
     procedure FixFixedRow;
   protected
     Indent: Integer;                                                                                                   { Indent new added lines x spaces }
     procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
   public
     constructor Create(AOwner: TComponent);   override;
     destructor Destroy; override;
     procedure CreateWindowHandle(const Params: TCreateParams); override;
     procedure Clear;
     procedure ContentChanged;
     procedure SetUp;
   published
     property ShowTime   : Boolean      read FInsertTime write FInsertTime default FALSE;
     property ShowDate   : Boolean      read FInsertDate write FInsertDate default FALSE;
     property AutoScroll : Boolean      read FAutoScroll write FAutoScroll default TRUE;                                { Automatically scroll to show the last line }
     property Verbosity  : TLogVerb     read FVerbFilter write FVerbFilter;                                             { Filter out all messages BELOW this verbosity level }

     property OnError    : TNotifyEvent read FLogError   write FLogError;                                                   { Can be used to inform the application to automatically switch to log when an error is listed }
     property OnWarn     : TNotifyEvent read FLogWarn    write FLogWarn;
     property RamLog     : TVisRamLog   read FRamLog;
  end;

procedure Register;

IMPLEMENTATION

USES ccCore;


constructor TVisLog.Create(AOwner: TComponent);
begin
 inherited Create(AOwner);     // Note: Don't set 'Parent:= Owner' in constructor. Details: http://stackoverflow.com/questions/6403217/how-to-set-a-tcustomcontrols-parent-in-create
 FRamLog:= TVisRamLog.Create;
 FRamLog.SetLog(Self);

 FInsertTime       := FALSE;
 FInsertDate       := False;
 FVerbFilter       := lvVerbose;
 FAutoScroll       := TRUE;
 Indent            := 0;                                                                                  { Intend new added lines with x spaces }

 ScrollBar         := TScrollBar.Create(Self);    // Here I can set the parent. ANYWAY, it may not be a good idea to put controls into TStringGrid. It was not designed for that.
 ScrollBar.Parent  := Self;
end;


//CreateWnd can be called more than once:  http://docs.embarcadero.com/products/rad_studio/delphiAndcpp2009/HelpUpdate2/EN/html/delphivclwin32/Controls_TWinControl_CreateWnd.html
procedure TVisLog.CreateWindowHandle(const Params: TCreateParams);
begin
 inherited CreateWindowHandle(Params);

 if NOT Initialized then { Make sure we don't call this code twice }
  begin
   Initialized:= TRUE;

   ScrollBars      := ssNone;
   RowCount        := HeaderOverhead;
   ColCount        := 3;
   FixedCols       := 0;
   ColWidths[0]    := 110;
   ColWidths[1]    := Width- ColWidths[0]- ScrollBar.Width;
   Cells[0, 0]     := 'Time';
   Cells[1, 0]     := 'Message';

   ScrollBar.Kind  := sbVertical;
   ScrollBar.Align := alRight;
   ScrollBar.DoubleBuffered := FALSE;           { fix delphi bug }
  end;
end;


destructor TVisLog.Destroy;
begin
  FreeAndNil(FRamLog);
  inherited;
end;


procedure TVisLog.Clear;
begin
 RowCount:= 1;
 Assert(ScrollBar <> NIL);
 ScrollBar.Position:= 0;
 ScrollBar.Max:= 0;
 ScrollBar.Visible:= FALSE;
 if RamLog <> NIL
 then RamLog.Clear;
end;


{ Allows the 'click' action to reach the Button }
procedure TVisLog.WMCommand(var AMessage: TWMCommand);
begin
  if EditorMode AND (AMessage.Ctl = InplaceEditor.Handle)
  then inherited
  else
    if AMessage.Ctl <> 0
    then AMessage.Result := SendMessage(AMessage.Ctl, CN_COMMAND, TMessage(AMessage).WParam, TMessage(AMessage).LParam);
end;






{--------------------------------------------------------------------------------------------------
   CONTENT
--------------------------------------------------------------------------------------------------}
procedure TVisLog.SetUp;

  function computeRowCount: Integer;
  begin
   Result:= Trunc((ClientHeight / (DefaultRowHeight+1)));  // RoundDown
   if Result > FRamLog.Lines.Count+ HeaderOverhead
   then Result:= FRamLog.Lines.Count+ HeaderOverhead;
  end;

  procedure SetScrollBar;
  VAR Max: Integer;
  begin
   Max:= (FRamLog.Lines.Count+ HeaderOverhead)- rowCount;
   if Max < 0 then Max:= 0;
   ScrollBar.Max:= Max;
   ScrollBar.Visible:= Max > 0;
  end;

begin
 Assert(FRamLog <> NIL, 'RamLog not assigned!');
 Assert((ScrollBars= ssHorizontal) OR (ScrollBars = ssNone));

 RowCount:= computeRowCount;
 ColCount:= 3;                                                          { We only add Grid columns for the visible AVA columns }
 SetScrollBar;

 FixFixedRow;
end;



procedure TVisLog.ContentChanged;
begin
 SetUp;
 InvalidateGrid;
 if AutoScroll
 then BottomRow(RowCount);
end;



procedure TVisLog.FixFixedRow;
begin
 if (csCreating in ControlState) then EXIT;

 { Add fixed row }
 if (FixedRows< 1)
 AND (RowCount> 1)
 then FixedRows:= 1;

 { Remove fixed row }
 if (FixedRows> 0)
 AND (RowCount< 2)
 then FixedRows:= 0;
end;












{--------------------------------------------------------------------------------------------------
   DRAW
--------------------------------------------------------------------------------------------------}

procedure TVisLog.DrawCell(ACol, ARow: Integer; ARect: TRect; AState: TGridDrawState);
VAR
   s: string;
   LogLine: PLogLine;
   FilteredRow: integer;
begin
 if (csDesigning in ComponentState)
 OR (csCreating in ControlState)
 OR (FRamLog= NIL)
 OR (FRamLog.Lines.Count= 0)
 OR (ARow = 0)                       // header
 OR NOT DefaultDrawing then
  begin
   inherited;
   EXIT;
  end;

 if ARow- HeaderOverhead > FRamLog.Lines.Count then
  begin
   inherited;
   EXIT;
  end;

 {TODO: take into account the grid scrollbar }
 FilteredRow:= FRamLog.Lines.GetFilteredRow(aRow- HeaderOverhead, Verbosity);
 if FilteredRow < 0 then
  begin
   inherited;
   EXIT;
  end;
 LogLine:= FRamLog.Lines[FilteredRow];

 case ACol of
  0: s:= DateTimeToStr(LogLine.Time);
  1: s:= LogLine.Msg;
 end;

 Canvas.Font.Color:= Verbosity2Color(LogLine.Level);
 Canvas.TextRect(ARect, ARect.Left+2, ARect.Top+2, s);
end;
















{--------------------------------------------------------------------------------------------------
   STUFF
--------------------------------------------------------------------------------------------------} {
procedure TVisLog.setRamLog(const Value: TVisRamLog);
begin
 FRamLog := Value;

 if FRamLog <> NIL
 then FRamLog.Log:= Self;
end; }



procedure TVisLog.BottomRow(CurAvaRow: Integer);   { Similar to TopRow. Scroll to the last low }
VAR Rw: Integer;
begin
 Rw:= CurAvaRow- VisibleRowCount-1;
 if rw < 0
 then ScrollBar.Position:= FixedRows+1    {  Set TopRow to scroll the rows in the grid so that the row with index TopRow is the first row after the fixed rows  }
 else ScrollBar.Position:= Rw;
end;





procedure Register;
begin
  RegisterComponents('Cubic', [TVisLog]);
end;



end.
