if $::hostname == 'domain.com' {

    class {'nginx': }
    nginx::resource::upstream { 'www.domain.com':
      members => [
        '10.10.10.10',
        ],
    }
    nginx::resource::upstream { 'www.domain.com':
      members => {
        '10.10.10.10:80' => {
          server => '10.10.10.10',
          port   => 80,
        },
      },
    }
    nginx::resource::vhost {'plain':
      server_name      => ['www.domain.com'],
      ssl              => false,
      www_root         => 'dummy',
      vhost_cfg_append => { 'return' => '301 https://$host$request_uri' },
    }
    nginx::resource::vhost { "www.domain.com":
      ensure                => present,
      ssl_port              => 443,
      listen_port           => 443,
      proxy                 => 'http://domain.com',
      ssl                   => true,
      ssl_cert              => '/etc/ssl/private/domain/domain.cer',
      ssl_key               => '/etc/ssl/private/domain/domain.key',
      client_max_body_size  => '100m',
      access_log           => '/var/log/nginx/domain-access.log',
      error_log            => '/var/log/nginx/domain-error.log',
      log_format           => {
        'main' => '$remote_addr - $remote_user [$time_local] "$request" $status $request_time $body_bytes_sent "$http_referer" "$http_user_agent"',
      },
      proxy_read__timeout   => '10s',
      proxy_send_timeout    => '10s',
      proxy_connect_timeout => '10s',
      proxy_set_header       => [
        'Upgrade $http_upgrade',
        'Connection "upgrade"',
        'Host $host',
        'X-Real-IP $remote_addr',
        'X-Forwarded-For $proxy_add_x_forwarded_for',
        'proxy_http_version 1.1',
      ],
    }
    
    nginx::resource::upstream { 'resource2':
      members => {
        '20.20.20.20:80' => {
          server => '20.20.20.20',
          port   => 80,
        },
      },
    }
    
    nginx::resource::location { "resource2":
      ensure                => present,
      ssl_port              => 443,
      listen_port           => 443,
      proxy                 => 'http://resource2',
      location              => '/resource2',
      ssl                   => true,
      ssl_cert              => '/etc/ssl/private/domain/domain.cer',
      ssl_key               => '/etc/ssl/private/domain/domain.key',
      client_max_body_size  => '100m',
      access_log           => '/var/log/nginx/domain_resource-access.log',
      error_log            => '/var/log/nginx/domain_resource-error.log',
      log_format           => {
        'main' => '$remote_addr - $remote_user [$time_local] "$request" $status $request_time $body_bytes_sent "$http_referer" "$http_user_agent"',
      },
      proxy_read__timeout   => '10s',
      proxy_send_timeout    => '10s',
      proxy_connect_timeout => '10s',
      proxy_set_header      => [
        'Upgrade $http_upgrade',
        'Connection "upgrade"',
        'Host $host',
        'X-Real-IP $remote_addr',
        'X-Forwarded-For $proxy_add_x_forwarded_for',
        'proxy_http_version 1.1',
        ],
      }
 
    }
    
    class {'nginx::config':
      worker_processes     => 8,
      worker_connections   => 4096,
      worker_rlimit_nofile => 4096,
      confd_purge          => true,
      log_format           => {
        'main' => '$remote_addr - $remote_user [$time_local] "$request" $status $request_time $body_bytes_sent "$http_referer" "$http_user_agent"',
      },
    }

    
