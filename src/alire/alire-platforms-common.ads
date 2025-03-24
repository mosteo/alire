with Alire.OS_Lib;

package Alire.Platforms.Common is

   --  Reusable code from both Linux/macOS or other several OSes. Intended for
   --  use from the platform-specific bodies.

   use OS_Lib.Operators; -- Bring in "/" for paths

   function Machine_Hardware_Name return Architectures;
   --  As reported by uname, already turned into our architecture enum

   ---------------------
   -- Unix_Home_Folder --
   ---------------------

   function Unix_Home_Folder return String;

   ----------------------
   -- Unix_Temp_Folder --
   ----------------------

   function Unix_Temp_Folder return String
   is (OS_Lib.Getenv ("XDG_RUNTIME_DIR",
                      Default => OS_Lib.Getenv ("TMPDIR",
                                                Default => ".")));

   -------------------
   -- XDG_Data_Home --
   -------------------

   function XDG_Data_Home return String
   is (OS_Lib.Getenv
         ("XDG_DATA_HOME",
          Default => Unix_Home_Folder / ".local/share")
       / "alire");

   ---------------------
   -- XDG_Config_Home --
   ---------------------

   function XDG_Config_Home return String
   is (OS_Lib.Getenv
         ("XDG_CONFIG_HOME",
          Default => Unix_Home_Folder / ".config")
       / "alire");

end Alire.Platforms.Common;
