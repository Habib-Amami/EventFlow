# Provision the Pydantic Lambda Layer
resource "terraform_data" "pydantic_layer_build" {
  triggers_replace = [
    filesha256("${path.root}/../layers/pydantic-layer/requirements.txt")
  ]

  provisioner "local-exec" {
    command = <<-EOT
      rm -rf ${path.root}/../layers/pydantic-layer/python
      mkdir -p ${path.root}/../layers/pydantic-layer/python

      uv pip install \
        --target ${path.root}/../layers/pydantic-layer/python \
        --python-platform x86_64-manylinux2014 \
        --python 3.14 \
        --only-binary=:all: \
        -r ${path.root}/../layers/pydantic-layer/requirements.txt
    EOT
  }
}

data "archive_file" "pydantic_layer_zip" {
  type        = "zip"
  source_dir  = "${path.root}/../layers/pydantic-layer"
  output_path = "${path.root}/../build/pydantic-layer.zip"

  depends_on = [terraform_data.pydantic_layer_build]
}

resource "aws_lambda_layer_version" "pydantic" {
  filename            = data.archive_file.pydantic_layer_zip.output_path
  layer_name          = "eventflow-pydantic"
  compatible_runtimes = ["python3.14"]

  source_code_hash = data.archive_file.pydantic_layer_zip.output_base64sha256
}



# Provision the Common Lambda Layer
data "archive_file" "common_layer_zip" {
  type        = "zip"
  source_dir  = "${path.root}/../layers/common-layer"
  output_path = "${path.root}/../build/common-layer.zip"
}

resource "aws_lambda_layer_version" "common" {
  filename            = data.archive_file.common_layer_zip.output_path
  layer_name          = "eventflow-common"
  compatible_runtimes = ["python3.14"]

  source_code_hash = data.archive_file.common_layer_zip.output_base64sha256
}