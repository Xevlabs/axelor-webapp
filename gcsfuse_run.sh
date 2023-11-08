
# Create mount directory for service
mkdir -p $MNT_DIR

echo "Mounting GCS Fuse."
gcsfuse --debug_gcs --debug_fuse $BUCKET $MNT_DIR
echo "Mounting completed."
cd /opt/tomcat/bin/
# Start the application
./catalina.sh run
