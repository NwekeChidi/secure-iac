#!/bin/sh
#
# entrypoint.sh – bootstrap for the OWASP ZAP Lambda container
#

# Default handler can be overridden by passing a different one as $1
HANDLER="${1:-handler.lambda_handler}"

# -------------------------------------------------------------------
# If the AWS_LAMBDA_RUNTIME_API env‑var is **not** set we assume the
# image is running *locally*.  In that case we download & launch the
# Runtime Interface Emulator (aws‑lambda‑rie) so that the container
# behaves exactly like it would inside the real Lambda service.
# -------------------------------------------------------------------
if [ -z "$AWS_LAMBDA_RUNTIME_API" ]; then
  # Grab the latest RIE binary (≈ 4 MB) if it isn’t already present
  if [ ! -x /usr/local/bin/aws-lambda-rie ]; then
    curl -sSL \
      -o /usr/local/bin/aws-lambda-rie \
      https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie
    chmod +x /usr/local/bin/aws-lambda-rie
  fi

  # Start the emulator, then run the Python Runtime Interface Client
  exec /usr/local/bin/aws-lambda-rie python -m awslambdaric "$HANDLER"

# -------------------------------------------------------------------
# When the image is running *in* AWS Lambda, the service injects the
# Runtime Interface Client, so we can launch it directly.
# -------------------------------------------------------------------
else
  exec python -m awslambdaric "$HANDLER"
fi
