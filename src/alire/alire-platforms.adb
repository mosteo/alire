with Alire.OS_Lib;

package body Alire.Platforms is

   ----------------
   -- On_Windows --
   ----------------

   pragma Warnings (Off, "condition is always"); -- Silence warning of OS check
   function On_Windows return Boolean
   is (OS_Lib.Dir_Separator = '\');
   pragma Warnings (On);

end Alire.Platforms;
