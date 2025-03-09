with Ada.Streams.Stream_IO;

package body Alire.Templates is

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
   exception
      when E : others =>
         Log_Exception (E);

         if Is_Open (File) then
            Close (File);
         end if;

         raise;
   end Write_File;

end Alire.Templates;
