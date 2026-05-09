# Deployment Files for MomenMedmSys

## Files Overview

| File | Purpose |
|------|---------|
| `Dockerfile` | Container image build for the ASP.NET Core app |
| `docker-compose.yml` | Run app + MySQL together in containers (local/VPS) |
| `render.yaml` | Render.com infrastructure-as-code config |
| `.dockerignore` | Excludes unnecessary files from Docker builds |
| `web.config` | IIS deployment configuration (Windows servers) |
| `nginx.conf` | Nginx reverse proxy config (Linux servers) |

---

## Hosting Information Needed

### 1. Database Server (MySQL)
| Field | Where to change |
|-------|-----------------|
| Host/Server address | `appsettings.json` → `Database.Server` / `ConnectionStrings.DefaultConnection` |
| Port (default 3306) | `appsettings.json` → `Database.Port` |
| Database name | `appsettings.json` → `Database.Database` |
| Username | `appsettings.json` → `Database.User` |
| Password | `appsettings.json` → `Database.Password` |
| SSL mode | `appsettings.json` → `Database.SslMode` |

### 2. Application URL
- For Docker/VPS: set via `ASPNETCORE_URLS` env variable
- For Render: uses the `PORT` env variable automatically
- For IIS: configure binding in IIS Manager
- For Nginx: set `proxy_pass` to the app's internal URL

### 3. Domain & SSL
- Domain name → update `server_name` in `nginx.conf`
- SSL certificate files → update paths in `nginx.conf`
- For IIS: bind SSL certificate in IIS Manager

### 4. Environment
- Set `ASPNETCORE_ENVIRONMENT` to `Production`

---

## Deployment Methods

### Option 1: Render.com (Recommended for free hosting)

Render supports Docker-based deployments and gives you a free `*.onrender.com` URL.

**Steps:**
1. Push your project to a GitHub repository
2. Go to [Render Dashboard](https://dashboard.render.com) → New Web Service
3. Connect your GitHub repo
4. Set **Runtime** to `Docker`
5. Set **Dockerfile Path** to `deploy/Dockerfile`
6. Choose **Free** instance type
7. Add these **Environment Variables** (set via Render dashboard or `deploy/render.yaml`):
   ```
   ASPNETCORE_ENVIRONMENT=Production
   Database__Server=your-mysql-host.com
   Database__Port=3306
   Database__Database=medmsys
   Database__User=your_db_user
   Database__Password=your_db_password
   Database__SslMode=true
   Database__AllowPublicKeyRetrieval=true
   ConnectionStrings__DefaultConnection=Server=your-mysql-host.com;Database=medmsys;User=your_db_user;Password=your_db_password;SslMode=Required;AllowPublicKeyRetrieval=True;
   ```
8. Deploy!

**Free MySQL database options for Render:**
- [Aiven.io](https://aiven.io) — free MySQL 5GB (no credit card)
- [Supabase](https://supabase.com) — free PostgreSQL (would need code changes)
- [PlanetScale](https://planetscale.com) — free MySQL-compatible (5GB)

### Option 2: Docker (Any VPS or Cloud)
```bash
cd deploy
docker-compose up -d
```

### Option 3: Manual on Linux
```bash
dotnet publish MomenMedmSys.Web -c Release -o /app/publish
dotnet MomenMedmSys.Web.dll --urls http://localhost:5000
```
Then configure Nginx using `deploy/nginx.conf`.

### Option 4: IIS (Windows)
1. Install .NET 8 Hosting Bundle on the server
2. Publish: `dotnet publish -c Release -o C:\inetpub\apps\mems`
3. Copy `web.config` to the published folder
4. Create IIS site pointing to the folder with an app pool using "No Managed Code"
