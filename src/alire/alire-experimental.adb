package body Alire.Experimental is

   -----------
   -- Check --
   -----------

   procedure Check (Feature : Features; Breaks : Breaking) is
      pragma Unreferenced (Breaks);
   begin
      if Enabled then
         Trace.Debug ("Experimental feature " & Feature'Image & " allowed");
      else
         Raise_Checked_Error
           ("Use global switch " & TTY.Terminal ("-x") & " to enable "
            & "experimental feature " & Feature'Image);
      end if;
   end Check;

end Alire.Experimental;
