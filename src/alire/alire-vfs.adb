with Ada.Directories;

package body Alire.VFS is

   ----------------------
   -- Attempt_Portable --
   ----------------------

   function Attempt_Portable (Path : Any_Path;
                              From : Any_Path := Directories.Current)
                              return String
   is
      Relative : constant Any_Path :=
         Directories.Find_Relative_Path (Parent => From,
                                         Child  => Path);
   begin
      if Check_Absolute_Path (Relative) then
         return Path;
      else
         return String (To_Portable (Relative));
      end if;
   end Attempt_Portable;

   -----------------
   -- Is_Same_Dir --
   -----------------

   function Is_Same_Dir (P1, P2 : Any_Path) return Boolean is
      use GNAT.OS_Lib;
   begin
      if not Is_Directory (P1) or else not Is_Directory (P2) then
         return False;
      end if;

      --  Attempt a lest costly check first

      declare
         use Ada.Directories;
      begin
         if Full_Name (P1) = Full_Name (P2) then
            return True;
         end if;
      end;

      --  To be absolutely sure, touch a temp file in one of the dirs and
      --  verify whether it exist in the other.

      declare
         Tmp : constant Directories.Temp_File := Directories.In_Dir (P1);
         use Directories.Operators;
      begin
         Directories.Touch (Tmp.Filename);
         return Is_Regular_File (P2
                                 / Ada.Directories.Simple_Name (Tmp.Filename));
      end;
   end Is_Same_Dir;

end Alire.VFS;
