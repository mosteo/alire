with Alire.Externals.Unindexed;

with TOML;

package body Alire.Externals is

   ------------
   -- Detect --
   ------------

   function Detect (This : List;
                    Name : Crate_Name) return Containers.Release_Set is
   begin
      return Detected : Containers.Release_Set do
         for External of This loop
            Detected.Union (External.Detect (Name));
         end loop;
      end return;
   end Detect;

   ---------------
   -- From_TOML --
   ---------------

   function From_TOML (From : TOML_Adapters.Key_Queue) return External'Class is
      use type TOML.TOML_Value;
   begin

      --  An empty value is the particular case of unindexed external (we known
      --  it exists, but nothing else).

      if From.Unwrap = TOML.No_TOML_Value or else
        (From.Unwrap.Kind in TOML.TOML_Table and then
         From.Unwrap.Keys'Length = 0)
      then
         return Unindexed.External'(null record);
      elsif From.Unwrap.Kind not in TOML.TOML_Table then
         From.Checked_Error ("external description must be a TOML table"
                             & " but got a " & From.Unwrap.Kind'Img);
      end if;

      --  No other externals defined yet:
      From.Checked_Error ("invalid external description");

   exception
      when Checked_Error =>
         raise;
      when E : others =>
         Log_Exception (E);
         From.Checked_Error
           ("invalid external description (see details with -d)");
   end From_TOML;

end Alire.Externals;
