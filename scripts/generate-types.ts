import fs from 'fs';
import path from 'path';
import { Client } from 'pg';

const client = new Client({
  connectionString: process.env.DATABASE_URL,
});

function mapPGTypeToTS(pgType: string): string {
  if (pgType.includes('int') || pgType === 'numeric' || pgType === 'decimal') return 'number';
  if (pgType === 'uuid' || pgType.includes('text') || pgType.includes('varchar')) return 'string';
  if (pgType.includes('timestamp') || pgType === 'date') return 'Date';
  if (pgType === 'boolean') return 'boolean';
  if (pgType.includes('json')) return 'Record<string, any>';
  return 'any';
}

async function getTables(schema: string) {
  const { rows } = await client.query(
    `
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = $1 AND table_type = 'BASE TABLE'
    `, [schema]
  );
  return rows.map(r => r.table_name);
}

const capitalize = (str: string) => str.charAt(0).toUpperCase() + str.slice(1);

async function generateInterface(table: string, schema: string) {
  const { rows } = await client.query(
    `
    SELECT column_name, data_type, is_nullable
    FROM information_schema.columns
    WHERE table_name = $1 AND table_schema = $2
    ORDER BY ordinal_position
    `, [table, schema]
  );

  const { rows: pkRows } = await client.query(
    `
    SELECT kcu.column_name
    FROM information_schema.table_constraints tco
    JOIN information_schema.key_column_usage kcu
    ON kcu.constraint_name = tco.constraint_name 
    AND kcu.constraint_schema = tco.constraint_schema
    WHERE tco.constraint_type = 'PRIMARY KEY' 
    AND kcu.table_name = $1 
    AND kcu.table_schema = $2
    `, [table, schema]
  );
  const pkColumns = pkRows.map(r => r.column_name);

  const { rows: fkRows } = await client.query(
    `
    SELECT kcu.column_name
    FROM information_schema.table_constraints tco
    JOIN information_schema.key_column_usage kcu
    ON kcu.constraint_name = tco.constraint_name 
    AND kcu.constraint_schema = tco.constraint_schema
    WHERE tco.constraint_type = 'FOREIGN KEY' 
    AND kcu.table_name = $1 
    AND kcu.table_schema = $2
    `, [table, schema]
  );
  const fkColumns = fkRows.map(r => r.column_name);

  let tsInterface = `export interface ${capitalize(table)} {\n`;
  for (const col of rows) {
    const optionalMark = col.is_nullable === 'YES' ? '?' : '';
    const pkcomment = pkColumns.includes(col.column_name) ? '    // primary key' : '';
    const fkcomment = fkColumns.includes(col.column_name) ? '    // foreign key' : '';
    tsInterface += `  ${col.column_name}${optionalMark}: ${mapPGTypeToTS(col.data_type)};${pkcomment}${fkcomment}\n`;
  }
  tsInterface += '}\n';

  const outputDir = path.join(process.cwd(), 'shared-types/src/types');
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }
  fs.writeFileSync(path.join(outputDir, `${table}.ts`), tsInterface);
  console.log(`Interface for table "${table}" generated.`);

  return table;
}

async function main() {
  try {
    await client.connect();

    const schema = 'main';
    const tables = await getTables(schema);

    const generatedTables: string[] = [];

    for (const table of tables) {
      const t = await generateInterface(table, schema);
      generatedTables.push(t);
    }

    const outputDir = path.join(process.cwd(), 'shared-types/src/types');
    const indexContent = generatedTables.map(t => `export * from './${t}';`).join('\n');
    fs.writeFileSync(path.join(outputDir, 'index.ts'), indexContent);
    console.log('index.ts generated for all interfaces.');

  } catch (error) {
    console.log(error);
  } finally {
    await client.end();
  }
}

main();
