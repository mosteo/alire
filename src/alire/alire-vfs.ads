with Alire.Directories;
private with Alire.OS_Lib;

with AAA.Strings; use AAA.Strings;

package Alire.VFS is

   --  Portable paths are relative and use forward slashes. Absolute paths
   --  cannot be portable.

   function Is_Portable (Path : Any_Path) return Boolean;
   --  Say if the path may be safely cast to a portable path

   function Attempt_Portable (Path : Any_Path;
                              From : Any_Path := Directories.Current)
                              return String;
   --  If Path seen from From is relative, convert to portable, else return
   --  as-is

   function Parent (Path : Portable_Path) return Portable_Path;
   --  Like Ada.Directories.Containing_Directory. Will return "." for simple
   --  names.

   function Simple_Name (Path : Portable_Path) return String;
   --  Like Ada.Directories.Simple name but for portable paths no matter the OS

   function To_Portable (Path : Relative_Path) return Portable_Path;

   function To_Native (Path : Portable_Path) return Relative_Path;

   --  Wrapper types on top of GNATCOLL.VFS that hide pointers/deallocations.
   --  Some types are renamed here to be able to rely on this spec without
   --  needing to mix both Alire.VFS and GNATCOLL.VFS.

   function Is_Same_Dir (P1, P2 : Any_Path) return Boolean;
   --  Check if two paths are to the same dir, even if they're given as
   --  different equivalent full paths in the filesystem (e.g., Windows
   --  short and long names).

private

   -----------------
   -- Is_Portable --
   -----------------

   function Is_Portable (Path : Any_Path) return Boolean
   is ((for all Char of Path => Char /= '\')
       and then
         not Check_Absolute_Path (Path));

   ------------
   -- Parent --
   ------------

   function Parent (Path : Portable_Path) return Portable_Path
   is (To_Portable
        (Directories.Adirs.Containing_Directory
          (To_Native (Path))));

   -----------------
   -- Simple_Name --
   -----------------

   function Simple_Name (Path : Portable_Path) return String
   is (if Contains (String (Path), "/")
       then Directories.Adirs.Simple_Name (To_Native (Path))
       else String (Path));

   -----------------
   -- To_Portable --
   -----------------

   function To_Portable (Path : Relative_Path) return Portable_Path
   is (Portable_Path
       (OS_Lib.To_Portable
          (Path)));

   ---------------
   -- To_Native --
   ---------------

   function To_Native (Path : Portable_Path) return Relative_Path
   is (Relative_Path (OS_Lib.To_Native (OS_Lib.Portable_Path_Like (Path))));

end Alire.VFS;
