server {
  server_name wpbackend.vip3rtech6069.com;

  access_log  /var/log/nginx/wpbackend.vip3rtech6069.com.log;
  error_log /var/log/nginx/wpbackend.vip3rtech6069.error.log;

  location / {
    # Only allow my IP
    # allow 127.0.0.1;
    # deny all;

    proxy_pass http://127.0.0.1:8080;
    proxy_set_header    X-Forwarded-For    $proxy_add_x_forwarded_for;
    proxy_set_header    X-Forwarded-Proto  $scheme;
    proxy_set_header    X-Forwarded-Host   $host;
    proxy_set_header    X-Forwarded-Port   $server_port;
    proxy_set_header    X-Real-IP          $remote_addr;
    proxy_set_header    Host               $host;

  }

  # Allow these API endpoints for everyone
  #location ~* ^/wp-json/wp/v2/(posts|categories) {
  #  proxy_pass http://127.0.0.1:8080;
  #  proxy_set_header    X-Forwarded-For    $proxy_add_x_forwarded_for;
  #  proxy_set_header    X-Forwarded-Proto  $scheme;
  #  proxy_set_header    X-Forwarded-Host   $host;
  #  proxy_set_header    X-Forwarded-Port   $server_port;
  #  proxy_set_header    X-Real-IP          $remote_addr;
  #  proxy_set_header    Host               $host;
  #}

  # Allow media file access for everyone
  #location /wp-content/uploads {
  #  proxy_pass http://127.0.0.1:8080;
  #  proxy_set_header    X-Forwarded-For    $proxy_add_x_forwarded_for;
  #  proxy_set_header    X-Forwarded-Proto  $scheme;
  #  proxy_set_header    X-Forwarded-Host   $host;
  #  proxy_set_header    X-Forwarded-Port   $server_port;
  #  proxy_set_header    X-Real-IP          $remote_addr;
  #  proxy_set_header    Host               $host;
  #}

  # Redirect error pages to main website
  #error_page 403 = @redirect;

  #location @redirect {
  #   return 301 $scheme://vip3rtech6069.com/403;
  #}


    listen 80;
    listen [::]:80;

}
