with Ada.Directories;

with Alire.Directories;
with Alire.Roots;
with Alire.Templates;

with GNATCOLL.VFS;

package body Alire.Features.Init is

   ---------------------
   -- Working_Release --
   ---------------------

   procedure Working_Release (Name          : Project;
                              Kind          : Kinds;
                              Path          : String;
                              Metadata_Only : Boolean)
   is
      Destination : Directories.Temp_File := Directories.With_Name (Path);
   begin
      --  Don't clean up if already existing:
      if Ada.Directories.Exists (Path) then
         Destination.Keep;
      end if;

      --  Generate skeleton files if not metadata-only:
      if not Metadata_Only then
      end if;

      --  Generate the .../alire/ metadata files
      declare
         use GNATCOLL.VFS;
         Root : constant Alire.Roots.Root := Alire.Roots.New_Root (Name, Path);
      begin
         Make_Dir (Create (+Root.Working_Folder));

         Templates.Generate_Prj_Alr
           (Root.Release,
            Root.Crate_File);

         Templates.Generate_Agg_Gpr (Root);
      end;

      --  Everything went well, so destination is to be kept:
      Destination.Keep;
   end In_Directory;

end Alire.Features.Init;
