--  Verify that assertions are enabled in the testsuite. A test is successful
--  if it exits normally; it is a failure if it raises an uncaught exception or
--  exits with a non-zero status code.

procedure @_CAPITALIZE:NAME_@_Tests.Assertions_Enabled is
begin
   begin
      Assert (False, "Raises if assertions are enabled");
   exception
      when Assertion_Error =>
         return; -- Assertion raised and caught as expected
   end;
   raise Program_Error with "Assertions are disabled"; -- Assert did not raise
end @_CAPITALIZE:NAME_@_Tests.Assertions_Enabled;
