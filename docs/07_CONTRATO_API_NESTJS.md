# Contrato API NestJS

Este es el único contrato REST previsto para el modo API de la aplicación móvil.
La URL base se define en `API_BASE_URL`, por ejemplo:
`http://10.0.2.2:3000/api/` para un emulador Android.

## Mascotas: consulta del cliente

`GET /mascotas`

Devuelve una lista JSON, o un objeto con la lista en la propiedad `data`.

```json
[
  {
    "id": "mascota-1",
    "nombre": "Max",
    "especie": "Perro",
    "raza": "Labrador",
    "genero": "Macho",
    "fechaNacimiento": "2022-05-10",
    "observaciones": "Control al día",
    "estado": "activo",
    "createdAt": "2026-09-01T10:00:00.000Z"
  }
]
```

La aplicación no envía operaciones de creación, edición ni eliminación de mascotas.

## Solicitudes de citas

| Operación | Método y ruta | Cuerpo JSON |
|---|---|---|
| Consultar | `GET /solicitudes-citas` | No requiere |
| Crear | `POST /solicitudes-citas` | `mascotaId`, `fechaHora`, `motivo`, `estado` |
| Reprogramar | `PATCH /solicitudes-citas/:id` | `mascotaId`, `fechaHora`, `motivo`, `estado` |
| Cancelar | `DELETE /solicitudes-citas/:id` | No requiere |

Respuesta de consulta esperada:

```json
[
  {
    "id": "cita-1",
    "mascotaId": "mascota-1",
    "mascotaNombre": "Max",
    "fechaHora": "2026-09-02T09:00:00.000Z",
    "motivo": "Control general",
    "estado": "pendiente",
    "createdAt": "2026-09-01T10:00:00.000Z"
  }
]
```

Los códigos HTTP exitosos son los de la familia `2xx`. Cualquier otro código se muestra al cliente como un error en español.
