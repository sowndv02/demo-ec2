using System.Runtime.InteropServices;
using Microsoft.AspNetCore.HttpOverrides;

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
