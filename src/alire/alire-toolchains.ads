with Ada.Containers.Indefinite_Ordered_Sets;

with AAA.Strings;

with Alire.Config;
with Alire.Dependencies;
with Alire.Milestones;
with Alire.Releases;
with Alire.Utils;
with Alire.Utils.TTY;

package Alire.Toolchains is

   package Name_Sets is
     new Ada.Containers.Indefinite_Ordered_Sets (Crate_Name);

   Tools : constant Name_Sets.Set :=
             Name_Sets.Empty_Set
               .Union (Name_Sets.To_Set (GNAT_Crate))
               .Union (Name_Sets.To_Set (GPRbuild_Crate));
   --  All crates that are part of the provided binary toolchain

   function Any_Tool (Crate : Crate_Name) return Dependencies.Dependency;
   --  Returns a dependency on crate*

   procedure Assistant (Level              : Config.Level;
                        Allow_Incompatible : Boolean := False);
   --  Runs the interactive assistant to select the default toolchain. By
   --  default, the native Alire-provided compiler for Current_OS is proposed.
   --  This information may apply config-wide or workspace-wide. Installation
   --  goes, in any case, to the config cache location.

   --  The following functions will transform any `gnat_XXX` dependency on
   --  plain `gnat`. This way we need to to litter the callers with similar
   --  transformations, as we always want whatever gnat_XXX is used for "gnat".

   procedure Set_Automatic_Assistant (Enabled : Boolean; Level : Config.Level);
   --  Enable/Disable the automatic assistant on next run

   function Assistant_Enabled return Boolean;

   procedure Set_As_Default (Release : Releases.Release; Level : Config.Level);
   --  Mark the given release as the default to be used. Does not check that it
   --  be already installed.

   function Tool_Is_Configured (Crate : Crate_Name) return Boolean;
   --  Say if a tool is actually configured by the user

   function Tool_Dependency (Crate : Crate_Name) return Dependencies.Dependency
     with Pre => Tool_Is_Configured (Crate);
   --  Return the configured compiler as an exact compiler=version dependency

   function Tool_Key (Crate : Crate_Name) return Config.Config_Key;

   function Tool_Milestone (Crate : Crate_Name) return Milestones.Milestone;

   function Tool_Release (Crate : Crate_Name) return Releases.Release;
   --  Will raise Checked_Error for unconfigured, or configured but without the
   --  release being deployed (e.g. the user messed with files and deleted it
   --  manually).

   procedure Unconfigure (Crate : Crate_Name);
   --  Set the crate as not configured.

   Description : constant AAA.Strings.Vector
     := AAA.Strings.Empty_Vector
       .Append ("Alire indexes binary releases of GNAT and gprbuild. The "
                & "compilers are indexed with their target name, e.g., "
                & Utils.TTY.Name ("gnat_native") & " or "
                & Utils.TTY.Name ("gnat_riscv_elf") & ". ")
     .Append ("")
     .Append ("Use " & TTY.Terminal ("alr toolchain --help") & " to obtain "
              & "information about toolchain management. Alire can be "
              & "configured to rely on a toolchain installed by the user in "
              & "the environment, or to use one of the indexed toolchains "
              & "whenever possible.")
     .Append ("")
     .Append ("Some crates may override the default toolchain by specifying "
              & "dependencies on particular compiler crates, for example to "
              & "use a cross-compiler. In this situation, a compiler already "
              & "available (selected as default or already installed) will "
              & "take precedence over a compiler available in the catalog. ")
     .Append ("")
     .Append ("See also "
              & TTY.URL ("https://alire.ada.dev/docs/#toolchains") & " for "
              & "additional details about compiler dependencies and toolchain "
              & "interactions.");

private

   -----------------------
   -- Assistant_Enabled --
   -----------------------

   function Assistant_Enabled return Boolean
   is (Config.Get (Config.Keys.Toolchain_Assistant, Default => True));

   --------------
   -- Tool_Key --
   --------------
   --  Construct the "toolchain.use.crate" keys
   function Tool_Key (Crate : Crate_Name) return Config.Config_Key
   is (if Utils.Starts_With (Crate.As_String, "gnat_")
       then Tool_Key (GNAT_Crate)
       else Config.Config_Key
              (String (Config.Keys.Toolchain_Use) & "." & Crate.As_String));

   --------------------
   -- Tool_Milestone --
   --------------------
   --  Return the milestone stored by the user for this tool
   function Tool_Milestone (Crate : Crate_Name) return Milestones.Milestone
   is (Milestones.New_Milestone (Config.Get (Tool_Key (Crate), "")));

end Alire.Toolchains;