package Alire.Features.Init is

   --  Initialization of a new working release in a given folder

   type Kinds is (Binary, Library);
   --  Determines the kind of GPR project that will be used as template.

   procedure Working_Release (Name          : Project;
                              Kind          : Kinds;
                              Path          : String;
                              Metadata_Only : Boolean);
   --  If Path exists previously, it will be kept in case of failure.
   --  When Metadata_Only, only <Path>/alire/* will be populated. Otherwise,
   --  also a <Path>/src/* minimally compilable skel will be put in place,
   --  with a corresponding <Path>/name.gpr.

end Alire.Features.Init;
