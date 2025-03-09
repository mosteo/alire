with Ada.Calendar;
with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Streams;

private with Templates_Parser;

package Alire.Templates with Elaborate_Body is

   type Embedded is access constant Ada.Streams.Stream_Element_Array;

   function "+" (S : aliased Ada.Streams.Stream_Element_Array) return Embedded;
   --  Sweep under the rug uses of 'Access, used in child package Builtins

   type Translations (<>) is private;

   procedure Register (File  : Relative_Path;
                       Data  : Embedded;
                       Stamp : Ada.Calendar.Time) is null;

   procedure Write_File (Src : Embedded;
                         Dst : Relative_File);
   --  Write an embedded file on disk. Does not perform any translations.

   procedure Translate_File (Src : Embedded;
                             Dst : Relative_File;
                             Map : Translations);

   --  Since we mostly want to generate entire folders with several files, we
   --  use this type to represent a bundle of files.

   package File_Data_Maps is new
     Ada.Containers.Indefinite_Ordered_Maps (Portable_Path, Embedded);
   --  In addition to be portable, these paths must be obviously relative

   type Tree is new File_Data_Maps.Map with null record;

   function New_Tree return Tree;

   function Append (This : Tree;
                    File : Portable_Path;
                    Data : Embedded) return Tree;

   procedure Translate_Tree (Parent : Relative_Path;
                             Files  : Tree'Class;
                             Map    : Translations);
   --  Will create all files under Parent, respecting their relative path and
   --  applying the given translations. Translations will also be applied to
   --  paths.

private

   ---------
   -- "+" --
   ---------

   function "+" (S : aliased Ada.Streams.Stream_Element_Array) return Embedded
   is (S'Unchecked_Access);
   --  Hide uses of 'Access, used in child package Builtins

   type Translations is tagged record
      Set : Templates_Parser.Translate_Set;
   end record;

   ---------------------
   -- New_Translation --
   ---------------------

   function New_Translation return Translations
   is (Set => Templates_Parser.Null_Set);

   ------------
   -- Append --
   ------------

   function Append (This : Translations;
                    Var  : String;
                    Val  : String) return Translations
   is (Set => Templates_Parser."&"
       (This.Set, Templates_Parser.Assoc (Var, Val)));

   ----------------
   -- New_Bundle --
   ----------------

   function New_Tree return Tree is (Empty);

end Alire.Templates;
