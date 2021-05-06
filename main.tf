locals {
  backend_host = "s3.${var.region}.amazonaws.com"
  host_header  = "${var.s3_bucket_name}.s3.amazonaws.com"
}
module "acuris_apps_config_vcl_backend" {
  source = "mergermarket/fastly-routing-config-vcl-backend/acuris"

  backend_name = var.backend_name
  backend_host = local.backend_host
}

