UNIT FormLog;

{=============================================================================================================
   CubicDesign
   2022-04-02
   See Copyright.txt

   Visual log (window).
   More details in FormLog.pas

   Usage:
     Call CreateLogForm as early as possible in your app and ReleaseLogForm as late as possible in your app.
=============================================================================================================}

INTERFACE

USES
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  clRichLogTrack, clRichLog;

TYPE
  TfrmLog = class(TForm)
    Log        : TRichLog;
    Container  : TPanel;    { We use a container for all controls on this form so we can reparent them easily to another form }
    pnlBottom  : TPanel;
    chkAutoOpen: TCheckBox;
    btnClear   : TButton;
    trkLogVerb : TRichLogTrckbr;
    procedure btnClearClick(Sender: TObject);
    procedure LogError     (Sender: TObject);
    procedure FormDestroy  (Sender: TObject);
    procedure FormCreate   (Sender: TObject);
  end;

{ Initialization }
function  CreateLogForm: TfrmLog;
procedure ReleaseLogForm;
procedure ShowLog;

{ Utils }
procedure LogAddVerb (Mesaj: string);
procedure LogAddHint (Mesaj: string);
procedure LogAddInfo (Mesaj: string);
procedure LogAddImpo (Mesaj: string);
procedure LogAddWarn (Mesaj: string);
procedure LogAddError(Mesaj: string);
procedure LogAddMsg  (Mesaj: string);
procedure LogAddBold (Mesaj: string);

procedure LogAddEmptyRow;
procedure LogClear;
procedure LogSaveAsRtf(CONST FileName: string);


IMPLEMENTATION {$R *.dfm}

USES
   ccIniFileVCL, ccAppdata;

VAR
   frmLog: TfrmLog = NIL; // Keep this private



{-------------------------------------------------------------------------------------------------------------
   MAIN FUNCTIONS
-------------------------------------------------------------------------------------------------------------}

{ Call this as soon as possible so it can catch all Log messages generated during app start up. A good place might be in your DPR file before Application.CreateForm(TMainForm, frmMain) }
function CreateLogForm: TfrmLog;
begin
 Assert(frmLog = NIL, 'frmLog already created!');
 frmLog:= TfrmLog.Create(NIL);
 Result:= frmLog;
 LoadForm(frmLog);
 Assert(Application.MainForm <> frmLog, 'The Log should not be the MainForm'); { Just in case: Make sure this is not the first form created }
end;


{ Call this as late as possible, on application shutdown }
procedure ReleaseLogForm;
begin
 FreeAndNil(frmLog);
end;


procedure ShowLog;
begin
 frmLog.Show;
end;




{-------------------------------------------------------------------------------------------------------------
   FORM
-------------------------------------------------------------------------------------------------------------}
procedure TfrmLog.FormCreate(Sender: TObject);
begin
 Log.Onwarn:= LogError; // Auto show form if we send an error msg to the log
 Log.OnError:= LogError; 
end;


procedure TfrmLog.FormDestroy(Sender: TObject);
begin
 Container.Parent:= Self;
 if NOT ccAppdata.AppInitializing { We don't save anything if the start up was improper! }
 then SaveForm(Self);
end;


procedure TfrmLog.btnClearClick(Sender: TObject);
begin
 Log.Clear;
end;


procedure TfrmLog.LogError(Sender: TObject);
begin
 if chkAutoOpen.Checked
 then Show;
end;







{--------------------------------------------------------------------------------------------------
   UTILS
   SEND MESSAGES DIRECTLY TO LOG WND
--------------------------------------------------------------------------------------------------}
procedure LogAddVerb(Mesaj: string);
begin
 Assert(frmLog <> NIL, 'The log window is not ready yet!');
 frmLog.Log.AddVerb(Mesaj);
end;


procedure LogAddHint(Mesaj: string);
begin
 Assert(frmLog <> NIL, 'The log window is not ready yet!');
 frmLog.Log.AddHint(Mesaj);
end;


procedure LogAddInfo(Mesaj: string);
begin
 Assert(frmLog <> NIL, 'The log window is not ready yet!');
 frmLog.Log.AddInfo(Mesaj);
end;


procedure LogAddImpo(Mesaj: string);
begin
 Assert(frmLog <> NIL, 'The log window is not ready yet!');
 frmLog.Log.AddImpo(Mesaj);
end;


procedure LogAddWarn(Mesaj: string);
begin
 Assert(frmLog <> NIL, 'The log window is not ready yet!');
 frmLog.Log.AddWarn(Mesaj);
end;


procedure LogAddError(Mesaj: string);
begin
 Assert(frmLog <> NIL, 'The log window is not ready yet!');
 frmLog.Log.AddError(Mesaj);

 if frmLog.chkAutoOpen.Checked
 then ShowLog
end;


procedure LogAddMsg(Mesaj: string);  { Always show this message, no matter the verbosity of the log. Equivalent to Log.AddError but the msg won't be shown in red. }
begin
 Assert(frmLog <> NIL, 'The log window is not ready yet!');
 frmLog.Log.AddMsg(Mesaj);
end;


procedure LogAddBold(Mesaj: string);
begin
 Assert(frmLog <> NIL, 'The log window is not ready yet!');
 frmLog.Log.AddBold(Mesaj);
end;






procedure LogClear;
begin
 Assert(frmLog <> NIL, 'The log window is not ready yet!');
 frmLog.Log.AddEmptyRow;
end;


procedure LogAddEmptyRow;
begin
 Assert(frmLog <> NIL, 'The log window is not ready yet!');
 frmLog.Log.AddEmptyRow;
end;

procedure LogSaveAsRtf(CONST FileName: string);
begin
 Assert(frmLog <> NIL, 'The log window is not ready yet!');
 frmLog.Log.SaveAsRtf(FileName);
end;





end.
