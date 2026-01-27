FROM nginx:alpine

# Copy config (It is now in the same folder as this Dockerfile)
COPY default.conf /etc/nginx/conf.d/default.conf

# Copy web files (We can see 'mobile' directly from root)
COPY mobile/build/web /usr/share/nginx/html