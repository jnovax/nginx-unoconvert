# UnoConvert with Nginx Load Balancer

This setup provides a scalable unoconvert service using nginx as a reverse proxy and load balancer for multiple unoconvert instances.

## Architecture

- **Nginx**: Acts as a reverse proxy and load balancer on port 8080
- **UnoConvert Services**: 3 instances of LibreOffice unoserver running on internal port 2004
- **Load Balancing**: Round-robin distribution across all available instances

## Quick Start

1. Start all services:
   ```bash
   docker-compose up -d
   ```

2. Check service status:
   ```bash
   docker-compose ps
   ```

3. Test the service:
   ```bash
   curl -X POST -F "file=@demo/demo.docx" http://localhost:8080/convert/pdf
   ```

## Service Endpoints

- **Main Service**: `http://localhost:8080/` - Load balanced across all unoconvert instances
- **Health Check**: `http://localhost:8080/nginx-health` - Nginx health status
- **Status Page**: `http://localhost:8080/nginx-status` - Nginx statistics (restricted access)

## Configuration

### Scaling

To add more unoconvert instances:

1. Add new service to `docker-compose.yml`:
   ```yaml
   unoconvert4:
     image: libreofficedocker/libreoffice-unoserver:3.22
     expose:
       - "2004"
     restart: unless-stopped
   ```

2. Add the new service to nginx upstream in `nginx.conf`:
   ```nginx
   upstream unoconvert_backend {
       server unoconvert1:2004;
       server unoconvert2:2004;
       server unoconvert3:2004;
       server unoconvert4:2004;  # New instance
   }
   ```

3. Update nginx dependencies in `docker-compose.yml`:
   ```yaml
   nginx:
     depends_on:
       - unoconvert1
       - unoconvert2
       - unoconvert3
       - unoconvert4  # New dependency
   ```

### Load Balancing Methods

The current setup uses round-robin. You can modify `nginx.conf` for different strategies:

- **Least Connections**: Add `least_conn;` to the upstream block
- **IP Hash**: Add `ip_hash;` to the upstream block
- **Weighted**: Add weights like `server unoconvert1:2004 weight=3;`

### Health Checks

Uncomment the health check lines in `nginx.conf` for automatic failover:
```nginx
server unoconvert1:2004 max_fails=3 fail_timeout=30s;
```

## Monitoring

- View nginx logs: `docker-compose logs nginx`
- View unoconvert logs: `docker-compose logs unoconvert1`
- Check nginx status: `curl http://localhost:8080/nginx-status`

## Troubleshooting

1. **Service not responding**: Check if all containers are running
   ```bash
   docker-compose ps
   ```

2. **Load balancing not working**: Check nginx configuration
   ```bash
   docker-compose exec nginx nginx -t
   ```

3. **High load**: Scale up by adding more unoconvert instances

## Demo

Test files are available in the `demo/` directory. Use `demo/test.sh` to run conversion tests.
