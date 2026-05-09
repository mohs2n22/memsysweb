FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY MomenMedmSys.slnx ./
COPY MomenMedmSys.Core/MomenMedmSys.Core.csproj MomenMedmSys.Core/
COPY MomenMedmSys.Data/MomenMedmSys.Data.csproj MomenMedmSys.Data/
COPY MomenMedmSys.Services/MomenMedmSys.Services.csproj MomenMedmSys.Services/
COPY MomenMedmSys.Web/MomenMedmSys.Web.csproj MomenMedmSys.Web/

RUN dotnet restore MomenMedmSys.Web/MomenMedmSys.Web.csproj

COPY . .
RUN dotnet publish MomenMedmSys.Web/MomenMedmSys.Web.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
EXPOSE 8080

COPY --from=build /app/publish .

ENV ASPNETCORE_ENVIRONMENT=Production

CMD ASPNETCORE_URLS="http://+:${PORT:-8080}" dotnet MomenMedmSys.Web.dll
