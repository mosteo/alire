with Alire.Experimental;
with Alire.TOML_Keys;
with Alire.Utils.Did_You_Mean;

package body Alire.Properties.Environment is

   function Actions_Suggestion
   is new Utils.Did_You_Mean.Enum_Suggestion
     (Actions, Utils.Did_You_Mean.Lower_Case);

   ------------
   -- Action --
   ------------

   function Action (This : Variable) return Actions is
     (This.Action);

   ----------
   -- Name --
   ----------

   function Name (This : Variable) return String is
     (+This.Name);

   function Shell_Name (This : Variable) return String is
     ("${" & Name (This) & "}");

   -----------
   -- Value --
   -----------

   function Value (This : Variable) return String is
     (+This.Value);

   ---------------
   -- Image_RHS --
   ---------------

   function Image_RHS (This : Variable) return String is
     (Name (This)
      & (case This.Action is
            when Append  => "=" & Shell_Name (This)  & ":"  & Value (This),
            when Prepend => "=" & Value (This) & ":" & Shell_Name (This),
            when Set     => "=" & Value (This)));

   -----------
   -- Image --
   -----------

   overriding
   function Image (This : Variable) return String is
      ("Environment: " & Image_RHS (This));

   ---------
   -- Key --
   ---------

   overriding
   function Key (This : Variable) return String is
      pragma Unreferenced (This);
   begin
      return TOML_Keys.Environment;
   end Key;

   ---------------
   -- From_TOML --
   ---------------

   function From_TOML (From : TOML_Adapters.Key_Queue)
                       return Conditional.Properties
   is
      use type Conditional.Properties;
      use TOML;
      Env : TOML_Value;

      ----------------
      -- path_check --
      ----------------

      function Path_Check (S : String) return String is
      begin
         --  We expect something resembling a portable path
         if (for some Char of S => Char = '\') then
            Raise_Checked_Error
              ("Forbidden '\' character in environment path; use '/' instead");
         end if;

         if GNAT.OS_Lib.Directory_Separator /= '/' then
            return AAA.Strings.Replace (S, "/",
                                        "" & GNAT.OS_Lib.Directory_Separator);
         else
            return S;
         end if;
      end Path_Check;

   begin
      if From.Unwrap.Kind /= TOML_Table then
         From.Checked_Error
           ("environment: table with assignments expected, but got: "
            & From.Unwrap.Kind'Img);
      end if;

      if From.Pop_Single_Table (Env, TOML_Table) /= TOML_Keys.Environment then
         raise Program_Error;
         --  Can't happen, unless the dispatch to us itself was erroneous
      end if;

      return Props : Conditional.Properties do
         for Name of Env.Keys loop
            declare
               Var  : Variable;   -- The env. var. being parsed
               Val  : TOML_Value; -- The env. var. action. value
                                  --  Which can be in turn the string value or
                                  --  a nested table with "literal.value"
               Literal : Boolean := False;
            begin
               Var.Name := Name;

               --  Action

               declare
                  Action_Image : constant String :=
                                   From.Descend
                                     (Value   => Env.Get (Name),
                                      Context => "environment: " & (+Name))
                                     .Pop_Single_Table (Val);
               begin
                  Var.Action := Actions'Value (Action_Image);
               exception
                  when Constraint_Error => -- because Action is invalid
                     From.Checked_Error
                       (": " & (+Var.Name)
                        & " invalid action: '" & Action_Image & "'." &
                          Actions_Suggestion (Action_Image));
               end;

               --  Either VAR.action.value or VAR.action.literal.value
               Literal := Val.Kind in TOML.TOML_Table;

               if Literal then
                  Experimental.Check (Experimental.Literal_Environment,
                                      Experimental.Minor);

                  if Val.Keys'Length /= 1 or else +Val.Keys (1) /= "literal"
                  then
                     Raise_Checked_Error
                       ("Only a single child with value 'literal' allowed "
                        & "after environment.VAR.action");
                  end if;

                  Val := Val.Get ("literal");
               end if;

               --  We consider values as possibly containing paths, so we do
               --  translation to native at this time, unless "literal" was
               --  specified.

               if Val.Kind not in TOML.TOML_String then
                  Raise_Checked_Error
                    ("Expected a single entry of type STRING, but got a "
                     & Val.Kind'Img);
               end if;

               if Literal then
                  Var.Value := +Val.As_String;
               else
                  Var.Value := +Path_Check (Val.As_String);
               end if;

               --  Pop entry to avoid upper "unexpected key" errors

               Env.Unset (+Name);

               --  Final assignment

               Props := Props and Var;
            end;
         end loop;

      end return;
   end From_TOML;

   -------------
   -- To_TOML --
   -------------

   overriding
   function To_TOML (This : Variable) return TOML.TOML_Value is
      use TOML;
      Child : constant TOML_Value := Create_Table;
   begin
      return Result : constant TOML_Value := Create_Table do

         --  Create the VAR.action.Value nested tables

         Child.Set (AAA.Strings.To_Lower_Case (This.Action'Img),
                    Create_String (Value (This)));

         Result.Set (Name (This),
                     Child);
      end return;
   end To_TOML;

   -------------
   -- To_YAML --
   -------------

   overriding
   function To_YAML (This : Variable) return String is
     ("Environment: '" & Image_RHS (This) & "'");

end Alire.Properties.Environment;
