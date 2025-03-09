with Ada.Calendar;
with Ada.Streams;

package Alire.Templates with Elaborate_Body is

   type Data is access constant Ada.Streams.Stream_Element_Array;

   procedure Register (File  : Relative_Path;
                       Bytes : Data;
                       Stamp : Ada.Calendar.Time);
   --  Register an embedded template to make it available for use

end Alire.Templates;
