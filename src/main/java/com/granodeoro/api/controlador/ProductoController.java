package com.granodeoro.api.controlador;

import com.granodeoro.api.dto.ProductoDTO;
import com.granodeoro.api.modelo.LineaProducto;
import com.granodeoro.api.servicio.ProductoService;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/**
 * API REST de productos.
 * GET /api/lineas | GET /api/productos?linea=N | GET /api/productos/alertas
 * GET /api/productos/{id} | POST /api/productos | PUT /api/productos/{id} | DELETE /api/productos/{id}
 */
@RestController
@RequestMapping("/api")
public class ProductoController {

    private final ProductoService servicio;

    public ProductoController(ProductoService servicio) {
        this.servicio = servicio;
    }

    @GetMapping("/lineas")
    public List<LineaProducto> lineas() {
        return servicio.listarLineas();
    }

    @GetMapping("/productos")
    public List<ProductoDTO> listar(@RequestParam(name = "linea", required = false) Integer idLinea) {
        return servicio.listar(idLinea);
    }

    @GetMapping("/productos/alertas")
    public List<ProductoDTO> alertas() {
        return servicio.listarAlertas();
    }

    @GetMapping("/productos/{id}")
    public ProductoDTO obtener(@PathVariable Integer id) {
        return servicio.obtener(id);
    }

    @PostMapping("/productos")
    @ResponseStatus(HttpStatus.CREATED)
    public ProductoDTO crear(@Valid @RequestBody ProductoDTO datos) {
        return servicio.crear(datos);
    }

    @PutMapping("/productos/{id}")
    public ProductoDTO actualizar(@PathVariable Integer id, @Valid @RequestBody ProductoDTO datos) {
        return servicio.actualizar(id, datos);
    }

    @DeleteMapping("/productos/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void desactivar(@PathVariable Integer id) {
        servicio.desactivar(id);
    }
}
