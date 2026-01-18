with Ada.Directories;
with Ada.Wide_Wide_Text_IO; use Ada.Wide_Wide_Text_IO;

with AAA.Strings; use AAA.Strings;

with Alire.Directories;

with LML;

package body Alire.Utils.Text_Files is

   package Adirs renames Ada.Directories;

   ------------------
   -- Append_Lines --
   ------------------

   procedure Append_Lines (File       : Any_Path;
                           Lines      : AAA.Strings.Vector;
                           Backup     : Boolean  := True;
                           Backup_Dir : Any_Path := "")
   is
      F : Text_Files.File := Load (File, Backup, Backup_Dir);
   begin
      F.Lines.Append (Lines);
   end Append_Lines;

   -------------------
   -- Replace_Lines --
   -------------------

   procedure Replace_Lines (File       : Any_Path;
                            Lines      : AAA.Strings.Vector;
                            Backup     : Boolean  := True;
                            Backup_Dir : Any_Path := "")
   is
      F : Text_Files.File := Load (File, Backup, Backup_Dir);
   begin
      F.Lines := Lines;
   end Replace_Lines;

   --------------
   -- Finalize --
   --------------

   overriding
   procedure Finalize (This : in out File) is
      File : File_Type;
   begin
      if This.Lines = This.Orig then
         Trace.Debug ("No changes to save in " & This.Name);
         return;
      elsif not This.Load_OK then
         Trace.Debug ("File " & This.Name & " could not be loaded, "
                      & "skipping rewrite of its contents.");
         return;
      else
         Trace.Debug ("Replacing contents of " & This.Name);
      end if;

      declare
         Replacer : Directories.Replacer :=
                      Directories.New_Replacement (This.Name,
                                                   This.Backup,
                                                   This.Backup_Dir);
      begin
         Create (File, Out_File, Replacer.Editable_Name);
         for Line of This.Lines loop
            Put_Line (File, LML.Decode (Line));
         end loop;
         Close (File);
         Replacer.Replace;
      exception
         when E : others =>
            Log_Exception (E);
            raise;
      end;

   exception
      when E : others =>
         Alire.Utils.Finalize_Exception (E);
   end Finalize;

   -----------
   -- Lines --
   -----------

   function Lines (This : aliased in out File)
                   return access AAA.Strings.Vector
   is (This.Lines'Access);

   -----------
   -- Lines --
   -----------

   function Lines (Filename : Any_Path)
                   return AAA.Strings.Vector
   is
      F : constant File := Load (Filename);
   begin
      return F.Lines;
   end Lines;

   ------------
   -- Create --
   ------------

   function Create (Name : Any_Path) return File
   is (Ada.Finalization.Limited_Controlled with
       Length     => Name'Length,
       Backup_Len => 0,
       Name       => Name,
       Load_OK    => True,
       Backup     => False,
       Backup_Dir => "",
       Lines      => <>,
       Orig       => <>);

   ----------
   -- Load --
   ----------

   function Load (From       : Any_Path;
                  Backup     : Boolean := True;
                  Backup_Dir : Any_Path := "")
                  return File
   is
      F : File_Type;
   begin
      return This : File := (Ada.Finalization.Limited_Controlled with
                             Length     => From'Length,
                             Backup_Len => Backup_Dir'Length,
                             Name       => From,
                             Load_OK    => False,
                             Backup     => Backup,
                             Backup_Dir => Backup_Dir,
                             Lines      => <>,
                             Orig       => <>)
      do
         Trace.Debug ("Opening file: " & From);
         Trace.Debug ("With file size:" & Adirs.Size (From)'Image);

         Open (F, In_File, From);
         while not End_Of_File (F) loop
            declare
               Curr_Line : Positive := 1;
            begin
               This.Orig.Append (LML.Encode (Get_Line (F)));
               Curr_Line := Curr_Line + 1;
            exception
               when E : others =>
                  Trace.Error ("Cannot read line" & Curr_Line'Image
                               & " from file: " & From);
                  Log_Exception (E);
                  raise;
            end;
         end loop;
         Close (F);

         This.Load_OK := True;
         This.Lines   := This.Orig;
      end return;
   end Load;

end Alire.Utils.Text_Files;
