using MySqlConnector;
using System.Text.Json;
using System.Text.Json.Serialization;

class Program
{
    static async Task<int> Main(string[] args)
    {
        var connectionString = args.Length > 0 && !string.IsNullOrWhiteSpace(args[0])
            ? args[0]
            : "Server=localhost;Port=3306;Database=tickets_db;Uid=YOUR_DB_USER;Pwd=YOUR_DB_PASSWORD;SslMode=None";

        var outputPath = args.Length > 1 && !string.IsNullOrWhiteSpace(args[1])
            ? args[1]
            : Path.Combine(AppContext.BaseDirectory, "DB_AUDIT.json");

        var result = new Dictionary<string, object?>();
        try
        {
            using var conn = new MySqlConnection(connectionString);
            await conn.OpenAsync();

            // Version
            using (var cmd = new MySqlCommand("SELECT VERSION()", conn))
            {
                var version = (string?)await cmd.ExecuteScalarAsync();
                result["mysqlVersion"] = version;
            }

            // Tables
            var tables = new List<string>();
            using (var cmd = new MySqlCommand("SHOW TABLES", conn))
            using (var reader = await cmd.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    tables.Add(reader.GetString(0));
                }
            }
            result["tableCount"] = tables.Count;
            result["tables"] = tables;

            // Detail per table
            var detail = new Dictionary<string, object>();
            foreach (var table in tables)
            {
                var tableInfo = new Dictionary<string, object?>();

                // Columns
                var columns = new List<object>();
                using (var dcmd = new MySqlCommand($"DESCRIBE `{table}`", conn))
                using (var r = await dcmd.ExecuteReaderAsync())
                {
                    while (await r.ReadAsync())
                    {
                        columns.Add(new
                        {
                            Field = r.GetString(0),
                            Type = r.GetString(1),
                            Null = r.GetString(2),
                            Key = r.GetString(3),
                            Default = r.IsDBNull(4) ? null : r.GetValue(4),
                            Extra = r.IsDBNull(5) ? null : r.GetString(5)
                        });
                    }
                }
                tableInfo["Columns"] = columns;

                // Create SQL
                string? createSql = null;
                using (var ccmd = new MySqlCommand($"SHOW CREATE TABLE `{table}`", conn))
                using (var cr = await ccmd.ExecuteReaderAsync())
                {
                    if (await cr.ReadAsync())
                    {
                        createSql = cr.GetString(1);
                    }
                }
                tableInfo["CreateSql"] = createSql;

                // Foreign keys
                var foreignKeys = new List<object>();
                using (var fkcmd = new MySqlCommand(@"SELECT
                        kcu.CONSTRAINT_NAME,
                        kcu.TABLE_NAME,
                        kcu.COLUMN_NAME,
                        kcu.REFERENCED_TABLE_NAME,
                        kcu.REFERENCED_COLUMN_NAME
                    FROM information_schema.KEY_COLUMN_USAGE kcu
                    WHERE kcu.TABLE_SCHEMA = DATABASE()
                      AND kcu.TABLE_NAME = @tbl
                      AND kcu.REFERENCED_TABLE_NAME IS NOT NULL", conn))
                {
                    fkcmd.Parameters.AddWithValue("@tbl", table);
                    using var fkr = await fkcmd.ExecuteReaderAsync();
                    while (await fkr.ReadAsync())
                    {
                        foreignKeys.Add(new
                        {
                            Constraint = fkr.GetString(0),
                            Column = fkr.GetString(2),
                            ReferencedTable = fkr.GetString(3),
                            ReferencedColumn = fkr.GetString(4)
                        });
                    }
                }
                tableInfo["ForeignKeys"] = foreignKeys;

                // Indexes
                var indexes = new List<object>();
                using (var icmd = new MySqlCommand($"SHOW INDEX FROM `{table}`", conn))
                using (var ir = await icmd.ExecuteReaderAsync())
                {
                    while (await ir.ReadAsync())
                    {
                        indexes.Add(new
                        {
                            KeyName = ir.GetString("Key_name"),
                            ColumnName = ir.GetString("Column_name"),
                            NonUnique = ir.GetInt32("Non_unique"),
                            SeqInIndex = ir.GetInt32("Seq_in_index"),
                            IndexType = ir.IsDBNull(ir.GetOrdinal("Index_type")) ? null : ir.GetString("Index_type")
                        });
                    }
                }
                tableInfo["Indexes"] = indexes;

                // Size
                using (var scmd = new MySqlCommand(@"SELECT
                        ROUND(((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024), 2) AS SizeMB
                    FROM information_schema.TABLES
                    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = @tbl", conn))
                {
                    scmd.Parameters.AddWithValue("@tbl", table);
                    var sizeMb = await scmd.ExecuteScalarAsync();
                    tableInfo["SizeMB"] = sizeMb;
                }

                detail[table] = tableInfo;
            }
            result["detail"] = detail;

            var jsonOptions = new JsonSerializerOptions
            {
                WriteIndented = true,
                DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull
            };
            var json = JsonSerializer.Serialize(result, jsonOptions);
            await File.WriteAllTextAsync(outputPath, json);
            Console.WriteLine($"Audit written to: {outputPath}");
            return 0;
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine(ex.ToString());
            return 1;
        }
    }
}
