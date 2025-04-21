import os, subprocess, json, boto3, time

TARGET = os.getenv("TARGET_URL")
S3_BUCKET = os.getenv("REPORT_BUCKET")

def lambda_handler(event, context):
    outfile = f"/tmp/zap-{int(time.time())}.html"
    subprocess.check_call(
        ["zap-cli", "-daemon", "-cmd", "-quickurl", TARGET,
         "-quickout", outfile, "-quickprogress"]
    )

    s3 = boto3.client("s3")
    key = outfile.split('/')[-1]
    s3.upload_file(outfile, S3_BUCKET, key,
                   ExtraArgs={"ContentType": "text/html"})
    return { "report_s3_key": key }
