private with Ada.Finalization;

package Alire.Utils.Binary_Files is

   --  Read a file as a sequence of bytes without considering encoding.

   type Raw_Sequence is tagged limited private;

   function Read (From : File_Path) return Raw_Sequence;

   function As_String (This : Raw_Sequence) return access String;

private

   type String_Access is access String;

   type Raw_Sequence is new Ada.Finalization.Limited_Controlled with record
      Data : String_Access;
   end record;

   overriding procedure Finalize (This : in out Raw_Sequence);

end Alire.Utils.Binary_Files;
