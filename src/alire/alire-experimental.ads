package Alire.Experimental with Preelaborate is

   --  Index-breaking changes are registered here so we can lockstep them
   --  easily. Features locked behind this package check should be made
   --  just regular features on index version change.

   Enabled : aliased Boolean := False;
   --  Set to True to enable future features.

   type Breaking is (Minor, Major);
   --  Mark a feature with minor/major so we know what to bump once it is
   --  taken out of experimental. Remember that this refers to index versions.

   type Features is
     (Literal_Environment
      --  Allows using the [environment.VARIABLE.<action>.literal.VALUE] table

      , End_Of_Features);

   procedure Check (Feature : Features; Breaks : Breaking);

end Alire.Experimental;
