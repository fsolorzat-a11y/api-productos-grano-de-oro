package com.granodeoro.api.repositorio;

import com.granodeoro.api.modelo.LineaProducto;
import org.springframework.data.jpa.repository.JpaRepository;

/** Acceso a las líneas de producto. Spring Data genera los métodos CRUD. */
public interface LineaProductoRepository extends JpaRepository<LineaProducto, Integer> {
}
