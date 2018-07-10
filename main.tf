data "template_file" "vcl_recv" {
  template = <<END
        if (req.backend == F_default_backend && ($${vcl_recv_condition})) {
            set req.backend = $${backend_name};
            set req.http.Date = now;
            set req.http.host = "$${backend_host}";
            set req.http.Authorization = "AWS $${aws_access_key_id}:" digest.hmac_sha1_base64("$${aws_secret_access_key}", if(req.request == "HEAD", "GET", req.request) LF LF LF req.http.Date LF "/$${s3_bucket_name}" req.url.path);
        }
END

  vars {
    vcl_recv_condition    = "${var.vcl_recv_condition}"
    backend_name          = "${var.backend_name}"
    backend_host          = "${var.backend_host}"
    aws_access_key_id     = "${var.aws_access_key_id}"
    aws_secret_access_key = "${var.aws_secret_access_key}"
    s3_bucket_name        = "${var.s3_bucket_name}"
  }
}

data "template_file" "vcl_backend" {
  template = <<END
        backend $${backend_name} {
            .connect_timeout = $${connect_timeout};
            .dynamic = $${dynamic};
            .first_byte_timeout = $${first_byte_timeout};
            .between_bytes_timeout = $${between_bytes_timeout};
            .max_connections = $${max_connections};
            .port = "$${backend_port}";
            .host = "$${backend_host}";

            .ssl = true;
            $${ssl_sni_hostname_section}
            .ssl_cert_hostname = "$${ssl_cert_hostname}";
            $${ssl_ca_cert_section}
            .ssl_check_cert = $${ssl_check_cert};
            .probe = {
                .request = "HEAD $${healthcheck_path} HTTP/1.1" "Connection: close";
                .window = $${probe_window};
                .threshold = $${probe_threshold};
                .timeout = $${probe_timeout};
                .initial = $${probe_initial};
                .interval = $${probe_interval};
                $${dummy}
            }
        }
END

  vars {
    vcl_recv_condition    = "${var.vcl_recv_condition}"
    backend_name          = "${var.backend_name}"
    first_byte_timeout    = "${var.first_byte_timeout}"
    connect_timeout       = "${var.connect_timeout}"
    dynamic               = "${var.dynamic}"
    between_bytes_timeout = "${var.between_bytes_timeout}"
    max_connections       = "${var.max_connections}"
    backend_port          = "${var.backend_port}"
    backend_host          = "${var.backend_host}"

    ssl_sni_hostname_section = "${
        var.ssl_sni_hostname == "" ? "" : join("", list("
            .ssl_sni_hostname = \"", var.ssl_sni_hostname, "\";
        "))
    }"

    ssl_ca_cert_section   = "${
        var.ssl_ca_cert == "" ? "" : join("", list("
            .ssl_ca_cert = {\"", var.ssl_ca_cert, "\"};
        "))
    }"

    ssl_cert_hostname     = "${var.ssl_cert_hostname == "" ? var.backend_host : var.ssl_cert_hostname}"
    ssl_check_cert        = "${var.ssl_check_cert}"

    probe_window          = "${var.probe_window}"
    probe_threshold       = "${var.probe_threshold}"
    probe_timeout         = "${var.probe_timeout}"
    probe_interval        = "${var.probe_interval}"
    probe_initial         = "${var.probe_initial}"
    healthcheck_path      = "${var.healthcheck_path}"
    dummy                 = "${var.probe_enabled ? "" : ".dummy = true;"}"
  }
}
