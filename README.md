# API de productos · Grano de Oro (GA7-220501096 · AA3-EV01)

Módulo con **Spring Boot 3.3 (Java 17), Spring Data JPA (Hibernate) y MySQL** para gestionar los productos que se
controlan por cantidad: rejones, instalaciones y Frota de Oro, con alertas de bajo stock (CU-03, CU-05; RF-003, RF-004, RF-009).

## Ejecutar
1. Crear la base con `sql/01_grano_de_oro.sql` y `sql/02_usuarios_demo.sql`.
2. En NetBeans: abrir como proyecto Maven y ejecutar `ApiProductosApplication` (o `mvn spring-boot:run`).
3. Probar: `http://localhost:8080/api/productos` y `http://localhost:8080/api/productos/alertas`.

## Endpoints
| Método | Ruta | Descripción |
| --- | --- | --- |
| GET | /api/lineas | Líneas de negocio |
| GET | /api/productos?linea=N | Productos activos (filtro opcional) |
| GET | /api/productos/alertas | Stock actual ≤ stock mínimo |
| GET | /api/productos/{id} | Un producto (404 si no existe) |
| POST | /api/productos | Crear (201; 400 si hay datos inválidos) |
| PUT | /api/productos/{id} | Actualizar |
| DELETE | /api/productos/{id} | Retirar (desactiva, 204) |

Ejemplo de cuerpo JSON: `{"idLinea":2,"nombre":"Rejón","medida":"Medida 3","precioUnitario":30000,"stockActual":20,"stockMinimo":8}`
