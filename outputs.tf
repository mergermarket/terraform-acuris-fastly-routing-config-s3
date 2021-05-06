output "vcl_recv" {
  value = templatefile("${path.module}/template.vcl", 
    {
      vcl_recv_condition    = var.vcl_recv_condition
      backend_name          = var.backend_name
      host_header           = local.host_header
      aws_access_key_id     = var.aws_access_key_id
      aws_secret_access_key = var.aws_secret_access_key
      s3_bucket_name        = var.s3_bucket_name
    }
  )
}

output "vcl_backend" {
  value = module.acuris_apps_config_vcl_backend.vcl_backend
}

