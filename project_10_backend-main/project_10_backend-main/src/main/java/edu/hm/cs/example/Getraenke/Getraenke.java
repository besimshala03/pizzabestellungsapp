package edu.hm.cs.example.Getraenke;

import com.fasterxml.jackson.annotation.JsonBackReference;
import edu.hm.cs.example.Bestellungen.Bestellung;
import jakarta.persistence.*;


@Entity
public class Getraenke {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    private double preis;

    private String imageUrl;

    private boolean isPredefined;

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public boolean isPredefined() {
        return isPredefined;
    }

    public void setPredefined(boolean predefined) {
        isPredefined = predefined;
    }

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "orderG")
    @JsonBackReference
    private Bestellung orderG;


    public Getraenke(Long id, String name, double preis, String imageUrl) {
        this.id = id;
        this.name = name;
        this.preis = preis;
        this.imageUrl = imageUrl;
    }

    public Getraenke() {
    }

    public double getPreis() {
        return preis;
    }

    public void setPreis(double preis) {
        this.preis = preis;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getId() {
        return id;
    }

    public void setOrderG(Bestellung orderG) {
        this.orderG = orderG;
    }

    public Bestellung getOrderG() {
        return this.orderG;
    }
}
