with Alire.Cache;
with Alire.Utils.Tables;

package body Alr.Commands.Cache is

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
                    then Trim (Item.Element.Children.Length'Image)
                    elsif Depth = Release and then Loc = "builds"
                    then Trim (Item.Element.Children.Length'Image)
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
         Append (Location,
                 Location_Item.Name,
                 "",
                 Location_Item);

         if Max_Depth >= Release then
            for Release_Item of Location_Item.Element.Children loop
               Append (Release,
                       Location_Item.Name,
                       Release_Item.Name,
                       Release_Item);

               if Max_Depth >= Build and then Location_Item.Name = "builds"
               then
                  for Build_Item of Release_Item.Element.Children loop
                     Append (Build,
                             Location_Item.Name,
                             Release_Item.Name,
                             Build_Item);
                  end loop;
               end if;
            end loop;
         end if;
      end loop;

      Table.Print (Trace.Always);
   end List;

   -------------
   -- Execute --
   -------------

   overriding
   procedure Execute (Cmd  : in out Command;
                      Args :        AAA.Strings.Vector)
   is
   begin
      List;
   end Execute;

end Alr.Commands.Cache;
