# Deployment Guide

This guide covers deploying the Survey App React frontend to various hosting platforms.

## Prerequisites

- Node.js (v14+) and npm
- Built production files (`npm run build` creates `dist/` folder)
- Elixir backend deployed and accessible
- Environment variables configured

## Build Output

After running `npm run build`, you'll have a `dist/` folder with:
- `index.html` - Main HTML entry point
- `assets/` - Bundled JavaScript and CSS files

Build statistics:
- **JavaScript bundle**: ~76KB (gzipped)
- **CSS bundle**: ~4KB (gzipped)
- **Total size**: ~80KB (gzipped)
- **Load time**: Very fast

## Deployment Options

### Option 1: Vercel (Recommended)

Fastest and easiest deployment.

#### Steps:

1. **Install Vercel CLI**
   ```bash
   npm install -g vercel
   ```

2. **Deploy**
   ```bash
   vercel
   ```

3. **Configure at prompts**
   - Framework: Vite
   - Build command: `npm run build`
   - Output directory: `dist`
   - Functions directory: (skip)

4. **Set Environment Variables**
   ```bash
   vercel env add VITE_API_URL
   # Enter: https://your-elixir-backend.com/api
   ```

5. **Redeploy with env vars**
   ```bash
   vercel --prod
   ```

#### Benefits:
- Free tier available
- Automatic deployments from Git
- Built-in CDN
- Custom domains

### Option 2: Netlify

Similar to Vercel, very beginner-friendly.

#### Steps:

1. **Push code to GitHub**

2. **Connect to Netlify**
   - Go to netlify.com
   - Click "New site from Git"
   - Select your repository

3. **Configure build settings**
   - Build command: `npm run build`
   - Publish directory: `dist`

4. **Add environment variable**
   - Go to Site settings → Build & deploy → Environment
   - Add variable: `VITE_API_URL=https://your-backend.com/api`

5. **Deploy**
   - Netlify automatically deploys on Git push

#### Benefits:
- Free tier available
- Easy Git integration
- Automatic HTTPS
- Form handling available

### Option 3: GitHub Pages

Free but limited options.

#### Steps:

1. **Add to vite.config.js**
   ```javascript
   export default defineConfig({
     base: '/survey_react/',  // Replace with your repo name
     // ... rest of config
   })
   ```

2. **Update package.json**
   ```json
   "homepage": "https://yourusername.github.io/survey_react",
   "scripts": {
     "deploy": "npm run build && gh-pages -d dist"
   }
   ```

3. **Install gh-pages**
   ```bash
   npm install --save-dev gh-pages
   ```

4. **Deploy**
   ```bash
   npm run deploy
   ```

#### Note:
- Limited to `yourusername.github.io/repo-name`
- Cannot use custom domains on free plan

### Option 4: Traditional Server (Nginx/Apache)

For self-hosted or corporate servers.

#### Nginx Configuration

```nginx
server {
    listen 80;
    server_name survey.example.com;

    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name survey.example.com;

    # SSL certificates
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    root /var/www/survey-app/dist;
    index index.html;

    # Serve static files with caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # SPA routing - all requests go to index.html
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Proxy API requests to Elixir backend
    location /api/ {
        proxy_pass http://localhost:4000/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

#### Apache Configuration

```apache
<VirtualHost *:443>
    ServerName survey.example.com
    
    SSLEngine on
    SSLCertificateFile /path/to/cert.pem
    SSLCertificateKeyFile /path/to/key.pem
    
    DocumentRoot /var/www/survey-app/dist
    
    <Directory /var/www/survey-app/dist>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
        
        # SPA routing
        RewriteEngine On
        RewriteBase /
        RewriteRule ^index\.html$ - [L]
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule . /index.html [L]
    </Directory>
    
    # API proxy
    ProxyPreserveHost On
    ProxyPass /api/ http://localhost:4000/api/
    ProxyPassReverse /api/ http://localhost:4000/api/
    
    # Caching headers
    <FilesMatch "\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$">
        Header set Cache-Control "max-age=31536000, public"
    </FilesMatch>
</VirtualHost>

<VirtualHost *:80>
    ServerName survey.example.com
    Redirect permanent / https://survey.example.com/
