with Ada.Calendar;
with Ada.Streams;

private with Templates_Parser;

package Alire.Templates with Elaborate_Body is

   type Embedded is access constant Ada.Streams.Stream_Element_Array;

   type Translations (<>) is tagged private;

   function New_Translation return Translations;

   function Append (This : Translations;
                    Var  : String;
                    Val  : String) return Translations;

   procedure Register (File  : Relative_Path;
                       Data  : Embedded;
                       Stamp : Ada.Calendar.Time) is null;

   procedure Write_File (Src : Embedded;
                         Dst : Relative_File);
   --  Write an embedded file on disk. Does not perform any translations.

   procedure Translate_File (Src : Embedded;
                             Dst : Relative_File;
                             Map : Translations);

private

   type Translations is tagged record
      Set : Templates_Parser.Translate_Set;
   end record;

   ---------------------
   -- New_Translation --
   ---------------------

   function New_Translation return Translations
   is (Set => Templates_Parser.Null_Set);

   ----------
   -- This --
   ----------

   function Append (This : Translations;
                    Var  : String;
                    Val  : String) return Translations
   is (Set => Templates_Parser."&"
       (This.Set, Templates_Parser.Assoc (Var, Val)));

end Alire.Templates;
