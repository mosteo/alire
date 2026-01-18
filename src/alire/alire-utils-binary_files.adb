with Ada.Directories;
with Ada.Streams.Stream_IO;
with Ada.Unchecked_Deallocation;

package body Alire.Utils.Binary_Files is

   package Adirs renames Ada.Directories;

   procedure Free_String is new Ada.Unchecked_Deallocation
     (Object => String,
      Name   => String_Access);

   ----------
   -- Read --
   ----------

   function Read (From : File_Path) return Raw_Sequence is
      use Ada.Streams.Stream_IO;

      File : File_Type;
      Size : Natural;
   begin
      Trace.Debug ("Opening file (as bytes): " & From);
      Trace.Debug ("With file size:" & Adirs.Size (From)'Image);

      Open (File, In_File, From);
      Size := Natural (Ada.Streams.Stream_IO.Size (File));

      return Result : Raw_Sequence do
         Result.Data := new String (1 .. Size);
         String'Read (Stream (File), Result.Data.all);
         Close (File);
      end return;
   end Read;

   ---------------
   -- As_String --
   ---------------

   function As_String (This : Raw_Sequence) return access String is
   begin
      return This.Data;
   end As_String;

   --------------
   -- Finalize --
   --------------

   overriding procedure Finalize (This : in out Raw_Sequence) is
   begin
      if This.Data /= null then
         Free_String (This.Data);
      end if;
   end Finalize;

end Alire.Utils.Binary_Files;
