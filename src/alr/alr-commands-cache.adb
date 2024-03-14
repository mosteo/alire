with Alire.Cache;
with Alire.Directories;
with Alire.Paths;
with Alire.Utils.Tables;

package body Alr.Commands.Cache is

   Builds_Dir : constant String :=
                  Alire.Paths.Build_Folder_Inside_Working_Folder;

   ----------
   -- List --
   ----------

   procedure List (Max_Depth : Alire.Cache.Depths := Alire.Cache.Build) is
      use AAA.Strings;
      use all type Alire.Cache.Depths;
      use type Alire.Cache.Sizes;
      Table : Alire.Utils.Tables.Table;

      Usage : constant Alire.Cache.Usages := Alire.Cache.Usage;
      Max   : constant Alire.Cache.Sizes :=
                (if Usage.Is_Empty
                 then 0
                 else Usage.First_Element.Size);

      ------------
      -- Append --
      ------------

      procedure Append (Depth : Alire.Cache.Depths;
                        Loc   : String;
                        Rel   : String;
                        Item  : Alire.Cache.Base_Item'Class)
      is
         Graph : constant String (1 .. 10) := "|=========";
      begin
         --  Common info

         Table
           .Append (Alire.Directories.TTY_Image (Item.Size))
           .Append (if Depth = Location
                    then Trim (Item.Children.Length'Image)
                    elsif Depth = Release and then Loc = Builds_Dir
                    then Trim (Item.Children.Length'Image)
                    else "")
           .Append (Graph (1 ..
                      Integer'Max -- Ensure at least 1
                        (1,
                         Integer'Min (10, -- Ensure at most 10
                                      Integer (Item.Size * 10 / Max)))))
           .Append (if Rel = "" then TTY.Bold (Loc) else Loc);

         --  Release-only info

         if Depth >= Release then
            Table.Append (Rel);
         end if;

         if Depth >= Build then
            Table.Append (Item.Name (Item.Name'First .. Item.Name'First + 7));
         end if;

         Table.New_Row;
      end Append;

   begin
      Table
        .Header ("SIZE").Header ("COUNT").Header ("GRAPH").Header ("LOCATION");
      if Max_Depth >= Release then
         Table.Header ("RELEASE");
      end if;
      if Max_Depth >= Build then
         Table.Header ("BUILD");
      end if;
      Table.New_Row;

      for Location_Item of Usage loop

         --  We don't want to show the single clone of the publishing
         --  index, as it's small and it doesn't really fit the structure
         --  of location->release->build.

         if Location_Item.Name = "publish" then
            goto Continue;
         end if;

         Append (Location,
                 Location_Item.Name,
                 "",
                 Location_Item);

         if Max_Depth >= Release then
            for Release_Item of Location_Item.Children loop

               --  Small optimization; when a release only has a one build,
               --  conflate both in the same line.
               if Release_Item.Children.Length not in 1
                 or else Location_Item.Name /= Builds_Dir
               then
                  Append (Release,
                          Location_Item.Name,
                          Release_Item.Name,
                          Release_Item);
               end if;

               if Max_Depth >= Build
                 and then Location_Item.Name = Builds_Dir
               then
                  for Build_Item of Release_Item.Children loop
                     Append (Build,
                             Location_Item.Name,
                             Release_Item.Name,
                             Build_Item);
                  end loop;
               end if;
            end loop;
         end if;

         <<Continue>>
      end loop;

      Table.Print (Trace.Always);
   end List;

   -------------
   -- Summary --
   -------------

   procedure Summary is
      use Alire.Directories;
      Table : Alire.Utils.Tables.Table;
   begin
      Table
        .Append ("Path:")
        .Append (Alire.Cache.Path)
        .New_Row;

      Table
        .Append ("Size:")
        .Append (TTY_Image (Alire.Cache.Usage.First_Element.Size));

      Table.Print (Trace.Always);
   end Summary;

   -------------
   -- Execute --
   -------------

   overriding
   procedure Execute (Cmd  : in out Command;
                      Args :        AAA.Strings.Vector)
   is
   begin
      if True then
         Summary;
      else
         List;
      end if;
   end Execute;

end Alr.Commands.Cache;
