UNIT clVisLogUtils;

{=============================================================================================================
   CubicDesign
   2022.03
   See Copyright.txt
=============================================================================================================}

INTERFACE

USES
   System.SysUtils, Vcl.Graphics, ccCore;

TYPE
  TLogVerb= (lvDebug, lvVerbose, lvHints {Default}, lvInfos, lvImportant, lvWarnings, lvErrors);  { Exista also 7 which is of type 'Msg' and it is always shown in log }

CONST
   DefaultVerbosity= lvInfos;

function Verbosity2String(Verbosity: TLogVerb): string;
function Verbosity2Color(Verbosity: TLogVerb): TColor;


IMPLEMENTATION



function Verbosity2String(Verbosity: TLogVerb): string;
begin
 CASE Verbosity of
  lvDebug    : Result:= 'Debug';
  lvVerbose  : Result:= 'Verbose';
  lvHints    : Result:= 'Hints';
  lvInfos    : Result:= 'Info';           { This is the default level of verbosity }
  lvImportant: Result:= 'Important';
  lvWarnings : Result:= 'Warnings';
  lvErrors   : Result:= 'Errors';
 else
   Raise Exception.Create('Invalid verbosity');
 end;
end;


function Verbosity2Color(Verbosity: TLogVerb): TColor;
begin
 CASE Verbosity of
  lvDebug    : Result:= clSilverLight;
  lvVerbose  : Result:= clSilverDark;
  lvHints    : Result:= clGray;
  lvInfos    : Result:= clBlack;
  lvImportant: Result:= clOrangeDk;
  lvWarnings : Result:= clOrange;
  lvErrors   : Result:= clRed;
 else
   RAISE exception.Create('Invalid log verbosity!');
 end;
end;






end.
