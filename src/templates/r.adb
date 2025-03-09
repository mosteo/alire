pragma Warnings (Off);

--  AWSRes v1.3 - Generated on March 09 2025 at 23:00:20

pragma Style_Checks (Off);

with r.crate_bin_crate_bin_gpr;
with r.crate_bin_src_bin_adb;
with r.crate_bin_gitignore;
with r.crate_bin_alire_toml;

with Alire.Templates;
with GNAT.Calendar;

package body r is

   Initialized : Boolean := False;

   procedure Init is
      use Alire.Templates;
   begin
      if not Initialized then
         Initialized := True;
         Register
            ("crate_bin/crate_bin.gpr",
             r.crate_bin_crate_bin_gpr.Content'Access,
             GNAT.Calendar.Time_Of (2025, 03, 09, 09, 27, 18, 0.0));
         Register
            ("crate_bin/src/bin.adb",
             r.crate_bin_src_bin_adb.Content'Access,
             GNAT.Calendar.Time_Of (2025, 03, 09, 22, 00, 01, 0.0));
         Register
            ("crate_bin/.gitignore",
             r.crate_bin_gitignore.Content'Access,
             GNAT.Calendar.Time_Of (2025, 03, 09, 09, 27, 18, 0.0));
         Register
            ("crate_bin/alire.toml",
             r.crate_bin_alire_toml.Content'Access,
             GNAT.Calendar.Time_Of (2025, 03, 09, 20, 11, 29, 0.0));
      end if;
   end Init;

begin
   Init;
end r;
