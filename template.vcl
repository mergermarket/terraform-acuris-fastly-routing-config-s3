if (req.backend == F_default_backend && (${vcl_recv_condition})) {
    set req.backend = ${backend_name};
    set req.http.Date = now;
    set req.http.host = "${host_header}";
    set req.http.Authorization = "AWS ${aws_access_key_id}:" digest.hmac_sha1_base64("${aws_secret_access_key}", if(req.request == "HEAD", "GET", req.request) LF LF LF req.http.Date LF "/${s3_bucket_name}" req.url.path);
}
