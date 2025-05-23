# --- Stage 1: Build ---
    FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
    WORKDIR /app
    
    COPY ["CounterApi.sln", "."]
    COPY ["src/CounterApi.csproj", "src/"]
    COPY ["tests/CounterAPI.Tests/CounterAPI.Tests.csproj", "tests/CounterAPI.Tests/"]
    
    # Now restore works — all projects are present
    RUN dotnet restore "CounterApi.sln"
    
    COPY . .
    
    WORKDIR /app/src
    RUN dotnet build "CounterApi.csproj" -c Release -o /app/build
    
    # --- Stage 2: Publish ---
    FROM build AS publish
    WORKDIR /app/src
    RUN dotnet publish "CounterApi.csproj" -c Release -o /app/publish /p:UseAppHost=false
    
    # --- Stage 3: Runtime Image ---
    FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
    WORKDIR /app
    COPY --from=publish /app/publish .
    
    ENV ASPNETCORE_URLS=http://+:80 \
        DOTNET_EnableDiagnostics=0 \
        DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true
    
    EXPOSE 80
    ENTRYPOINT ["dotnet", "CounterApi.dll"]