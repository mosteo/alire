pragma Warnings (Off);

--  AWSRes v1.3 - Generated on March 09 2025 at 11:20:21

pragma Style_Checks (Off);

with r.templates_crate_bin_crate_bin_gpr;
with r.templates_crate_bin_src_crate_bin_adb;
with r.templates_crate_bin_gitignore;
with r.templates_crate_bin_alire_toml;

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
            ("templates/crate_bin/crate_bin.gpr.gz",
             r.templates_crate_bin_crate_bin_gpr.Content'Access,
             GNAT.Calendar.Time_Of (2025, 03, 09, 09, 27, 18, 0.0));
         Register
            ("templates/crate_bin/src/crate_bin.adb.gz",
             r.templates_crate_bin_src_crate_bin_adb.Content'Access,
             GNAT.Calendar.Time_Of (2025, 03, 09, 09, 27, 18, 0.0));
         Register
            ("templates/crate_bin/.gitignore.gz",
             r.templates_crate_bin_gitignore.Content'Access,
             GNAT.Calendar.Time_Of (2025, 03, 09, 09, 27, 18, 0.0));
         Register
            ("templates/crate_bin/alire.toml.gz",
             r.templates_crate_bin_alire_toml.Content'Access,
             GNAT.Calendar.Time_Of (2025, 03, 09, 09, 27, 18, 0.0));
      end if;
   end Init;

begin
   Init;
end r;
