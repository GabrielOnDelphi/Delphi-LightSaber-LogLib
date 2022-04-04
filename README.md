# Delphi-LightSaber - LogLib

   A simple but effective visual log control/library.  
   The programmer can send messages to the log that will be shown or not, depending on the chousen verbosity level of the log (see Verbosity property). 
   
   There is a non-visual log and a visual log. The idea is that your non-visual objects can send data to the non-viusal log, for example in a batch job. During the batch OR at the end of the batch all collected messages can be shown in the visual log.
   
   There is a pre-defined form that holds the log. To show it, call CreateLogForm in FormLog.pas  
   The purpose is to have one single log window per application that will receive messages from the entire application.  

   **Verbosity:**  
     Supports several verbosity levels (verbose, info, warnings, errors, etc).  
     Receives only messages that are above the specified verbosity threshold.  
     For example, if the log is set to show only warnings and errors and you send a messages marked as "verbose", then the messages will not be shown.  

**Demo**  
See https://github.com/GodModeUser/GUI-AutoSave for a compilable demo.  

![](ScreenShot.png)
