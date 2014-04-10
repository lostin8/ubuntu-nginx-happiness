server {
	listen 8080;

	root /var/www/example.com/subdomain;

        index index.html index.php index.htm;

	# Make site accessible from http://localhost/
	server_name subdomain.example.com;

	location / {
		# First attempt to serve request as file, then
		# as directory, then fall back to displaying a 404.
		try_files $uri $uri/ /index.php?q=$uri&$args;    # /index.html;
		# Uncomment to enable naxsi on this location
		# include /etc/nginx/naxsi.rules
	}

	# Only for nginx-naxsi used with nginx-naxsi-ui : process denied requests
	#location /RequestDenied {
	#	proxy_pass http://127.0.0.1:8080;
	#}

    #	error_page 404 /404.html;

	# redirect server error pages to the static page /50x.html
	#
	# error_page 500 502 503 504 /50x.html;
	location = /50x.html {
		root /usr/share/nginx/html;
	}

	# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
	#
	location ~ \.php$ {
	        try_files $uri = 404;
        	fastcgi_split_path_info ^(.+\.php)(/.+)$;
		    # NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini

		    # With php5-cgi alone:
		    #fastcgi_pass 127.0.0.1:9000;
		    # With php5-fpm:
		    fastcgi_pass unix:/var/run/php5-fpm.sock;
		    fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		    include fastcgi_params;
	        }

	# deny access to .htaccess files, if Apache's document root
	# concurs with nginx's one
	#
	#location ~ /\.ht {
	#	deny all;
	#}
}