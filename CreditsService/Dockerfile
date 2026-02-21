FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["CreditsService/CreditsService.csproj", "CreditsService/"]
RUN dotnet restore "CreditsService/CreditsService.csproj"
COPY CreditsService/ ./CreditsService/
WORKDIR "/src/CreditsService"
RUN dotnet publish -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "CreditsService.dll"]