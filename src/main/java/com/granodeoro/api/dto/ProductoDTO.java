package com.granodeoro.api.dto;

import com.granodeoro.api.modelo.Producto;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;

/**
 * Datos de un producto que viajan entre la API y el front-end (JSON).
 * Las anotaciones de validación aplican las reglas de la HU-005.
 */
public record ProductoDTO(
        Integer idProducto,
        @NotNull(message = "La línea es obligatoria") Integer idLinea,
        String nombreLinea,
        @NotBlank(message = "El nombre es obligatorio") @Size(max = 80, message = "El nombre admite máximo 80 caracteres") String nombre,
        @Size(max = 30, message = "La medida admite máximo 30 caracteres") String medida,
        @Size(max = 200, message = "La descripción admite máximo 200 caracteres") String descripcion,
        @NotNull(message = "El precio es obligatorio") @DecimalMin(value = "0.0", message = "El precio no puede ser negativo") BigDecimal precioUnitario,
        @Min(value = 0, message = "El stock actual no puede ser negativo") int stockActual,
        @Min(value = 0, message = "El stock mínimo no puede ser negativo") int stockMinimo,
        boolean activo,
        boolean stockBajo) {

    /** Convierte una entidad en DTO para responder al front-end. */
    public static ProductoDTO desde(Producto p) {
        return new ProductoDTO(p.getIdProducto(), p.getLinea().getIdLinea(), p.getLinea().getNombre(),
                p.getNombre(), p.getMedida(), p.getDescripcion(), p.getPrecioUnitario(),
                p.getStockActual(), p.getStockMinimo(), p.isActivo(), p.hayStockBajo());
    }
}
