pragma Warnings (Off);

--  AWSRes v1.3 - Generated on March 14 2025 at 19:42:38

pragma Style_Checks (Off);

with r.crate_bin_alire_toml;
with r.crate_bin_name_gpr;
with r.crate_bin_src_name_adb;
with r.crate_common_gitignore_hidden;
with r.crate_lib_alire_toml;
with r.crate_lib_name_gpr;
with r.crate_lib_src_name_ads;
with r.crate_test_tests_alire_toml;
with r.crate_test_tests_common_name_tests_ads;
with r.crate_test_tests_crate_test_tests_gpr;
with r.crate_test_tests_src_name_testsxexample_test_adb;

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
            ("crate_bin/alire.toml",
             r.crate_bin_alire_toml.Content'Access,
             GNAT.Calendar.Time_Of (2025, 03, 14, 18, 40, 58, 0.0));
         Register
            ("crate_bin/name.gpr",
             r.crate_bin_name_gpr.Content'Access,
             GNAT.Calendar.Time_Of (2025, 03, 14, 16, 57, 51, 0.0));
         Register
            ("crate_bin/src/name.adb",
             r.crate_bin_src_name_adb.Content'Access,
             GNAT.Calendar.Time_Of (2025, 03, 14, 16, 57, 51, 0.0));
         Register
            ("crate_common/gitignore.hidden",
             r.crate_common_gitignore_hidden.Content'Access,
             GNAT.Calendar.Time_Of (2025, 03, 14, 16, 57, 51, 0.0));
         Register
            ("crate_lib/alire.toml",
             r.crate_lib_alire_toml.Content'Access,
             GNAT.Calendar.Time_Of (2025, 03, 14, 18, 41, 09, 0.0));
         Register
            ("crate_lib/name.gpr",
             r.crate_lib_name_gpr.Content'Access,
             GNAT.Calendar.Time_Of (2025, 03, 14, 16, 57, 51, 0.0));
         Register
            ("crate_lib/src/name.ads",
             r.crate_lib_src_name_ads.Content'Access,
             GNAT.Calendar.Time_Of (2025, 03, 14, 16, 57, 51, 0.0));
         Register
            ("crate_test/tests/alire.toml",
             r.crate_test_tests_alire_toml.Content'Access,
             GNAT.Calendar.Time_Of (2025, 03, 14, 16, 57, 51, 0.0));
         Register
            ("crate_test/tests/common/name_tests.ads",
             r.crate_test_tests_common_name_tests_ads.Content'Access,
             GNAT.Calendar.Time_Of (2025, 03, 14, 16, 57, 51, 0.0));
         Register
            ("crate_test/tests/crate_test_tests.gpr",
             r.crate_test_tests_crate_test_tests_gpr.Content'Access,
             GNAT.Calendar.Time_Of (2025, 03, 14, 16, 57, 51, 0.0));
         Register
            ("crate_test/tests/src/name_tests-example_test.adb",
             r.crate_test_tests_src_name_testsxexample_test_adb.Content'Access,
             GNAT.Calendar.Time_Of (2025, 03, 14, 16, 57, 51, 0.0));
      end if;
   end Init;

begin
   Init;
end r;
