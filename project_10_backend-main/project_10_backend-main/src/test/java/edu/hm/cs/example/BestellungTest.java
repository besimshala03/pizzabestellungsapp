package edu.hm.cs.example;

import edu.hm.cs.example.Bestellungen.Bestellung;
import edu.hm.cs.example.Getraenke.Getraenke;
import edu.hm.cs.example.Pizza.Pizza;
import edu.hm.cs.example.zutaten.Zutaten;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.List;

public class BestellungTest {

    private Bestellung bestellung;

    @BeforeEach
    public void setUp() {
        bestellung = new Bestellung();
    }

    @Test
    public void testBestellung() {
        List<Pizza> pizza =new ArrayList<>();
        List<Getraenke> getraenke = new ArrayList<>();
        Bestellung bestellung1 = new Bestellung(1L, pizza, getraenke, 20.0, "2024-12-12", "xya", "Mr Bean Abi");

        Assertions.assertEquals(1L, bestellung1.getId());
        Assertions.assertEquals(pizza, bestellung1.getPizzas());
        Assertions.assertEquals(getraenke, bestellung1.getGetraenke());
        Assertions.assertEquals(20.0, bestellung1.getPreis());
        Assertions.assertEquals("2024-12-12", bestellung1.getDatumUhrzeit());
        Assertions.assertEquals("xya", bestellung1.getAdresse());
        Assertions.assertEquals("Mr Bean Abi", bestellung1.getKundenname());
    }

    @Test
    public void testSetPreis() {
        List<Pizza> pizza =new ArrayList<>();
        List<Getraenke> getraenke = new ArrayList<>();
        Bestellung bestellung1 = new Bestellung(1L, pizza, getraenke, 20.0, "2024-12-12", "xya", "Mr Bean Abi");
        bestellung1.setPreis(10.0);
        Assertions.assertEquals(10.0, bestellung1.getPreis());
    }
    @Test
    public void testCalculateTotalPrice() {

        List<Zutaten> zutaten = new ArrayList<>();
        List<Zutaten> zutaten2 = new ArrayList<>();
        // Create sample pizzas
        List<Pizza> pizzas = new ArrayList<>();
        pizzas.add(new Pizza(1L, "Margherita", "xyz", 7.5, "sdd", zutaten));
        pizzas.add(new Pizza(2L, "Prosciutto", "xyz", 8.0, "sdd", zutaten2));

        // Create sample drinks
        List<Getraenke> getraenke = new ArrayList<>();
        getraenke.add(new Getraenke(1L, "Cola", 2.5, "dasa"));
        getraenke.add(new Getraenke(2L, "Water", 1.0, "asdd"));

        // Set the pizzas and drinks for the order
        bestellung.setPizzas(pizzas);
        bestellung.setGetraenke(getraenke);

        // Calculate total price
        bestellung.calculateTotalPrice();

        // Assert that the total price is calculated correctly
        Assertions.assertEquals(19.0, bestellung.getPreis(), 0.001);
    }

    @Test
    public void testToString() {
        bestellung.setId(1L);
        bestellung.setKundenname("Max Mustermann");
        bestellung.setAdresse("Musterstraße 1, 12345 Musterstadt");
        bestellung.setDatumUhrzeit("2024-07-02 15:30");

        String expectedToString = "Bestellung{id=1, pizzas=[], getraenke=[], datumUhrzeit='2024-07-02 15:30', adresse='Musterstraße 1, 12345 Musterstadt', kundenname='Max Mustermann', preis=0.0}";
        Assertions.assertEquals(expectedToString, bestellung.toString());
    }
}
