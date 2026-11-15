-- 1, 2 y 3. Agrega la columna PRIORIDAD, la hace obligatoria y establece NORMAL por defecto para conservar los datos existentes
ALTER TABLE TICKET_AULA
ADD COLUMN PRIORIDAD VARCHAR(10) NOT NULL DEFAULT 'NORMAL';

-- 4. Crea la restricción CHECK para que la base de datos rechace cualquier prioridad que no sea NORMAL o ALTA
ALTER TABLE TICKET_AULA
ADD CONSTRAINT CHK_PRIORIDAD CHECK (PRIORIDAD IN('NORMAL', 'ALTA'));