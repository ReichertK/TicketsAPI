using System;
using System.Collections.Generic;
using System.Data;
using MySqlConnector;

namespace DbAuditTool
{
    class Program
    {
        static void Main(string[] args)
        {
            string connStr = "Server=localhost;Port=3306;Database=cdk_tkt_dev;Uid=root;Pwd=1346;ConvertZeroDateTime=true;SslMode=none";
            
            Console.WriteLine("🔍 AUDITORÍA DB - Tablas sin uso");
            Console.WriteLine("=================================\n");

            using var conn = new MySqlConnection(connStr);
            conn.Open();
            Console.WriteLine("✅ Conexión establecida a cdk_tkt_dev\n");

            // 1. Conteo de filas
            Console.WriteLine("📊 CONTEO DE FILAS:\n");
            string query = @"
                SELECT 'tkt_search' AS tbl, COUNT(*) AS rows FROM tkt_search
                UNION ALL SELECT 'tkt_suscriptor', COUNT(*) FROM tkt_suscriptor
                UNION ALL SELECT 'usuario_empresa_sucursal_perfil_sistema', COUNT(*) FROM usuario_empresa_sucursal_perfil_sistema
                UNION ALL SELECT 'usuario_tipo', COUNT(*) FROM usuario_tipo
                UNION ALL SELECT 'usuario_rol', COUNT(*) FROM usuario_rol
                UNION ALL SELECT 'accion', COUNT(*) FROM accion
                UNION ALL SELECT 'perfil', COUNT(*) FROM perfil
                UNION ALL SELECT 'perfil_accion_sistema', COUNT(*) FROM perfil_accion_sistema
                UNION ALL SELECT 'sistema', COUNT(*) FROM sistema;";

            var results = new List<(string Tabla, long Filas)>();
            using (var cmd = new MySqlCommand(query, conn))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    string tabla = reader.GetString(0);
                    long filas = reader.GetInt64(1);
                    results.Add((tabla, filas));
                    Console.WriteLine($"  {tabla,-45} : {filas,8} filas");
                }
            }

            // 2. Verificar FKs entrantes
            Console.WriteLine("\n🔗 VERIFICANDO FOREIGN KEYS...\n");
            
            var tablas = new[] { "tkt_search", "tkt_suscriptor", "usuario_empresa_sucursal_perfil_sistema", 
                                 "usuario_tipo", "usuario_rol", "accion", "perfil", "perfil_accion_sistema", "sistema" };
            int totalFKs = 0;
            var tablasConFKs = new List<string>();

            foreach (var tabla in tablas)
            {
                string fkQuery = $@"
                    SELECT TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME
                    FROM information_schema.KEY_COLUMN_USAGE
                    WHERE REFERENCED_TABLE_NAME = '{tabla}' AND TABLE_SCHEMA = DATABASE()";
                
                using var cmd = new MySqlCommand(fkQuery, conn);
                using var reader = cmd.ExecuteReader();
                
                bool hasFKs = false;
                while (reader.Read())
                {
                    if (!hasFKs)
                    {
                        Console.WriteLine($"  ⚠️  {tabla} tiene FKs entrantes:");
                        hasFKs = true;
                        tablasConFKs.Add(tabla);
                    }
                    Console.WriteLine($"      - {reader.GetString(0)}.{reader.GetString(1)} (constraint: {reader.GetString(2)})");
                    totalFKs++;
                }
                
                if (!hasFKs)
                {
                    Console.WriteLine($"  ✓ {tabla} sin FKs entrantes");
                }
            }

            // 3. Resumen y decisión
            Console.WriteLine("\n=================================");
            Console.WriteLine("📋 RESUMEN:\n");
            
            var vacias = results.FindAll(r => r.Filas == 0);
            Console.WriteLine($"  Tablas vacías (0 filas): {vacias.Count}");
            Console.WriteLine($"  Total FKs entrantes: {totalFKs}");

            if (vacias.Count > 0 && totalFKs == 0)
            {
                Console.WriteLine("\n✅ SEGURO PARA ELIMINAR:");
                foreach (var t in vacias)
                {
                    Console.WriteLine($"   - {t.Tabla}");
                }
                
                Console.WriteLine("\n¿Desea ejecutar el DROP de estas tablas? (s/n): ");
                var respuesta = Console.ReadLine();
                
                if (respuesta?.ToLower() == "s")
                {
                    Console.WriteLine("\n🗑️ ELIMINANDO TABLAS...\n");
                    
                    using var transaction = conn.BeginTransaction();
                    try
                    {
                        var cmdDrop = conn.CreateCommand();
                        cmdDrop.Transaction = transaction;
                        
                        cmdDrop.CommandText = "SET FOREIGN_KEY_CHECKS=0";
                        cmdDrop.ExecuteNonQuery();
                        
                        foreach (var t in vacias)
                        {
                            cmdDrop.CommandText = $"DROP TABLE IF EXISTS `{t.Tabla}`";
                            cmdDrop.ExecuteNonQuery();
                            Console.WriteLine($"  ✓ Eliminada: {t.Tabla}");
                        }
                        
                        cmdDrop.CommandText = "SET FOREIGN_KEY_CHECKS=1";
                        cmdDrop.ExecuteNonQuery();
                        
                        transaction.Commit();
                        Console.WriteLine("\n✅ Tablas eliminadas exitosamente");
                        
                        // Verificar
                        Console.WriteLine("\n📋 Tablas restantes:");
                        using var cmdShow = new MySqlCommand("SHOW TABLES", conn);
                        using var readerShow = cmdShow.ExecuteReader();
                        int count = 0;
                        while (readerShow.Read())
                        {
                            count++;
                        }
                        Console.WriteLine($"  Total: {count} tablas");
                    }
                    catch (Exception ex)
                    {
                        transaction.Rollback();
                        Console.WriteLine($"\n❌ Error al eliminar: {ex.Message}");
                    }
                }
                else
                {
                    Console.WriteLine("\n❌ Operación cancelada");
                }
            }
            else
            {
                Console.WriteLine("\n⚠️  Revisar manualmente antes de eliminar");
                if (tablasConFKs.Count > 0)
                {
                    Console.WriteLine($"\nTablas con FKs entrantes: {string.Join(", ", tablasConFKs)}");
                }
            }
            
            Console.WriteLine("\n=================================\n");
        }
    }
}
