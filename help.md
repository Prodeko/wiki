If you want to rerun install script, run `git clean -ffdx` to clear all the data from previous installation. Otherwise you might get weird authentication/401 errors.

## Trouble shooting

### Images don't upload/load. 401 error for /attachments.redirect (in the network tab of developer tools)\*

- Same as above. You should probably be using old database but your keys are different now.
- Are you behind a HTTPS proxy? Then you'll need to setup HTTPS for minio too.
- Check this out if you see KMS in dev logs (yarn dev): https://github.com/minio/minio/issues/6367

### Images don't upload/load. 404 error for /wiki-bucket \*

- Are you sure there's a directory `data/minio_root/wiki-bucket`

# s3 help

https://docs.aws.amazon.com/AmazonS3/latest/dev/cors.html

# Awesome make file!
