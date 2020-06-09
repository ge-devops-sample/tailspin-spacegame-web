
# This Dockerfile creates the final image to be published to Docker or
# Azure Container Registry
# Create a container with the compiled asp.net core app
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
WORKDIR /app
EXPOSE 80
# Copy only the deployment artifacts
COPY /out .
ENTRYPOINT ["dotnet", "Tailspin.SpaceGame.Web.dll"]