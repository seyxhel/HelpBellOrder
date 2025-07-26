# Zammad Class Project Setup

This is your customized fork of Zammad for your class project. We've updated it to use Ruby 3.3.9 and set up Docker for easy development on Windows.

## Quick Start with Docker (Recommended)

### Prerequisites
- Docker Desktop for Windows
- Git (already installed)

### Getting Started

1. **Start the development environment:**
   ```powershell
   docker-compose -f docker-compose.dev.yml up --build
   ```

2. **Wait for the containers to start** (this may take a few minutes on first run)

3. **Access Zammad:**
   - Open your browser to: http://localhost:3000
   - Follow the setup wizard

4. **Stop the environment:**
   ```powershell
   docker-compose -f docker-compose.dev.yml down
   ```

### Development Workflow

- **Make code changes:** Edit files in VS Code as normal
- **View changes:** They'll be reflected immediately at http://localhost:3000
- **Run commands:** Use `docker-compose exec zammad bash` to get a shell inside the container

## What We've Done

✅ **Updated Ruby version** from 3.3.8 to 3.3.9 in Gemfile  
✅ **Updated Dockerfile** to use Ruby 3.3.9  
✅ **Set up Docker development environment** to avoid Windows native compilation issues  
✅ **Your own GitHub repository** (seyxhel/zammad) ready for customization  

## For Your Class Project

You can now:
- Customize the Zammad interface
- Add new features
- Modify existing functionality
- Submit your changes to your own repository

## Alternative: Native Windows Setup

If you prefer to work without Docker, you'll need to:

1. Install missing system dependencies (MSYS2, development headers)
2. Fix native extension compilation issues
3. Set up PostgreSQL and Redis manually

The Docker approach is much simpler and more reliable for class work.

## Next Steps

1. Explore the Zammad interface at http://localhost:3000
2. Check out the codebase structure
3. Start implementing your class project requirements
4. Commit your changes to your repository

## Support

If you encounter issues:
1. Check Docker Desktop is running
2. Ensure ports 3000, 5432, and 6379 aren't in use
3. Try `docker-compose -f docker-compose.dev.yml down` and restart
