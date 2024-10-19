package edu.hm.cs.example;

import edu.hm.cs.example.zutaten.Zutaten;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

public class ZutatenTest {

    @Test
    public void testGetId() {
        Zutaten zutaten = new Zutaten(1L, "Zwiebel", 2.0);

        Assertions.assertEquals(1L, zutaten.getId());
    }

    @Test
    public void testZutaten() {
        Zutaten zutaten1 = new Zutaten(2L, "Zwiebel", 2.0);

        Assertions.assertEquals(2L, zutaten1.getId());
        Assertions.assertEquals("Zwiebel", zutaten1.getName());
        Assertions.assertEquals(2.0, zutaten1.getPreis());
    }
}
