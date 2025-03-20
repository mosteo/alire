with Ada.Directories;

with AAA.Strings; use AAA.Strings;

with Alire.Errors;
with Alire.Directories;
with Alire.Formatting;
with Alire.OS_Lib.Subprocess;
with Alire.Platforms;
with Alire.Settings.Builtins;
with Alire.Spawn;
with Alire.URI;
with Alire.Utils;             use Alire.Utils;
with Alire.Utils.Tools;

with Den.Filesystem;
with Den.Walk;

package body Alire.Origins.Deployers.Source_Archive is

   package Dirs renames Ada.Directories;

   procedure Untar (Src_File_Full_Name : Absolute_Path);
   --  Extract the tar archive at Src_File_Full_Name in the current directory

   -----------
   -- Untar --
   -----------

   procedure Untar (Src_File_Full_Name : Absolute_Path) is

      package Subprocess renames Alire.OS_Lib.Subprocess;

      Unused : AAA.Strings.Vector;
   begin

      --  Make sure tar is installed
      Utils.Tools.Check_Tool (Utils.Tools.Tar);

      case Platforms.On_Windows is

         when True =>

            --  On some versions of tar found on Windows, an option is required
            --  to force e.g. C: to mean a local file location rather than the
            --  net host C. Unfortunately this not common to all tar on
            --  Windows, so we first try to untar with the --force-local, and
            --  if that fails, we retry without --force-local.

            declare
            begin
               --  Try to untar with --force-local
               Unused := Subprocess.Checked_Spawn_And_Capture
                 ("tar", Empty_Vector &
                    "--force-local" &
                    "-x" &
                    "-f" & Src_File_Full_Name,
                  Err_To_Out => True);

            exception

               when E : Checked_Error =>

                  Trace.Debug ("tar --force-local failed: " & Errors.Get (E));

                  --  In case of error, retry without the --force-local option
                  Unused := Subprocess.Checked_Spawn_And_Capture
                    ("tar", Empty_Vector &
                       "-x" &
                       "-f" & Src_File_Full_Name,
                     Err_To_Out => True);
            end;

         when False =>

            --  On other platforms, just run tar without --force-local
            Unused := Subprocess.Checked_Spawn_And_Capture
              ("tar", Empty_Vector &
                 "-x" &
                 "-f" & Src_File_Full_Name,
               Err_To_Out => True);
      end case;

   exception
      when E : Checked_Error =>
         Trace.Warning ("tar failed: " & Errors.Get (E, Clear => False));

         --  Reraise current occurrence
         raise;
   end Untar;

   ------------
   -- Deploy --
   ------------

   overriding
   function Deploy (This : Deployer; Folder : String) return Outcome is
      Archive_Name : constant String := This.Base.Archive_Name;
      Archive_File : constant String := Dirs.Compose (Folder, Archive_Name);
   begin
      Trace.Detail ("Deploying source archive " &
                      Archive_Name &
                      " into " &
                      Folder &
                      "...");
      Unpack (Src_File => Archive_File,
              Dst_Dir  => Folder,
              Delete   => True,
              Move_Up  => True);

      return Outcome_Success;
   end Deploy;

   ------------------
   -- Compute_Hash --
   ------------------

   overriding
   function Compute_Hash (This   : Deployer;
                          Folder : String;
                          Kind   : Hashes.Kinds) return Hashes.Any_Digest is
      Archive_Name : constant String := Dirs.Simple_Name
        (This.Base.Archive_Name);
      Archive_File : constant String := Dirs.Compose (Folder, Archive_Name);
   begin
      return Hashes.Digest (Hashes.Hash_File (Kind, Archive_File));
   end Compute_Hash;

   --------------
   -- Download --
   --------------
   --  Download the source archive from a non-local origin.

   function Download (URL      : String;
                      Filename : Any_Path;
                      Folder   : Directory_Path)
                      return Outcome
   is
      use Alire.Directories;
      Archive_File : constant File_Path :=
        Folder / Ada.Directories.Simple_Name (Filename);

      Configured_Download_Cmd : constant String :=
        Alire.Settings.Builtins.Origins_Archive_Download_Cmd.Get;

      --  In the case of the default download command, we adjust curl's
      --  verbosity if warranted by the logging level.
      Download_Cmd : constant String :=
        (if Log_Level >= Trace.Info
           and then Configured_Download_Cmd = "curl ${URL} -L -s -o ${DEST}"
         then "curl ${URL} -L --progress-bar -o ${DEST}"
         else Configured_Download_Cmd);

      procedure Exec_Check (Exec : String) is
      begin
         if Exec = "curl" then
            Utils.Tools.Check_Tool (Utils.Tools.Curl);
         end if;
      end Exec_Check;
   begin
      Trace.Debug ("Creating folder: " & Folder);

      Directories.Create_Tree (Folder);

      Trace.Detail ("Downloading file: " & URL);
      Alire.Spawn.Settings_Command
        (Download_Cmd,
         Formatting.For_Archive_Download (URL, Archive_File),
         Exec_Check'Access);

      return Outcome_Success;
   exception
      when E : others =>
         return Alire.Errors.Get (E);
   end Download;

   -----------
   -- Fetch --
   -----------

   overriding
   function Fetch (This : Deployer; Folder : String) return Outcome is
   begin

      --  If the file is local, do a simple copy. While curl seems to work in
      --  linux also for local files, something funny is going on Windows which
      --  is difficult to pinpoint.

      if URI.URI_Kind (This.Base.Archive_URL) in URI.Local_Other then
         if not Dirs.Exists (Folder) then
            Alire.Directories.Create_Tree (Folder);
         end if;

         Ada.Directories.Copy_File
           (URI.Local_Path (This.Base.Archive_URL),
            Dirs.Compose (Folder, Dirs.Simple_Name (This.Base.Archive_Name)));

         return Outcome_Success;
      else
         return Download (URL      => This.Base.Archive_URL,
                          Filename => This.Base.Archive_Name,
                          Folder   => Folder);
      end if;
   end Fetch;

   ------------
   -- Unpack --
   ------------

   procedure Unpack (Src_File : String;
                     Dst_Dir  : String;
                     Delete   : Boolean;
                     Move_Up  : Boolean)
   is

      -----------------------
      -- Check_And_Move_Up --
      -----------------------

      procedure Check_And_Move_Up is
         use Directories.Operators;

         Contents : constant Den.Sorted_Paths :=
                      Den.Walk.Ls (Den.Scrub (Dst_Dir),
                                   Options => (Canonicalize => True));
      begin
         if Contents.Is_Empty then
            raise Checked_Error with Errors.Set
              ("No content where a single directory was expected: " & Dst_Dir);
         end if;

         if Natural (Contents.Length) /= 1 or else
           not Directories.Is_Directory (Contents.First_Element)
         then
            raise Checked_Error with Errors.Set
              ("Unexpected contents where a single directory was expected: "
               & Dst_Dir);
         end if;

         Trace.Debug ("Unpacked crate root detected as: "
                      & Contents.First_Element);

         --  Move everything up one level:

         for File of Den.Walk.Ls (Dst_Dir / Contents.First_Element,
                                  Options => (Canonicalize => True))
         loop
            declare
               New_Name : constant String :=
                            Directories.Parent (Contents.First_Element)
                            / File;
            begin
               Dirs.Rename
                 (Old_Name => File,
                  New_Name => New_Name);
            exception
               when E : Dirs.Use_Error =>
                  Log_Exception (E);
                  raise Checked_Error with Errors.Set
                    ("Could not rename " & File
                     & " to " & New_Name);
            end;
         end loop;

         --  Delete the folder, that must be empty:

         begin
            Den.Filesystem.Delete_Directory (Contents.First_Element);
         exception
            when E : others =>
               Log_Exception (E);
               raise Checked_Error with Errors.Set
                 ("Could not remove supposedly empty directory: "
                  & Contents.First_Element);
         end;

      end Check_And_Move_Up;

      package Subprocess renames Alire.OS_Lib.Subprocess;

   begin

      case Archive_Format (Src_File) is
         when Tarball =>

            declare
               --  We had some trouble on Windows with trying to extract a
               --  tar archive in a specified destination directory (using the
               --  -C switch). To workaround these issue we now move to the
               --  destination directory before running tar ..

               --  .. which means we need to preserve the full name of
               --  the source file, in case the given name is
               --  relative.
               Src_File_Full_Name : constant Absolute_Path
                 := Den.Canonical (Src_File);

               --  Create the destination directory
               Dst_Guard : Directories.Temp_File :=
                 Directories.With_Name (Directories.Full_Name (Dst_Dir));

               --  Enter the destination directory, and automatically restore
               --  the current dir at the end of the scope.
               Guard : Directories.Guard (Directories.Enter (Dst_Dir))
                 with Unreferenced;
            begin

               Untar (Src_File_Full_Name);

               --  In case of success we keep the destination folder
               Dst_Guard.Keep;
            end;
         when Zip_Archive =>

            --  Make sure unzip is installed
            Utils.Tools.Check_Tool (Utils.Tools.Unzip);

            Subprocess.Checked_Spawn
              ("unzip", Empty_Vector & "-q" & Src_File & "-d" & Dst_Dir);
         when Unknown =>
            raise Checked_Error with Errors.Set
              ("Given packed archive has unknown format: " & Src_File);
      end case;

      if Delete then
         Trace.Debug ("Deleting source archive: " & Src_File);
         Ada.Directories.Delete_File (Src_File);
      end if;

      if Move_Up then
         Check_And_Move_Up;
      end if;
   end Unpack;

end Alire.Origins.Deployers.Source_Archive;
