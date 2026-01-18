private with Ada.Finalization;
private with Ada.Streams;

package Alire.Utils.Binary_Files is

   --  Read a file as a sequence of bytes without considering encoding.

   type Raw_Sequence is tagged limited private;

   function Read (From : File_Path) return Raw_Sequence;

   function As_String (this : Raw_Sequence) return access String;

private

   type Bytes_Ptr is access Ada.Streams.Stream_Element_Array;

   type Raw_Sequence is new Ada.Finalization.Limited_Controlled with record
      Bytes : Bytes_Ptr;
   end record;

end Alire.Utils.Binary_Files;
