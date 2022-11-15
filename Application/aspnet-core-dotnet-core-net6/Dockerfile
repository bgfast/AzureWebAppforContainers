#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["aspnet-core-dotnet-core-net6/aspnet-net6.csproj", "aspnet-core-dotnet-core-net6/"]
RUN dotnet restore "aspnet-core-dotnet-core-net6/aspnet-net6.csproj"
COPY . .
WORKDIR "/src/aspnet-core-dotnet-core-net6"
RUN dotnet build "aspnet-net6.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "aspnet-net6.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "aspnet-net6.dll"]