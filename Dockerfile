FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY ["src/Interswitch.Api/Interswitch.Api.csproj", "Interswitch.Api/"]
COPY ["src/Interswitch.Core/Interswitch.Core.csproj", "Interswitch.Core/"]
RUN dotnet restore "Interswitch.Api/Interswitch.Api.csproj"

# Copy everything else and build
COPY src/ .
RUN dotnet build "Interswitch.Api/Interswitch.Api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Interswitch.Api/Interswitch.Api.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Interswitch.Api.dll"]
