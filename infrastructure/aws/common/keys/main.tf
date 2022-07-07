variable aws-region   {}
variable key-name     {}
variable algorithm    { default="RSA" }
variable rsa_bits  { default="4096" }

resource tls_private_key this {
  algorithm   = var.algorithm
  rsa_bits = var.rsa_bits
}

resource aws_key_pair this {
  key_name   = var.key-name
  public_key = tls_private_key.this.public_key_openssh

  provisioner local-exec { 
    command = "echo '${tls_private_key.this.private_key_pem}' > .${var.key-name}"
  }
}

output key-name     { value = aws_key_pair.this.key_name}
output key-private  { value = tls_private_key.this.private_key_pem }
output key-public   { value = tls_private_key.this.public_key_openssh }