with Ada.Calendar;
with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Streams;

private with Templates_Parser;

package Alire.Templates with Elaborate_Body is

   type Embedded is access constant Ada.Streams.Stream_Element_Array;

   type Translations (<>) is private;

   procedure Register (File  : Relative_Path;
                       Data  : Embedded;
                       Stamp : Ada.Calendar.Time) is null;

   procedure Translate_File (Src : Embedded;
                             Dst : Relative_File;
                             Map : Translations);

   --  Types to support generation of filesystem trees from templates

   type Filesystem_Entry (Is_Dir : Boolean) is record
      case Is_Dir is
         when True  => null;
         when False => Data : Embedded;
      end case;
   end record;

   function New_Dir return Filesystem_Entry;

   function New_File (Data : Embedded) return Filesystem_Entry;

   package File_Data_Maps is new
     Ada.Containers.Indefinite_Ordered_Maps (Portable_Path, Filesystem_Entry);
   --  In addition to be portable, these paths must be obviously relative

   type Tree is new File_Data_Maps.Map with null record;

   function New_Tree return Tree;

   function Append (This : Tree;
                    File : Portable_Path;
                    Data : Filesystem_Entry) return Tree;

   function Append_If (This : Tree;
                       Cond : Boolean;
                       File : Portable_Path;
                       Data : Filesystem_Entry) return Tree;
   --  Conditionally append files to a file hierarchy

   procedure Translate_Tree (Parent : Relative_Path;
                             Files  : Tree'Class;
                             Map    : Translations);
   --  Will create all files under Parent, respecting their relative path and
   --  applying the given translations. Translations will also be applied to
   --  paths.

   --  Builders for use in child packages

   function "+" (S : aliased Ada.Streams.Stream_Element_Array)
                 return Filesystem_Entry;
   --  Sweep under the rug uses of 'Access, used in child package Builtins

private

   ---------
   -- "+" --
   ---------

   function "+" (S : aliased Ada.Streams.Stream_Element_Array)
                 return Filesystem_Entry
   is (New_File (S'Unchecked_Access));
   --  Hide uses of 'Access, used in child package Builtins

   type Translations is tagged record
      Set : Templates_Parser.Translate_Set;
   end record;

   ---------------------
   -- New_Translation --
   ---------------------

   function New_Translation return Translations
   is (Set => Templates_Parser.Null_Set);

   function Append (This : Translations;
                    Var  : String;
                    Val  : Boolean) return Translations
   is (Set => Templates_Parser."&"
       (This.Set, Templates_Parser.Assoc (Var, Val)));

   ------------
   -- Append --
   ------------

   function Append (This : Translations;
                    Var  : String;
                    Val  : String) return Translations
   is (Set => Templates_Parser."&"
       (This.Set, Templates_Parser.Assoc (Var, Val)));

   ------------
   -- Append --
   ------------

   function Append (This : Translations;
                    Var  : String;
                    Val  : UString) return Translations
   is (This.Append (Var, +Val));

   -------------
   -- New_Dir --
   -------------

   function New_Dir return Filesystem_Entry is (Is_Dir => True);

   --------------
   -- New_File --
   --------------

   function New_File (Data : Embedded) return Filesystem_Entry
   is (Is_Dir => False,
       Data   => Data);

   --------------
   -- New_Tree --
   --------------

   function New_Tree return Tree
   is (File_Data_Maps.Empty_Map with null record);

end Alire.Templates;
