package edu.hm.cs.example.Bestellungen;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import edu.hm.cs.example.Getraenke.Getraenke;
import edu.hm.cs.example.Pizza.Pizza;
import jakarta.persistence.*;

import java.util.ArrayList;
import java.util.List;

@Entity
public class Bestellung {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToMany(mappedBy = "orderP", fetch = FetchType.EAGER, cascade = CascadeType.ALL)
    @JsonManagedReference
    private List<Pizza> pizzas = new ArrayList<>();

    @OneToMany(mappedBy = "orderG", fetch = FetchType.EAGER, cascade = CascadeType.ALL)
    @JsonManagedReference
    private List<Getraenke> getraenke = new ArrayList<>();

    private String datumUhrzeit;

    private String adresse;

    private String kundenname;

    private double preis;

    public Bestellung() {}

    public Bestellung(Long id, List<Pizza> pizzas, List<Getraenke> getraenke, double preis, String datumUhrzeit, String adresse, String kundenname) {
        this.id = id;
        this.pizzas = pizzas;
        this.getraenke = getraenke;
        this.preis = preis;
        this.datumUhrzeit = datumUhrzeit;
        this.adresse = adresse;
        this.kundenname = kundenname;
    }

    public String getDatumUhrzeit() {
        return datumUhrzeit;
    }

    public void setDatumUhrzeit(String datumUhrzeit) {
        this.datumUhrzeit = datumUhrzeit;
    }

    public String getAdresse() {
        return adresse;
    }

    public void setAdresse(String adresse) {
        this.adresse = adresse;
    }

    public String getKundenname() {
        return kundenname;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public List<Pizza> getPizzas() {
        return pizzas;
    }

    public void setPizzas(List<Pizza> pizzas) {
        this.pizzas = pizzas;
    }

    public List<Getraenke> getGetraenke() {
        return getraenke;
    }

    public void setGetraenke(List<Getraenke> getraenke) {
        this.getraenke = getraenke;
    }

    public double getPreis() {
        return preis;
    }

    public void setPreis(double preis) {
        this.preis = preis;
    }

    public void calculateTotalPrice() {
        double totalPrice = 0.0;

        for (Pizza pizza : pizzas) {
            totalPrice += pizza.getPreis();

        }

        for (Getraenke getraenk : getraenke) {
            totalPrice += getraenk.getPreis();
        }

        this.preis = totalPrice;
    }

    public void setKundenname(String kundenname) {
        this.kundenname = kundenname;
    }

    @Override
    public String toString() {
        return "Bestellung{" +
                "id=" + id +
                ", pizzas=" + pizzas +
                ", getraenke=" + getraenke +
                ", datumUhrzeit='" + datumUhrzeit + '\'' +
                ", adresse='" + adresse + '\'' +
                ", kundenname='" + kundenname + '\'' +
                ", preis=" + preis +
                '}';
    }

}
