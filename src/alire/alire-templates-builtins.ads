pragma Style_Checks (Off);
--  awsres doesn't use proper casing, and fighting GNAT studio is tiresome

with R.Crate_Bin_Alire_Toml;
with R.Crate_Bin_Src_Bin_Adb;

package Alire.Templates.Builtins is

   function Init_Crate_Translation (Name : Crate_Name) return Translations;
   --  Use this translation to initialize crates (trees immediately following)

   Crate_Bin : constant Tree := New_Tree
     .Append ("alire.toml",       +R.Crate_Bin_Alire_Toml.Content)
     .Append ("src/@_NAME_@.adb", +R.Crate_Bin_Src_Bin_Adb.Content)
     ;

private

   ----------------------------
   -- Init_Crate_Translation --
   ----------------------------

   function Init_Crate_Translation (Name : Crate_Name) return Translations
   is (New_Translation.Append ("NAME", Name.As_String));

end Alire.Templates.Builtins;
