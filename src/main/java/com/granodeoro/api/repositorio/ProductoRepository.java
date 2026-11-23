package com.granodeoro.api.repositorio;

import com.granodeoro.api.modelo.Producto;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

/** Acceso a los productos con consultas derivadas del nombre del método y una consulta JPQL. */
public interface ProductoRepository extends JpaRepository<Producto, Integer> {

    /** Productos activos de una línea, ordenados por nombre. */
    List<Producto> findByLineaIdLineaAndActivoTrueOrderByNombre(Integer idLinea);

    /** Todos los productos activos, ordenados por nombre. */
    List<Producto> findByActivoTrueOrderByNombre();

    /** Productos activos con stock actual menor o igual al mínimo (alertas, RF-009). */
    @Query("SELECT p FROM Producto p WHERE p.activo = true AND p.stockActual <= p.stockMinimo ORDER BY p.nombre")
    List<Producto> buscarAlertasBajoStock();
}
