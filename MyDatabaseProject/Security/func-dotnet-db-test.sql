CREATE USER [func-dotnet-db-test] from external provider with DEFAULT_SCHEMA = [xyz];
GO;
GRANT DELETE,INSERT,SELECT,UPDATE ON SCHEMA::[xyz] TO [func-dotnet-db-test];
GO;
GRANT UNMASK TO [func-dotnet-db-test];
GO;