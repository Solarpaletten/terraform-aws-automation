# Archive data for Lambda functions
data "archive_file" "start_instances_zip" {
  type        = "zip"
  output_path = "start_instances.zip"
  source {
    content = templatefile("${path.module}/lambda/start_instances.py", {
      project_name = var.project_name
    })
    filename = "index.py"
  }
}

data "archive_file" "stop_instances_zip" {
  type        = "zip"
  output_path = "stop_instances.zip"
  source {
    content = templatefile("${path.module}/lambda/stop_instances.py", {
      project_name = var.project_name
    })
    filename = "index.py"
  }
}