</VirtualHost>
```

#### Deployment Steps

1. **Build the application**
   ```bash
   npm run build
   ```

2. **Upload to server**
   ```bash
   scp -r dist/* user@server:/var/www/survey-app/dist/
   ```

3. **Update environment**
   - Modify `.env` or set environment variables on server
   - Update API base URL

4. **Restart web server**
   ```bash
   sudo systemctl restart nginx
   # or
   sudo systemctl restart apache2
   ```

### Option 5: Docker

For containerized deployment.

#### Create Dockerfile

```dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:18-alpine
RUN npm install -g serve
WORKDIR /app
COPY --from=builder /app/dist ./dist

ENV PORT=3000
EXPOSE ${PORT}

CMD ["serve", "-s", "dist", "-l", "3000"]
```

#### Create docker-compose.yml

```yaml
version: '3.8'

services:
  survey-app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - VITE_API_URL=http://elixir-backend:4000/api
    depends_on:
      - elixir-backend
    
  elixir-backend:
    image: your-elixir-image:latest
    ports:
      - "4000:4000"
```

#### Build and deploy

```bash
docker build -t survey-app:latest .
docker run -p 3000:3000 -e VITE_API_URL=https://api.example.com survey-app:latest
```

## Environment Configuration

Before deployment, update the API URL in your environment:

**For Vercel/Netlify:**
```
VITE_API_URL=https://your-elixir-backend.com/api
```

**For environment file:**
Create `.env.production`:
```
VITE_API_URL=https://your-elixir-backend.com/api
VITE_APP_MODE=production
```

## SSL/HTTPS Setup

**Important**: Always use HTTPS in production.

### Let's Encrypt (Free)

```bash
# Using Certbot
sudo apt-get install certbot python3-certbot-nginx
sudo certbot certonly --nginx -d survey.example.com
```

### CloudFlare

1. Add your domain to CloudFlare
2. Enable SSL/TLS (Full or Flexible)
3. Point your nameservers to CloudFlare

## Performance Optimization

### Before Deployment

1. **Minification** (automatic with `npm run build`)
   
2. **Lazy Loading**
   ```javascript
   // Already implemented for route-based code splitting
   const AdminDashboard = lazy(() => import('./pages/AdminDashboard'))
   ```

3. **Image Optimization**
   - Use WebP format where possible
   - Compress images before adding

4. **Caching Strategy**
   - Static assets: 1 year cache
   - HTML: No cache
   - API responses: Per-endpoint configuration

### Monitoring

Set up monitoring services:
- **Sentry**: Error tracking
- **LogRocket**: User session recording
- **New Relic**: Performance monitoring
- **Google Analytics**: User analytics

## Post-Deployment Checklist

- [ ] App loads at correct URL
- [ ] Login works with test credentials
- [ ] API calls reach Elixir backend
- [ ] Form submission works end-to-end
- [ ] Admin dashboard loads with data
- [ ] Mobile responsiveness tested
- [ ] HTTPS/SSL working
- [ ] Form validation works
- [ ] Error messages display correctly
- [ ] Performance acceptable (<3s load time)
- [ ] Cross-browser tested (Chrome, Firefox, Safari)
- [ ] Security headers configured
- [ ] CORS properly configured
- [ ] Rate limiting set on backend

## Rollback Strategy

### For Git-based Deployments (Vercel/Netlify)

```bash
# Revert last commit
git revert HEAD
git push  # Auto-deploys

# Or redeploy specific commit
vercel --prod
```

### For Manual Deployments

```bash
# Keep previous build
cp -r dist dist-backup-$(date +%s)

# Deploy new version
npm run build
scp -r dist/* user@server:/var/www/survey-app/dist/

# If issues, restore from backup
cp -r dist-backup-X/* dist/
```

## Troubleshooting

### Blank Page After Deployment

- Check browser console for errors
- Verify `VITE_API_URL` is correct
- Clear browser cache (Ctrl+Shift+Delete)
- Check that index.html is being served

### API Calls Failing

- Verify CORS headers on Elixir backend
- Check network tab in DevTools
- Verify API URL in .env
- Check backend is running and accessible

### Styling/CSS Not Loading

- Hard refresh browser (Ctrl+Shift+R)
- Check CSS file in network tab
- Verify asset paths are correct
- Check proxy configuration if behind proxy

### Slow Performance

- Check bundle size: `npm run build`
- Enable GZIP compression on server
- Optimize images
- Use CDN for static assets
- Check API response times

## Security Checklist

- [ ] HTTPS enabled
- [ ] CORS properly configured
- [ ] API rate limiting enabled
- [ ] Input validation on backend
- [ ] No sensitive data in localStorage
- [ ] Environment variables not exposed
- [ ] Security headers configured
- [ ] XSS protection enabled
- [ ] CSRF tokens if applicable
- [ ] Regular security updates

## Scaling

For high traffic:

1. **Enable caching**
   - Browser caching for static assets
   - Server-side caching for API responses

2. **Use CDN**
   - CloudFlare, Akamai, or similar
   - Cache static assets globally

3. **Load balancing**
   - Multiple server instances
   - Load balancer in front

4. **Database optimization**
   - MongoDB indexes
   - Query optimization
   - Connection pooling

---

**Document Version**: 1.0  
**Last Updated**: February 18, 2026
