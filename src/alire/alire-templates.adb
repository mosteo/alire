with Ada.Streams.Stream_IO;
with Ada.Wide_Wide_Text_IO;

with Alire.Directories;
with Alire.VFS;

with LML;

package body Alire.Templates is

   ------------
   -- Append --
   ------------

   function Append (This : Tree;
                    File : Portable_Path;
                    Data : Embedded) return Tree
   is
   begin
      return Result : Tree := This do
         Result.Insert (File, Data);
      end return;
   end Append;

   ---------------
   -- As_String --
   ---------------

   function As_String (Data : Embedded) return String is
      Fake_String : aliased String (1 .. Data'Length);
      for Fake_String'Address use Data (Data'First)'Address;
   begin
      return Fake_String;
   end As_String;

   --------------------
   -- Translate_File --
   --------------------

   procedure Translate_File (Src : Embedded;
                             Dst : Relative_File;
                             Map : Translations)
   is
      use Ada.Wide_Wide_Text_IO;
      File : File_Type;
   begin
      Create (File, Name => Dst);
      Put (File,
           LML.Decode
             (Templates_Parser.Translate
                (As_String (Src), Map.Set)));
      Close (File);
   exception
      when E : others =>
         Log_Exception (E);

         if Is_Open (File) then
            Close (File);
         end if;

         raise;
   end Translate_File;

   --------------------
   -- Translate_Tree --
   --------------------

   procedure Translate_Tree (Parent : Relative_Path;
                             Files  : Tree'Class;
                             Map    : Translations)
   is
      package Dirs renames Directories;
      package TP renames Templates_Parser;
      use Directories.Operators;
      use File_Data_Maps;
   begin
      for I in Files.Iterate loop
         declare
            Raw_File_Name : constant Portable_Path := Key (I);

            --  Translate the path
            File_Name     : constant Relative_File :=
                              VFS.To_Native
                                (Portable_Path
                                   (TP.Translate (String (Raw_File_Name),
                                                  Map.Set)));
         begin
            --  Ensure parent exists
            Dirs.Create_Tree (Parent / Dirs.Parent (File_Name));

            --  And translate the actual file
            Translate_File (Files (I),
                            Parent / File_Name,
                            Map);
         end;
      end loop;
   end Translate_Tree;

   ----------------
   -- Write_File --
   ----------------

   procedure Write_File (Src : Embedded;
                         Dst : Relative_File)
   is
      use Ada.Streams.Stream_IO;
      File : File_Type;
   begin
      Create (File, Name => Dst);
      Write (File, Src.all);
      Close (File);
   exception
      when E : others =>
         Log_Exception (E);

         if Is_Open (File) then
            Close (File);
         end if;

         raise;
   end Write_File;

end Alire.Templates;
