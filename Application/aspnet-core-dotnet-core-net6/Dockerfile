# https://hub.docker.com/_/microsoft-dotnet
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /source

# copy csproj and restore as distinct layers
#COPY *.sln .
#COPY aspnet-core-dotnet-core-net6/*.csproj ./aspnetapp/
#RUN dotnet restore
COPY . .
RUN dotnet restore
RUN dotnet publish -o /app

# copy everything else and build app
#COPY aspnet-core-dotnet-core-net6/. ./aspnet-core-dotnet-core-net6/
#WORKDIR /source/aspnet-core-dotnet-core-net6
#RUN dotnet publish -c release -o /app --no-restore

# final stage/image
FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app
COPY --from=build /app ./
ENTRYPOINT ["dotnet", "aspnet-core-dotnet-core-net6.dll"]
