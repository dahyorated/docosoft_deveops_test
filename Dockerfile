# --- Stage 1: Build ---
    FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
    WORKDIR /app
    
    COPY ["CounterApi.sln", "."]
    COPY ["src/CounterApi.csproj", "src/"]
    
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
    
    ENV DOTNET_EnableDiagnostics=0 \
        DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true
    
    EXPOSE 80
    ENTRYPOINT ["dotnet", "CounterApi.dll"]