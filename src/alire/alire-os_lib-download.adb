with Ada.Directories;

with Alire.Directories;
with Alire.Errors;
with Alire.OS_Lib.Subprocess;

package body Alire.OS_Lib.Download is

   ----------
   -- File --
   ----------

   function File (URL      : String;
                  Filename : Any_Path;
                  Folder   : Directory_Path)
                  return Outcome
   is
      Archive_File : constant Directory_Path :=
                       Folder / Ada.Directories.Simple_Name (Filename);
   begin
      Trace.Debug ("Creating folder: " & Folder);
      Directories.Create_Tree (Folder);

      Trace.Detail ("Downloading file: " & URL);

      OS_Lib.Subprocess.Checked_Spawn
        ("curl",
         Empty_Vector &
           URL &
           "--location" &  -- allow for redirects at the remote host
           (if Log_Level < Trace.Info
            then Empty_Vector & "--silent"
            else Empty_Vector & "--progress-bar") &
           "--output" &
           Archive_File);

      return Outcome_Success;
   exception
      when E : others =>
         return Alire.Errors.Get (E);
   end File;

end Alire.OS_Lib.Download;
