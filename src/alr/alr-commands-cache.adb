with Alire.Cache;
with Alire.Utils.Tables;

package body Alr.Commands.Cache is

   ----------
   -- List --
   ----------

   procedure List (Max_Depth : Alire.Cache.Depths := Alire.Cache.Build) is
      use all type Alire.Cache.Depths;
      Table : Alire.Utils.Tables.Table;

      ------------
      -- Append --
      ------------

      procedure Append (Depth : Alire.Cache.Depths;
                        Loc   : String;
                        Rel   : String;
                        Item  : Alire.Cache.Base_Item'Class) is
      begin
         --  Common info

         Table
           .Append (Alire.Directories.TTY_Image (Item.Size))
           .Append ("[=]")
           .Append (Loc);

         --  Release-only info

         if Depth = Release then
            Table.Append (Rel);
         end if;

         Table.New_Row;
      end Append;

   begin
      Table.Header ("SIZE").Header ("GRAPH").Header ("LOCATION");
      if Max_Depth >= Release then
         Table.Header ("RELEASE");
      end if;
      if Max_Depth >= Build then
         Table.Header ("BUILD");
      end if;
      Table.New_Row;

      for Location_Item of Alire.Cache.Usage loop
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
