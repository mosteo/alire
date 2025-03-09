
--  AWSRes v1.3 - Generated on March 09 2025 at 10:41:36

pragma Style_Checks (Off);


with AWS.Resources.Embedded;
with GNAT.Calendar;

package body res is

   Initialized : Boolean := False;

   procedure Init is
      use AWS.Resources.Embedded;
   begin
      if not Initialized then
         Initialized := True;
      end if;
   end Init;

begin
   Init;
end res;
