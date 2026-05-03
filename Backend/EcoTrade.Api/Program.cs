using EcoTrade.Api.Options;
using EcoTrade.Api.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.Configure<MlServiceOptions>(
    builder.Configuration.GetSection(MlServiceOptions.SectionName));

var pg = builder.Configuration.GetConnectionString("Postgres")
    ?? throw new InvalidOperationException("ConnectionStrings:Postgres tanımlı değil.");
builder.Services.AddSingleton<IProducerPanelRepository>(_ => new ProducerPanelRepository(pg));

builder.Services.AddSingleton<IHackathonChatService, HackathonMockChatService>();

builder.Services.AddHttpClient<IPredictionService, PredictionService>((sp, client) =>
{
    var opts = sp.GetRequiredService<Microsoft.Extensions.Options.IOptions<MlServiceOptions>>().Value;
    var baseUrl = opts.BaseUrl.TrimEnd('/');
    client.BaseAddress = new Uri(baseUrl + "/");
    var sec = Math.Clamp(opts.TimeoutSeconds, 5, 120);
    client.Timeout = TimeSpan.FromSeconds(sec);
});

builder.Services.AddHttpClient<IMlChatService, MlChatService>((sp, client) =>
{
    var opts = sp.GetRequiredService<Microsoft.Extensions.Options.IOptions<MlServiceOptions>>().Value;
    client.BaseAddress = new Uri(opts.BaseUrl.TrimEnd('/') + "/");
    var sec = Math.Clamp(opts.TimeoutSeconds, 5, 120);
    client.Timeout = TimeSpan.FromSeconds(sec);
});

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Flutter Web (Chrome): tarayıcı kaynaklı CORS; Development'ta yerel origin'lere izin.
if (builder.Environment.IsDevelopment())
{
    builder.Services.AddCors(options =>
    {
        options.AddPolicy(
            "DevFlutterWeb",
            policy => policy
                .SetIsOriginAllowed(_ => true)
                .AllowAnyHeader()
                .AllowAnyMethod());
    });
}

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
    app.UseCors("DevFlutterWeb");
}

// Sadece HTTPS dinleniyorsa yönlendir; yoksa http://127.0.0.1:5159 tarayıcıda kırılmaz.
var urls = Environment.GetEnvironmentVariable("ASPNETCORE_URLS") ?? string.Empty;
if (urls.Contains("https://", StringComparison.OrdinalIgnoreCase))
{
    app.UseHttpsRedirection();
}

app.MapControllers();

// Tarayıcıda sadece http://...:5159/ açılınca boş/404 yerine Swagger'a gitsin.
if (app.Environment.IsDevelopment())
{
    app.MapGet("/", () => Results.Redirect("/swagger"));
}

app.Run();
