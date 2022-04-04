UNIT clLogUtils;

{=============================================================================================================
   CubicDesign
   2022.03
   See Copyright.txt
=============================================================================================================}

INTERFACE

USES
   System.SysUtils, Vcl.Graphics, ccCore;

TYPE
  TLogVerb= (lvVerbose, lvHints, lvInfos, lvImportant, lvWarnings, lvErrors);

CONST
  ctLogVerb  = clGray;
  ctLogHint  = clDkGray;
  ctLogInfo  = clBlack;
  ctLogImprt = clPurpleDk;
  ctLogWarn  = clOrangeDark;
  ctLogError = clRed;

CONST
  DefaultVerbosity= lvInfos;

function Verbosity2String(Verbosity: TLogVerb): string;



IMPLEMENTATION



function Verbosity2String(Verbosity: TLogVerb): string;
begin
 case Verbosity of
   lvVerbose   : Result := 'Verbose';
   lvHints     : Result := 'Hints';
   lvInfos     : Result := 'Info';      { This is the default level of verbosity }
   lvImportant : Result := 'Important';
   lvWarnings  : Result := 'Warnings';
   lvErrors    : Result := 'Errors';
 else
   Raise Exception.Create('Invalid verbosity');
 end;
end;


end.
