#!/bin/bash
sudo apt install certbot python3-certbot-nginx

sudo certbot --nginx -d vip3rtech6069.com

# Query status
sudo systemctl status certbot.timer
sudo certbot renew --dry-run


# Autorenwal section starts here
# Add the following line to /etc/crontab using command: sudo crontab -e
# 0 12 * * * /usr/bin/certbot renew --quiet