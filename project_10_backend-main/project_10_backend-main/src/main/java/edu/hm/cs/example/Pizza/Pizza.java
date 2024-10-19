package edu.hm.cs.example.Pizza;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import edu.hm.cs.example.Bestellungen.Bestellung;
import edu.hm.cs.example.zutaten.Zutaten;
import jakarta.persistence.*;

import java.util.List;

@Entity
public class Pizza {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    private String beschreibung;

    private double preis;

    private String imageUrl;

    private boolean isPredefined;

    public boolean isPredefined() {
        return isPredefined;
    }

    public void setPredefined(boolean predefined) {
        isPredefined = predefined;
    }

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "orderP")
    @JsonBackReference
    private Bestellung orderP;

    @OneToMany(mappedBy = "pizzazutaten", fetch = FetchType.EAGER, cascade = CascadeType.ALL)
    @JsonManagedReference
    private List<Zutaten> zutaten;

    public Pizza(Long id, String name, String beschreibung, double preis, String imageUrl, List<Zutaten> zutaten) {
        this.id = id;
        this.name = name;
        this.beschreibung = beschreibung;
        this.preis = preis;
        this.imageUrl = imageUrl;
        this.zutaten = zutaten;
    }

    public Pizza() {}

    public double getPreis() {
        return preis;
    }

    public void setPreis(double preis) {
        this.preis = preis;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getBeschreibung() {
        return beschreibung;
    }

    public void setBeschreibung(String beschreibung) {
        this.beschreibung = beschreibung;
    }
    // In der Pizza Klasse
    public void setOrderP(Bestellung orderP) {
        this.orderP = orderP;
    }

    public List<Zutaten> getZutaten() {
        return zutaten;
    }

    public void setZutaten(List<Zutaten> zutaten) {
        this.zutaten = zutaten;
    }

    public String getImageUrl() {
        return imageUrl;
    }
    @Override
    public String toString() {
        return "Pizza{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", beschreibung='" + beschreibung + '\'' +
                ", preis=" + preis +
                ", imageUrl='" + imageUrl + '\'' +
                ", zutaten=" + zutaten +
                '}';
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }
}

