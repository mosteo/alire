with Alire.Containers;
with Alire.Releases;
with Alire.Roots;

package Alire.Templates is

   procedure Generate_Agg_Gpr (Instance : Containers.Release_Map;
                               Root     : Alire.Roots.Root);
   --  Generate the aggregate project file with given resolved dependencies

   procedure Generate_Prj_Alr (Release  : Releases.Release;
                               Filename : String);
   --  Generate textual release representation at given location

end Alire.Templates;
