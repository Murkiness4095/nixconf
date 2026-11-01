{
  flake.nixosModules.adguardhome = {
    services.adguardhome = {
      enable = true;
      openFirewall = true;

      # port = 8083;
      # host = "0.0.0.0";
      settings.http.address = "0.0.0.0:8083";

      # 允许在 Web 后台手动修改其他非声明式配置
      mutableSettings = true;

      settings = {
        dns = {
          bind_hosts = [ "0.0.0.0" ];
          port = 53;

          # 上游 DNS 配置与并发模式
          upstream_mode = "parallel";
          upstream_dns = [
            "https://dns.alidns.com/dns-query"
            "https://doh.pub/dns-query"
            "https://cloudflare-dns.com/dns-query"
            "https://dns.google/dns-query"
          ];
          bootstrap_dns = [
            "223.5.5.5"
            "119.29.29.29"
            "114.114.114.114"
          ];
          fallback_dns = [
            "223.5.5.5"
            "119.29.29.29"
          ];

          # DNS 性能与安全参数
          cache_enabled = true;
          cache_size = 4194304; # 4MB
          enable_dnssec = true;
          ratelimit = 20;
          refuse_any = true;
          handle_ddr = true;
          max_goroutines = 300;
          upstream_timeout = "10s";

          blocked_hosts = [
            "version.bind"
            "id.server"
            "hostname.bind"
          ];
          trusted_proxies = [
            "127.0.0.0/8"
            "::1/128"
          ];
        };
      };
    };
  };
}
