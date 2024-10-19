package edu.hm.cs.example.zutaten;

import com.fasterxml.jackson.annotation.JsonBackReference;
import edu.hm.cs.example.Pizza.Pizza;
import jakarta.persistence.*;


@Entity
public class Zutaten {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

   private String name;

   private double preis;

   private boolean isPredefined;

    public boolean isPredefined() {
        return isPredefined;
    }

    public void setPredefined(boolean predefined) {
        isPredefined = predefined;
    }

    @ManyToOne
    @JoinColumn(name = "pizzazutaten")
    @JsonBackReference
    private Pizza pizzazutaten;



    public Zutaten(Long id, String name, double preis) {
       this.id = id;
       this.name = name;
       this.preis = preis;
   }

    public Zutaten() {
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

    public void setPizzazutaten(Pizza pizza) {
        this.pizzazutaten = pizza;
    }
    @Override
    public String toString() {
        return "Zutaten{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", preis=" + preis +
                '}';
    }

}
