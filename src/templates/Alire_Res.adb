
--  AWSRes v1.3 - Generated on October 27 2024 at 20:04:05

pragma Style_Checks (Off);

with Alire_Res.manifests_alire_bin_toml;

with AWS.Resources.Embedded;
with GNAT.Calendar;

package body Alire_Res is

   Initialized : Boolean := False;

   procedure Init is
      use AWS.Resources.Embedded;
   begin
      if not Initialized then
         Initialized := True;
         Register
            ("manifests/alire_bin.toml.gz",
             Alire_Res.manifests_alire_bin_toml.Content'Access,
             GNAT.Calendar.Time_Of (2024, 10, 27, 18, 56, 37, 0.0));
      end if;
   end Init;

begin
   Init;
end Alire_Res;
