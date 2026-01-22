# Databases notes

## Managing Databases with Docker

When using databases within Docker containers, it's essential to manage data persistence and backups effectively.

### Get an sql prompt inside a running container

For MySQL/MariaDB:

```sh
docker exec -it container_name mysql -u root -p
docker exec -it container_name mariadb -u root -p
```

## Tips and Tricks

### Cleaning Largest Tables

In order to identify the largest tables in your database, you can use the following SQL query:

```sql
SELECT table_schema as `Database`, table_name AS `Table`, round(((data_length + index_length) / 1024 / 1024), 2) `Size in MB` FROM information_schema.TABLES ORDER BY (data_length + index_length) DESC;
```

Create a stored procedure to clean old logs from a specific table (`tabName` in this example) in batches to avoid long locks:

```sql
USE database_name; -- Get it with show databases;
DELIMITER $$

CREATE OR REPLACE PROCEDURE clean_old_logs()
BEGIN
    DECLARE rows_affected INT DEFAULT 1;

    WHILE rows_affected > 0 DO
        DELETE FROM `tabName`
        WHERE creation < NOW() - INTERVAL 3 DAY
        LIMIT 500;

        SET rows_affected = ROW_COUNT();
    END WHILE;
END$$

DELIMITER ;

CALL clean_old_logs();
```

Optimize the table you need after cleaning:

```sql
OPTIMIZE TABLE `tabName`;
```