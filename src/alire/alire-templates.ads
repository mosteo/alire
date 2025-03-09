with Ada.Calendar;
with Ada.Streams;

package Alire.Templates with Elaborate_Body is

   type Embedded is access constant Ada.Streams.Stream_Element_Array;

   procedure Register (File  : Relative_Path;
                       Data  : Embedded;
                       Stamp : Ada.Calendar.Time) is null;

   procedure Write_File (Src : Embedded;
                         Dst : Relative_File);
   --  Write an embedded file on disk. Does not perform any translations.

end Alire.Templates;
