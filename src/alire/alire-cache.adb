with Alire.Directories;
with Alire.Paths;
with Alire.Platforms.Folders;
with Alire.Settings.Builtins;
with Alire.Settings.Edit;

with Ncdu;

package body Alire.Cache is

   use Alire.Directories.Operators;

   package Adirs renames Ada.Directories;
   package Du is new Ncdu;

   ----------
   -- Path --
   ----------

   function Path return Absolute_Path
   is (if Settings.Builtins.Cache_Dir.Get /= "" then
          Settings.Builtins.Cache_Dir.Get
       elsif not Settings.Edit.Is_At_Default_Dir then
          Settings.Edit.Path / Paths.Cache_Folder_Inside_Working_Folder
       else
          Platforms.Folders.Cache);

   -----------
   -- Usage --
   -----------

   function Usage return Usages is

      Tree  : constant Du.Tree := Du.List (Path);

      ----------------
      -- Usage_Wrap --
      ----------------

      procedure Usage_Wrap (Parent   : in out Usages;
                            Children : Du.Tree;
                            Depth    : Depths;
                            Branch   : String := ""
                              --  Says if toolchains, releases, or builds
                           )
      is
      begin
         for Child of Children loop
            declare
               Branch           : constant String
                 := (if Usage_Wrap.Branch /= ""
                     then Usage_Wrap.Branch
                     else Adirs.Simple_Name (Child.Element.Path));
               Wrapped_Children : Usages;
            begin

               --  Wrap the children if we still have room to go down

               if Depth < Release or else
                 (Depth < Build and then Branch = "builds")
               then
                  Usage_Wrap (Wrapped_Children,
                              Child.Element.Children,
                              Depth  => Depths'Succ (Depth),
                              Branch => Branch);
               end if;

               --  Create the wrapped node at the current depth

               Parent.Insert
                 (Item'
                    (Depth    => Depth,
                     Name     => +Adirs.Simple_Name (Child.Element.Path),
                     Path     => +Child.Element.Path,
                     Size     => Child.Tree_Size,
                     Children => Wrapped_Children));
            end;
         end loop;
      end Usage_Wrap;

   begin
      --  The root node should be the cache dir itself
      if Tree.Length not in 1 then
         raise Program_Error
           with "Cache tree root length /= 1:" & Tree.Length'Image;
      end if;

      --  Iterate the obtained tree wrapping contents as our usage type
      return Result : Usages do
         Usage_Wrap (Result,
                     Tree.First_Element.Element.Children,
                     Depths'First);
      end return;
   end Usage;

end Alire.Cache;
