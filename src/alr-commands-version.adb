with Alire.OS_Lib;

with Alr.Bootstrap;
with Alr.OS_Lib;

package body Alr.Commands.Version is

   -------------
   -- Execute --
   -------------

   overriding procedure Execute (Cmd : in out Command) is
      pragma Unreferenced (Cmd);
      use Alr.OS_Lib;
   begin
      -- FIXME this is OS dependent
      Alire.OS_Lib.Spawn (Bootstrap.Alr_Src_Folder / "scripts" / "version");
      Log ("alr internal bootstrap version is " & Bootstrap.Alr_Bootstrap_Release.Image &
             " from " & Bootstrap.Alr_Bootstrap_Release.Repo_Image);
   end Execute;

end Alr.Commands.Version;
