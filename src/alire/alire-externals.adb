with AAA.Enum_Tools;

with Alire.Externals.From_Output;
with Alire.TOML_Keys;

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

      ---------------
      -- From_TOML --
      ---------------

      function From_TOML (Kind : Kinds) return External'Class is
        (case Kind is
            when Output_Version => From_Output.From_TOML (From));

   begin

      --  Retrieve the kind from the table (no guessing from table keys to make
      --  more accurate diagnostics) and dispatch:

      declare
         function Is_Valid is new AAA.Enum_Tools.Is_Valid (Kinds);
         Kind : TOML.TOML_Value;
         OK   : constant Boolean := From.Pop (TOML_Keys.External_Kind, Kind);
      begin
         if not OK then
            From.Checked_Error ("missing external kind field");
         end if;

         if Kind.Kind not in TOML.TOML_String then
            From.Checked_Error ("external kind must be a string, but got a "
                                & Kind.Kind'Img);
         elsif not Is_Valid (TOML_Adapters.Adafy (Kind.As_String)) then
            From.Checked_Error ("external kind is invalid: " & Kind.As_String);
         end if;

         return Result : constant External'Class :=
           From_TOML (Kinds'Value (TOML_Adapters.Adafy (Kind.As_String)))
         do
            From.Report_Extra_Keys; -- Table must be exhausted at this point
         end return;
      end;

   exception
      when Checked_Error =>
         raise;
      when E : others =>
         Log_Exception (E);
         From.Checked_Error
           ("invalid external description (see details with -d)");
   end From_TOML;

end Alire.Externals;
