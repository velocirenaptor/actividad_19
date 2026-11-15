# 19. De la V1 a V2: Evolución y Versionado de una Base de Datos

## 📋 Información Académica
* **Institución:** Universidad Veracruzana — Facultad de Negocios y Tecnologías (Ixtaczoquitlán, Veracruz)
* **Programa Educativo:** Ingeniería de Software
* **Experiencia Educativa:** Diseño de Software
* **Docente:** Martin Mancilla Gómez
* **Estudiante:** Axel Uriel García Loyo
* **Fecha de elaboración:** 27 de octubre de 2026

---

## 📝 Parte 1: Análisis Manual

### 1. ¿Qué cambia entre V1 y V2?
La incorporación de una columna de **prioridad** a cada reporte existente sin eliminar ni recrear la tabla original.

### 2. ¿Qué información debe permanecer intacta?
Todos los registros e información que ya se encontraban en la **V1** (`id_ticket`, `aula`, `descripcion`, `estado`), integrándose con la nueva estructura de la **V2** (`prioridad`).

### 3. ¿Qué podría ocurrir si agregas una columna obligatoria a una tabla con registros y no defines cómo completar esos valores?
A los datos preexistentes se les tendría que asignar manualmente o por defecto lo que exige el nuevo campo; de no hacerlo, el motor de base de datos lanzará errores de integridad o restricciones SQL al intentar aplicar el cambio.

### 4. ¿Qué instrucciones SQL podrías necesitar para realizar la migración?
* **Definición y modificación de estructura (DDL):** `CREATE DATABASE`, `CREATE TABLE`, `ALTER TABLE` (con cláusulas `ADD COLUMN`, `MODIFY COLUMN`, `DROP COLUMN` o `ADD CONSTRAINT`).
* **Manipulación y consulta de datos (DML):** `INSERT INTO`, `SELECT ... FROM`.

### 5. Representación de la Migración ($V1 \rightarrow V2$)

#### Estructura V1 (Datos existentes)
| id | aula | descripcion | estado |
| :--- | :--- | :--- | :--- |
| `1` | `A-101` | Proyector sin imagen | `Abierto` |
| `...` | `...` | `...` | `...` |

> **Proceso de Migración:**
> 1. Agregar columna `prioridad`.
> 2. Asignar valor por defecto `'Normal'`.
> 3. Aplicar restricción: solo permitir `'Normal'` o `'Alta'`.

#### Estructura V2 (Estructura modificada y datos conservados)
| id | aula | descripcion | estado | prioridad |
| :--- | :--- | :--- | :--- | :--- |
| `1` | `A-101` | Proyector sin imagen | `Abierto` | `Normal` |
| `...` | `...` | `...` | `...` | `Normal` |

---

## 💻 Implementación SQL y Pruebas (Pruebas 1, 2 y 4)

Las pruebas se ejecutaron en un entorno SQL (PostgreSQL / SQLite Online) validando la creación de la tabla base, la migración de esquema, la inserción de registros válidos y el bloqueo de registros inválidos.

### 1. Creación de Esquema Base (V1) e Inserción Inicial
```sql
CREATE TABLE TICKET_AULA (
    ID_TICKET INTEGER NOT NULL PRIMARY KEY,
    AULA VARCHAR(10) NOT NULL,
    DESCRIPTION VARCHAR(100) NOT NULL,
    ESTADO VARCHAR(12) NOT NULL
);

INSERT INTO TICKET_AULA VALUES (1, 'A-101', 'Proyector sin imagen', 'ABIERTO');
INSERT INTO TICKET_AULA VALUES (2, 'A-102', 'Aire acondicionado averiado', 'EN_PROCESO');
INSERT INTO TICKET_AULA VALUES (3, 'A-103', 'Contacto sin energia', 'CERRADO');
```

### 2. Script de Migración a V2 (Conservación y Restricciones)
Se añade la columna `PRIORIDAD` con valor predeterminado `'NORMAL'` para conservar los registros históricos y se agrega una restricción `CHECK`.

```sql
ALTER TABLE TICKET_AULA
ADD COLUMN PRIORIDAD VARCHAR(10) NOT NULL DEFAULT 'NORMAL';

ALTER TABLE TICKET_AULA
ADD CONSTRAINT CHK_PRIORIDAD CHECK (PRIORIDAD IN ('NORMAL', 'ALTA'));
```

### 3. Casos de Prueba

#### ✅ Caso Válido (Registro con prioridad `'ALTA'`)
```sql
INSERT INTO TICKET_AULA (ID_TICKET, AULA, DESCRIPTION, ESTADO, PRIORIDAD)
VALUES (4, 'A-104', 'Falla de iluminacion', 'ABIERTO', 'ALTA');
```
* **Resultado:** Inserción exitosa. Los registros `1`, `2` y `3` conservaron sus datos originales con prioridad `NORMAL` asignada automáticamente, y el registro `4` se almacenó con prioridad `ALTA`.

#### ❌ Caso Inválido (Intento de registro con prioridad `'CRITICA'`)
```sql
INSERT INTO TICKET_AULA (ID_TICKET, AULA, DESCRIPTION, ESTADO, PRIORIDAD)
VALUES (5, 'A-105', 'Falla de tuberias', 'ABIERTO', 'CRITICA');
```
* **Resultado:** Bloqueado por el gestor de base de datos con el error:
  > `Error 23514: new row for relation "ticket_aula" violates check constraint "chk_prioridad"`

---

## 📄 Parte 5: Documentación del Cambio

* **Versión origen:** `V1`
* **Versión destino:** `V2`
* **Cambio realizado:** Se agregó la columna `PRIORIDAD` (`VARCHAR(10)`), obligatoria (`NOT NULL`), con valor predeterminado `'NORMAL'` y restricción `CHECK` para admitir únicamente los valores `'NORMAL'` o `'ALTA'`.
* **Requisito que lo justifica:** Solicitud del área de mantenimiento para poder clasificar y jerarquizar los reportes de incidencias en las aulas.
* **Resultado de pruebas:** **Exitoso.** Se conservó el historial previo asignándole la prioridad `'NORMAL'`, se admitió correctamente el nuevo registro con prioridad `'ALTA'` y el sistema bloqueó el intento de inserción con la prioridad no permitida `'CRITICA'`.
* **Riesgo o precaución ante una ejecución fallida:** Al agregar una columna obligatoria (`NOT NULL`) a una tabla que ya contiene registros, la migración fallará de inmediato si no se define un valor `DEFAULT` que complete los campos de las filas existentes.