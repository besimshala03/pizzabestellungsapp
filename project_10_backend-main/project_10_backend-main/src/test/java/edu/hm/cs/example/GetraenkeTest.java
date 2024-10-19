package edu.hm.cs.example;

import edu.hm.cs.example.Bestellungen.Bestellung;
import edu.hm.cs.example.Getraenke.Getraenke;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

public class GetraenkeTest{

    private Getraenke getraenke;

    @BeforeEach
    public void setUp() {
        getraenke = new Getraenke();
    }

    @Test
    public void testGettersAndSetters() {
        getraenke.setId(1L);
        getraenke.setName("Cola");
        getraenke.setPreis(2.5);
        getraenke.setImageUrl("https://example.com/cola.jpg");

        Assertions.assertEquals(1L, getraenke.getId());
        Assertions.assertEquals("Cola", getraenke.getName());
        Assertions.assertEquals(2.5, getraenke.getPreis(), 0.001);
        Assertions.assertEquals("https://example.com/cola.jpg", getraenke.getImageUrl());
    }

    @Test
    public void testOrderGAssociation() {
        Bestellung bestellung = new Bestellung();
        bestellung.setId(1L);

        getraenke.setOrderG(bestellung);

        Assertions.assertEquals(1L, getraenke.getOrderG().getId());
    }

    @Test
    public void testisPredefinesInitiallyFalse() {
        Assertions.assertFalse(getraenke.isPredefined());
    }

    @Test
    public void testSetPredefines() {
        getraenke.setPredefined(true);
        Assertions.assertTrue(getraenke.isPredefined());
    }

}
