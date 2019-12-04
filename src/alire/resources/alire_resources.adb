--  AWSRes v1.3 - Genarated on December 06 2019 at 20:09:55

pragma Style_Checks (Off);

with Alire_Resources.Resources_Binary_Project_Gpr;
with Alire_Resources.Resources_Library_Ads;
with Alire_Resources.Resources_Library_Project_Gpr;
with Alire_Resources.Resources_Main_Adb;

with Eat;
with Gnat.Calendar;

package body Alire_Resources is

   Initialized : Boolean := False;

   procedure Init is
      use Eat;
   begin
      if not Initialized then
         Initialized := True;
         Register
           ("resources/binary_project.gpr",
            Alire_Resources.Resources_Binary_Project_Gpr.Content'Access,
            Gnat.Calendar.Time_Of (2019, 12, 06, 17, 20, 04, 0.0));
         Register
           ("resources/library.ads",
            Alire_Resources.Resources_Library_Ads.Content'Access,
            Gnat.Calendar.Time_Of (2019, 12, 06, 17, 18, 44, 0.0));
         Register
           ("resources/library_project.gpr",
            Alire_Resources.Resources_Library_Project_Gpr.Content'Access,
            Gnat.Calendar.Time_Of (2019, 12, 06, 17, 19, 51, 0.0));
         Register
           ("resources/main.adb",
            Alire_Resources.Resources_Main_Adb.Content'Access,
            Gnat.Calendar.Time_Of (2019, 12, 06, 11, 13, 27, 0.0));
      end if;
   end Init;

begin
   Init;
end Alire_Resources;
