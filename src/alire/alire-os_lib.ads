with GNAT.OS_Lib;

private with AAA.Strings;

package Alire.OS_Lib with Preelaborate is

   function "/" (L : Any_Path; R : Relative_Path) return Any_Path with
     Pre  => L /= "",
     Post => (if R = "" then "/"'Result = L);
   --  Shorthand for path composition

   --  Package to enable easy use of "/"
   package Operators is
      function "/" (L : Any_Path; R : Relative_Path) return Any_Path
                    renames OS_Lib."/";
   end Operators;

   procedure Bailout (Code : Integer := 0);

   function Exe_Suffix return String;

   function Getenv (Name : String; Default : String := "") return String;

   procedure Setenv (Name : String; Value : String);

   function Locate_Exec_On_Path (Exec_Name : String) return String;
   --  Return the location of an executable if found on PATH, or "" otherwise.
   --  On Windows, no need to append ".exe" as it will be found without it.

   Forbidden_Dir_Separator : constant Character :=
                               (case GNAT.OS_Lib.Directory_Separator is
                                   when '/' => '\',
                                   when '\' => '/',
                                   when others =>
                                      raise Unimplemented
                                        with "Unknown dir separator");

   --  For things that may contain path fragments but are not proper paths

   Dir_Separator : Character renames GNAT.OS_Lib.Directory_Separator;

   subtype Native_Path_Like is String
     with Dynamic_Predicate =>
       (for all Char of Native_Path_Like => Char /= Forbidden_Dir_Separator)
     or else raise Ada.Assertions.Assertion_Error
       with "Not a native-path-like: " & Native_Path_Like;

   subtype Portable_Path_Like is String
     with Dynamic_Predicate =>
       (for all Char of Portable_Path_Like => Char /= '\')
     or else raise Ada.Assertions.Assertion_Error
       with "Not a portable-path-like: " & Portable_Path_Like;

   function To_Portable (Path : Any_Path) return Portable_Path_Like;
   --  Path is Any_Path and not Native_Path_Like because some Windows native
   --  programs return mixed style paths such as "C:/blah/blah".

   function To_Native (Path : Portable_Path_Like) return Native_Path_Like;

private

   use AAA.Strings;

   ----------------------
   -- To_Portable_Like --
   ----------------------

   function To_Portable (Path : Any_Path)
                              return Portable_Path_Like
   is (Replace (Path, "\", "/"));

   --------------------
   -- To_Native_Like --
   --------------------

   function To_Native (Path : Portable_Path_Like) return Native_Path_Like
   is (case Dir_Separator is
          when '/' => Replace (String (Path), "\", "/"),
          when '\' => Replace (String (Path), "/", "\"),
          when others => raise Program_Error
            with "unsupported OS with dir separator: '" & Dir_Separator & "'"
      );

end Alire.OS_Lib;
