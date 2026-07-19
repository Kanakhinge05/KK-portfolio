# ==========================================
# STAGE 1: Build & Asset Preparation
# ==========================================
FROM alpine:3.19 AS builder

WORKDIR /app

# Copy all project files into the builder workspace
COPY . .

# (Optional) If you ever want to run asset minification, 
# linting, or image optimization scripts, you would do it here.

# ==========================================
# STAGE 2: Production Final Image
# ==========================================
FROM nginx:1.25-alpine AS production

# Clean out default Nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy your optimized Nginx server configuration
COPY --from=builder /app/nginx.conf /etc/nginx/conf.d/default.conf

# Copy core web entrypoint and assets from the builder stage
COPY --from=builder /app/index.html /usr/share/nginx/html/
COPY --from=builder /app/profile-cutout.png /usr/share/nginx/html/
COPY --from=builder /app/resume.pdf /usr/share/nginx/html/

# Copy asset directories cleanly from the builder stage
COPY --from=builder /app/favicon/ /usr/share/nginx/html/favicon/
COPY --from=builder /app/favicon_io/ /usr/share/nginx/html/favicon_io/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]