@echo off
REM ===========================================
REM One-Click Setup Script for Windows
REM ===========================================

setlocal enabledelayedexpansion

echo =========================================
echo Warranty Management System - Setup
echo =========================================
echo.

REM Check Docker
echo Checking Docker installation...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not installed!
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)
echo OK: Docker found

REM Check Docker Compose
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker Compose is not installed!
    pause
    exit /b 1
)
echo OK: Docker Compose found

REM Check Maven
echo.
echo Checking Maven installation...
mvn --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Maven is not installed!
    echo Please install Maven from: https://maven.apache.org/download.cgi
    pause
    exit /b 1
)
echo OK: Maven found

REM Check existing containers
echo.
echo Checking existing containers...
docker ps -a | findstr "warranty_" >nul 2>&1
if not errorlevel 1 (
    echo WARNING: Found existing containers!
    set /p REMOVE="Do you want to remove them? [y/N]: "
    if /i "!REMOVE!"=="y" (
        echo Removing old containers...
        docker-compose down -v
    )
)

REM Create .env file
echo.
echo Setting up environment...
if not exist .env (
    echo Creating .env file...
    copy .env.example .env
    echo WARNING: Please edit .env file and set your passwords!
)

REM Build Maven
echo.
echo =========================================
echo Step 1: Building Maven project...
echo =========================================
call mvn clean package -DskipTests
if errorlevel 1 (
    echo ERROR: Maven build failed!
    pause
    exit /b 1
)
echo OK: Maven build successful

REM Build Docker
echo.
echo =========================================
echo Step 2: Building Docker images...
echo =========================================
docker-compose build --no-cache
if errorlevel 1 (
    echo ERROR: Docker build failed!
    pause
    exit /b 1
)
echo OK: Docker images built

REM Start containers
echo.
echo =========================================
echo Step 3: Starting containers...
echo =========================================
docker-compose up -d
if errorlevel 1 (
    echo ERROR: Failed to start containers!
    pause
    exit /b 1
)

REM Wait for services
echo.
echo Waiting for services to start...
echo - MySQL: Starting...
timeout /t 10 /nobreak >nul
echo - MySQL: Initializing...
timeout /t 10 /nobreak >nul
echo - Tomcat: Starting...
timeout /t 10 /nobreak >nul
echo - Application: Deploying...
timeout /t 10 /nobreak >nul

REM Check status
echo.
echo =========================================
echo Container status:
echo =========================================
docker-compose ps

REM Show info
echo.
echo =========================================
echo SETUP COMPLETED!
echo =========================================
echo.
echo Application URL:
echo    http://localhost:8080
echo.
echo Default Login:
echo    Username: admin
echo    Password: Admin@123
echo.
echo MySQL Connection:
echo    Host: localhost
echo    Port: 3306
echo    Database: warranty_system
echo    Username: warranty_user
echo    Password: warranty_pass
echo.
echo Useful Commands:
echo    View logs:     docker-compose logs -f
echo    Stop:          docker-compose down
echo    Restart:       docker-compose restart
echo    Status:        docker-compose ps
echo.
echo Documentation:
echo    Quick Start:   DOCKER_QUICKSTART.md
echo    Full Guide:    DOCKER_GUIDE.md
echo.
echo Happy coding!
echo.
pause
