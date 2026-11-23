package com.granodeoro.api.servicio;

import com.granodeoro.api.dto.ProductoDTO;
import com.granodeoro.api.modelo.LineaProducto;
import com.granodeoro.api.modelo.Producto;
import com.granodeoro.api.repositorio.LineaProductoRepository;
import com.granodeoro.api.repositorio.ProductoRepository;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

/** Lógica de negocio del módulo de productos (CU-03 y CU-05). */
@Service
public class ProductoService {

    private final ProductoRepository productos;
    private final LineaProductoRepository lineas;

    /** Spring inyecta los repositorios por el constructor. */
    public ProductoService(ProductoRepository productos, LineaProductoRepository lineas) {
        this.productos = productos;
        this.lineas = lineas;
    }

    /** Lista las líneas de producto para llenar el filtro del front-end. */
    public List<LineaProducto> listarLineas() {
        return lineas.findAll();
    }

    /** Lista los productos activos; si llega una línea, solo los de esa línea. */
    @Transactional(readOnly = true)
    public List<ProductoDTO> listar(Integer idLinea) {
        List<Producto> lista = (idLinea == null)
                ? productos.findByActivoTrueOrderByNombre()
                : productos.findByLineaIdLineaAndActivoTrueOrderByNombre(idLinea);
        return lista.stream().map(ProductoDTO::desde).toList();
    }

    /** Lista los productos en alerta de bajo stock. */
    @Transactional(readOnly = true)
    public List<ProductoDTO> listarAlertas() {
        return productos.buscarAlertasBajoStock().stream().map(ProductoDTO::desde).toList();
    }

    /** Busca un producto o responde 404 si no existe. */
    @Transactional(readOnly = true)
    public ProductoDTO obtener(Integer id) {
        return ProductoDTO.desde(buscar(id));
    }

    /** Crea un producto nuevo. */
    @Transactional
    public ProductoDTO crear(ProductoDTO datos) {
        Producto p = new Producto();
        copiar(datos, p);
        return ProductoDTO.desde(productos.save(p));
    }

    /** Actualiza un producto existente. */
    @Transactional
    public ProductoDTO actualizar(Integer id, ProductoDTO datos) {
        Producto p = buscar(id);
        copiar(datos, p);
        return ProductoDTO.desde(productos.save(p));
    }

    /**
     * "Elimina" un producto desactivándolo. No se borra la fila porque puede tener
     * ventas y movimientos de inventario que dependen de ella.
     */
    @Transactional
    public void desactivar(Integer id) {
        Producto p = buscar(id);
        p.setActivo(false);
        productos.save(p);
    }

    private Producto buscar(Integer id) {
        return productos.findById(id).orElseThrow(
                () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "El producto " + id + " no existe"));
    }

    private void copiar(ProductoDTO d, Producto p) {
        LineaProducto linea = lineas.findById(d.idLinea()).orElseThrow(
                () -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "La línea " + d.idLinea() + " no existe"));
        p.setLinea(linea);
        p.setNombre(d.nombre().trim());
        p.setMedida(d.medida());
        p.setDescripcion(d.descripcion());
        p.setPrecioUnitario(d.precioUnitario());
        p.setStockActual(d.stockActual());
        p.setStockMinimo(d.stockMinimo());
        p.setActivo(true);
    }
}
