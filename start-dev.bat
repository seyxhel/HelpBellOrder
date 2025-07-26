@echo off
echo Starting Zammad Class Project Development Environment...
echo.
echo This will start:
echo - Zammad application server (http://localhost:3000)
echo - PostgreSQL database
echo - Redis cache
echo.
pause

docker-compose -f docker-compose.dev.yml up --build
