import boto3
import os
import tarfile
import settings

HOST_NAME = os.popen("hostname").readlines()[0].replace("\n", "")

SECRET_ACCESS_KEY = settings.SECRET_ACCESS_KEY
ACCESS_KEY_ID = settings.ACCESS_KEY_ID
ENDPOINT_URL = settings.ENDPOINT_URL
REGION = getattr(settings, "REGION", "global-region")
DIRECTORY_PATHS = getattr(settings, "DIRECTORY_PATHS", ["/root"])


def compress_directories(directory_paths, output_path):
    # Create a TarFile object with the output path and maximum compression
    with tarfile.open(output_path, "w:gz", compresslevel=9) as tar_file:
        # Walk through all the directories
        for directory_path in directory_paths:
            # Get the base name of the directory
            try:
                base_name = os.path.basename(directory_path)
                print("Compressing ", base_name)
                # Walk through all the files and subdirectories in the directory
                for root, directories, files in os.walk(directory_path):
                    for file in files:
                        # Get the full path of the file
                        file_path = os.path.join(root, file)
                        # Get the path of the file relative to the parent directory
                        relative_path = os.path.relpath(file_path, directory_path)
                        # Set the arcname to include the base name of the parent directory
                        arcname = os.path.join(base_name, relative_path)
                        # Add the file to the tar file with the modified arcname
                        tar_file.add(file_path, arcname=arcname)
            except Exception as e:
                print("Exception trying to compress:", e)


# Replace these values with the actual directory paths and output path
print("Starting simple-backup-to-s3")

directory_paths = DIRECTORY_PATHS
output_path = f"/simple-backups/{HOST_NAME}.tar.gz"
output_path_bucket = f"{HOST_NAME}.tar.gz"
os.makedirs(os.path.dirname(output_path), exist_ok=True)

# Call the function to compress the directories
compress_directories(directory_paths, output_path)

# Create s3 object
s3 = boto3.resource(
    "s3",
    region_name=REGION,
    aws_secret_access_key=SECRET_ACCESS_KEY,
    aws_access_key_id=ACCESS_KEY_ID,
    endpoint_url=ENDPOINT_URL,
)

s3.meta.client.upload_file(output_path, "server-backups", output_path_bucket)
print("Upload Success!")
