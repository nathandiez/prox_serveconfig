FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 5000

# Set timezone
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install curl for healthcheck
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY ["serve_config_net.csproj", "./"]
RUN dotnet restore "./serve_config_net.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "serve_config_net.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "serve_config_net.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Create the config_files directory
RUN mkdir -p /app/config_files

ENV ASPNETCORE_URLS=http://+:5000

ENTRYPOINT ["dotnet", "serve_config_net.dll"]