# Wordpress Notes

This document contains various notes and configurations related to managing and maintaining WordPress installations.

## Migration

When migrating a WordPress site from one server to another, consider the following steps:

1. **Backup Files and Database**: Ensure you have a complete backup of your WordPress files and database.
    - The files to back up include the entire WordPress directory, typically located at `/var/www/html/your-site`.
    - The database can be backed up using tools like `mysqldump`

```sh
mysqldump -u username -p database_name > backup.sql
```

2. **Transfer Files**: Use `rsync` or `scp` to transfer the WordPress files to the new server.

```sh
rsync -avz /path/to/wordpress/ user@newserver:/path/to/destination/
```

3. **Import Database**: On the new server, create a new database and import the backup.

```sh
mysql -u username -p new_database_name < backup.sql
```

4. **Update wp-config.php**: Modify the `wp-config.php` file on the new server to reflect the new database credentials.

5. **Update Site URL**: If the domain name has changed, update the site URL in the database. You can do this using wp-cli:

```sh
# Migrate http to https
docker run --rm --volumes-from wp-container --network container:wp-container wordpress:cli search-replace 'http://original.domain' 'https://new.domain'
# Migrate https to https
docker run --rm --volumes-from wp-container --network container:wp-container wordpress:cli search-replace 'https://original.domain' 'https://new.domain'
# Migrate any remaining references
docker run --rm --volumes-from wp-container --network container:wp-container wordpress:cli search-replace 'original.domain' 'new.domain'
# Flush cache
docker run --rm --volumes-from wp-container --network container:wp-container wordpress:cli cache flush
```

Remember to recreate any cache of the extensions you are using.

