pragma Style_Checks (Off);
--  awsres doesn't use proper casing, and fighting GNAT studio is tiresome

with R.Crate_Bin_Alire_Toml;
with R.Crate_Bin_Src_Crate_Bin_Adb;

package Alire.Templates.Builtins is

   Crate_Bin : constant Tree := New_Tree
     .Append ("alire.toml",       R.Crate_Bin_Alire_Toml.Content'Access)
     .Append ("src/@_name_@.adb", R.Crate_Bin_Src_Crate_Bin_Adb.Content'Access)
     ;

end Alire.Templates.Builtins;
