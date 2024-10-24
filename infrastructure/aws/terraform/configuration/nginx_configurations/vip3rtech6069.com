server {
  server_name vip3rtech6069.com 3.6.63.16;

  access_log  /var/log/nginx/vip3rtech6069.com.log;
  error_log /var/log/nginx/vip3rtech6069.error.log;

  root /frontend_experience/angular/my-app;

  # Add index.php to the list if you are using PHP
  index index.html index.htm index.nginx-debian.html;=

  location / {
          # First attempt to serve request as file, then
          # as directory, then fall back to displaying a 404.
          try_files $uri $uri/ /index.html;
  }

  listen 80;
  listen [::]:80;

}