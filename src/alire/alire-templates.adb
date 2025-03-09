with Ada.Streams.Stream_IO;
with Ada.Wide_Wide_Text_IO;

with LML;

package body Alire.Templates is

      ---------------
   -- as_string --
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
