using System.Runtime.InteropServices;
using Microsoft.AspNetCore.HttpOverrides;
using Npgsql;

var startedAt = DateTimeOffset.UtcNow;

var builder = WebApplication.CreateBuilder(args);

builder.Services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
    options.KnownIPNetworks.Clear();
    options.KnownProxies.Clear();
});

builder.Services.AddHealthChecks();

var app = builder.Build();

app.UseForwardedHeaders();
app.UseDefaultFiles();
app.UseStaticFiles();

app.MapHealthChecks("/health");

app.MapGet("/api/db", async (IConfiguration config, CancellationToken cancellationToken) =>
{
    var connectionString = config.GetConnectionString("Dome");
    if (string.IsNullOrWhiteSpace(connectionString))
    {
        return Results.Ok(new { connected = false, message = "Chưa có ConnectionStrings:Dome." });
    }

    try
    {
        await using var connection = new NpgsqlConnection(connectionString);
        await connection.OpenAsync(cancellationToken);

        await using (var create = new NpgsqlCommand(
            """
            CREATE TABLE IF NOT EXISTS demo_ping (
                id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                created_at timestamptz NOT NULL DEFAULT now()
            )
            """, connection))
        {
            await create.ExecuteNonQueryAsync(cancellationToken);
        }

        await using (var insert = new NpgsqlCommand("INSERT INTO demo_ping DEFAULT VALUES", connection))
        {
            await insert.ExecuteNonQueryAsync(cancellationToken);
        }

        await using var query = new NpgsqlCommand(
            """
            SELECT COUNT(*)::bigint, current_database(), inet_server_addr()::text, version()
            FROM demo_ping
            """, connection);
        await using var reader = await query.ExecuteReaderAsync(cancellationToken);
        await reader.ReadAsync(cancellationToken);

        return Results.Ok(new
        {
            connected = true,
            database = reader.GetString(1),
            serverAddress = reader.IsDBNull(2) ? "" : reader.GetString(2),
            version = reader.GetString(3),
            pingCount = reader.GetInt64(0)
        });
    }
    catch (Exception exception)
    {
        return Results.Ok(new { connected = false, message = exception.Message });
    }
});

app.MapGet("/api/info", (HttpContext http) =>
{
    var connection = http.Connection;
    return Results.Ok(new
    {
        app = "Dome",
        framework = "ASP.NET Core 10",
        runtime = RuntimeInformation.FrameworkDescription,
        os = RuntimeInformation.OSDescription,
        architecture = RuntimeInformation.OSArchitecture.ToString(),
        machine = Environment.MachineName,
        environment = app.Environment.EnvironmentName,
        processors = Environment.ProcessorCount,
        utc = DateTimeOffset.UtcNow,
        uptimeSeconds = Math.Round((DateTimeOffset.UtcNow - startedAt).TotalSeconds, 1),
        remoteIp = connection.RemoteIpAddress?.ToString(),
        localPort = connection.LocalPort
    });
});

app.Run();
