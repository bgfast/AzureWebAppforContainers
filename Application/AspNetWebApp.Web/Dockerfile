#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.
#

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["AspNetWebApp.Web/AspNetWebApp.Web.csproj", "AspNetWebApp.Web/"]
RUN dotnet restore "AspNetWebApp.Web/AspNetWebApp.Web.csproj"
COPY . .
WORKDIR "/src/AspNetWebApp.Web"
RUN dotnet build "AspNetWebApp.Web.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "AspNetWebApp.Web.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "AspNetWebApp.Web.dll"]