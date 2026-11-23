package com.granodeoro.api.modelo;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/** Línea de negocio: Ejemplares, Rejones, Instalaciones o Frota de Oro (tabla linea_producto). */
@Entity
@Table(name = "linea_producto")
public class LineaProducto {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_linea")
    private Integer idLinea;

    @Column(name = "nombre", nullable = false, length = 40)
    private String nombre;

    public Integer getIdLinea() { return idLinea; }
    public void setIdLinea(Integer idLinea) { this.idLinea = idLinea; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
}
