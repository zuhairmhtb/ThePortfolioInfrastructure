server {
  server_name wpbackend.vip3rtech6069.com;

  access_log  /var/log/nginx/wpbackend.vip3rtech6069.com.log;
  error_log /var/log/nginx/wpbackend.vip3rtech6069.error.log;

  location / {
    proxy_pass http://127.0.0.1:8080;
    proxy_set_header    X-Forwarded-For    $proxy_add_x_forwarded_for;
    proxy_set_header    X-Forwarded-Proto  $scheme;
    proxy_set_header    X-Forwarded-Host   $host;
    proxy_set_header    X-Forwarded-Port   $server_port;
    proxy_set_header    X-Real-IP          $remote_addr;
    proxy_set_header    Host               $host;

  }


    listen 80;
    listen [::]:80;

}